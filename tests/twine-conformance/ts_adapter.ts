/**
 * TypeScript adapter for the twine conformance test
 *
 * Reads one request line at a time on stdin, `<type> <hex bytes>`, and replies with one
 * S-expression line each.
 *
 * Runs with Node's type stripping (Node >= 22.18), on the built client: `make -C src/ts build`
 * first.
 */

import { createInterface } from "node:readline";

import * as twine from "../../src/ts/dist/raw/twine.js";
import { decode_q } from "../../src/ts/dist/raw/types.js";

function hex(bs: Uint8Array): string {
  return Buffer.from(bs.buffer, bs.byteOffset, bs.byteLength).toString("hex");
}

function f64Bits(x: number): string {
  const dv = new DataView(new ArrayBuffer(8));
  dv.setFloat64(0, x, true);
  return dv.getBigUint64(0, true).toString(16).padStart(16, "0");
}

/**
 * The text form of the value at `off`
 *
 * Walks the structure with the decoder's cursors rather than `value()`, so dict entries come
 * out in encoding order, straight from the encoding.
 */
function node(d: twine.Decoder, off: twine.offset): string {
  off = d._deref(off);
  const c = d._byte(off);
  const high = c >> 4;
  const low = c & 0xf;
  switch (high) {
    case 0:
      if (low === 2) {
        d.get_null(off);
        return "null";
      }
      return d.get_bool(off) ? "(bool true)" : "(bool false)";
    case 1:
    case 2:
      return `(int "${d.get_int(off)}")`;
    case 3:
      return `(f64 "${f64Bits(d.get_float(off))}")`;
    case 4:
      return `(str "${hex(new TextEncoder().encode(d.get_str(off)))}")`;
    case 5:
      return `(blob "${hex(d.get_bytes(off))}")`;
    case 6: {
      const items = d.get_array(off).toArray().map((x) => node(d, x));
      return `(${["array", ...items].join(" ")})`;
    }
    case 7: {
      const pairs = d
        .get_dict(off)
        .toArray()
        .map(([k, v]) => `(${node(d, k)} ${node(d, v)})`);
      return `(${["dict", ...pairs].join(" ")})`;
    }
    case 8: {
      const t = d.get_tag(off);
      return `(tag ${t.tag} ${node(d, t.value)})`;
    }
    case 10:
    case 11:
    case 12: {
      const cstor = d.get_cstor(off);
      const args = cstor.args.map((x) => node(d, x));
      return `(${["cstor", String(cstor.cstor_idx), ...args].join(" ")})`;
    }
    case 14:
      return `(ref ${node(d, d.get_ref(off))})`;
    default:
      // let the library reject kinds it does not support
      d.shallow_value(off);
      throw new twine.TwineError({
        msg: `no text form for kind ${high} at off=0x${off.toString(16)}`,
        offset: off,
      });
  }
}

/** `s` as a quoted atom: printable ASCII only, without quotes or backslashes */
function message(s: string): string {
  const clean = [...s].map((c) => (c >= " " && c <= "~" && c !== '"' && c !== "\\" ? c : "?"));
  return `"${clean.join("")}"`;
}

function rational(d: twine.Decoder, off: twine.offset): string {
  const [num, den] = decode_q(d, off);
  return `(q "${num}" "${den}")`;
}

/** How to read the entry point, by the type the bytes represent */
const TYPES: Record<string, (d: twine.Decoder, off: twine.offset) => string> = {
  any: node,
  int: (d, off) => `(int "${d.get_int(off)}")`,
  q: rational,
};

/**
 * The reply line to one request
 *
 * Only decode errors are replies. Any other exception escapes and ends the program, which is
 * how a crash is reported.
 */
function reply(ty: string, data: Uint8Array): string {
  const decode = Object.hasOwn(TYPES, ty) ? TYPES[ty] : undefined;
  if (decode === undefined) {
    return `(unsupported ${message(ty)})`;
  }
  try {
    const d = new twine.Decoder(data);
    return decode(d, d.entrypoint());
  } catch (e) {
    if (e instanceof twine.TwineError) {
      return `(error ${message(e.msg)})`;
    } else if (e instanceof RangeError) {
      // a container item that points back at the container
      return `(error ${message("value is cyclic or nested too deeply")})`;
    }
    throw e;
  }
}

for await (const line of createInterface({ input: process.stdin, crlfDelay: Infinity })) {
  const sep = line.indexOf(" ");
  if (sep < 0) {
    process.stderr.write(`malformed request: ${JSON.stringify(line)}\n`);
    process.exit(1);
  }
  const data = new Uint8Array(Buffer.from(line.slice(sep + 1), "hex"));
  process.stdout.write(reply(line.slice(0, sep), data) + "\n");
}
