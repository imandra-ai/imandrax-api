import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

import { describe, expect, test } from "vitest";

import * as twine from "../lib/raw/twine.js";

const TEST_DATA = fileURLToPath(
  new URL("../../py/imandrax_api/lib/test_data/", import.meta.url),
);

function testData(name: string): Uint8Array {
  return new Uint8Array(readFileSync(TEST_DATA + name));
}

/** `v` as plain JSON data, the way Python's `json.dumps` sees a decoded value */
function toJson(v: twine.value): unknown {
  if (v instanceof Map) {
    return Object.fromEntries([...v].map(([k, x]) => [String(k), toJson(x)]));
  } else if (Array.isArray(v)) {
    return v.map(toJson);
  } else if (typeof v === "bigint") {
    return Number(v);
  } else {
    return v;
  }
}

function bytes(...xs: number[]): Uint8Array {
  return new Uint8Array(xs);
}

describe("twine decoder", () => {
  test("leb128", () => {
    const d = new twine.Decoder(bytes(0x1f, 0x07));
    // 15 + 7
    expect(d.get_int(0)).toBe(22n);
    const d2 = new twine.Decoder(bytes(0x1f, 0x81, 0x42));
    expect(d2.get_int(0)).toBe(BigInt((0x42 << 7) + 1 + 15));
  });

  test("caches are per instance", () => {
    const d1 = new twine.Decoder(bytes(0x00));
    const d2 = new twine.Decoder(bytes(0x00));
    expect(d1.caches).not.toBe(d2.caches);
  });

  test("withCache hits through pointers", () => {
    // Regression: `withCache` keyed on the offset it was given, before following pointers.
    // Each reference to a shared value is its own pointer, so shared values were never
    // found in the cache and were decoded once per reference.
    const calls: number[] = [];
    const dec = (d: twine.Decoder, off: twine.offset) =>
      twine.withCache(d, off, "T", (d, off) => {
        calls.push(off);
        return d.value(off);
      });
    // [0] the shared array (1, 2); [3] an array of two pointers, both to [0]
    const d = new twine.Decoder(bytes(0x62, 0x11, 0x12, 0x62, 0xf3, 0xf4));
    const [first, second] = d.get_array(3).toArray().map((x) => dec(d, x));
    expect(first).toEqual([1n, 2n]);
    expect(first).toBe(second);
    expect(calls).toHaveLength(1);
  });

  test("withCache caches undefined results", () => {
    let calls = 0;
    const d = new twine.Decoder(bytes(0x02));
    for (let i = 0; i < 2; i++) {
      twine.withCache(d, 0, "T", () => {
        calls += 1;
        return undefined;
      });
    }
    expect(calls).toBe(1);
  });

  test("get_float", () => {
    const f64 = new Uint8Array(9);
    f64[0] = 0x31;
    new DataView(f64.buffer).setFloat64(1, 0.125, true);
    expect(new twine.Decoder(f64).get_float(0)).toBe(0.125);

    const f32 = new Uint8Array(5);
    f32[0] = 0x30;
    new DataView(f32.buffer).setFloat32(1, 0.125, true);
    expect(new twine.Decoder(f32).get_float(0)).toBe(0.125);
  });

  test("get_float reads a view at its own offset", () => {
    // Regression: the DataView was built over the whole underlying buffer, ignoring the
    // view's `byteOffset`, as for bytes decoded out of a protobuf message
    const buf = new Uint8Array(12);
    buf[3] = 0x31;
    new DataView(buf.buffer).setFloat64(4, 1.5, true);
    expect(new twine.Decoder(buf.subarray(3)).get_float(0)).toBe(1.5);
  });

  test("skipping a float matches its payload size", () => {
    const buf = new Uint8Array(10);
    buf[0] = 0x31;
    new DataView(buf.buffer).setFloat64(1, 1.5, true);
    buf[9] = 0x11;
    const d = new twine.Decoder(buf);
    expect(d._skip(0)).toBe(9);
    expect(d.get_int(9)).toBe(1n);
  });

  test("big integers", () => {
    // Regression: the bytes of a bigint were shifted right instead of left.
    // 0x0200 >> 1 = 256, positive (low bit 0)
    expect(new twine.Decoder(bytes(0x52, 0x00, 0x02)).get_int(0)).toBe(256n);
    // (0x0201 >> 1) = 256, negative (low bit 1)
    expect(new twine.Decoder(bytes(0x52, 0x01, 0x02)).get_int(0)).toBe(-256n);
  });

  test("special scalars", () => {
    for (const [b, expected] of [
      [0x00, false],
      [0x01, true],
      [0x02, null],
    ] as const) {
      const d = new twine.Decoder(bytes(b));
      expect(d.value(0)).toBe(expected);
      expect(d.shallow_value(0)).toBe(expected);
    }
    expect(new twine.Decoder(bytes(0x62, 0x01, 0x00)).value(0)).toEqual([true, false]);
  });

  test("typereg corpus", () => {
    const d = new twine.Decoder(testData("typereg.twine"));
    const off = d.entrypoint();
    expect(off).toBe(22172);
    const expected = JSON.parse(readFileSync(TEST_DATA + "typereg.json", "utf8"));
    expect(JSON.stringify(toJson(d.value(off)))).toBe(JSON.stringify(expected));
  });

  test("pubsub corpus", () => {
    const d = new twine.Decoder(testData("pubsub.twine"));
    expect(toJson(d.value(d.entrypoint()))).toEqual({
      PUBSUB: {
        summary: "A container for Pub/Sub commands.",
        complexity: "Depends on subcommand.",
        group: "pubsub",
        since: "2.8.0",
        arity: -2,
      },
    });
  });
});
