/**
 * Robustness of the twine decoder on malformed input
 *
 * Contract: for any bytes and any offset, every public `Decoder` method either returns a value
 * or throws `TwineError`. It never throws anything else, and never returns data read from
 * outside the buffer.
 */
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

import fc from "fast-check";
import { describe, expect, test } from "vitest";

import * as twine from "../lib/raw/twine.js";

const TEST_DATA = fileURLToPath(
  new URL("../../py/imandrax_api/lib/test_data/", import.meta.url),
);

const CORPUS: Record<string, Uint8Array> = Object.fromEntries(
  ["typereg.twine", "pubsub.twine"].map((name) => [
    name,
    new Uint8Array(readFileSync(TEST_DATA + name)),
  ]),
);

// `dev` (the default) keeps runs quick; `ci` and `soak` via TWINE_FUZZ_PROFILE
const NUM_RUNS =
  { dev: 100, ci: 1000, soak: 50_000 }[process.env.TWINE_FUZZ_PROFILE ?? "dev"] ?? 100;

/** Run `f`; anything other than a result or `TwineError` fails the test */
function okOrTwineError(f: () => unknown): void {
  try {
    f();
  } catch (e) {
    if (!(e instanceof twine.TwineError)) throw e;
  }
}

function drain(c: twine.ArrayCursor | twine.DictCursor, d: twine.Decoder): void {
  if (c instanceof twine.DictCursor) {
    for (const [k, v] of c) {
      d.value(k);
      d.value(v);
    }
  } else {
    for (const off of c) d.value(off);
  }
}

const PUBLIC_METHODS = [
  "value",
  "shallow_value",
  "get_int",
  "get_bool",
  "get_null",
  "get_float",
  "get_str",
  "get_bytes",
  "get_array",
  "get_dict",
  "get_tag",
  "get_cstor",
] as const;

function decodeWith(d: twine.Decoder, method: (typeof PUBLIC_METHODS)[number], off: number) {
  switch (method) {
    case "get_array":
    case "get_dict":
      drain(d[method](off), d);
      break;
    case "get_cstor":
      for (const x of d.get_cstor(off).args) d.value(x);
      break;
    case "get_tag":
      d.value(d.get_tag(off).value);
      break;
    default:
      d[method](off);
  }
}

function bytes(...xs: number[]): Uint8Array {
  return new Uint8Array(xs);
}

describe("regressions", () => {
  test.each([
    ["empty-buffer", bytes()],
    ["f64-without-payload", bytes(0x3f)],
    ["f32-truncated-payload", bytes(0x30, 0x00)],
    ["invalid-utf8", bytes(0x41, 0xff)],
    ["str-runs-past-end", bytes(0x41)],
    ["bytes-runs-past-end", bytes(0x52, 0x00)],
    ["pointer-before-start", bytes(0xf0, 0x15)],
    ["leb128-past-end", bytes(0x1f)],
    ["leb128-unterminated", bytes(0x1f, 0x80)],
    ["array-items-past-end", bytes(0x62, 0x11)],
    // an array whose only item is a pointer back to the array itself
    ["cyclic-array", bytes(0x61, 0xf0)],
  ])("malformed %s throws TwineError", (_name, data) => {
    expect(() => new twine.Decoder(data).value(0)).toThrow(twine.TwineError);
  });

  test.each([
    ["empty-buffer", bytes()],
    ["pointer-before-start", bytes(0x05)],
  ])("malformed entrypoint %s throws TwineError", (_name, data) => {
    expect(() => new twine.Decoder(data).entrypoint()).toThrow(twine.TwineError);
  });

  test.each([-1, 1, 100, 0.5, Number.NaN])("offset %s out of range throws TwineError", (off) => {
    expect(() => new twine.Decoder(bytes(0x11)).get_int(off)).toThrow(twine.TwineError);
  });

  // a LEB128 count of 2**49 (+ 15 where the low nibble is 15), followed by one 1-byte item: a
  // container claiming far more items than the buffer holds
  const HUGE_COUNT = [0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x01];

  test.each([
    ["array", bytes(0x6f, ...HUGE_COUNT, 0x00)],
    ["dict", bytes(0x7f, ...HUGE_COUNT, 0x00, 0x00)],
    ["constructor", bytes(0xc0, ...HUGE_COUNT, 0x00)],
  ])("huge item count in %s throws TwineError", (_name, data) => {
    const d = new twine.Decoder(data);
    expect(() => d.value(0)).toThrow(twine.TwineError);
    expect(() => d.shallow_value(0)).toThrow(twine.TwineError);
  });

  test("skipping a constructor throws TwineError", () => {
    // Regression: `_skip` threw a plain object for constructors with arguments
    expect(() => new twine.Decoder(bytes(0xb0, 0x11))._skip(0)).toThrow(twine.TwineError);
  });
});

describe("properties", () => {
  test("entrypoint then value", () => {
    fc.assert(
      fc.property(fc.uint8Array({ maxLength: 256 }), (data) => {
        const d = new twine.Decoder(data);
        okOrTwineError(() => d.value(d.entrypoint()));
      }),
      { numRuns: NUM_RUNS },
    );
  });

  test("any offset, any method", () => {
    const arb = fc
      .uint8Array({ minLength: 1, maxLength: 256 })
      .chain((data) =>
        fc.tuple(
          fc.constant(data),
          fc.integer({ min: 0, max: data.length - 1 }),
          fc.constantFrom(...PUBLIC_METHODS),
        ),
      );
    fc.assert(
      fc.property(arb, ([data, off, method]) => {
        okOrTwineError(() => decodeWith(new twine.Decoder(data), method, off));
      }),
      { numRuns: NUM_RUNS },
    );
  });

  test("a cursor fits in the buffer", () => {
    // Resource bound: a cursor never claims more items than the rest of the buffer can hold,
    // so materializing it allocates O(buffer size)
    const arb = fc
      .uint8Array({ minLength: 1, maxLength: 256 })
      .chain((data) =>
        fc.tuple(fc.constant(data), fc.integer({ min: 0, max: data.length - 1 })),
      );
    fc.assert(
      fc.property(arb, ([data, off]) => {
        const d = new twine.Decoder(data);
        let c: twine.Cursor;
        let itemSize: number;
        try {
          const high = d._byte(d._deref(off)) >> 4;
          if (high === 6) {
            [c, itemSize] = [d.get_array(off), 1];
          } else if (high === 7) {
            [c, itemSize] = [d.get_dict(off), 2];
          } else {
            return;
          }
        } catch (e) {
          if (e instanceof twine.TwineError) return;
          throw e;
        }
        expect(c.length * itemSize).toBeLessThanOrEqual(data.length - c.offset);
      }),
      { numRuns: NUM_RUNS },
    );
  });

  test("mutated corpus", () => {
    type Mutation = { op: "truncate" | "overwrite" | "insert" | "delete"; pos: number; byte: number };
    const arb = fc.tuple(
      fc.constantFrom(...Object.keys(CORPUS).sort()),
      fc.array(
        fc.record({
          op: fc.constantFrom("truncate", "overwrite", "insert", "delete"),
          pos: fc.nat(),
          byte: fc.integer({ min: 0, max: 255 }),
        }) as fc.Arbitrary<Mutation>,
        { minLength: 1, maxLength: 4 },
      ),
    );
    fc.assert(
      fc.property(arb, ([name, mutations]) => {
        const data = [...CORPUS[name]!];
        for (const m of mutations) {
          if (data.length === 0) break;
          const pos = m.pos % data.length;
          switch (m.op) {
            case "truncate":
              data.length = pos;
              break;
            case "overwrite":
              data[pos] = m.byte;
              break;
            case "insert":
              data.splice(pos, 0, m.byte);
              break;
            case "delete":
              data.splice(pos, 1);
              break;
          }
        }
        const d = new twine.Decoder(new Uint8Array(data));
        okOrTwineError(() => d.value(d.entrypoint()));
      }),
      { numRuns: NUM_RUNS },
    );
  });
});
