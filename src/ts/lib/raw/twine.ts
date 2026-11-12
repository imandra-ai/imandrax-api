/**
 * The twine decoder
 *
 * Contract: for any bytes and any offset, every public `Decoder` method either returns a value
 * or throws `TwineError`. It never throws anything else, and never returns data read from
 * outside the buffer.
 */

export type offset = number;

/** A cache for decoding some values */
export type Cache<T> = Map<offset, T>;

export class TwineError extends Error {
  msg: string;
  offset: number;
  override name: string = "TwineError";

  constructor(params: { msg: string; offset: number }) {
    super(params.msg);
    this.msg = params.msg;
    this.offset = params.offset;
  }

  override toString(): string {
    return `TwineError: ${this.msg}`;
  }
}

/** Read a little-endian unsigned integer */
function readBigInt(data: Uint8Array): bigint {
  let shift = 0n;
  let res = 0n;
  for (const byte of data) {
    res = res | (BigInt(byte) << shift);
    shift += 8n;
  }
  return res;
}

function hex(off: number): string {
  return Number.isInteger(off) && off >= 0 ? `0x${off.toString(16)}` : `${off}`;
}

export type value =
  | null
  | boolean
  | bigint
  | string
  | number
  | Uint8Array
  | Map<value, value>
  | Array<value>
  | Cstor<value>
  | Tag<value>;

export type shallow_value =
  | null
  | boolean
  | bigint
  | string
  | number
  | Uint8Array
  | Array<[offset, offset]>
  | Array<offset>
  | Cstor<offset>
  | Tag<offset>;

export class Tag<T> {
  tag: number;
  value: T;

  constructor(tag: number, value: T) {
    this.tag = tag;
    this.value = value;
  }
}

/** A constructor */
export class Cstor<T> {
  cstor_idx: number;
  args: Array<T>;

  constructor(cstor_idx: number, args: T[]) {
    this.cstor_idx = cstor_idx;
    this.args = args;
  }
}

export abstract class Cursor {
  dec: Decoder;
  offset: offset;
  num_items: number;

  constructor(props: { dec: Decoder; offset: offset; num_items: number }) {
    this.dec = props.dec;
    this.offset = props.offset;
    this.num_items = props.num_items;
  }

  get length() {
    return this.num_items;
  }
}

export class ArrayCursor extends Cursor implements Iterator<offset> {
  [Symbol.iterator]() {
    return this;
  }

  next(): IteratorResult<offset> {
    if (this.num_items === 0) {
      return { done: true, value: undefined };
    } else {
      const off = this.offset;
      this.offset = this.dec._skip(off);
      this.num_items -= 1;
      return { done: false, value: this.dec._deref(off) };
    }
  }

  toArray(): Array<offset> {
    const res: offset[] = [];
    for (const x of this) res.push(x);
    return res;
  }
}

export class DictCursor extends Cursor implements Iterator<[offset, offset]> {
  [Symbol.iterator]() {
    return this;
  }

  next(): IteratorResult<[offset, offset]> {
    if (this.num_items === 0) {
      return { done: true, value: undefined };
    } else {
      const off = this.offset;
      const off2 = this.dec._skip(off);
      this.offset = this.dec._skip(off2);
      this.num_items -= 1;
      return {
        done: false,
        value: [this.dec._deref(off), this.dec._deref(off2)],
      };
    }
  }

  toArray(): Array<[offset, offset]> {
    const res: [offset, offset][] = [];
    for (const x of this) res.push(x);
    return res;
  }
}

/** A twine decoder */
export class Decoder {
  a: Uint8Array;

  /** per-type caches, keyed by offset; per decoder, i.e. per artifact */
  caches: Map<string, Cache<unknown>> = new Map();

  constructor(a: Uint8Array) {
    this.a = a;
  }

  private _outOfBounds(off: offset): TwineError {
    return new TwineError({
      msg: `offset ${hex(off)} out of bounds (buffer size ${this.a.length})`,
      offset: off,
    });
  }

  /** the byte at `off`; throws `TwineError` if `off` is outside the buffer */
  _byte(off: offset): number {
    // `a[off]` is `undefined` outside the buffer, and for non-integer offsets
    if (!Number.isInteger(off) || off < 0 || off >= this.a.length) {
      throw this._outOfBounds(off);
    }
    return this.a[off]!;
  }

  /** the `n` bytes starting at `off`; throws `TwineError` if they overrun the buffer */
  private _slice(off: offset, n: number): Uint8Array {
    if (off < 0 || off + n > this.a.length) {
      throw new TwineError({
        msg: `${n} bytes at off=${hex(off)} overrun the buffer (size ${this.a.length})`,
        offset: off,
      });
    }
    return this.a.subarray(off, off + n);
  }

  /**
   * reject a container at `at` claiming `n` items of at least `itemSize` bytes each from
   * `start`, if they cannot fit in the rest of the buffer; otherwise materializing the cursor
   * would allocate room for all of them
   */
  private _checkCount(at: offset, start: offset, n: bigint, itemSize: number): number {
    const remaining = this.a.length - start;
    if (n * BigInt(itemSize) > BigInt(Math.max(remaining, 0))) {
      throw new TwineError({
        msg: `container at off=${hex(at)} claims ${n} items, more than fit in the remaining ${remaining} bytes`,
        offset: at,
      });
    }
    return Number(n);
  }

  /** a length or offset, which must fit in the buffer */
  private _size(at: offset, n: bigint): number {
    if (n > BigInt(this.a.length)) {
      throw new TwineError({
        msg: `size ${n} at off=${hex(at)} exceeds the buffer (size ${this.a.length})`,
        offset: at,
      });
    }
    return Number(n);
  }

  /** read an unsigned integer as LEB128, also returns how many bytes were consumed */
  private _leb128(off: offset): [bigint, number] {
    let res = 0n;
    let shift = 0n;
    let n_bytes = 0;
    while (true) {
      n_bytes += 1;
      const x = this._byte(off);
      off += 1;
      const cur = x & 0x7f;
      res = res | (BigInt(cur) << shift);
      if (x !== cur) {
        shift += 7n;
      } else {
        return [res, n_bytes];
      }
    }
  }

  /** returns (int, n_bytes_consumed) */
  private __getint64(off: offset, low: number): [bigint, number] {
    if (low < 15) {
      return [BigInt(low), 0];
    }
    const [rest, consumed] = this._leb128(off + 1);
    return [rest + 15n, consumed];
  }

  /** deref pointers from `off`; returns the final offset and its (high, low) */
  private _head(off: offset): [offset, number, number] {
    while (true) {
      const c = this._byte(off);
      const high = c >> 4;
      const low = c & 0xf;
      if (high !== 15) {
        return [off, high, low];
      }
      const [p, _] = this.__getint64(off, low);
      off = off - this._size(off, p) - 1;
    }
  }

  /** deref pointers until `off` is not a pointer */
  _deref(off: offset): offset {
    return this._head(off)[0];
  }

  /** skip the current immediate value */
  _skip(off: offset): offset {
    const c = this._byte(off);
    const high = c >> 4;
    const low = c & 0xf;
    switch (high) {
      case 0:
        return off + 1;
      case 1:
      case 2:
      case 10:
      case 15: {
        const [_, n_bytes] = this.__getint64(off, low);
        return off + 1 + n_bytes;
      }
      case 3:
        return low === 0 ? off + 5 : off + 9;
      case 4:
      case 5: {
        const [len, n_bytes] = this.__getint64(off, low);
        return off + 1 + n_bytes + this._size(off, len);
      }
      case 6:
      case 7:
      case 8:
        throw new TwineError({
          msg: `cannot skip over array/dict/tag (high=${high}) at off=${hex(off)}`,
          offset: off,
        });
      case 11:
      case 12:
        throw new TwineError({
          msg: `cannot skip over constructor (high=${high}) at off=${hex(off)}`,
          offset: off,
        });
      default:
        throw new TwineError({ msg: `tag ${high} is reserved`, offset: off });
    }
  }

  get_int(off: offset): bigint {
    const [o, high, low] = this._head(off);
    if (high === 1) {
      return this.__getint64(o, low)[0];
    } else if (high === 2) {
      // negative int
      return -this.__getint64(o, low)[0] - 1n;
    } else if (high === 5) {
      // bigint
      const bytes = this.get_bytes(o);
      const sign = bytes.length === 0 || (bytes[0]! & 1) === 0 ? 1n : -1n;
      const absvalue = readBigInt(bytes) >> 1n;
      return sign * absvalue;
    } else {
      throw new TwineError({
        msg: `expected integer, but high=${high} at off=${hex(o)}`,
        offset: o,
      });
    }
  }

  get_float(off: offset): number {
    const [o, high, low] = this._head(off);
    if (high !== 3) {
      throw new TwineError({
        msg: `expected float, but high=${high} at off=${hex(o)}`,
        offset: o,
      });
    }
    // the payload starts right after the first byte
    const isf32 = low === 0;
    const payload = this._slice(o + 1, isf32 ? 4 : 8);
    const dv = new DataView(payload.buffer, payload.byteOffset, payload.byteLength);
    return isf32 ? dv.getFloat32(0, true) : dv.getFloat64(0, true);
  }

  get_bool(off: offset): boolean {
    const [o, high, low] = this._head(off);
    if (high === 0 && low === 0) return false;
    if (high === 0 && low === 1) return true;
    throw new TwineError({
      msg: `expected bool, but high=${high}, low=${low} at off=${hex(o)}`,
      offset: o,
    });
  }

  get_null(off: offset): null {
    const [o, high, low] = this._head(off);
    if (high === 0 && low === 2) {
      return null;
    }
    throw new TwineError({
      msg: `expected null, but high=${high}, low=${low} at off=${hex(o)}`,
      offset: o,
    });
  }

  get_str(off: offset): string {
    const [o, high, low] = this._head(off);
    if (high !== 4) {
      throw new TwineError({
        msg: `expected string, but high=${high} at off=${hex(o)}`,
        offset: o,
      });
    }
    const [len, n_bytes] = this.__getint64(o, low);
    const payload = this._slice(o + 1 + n_bytes, this._size(o, len));
    try {
      return new TextDecoder("utf-8", { fatal: true }).decode(payload);
    } catch (e) {
      throw new TwineError({
        msg: `invalid UTF-8 in string at off=${hex(o)}: ${e}`,
        offset: o,
      });
    }
  }

  get_bytes(off: offset): Uint8Array {
    const [o, high, low] = this._head(off);
    if (high !== 5) {
      throw new TwineError({
        msg: `expected bytes, but high=${high} at off=${hex(o)}`,
        offset: o,
      });
    }
    const [len, n_bytes] = this.__getint64(o, low);
    // a copy, so the result does not keep the whole buffer alive
    return this._slice(o + 1 + n_bytes, this._size(o, len)).slice();
  }

  get_array(off: offset): ArrayCursor {
    const [o, high, low] = this._head(off);
    if (high !== 6) {
      throw new TwineError({
        msg: `expected array, but high=${high} at off=${hex(o)}`,
        offset: o,
      });
    }
    const [len, n_bytes] = this.__getint64(o, low);
    const start = o + 1 + n_bytes;
    const n = this._checkCount(o, start, len, 1);
    return new ArrayCursor({ dec: this, offset: start, num_items: n });
  }

  get_dict(off: offset): DictCursor {
    const [o, high, low] = this._head(off);
    if (high !== 7) {
      throw new TwineError({
        msg: `expected dict, but high=${high} at off=${hex(o)}`,
        offset: o,
      });
    }
    const [len, n_bytes] = this.__getint64(o, low);
    const start = o + 1 + n_bytes;
    // each entry is a key and a value, at least one byte each
    const n = this._checkCount(o, start, len, 2);
    return new DictCursor({ dec: this, offset: start, num_items: n });
  }

  get_tag(off: offset): Tag<offset> {
    const [o, high, low] = this._head(off);
    if (high !== 8) {
      throw new TwineError({
        msg: `expected tag, but high=${high} at off=${hex(o)}`,
        offset: o,
      });
    }
    const [tag, n_bytes] = this.__getint64(o, low);
    return new Tag(Number(tag), o + 1 + n_bytes);
  }

  get_cstor(off: offset): Cstor<offset> {
    const [o, high, low] = this._head(off);
    if (high === 10) {
      const [idx, _] = this.__getint64(o, low);
      return new Cstor(Number(idx), []);
    } else if (high === 11) {
      const [idx, n_bytes] = this.__getint64(o, low);
      const start = o + 1 + n_bytes;
      this._checkCount(o, start, 1n, 1);
      return new Cstor(
        Number(idx),
        new ArrayCursor({ dec: this, offset: start, num_items: 1 }).toArray(),
      );
    } else if (high === 12) {
      const [idx, n_bytes] = this.__getint64(o, low);
      const countOff = o + 1 + n_bytes;
      const [num_items, n_bytes2] = this._leb128(countOff);
      const start = countOff + n_bytes2;
      const n = this._checkCount(o, start, num_items, 1);
      return new Cstor(
        Number(idx),
        new ArrayCursor({ dec: this, offset: start, num_items: n }).toArray(),
      );
    } else {
      throw new TwineError({
        msg: `expected constructor (high=${high}) at off=${hex(o)}`,
        offset: o,
      });
    }
  }

  /** Read an arbitrary (shallow) value, non-recursively */
  shallow_value(off: offset): shallow_value {
    const [o, high, low] = this._head(off);
    switch (high) {
      case 0:
        if (low === 2) return null;
        if (low === 0) return false;
        if (low === 1) return true;
        throw new TwineError({
          msg: `expected true/false/null at off=${hex(o)}`,
          offset: o,
        });
      case 1:
      case 2:
        return this.get_int(o);
      case 3:
        return this.get_float(o);
      case 4:
        return this.get_str(o);
      case 5:
        return this.get_bytes(o);
      case 6:
        return this.get_array(o).toArray();
      case 7:
        return this.get_dict(o).toArray();
      case 8:
        return this.get_tag(o);
      case 10:
      case 11:
      case 12:
        return this.get_cstor(o);
      default:
        throw new TwineError({
          msg: `invalid twine value (high=${high}) at off=${hex(o)}`,
          offset: o,
        });
    }
  }

  /** Read an arbitrary value */
  value(off: offset): value {
    try {
      return this._value(off);
    } catch (e) {
      // a container may hold a pointer back to itself, so malformed input can be cyclic;
      // valid input nested deeper than the stack ends up here too
      if (e instanceof RangeError) {
        throw new TwineError({
          msg: `value at off=${hex(off)} is cyclic or nested too deeply`,
          offset: off,
        });
      }
      throw e;
    }
  }

  private _value(off: offset): value {
    const [o, high] = this._head(off);
    switch (high) {
      case 6:
        return this.get_array(o).toArray().map((x) => this._value(x));
      case 7: {
        const d = new Map<value, value>();
        for (const [k, v] of this.get_dict(o)) {
          d.set(this._value(k), this._value(v));
        }
        return d;
      }
      case 8: {
        const tag = this.get_tag(o);
        return new Tag(tag.tag, this._value(tag.value));
      }
      case 10:
      case 11:
      case 12: {
        const c = this.get_cstor(o);
        return new Cstor(
          c.cstor_idx,
          c.args.map((x) => this._value(x)),
        );
      }
      default:
        return this.shallow_value(o) as value;
    }
  }

  entrypoint(): offset {
    if (this.a.length === 0) {
      throw new TwineError({ msg: "empty buffer has no entrypoint", offset: 0 });
    }
    const last = this.a.length - 1;
    const offset = last - this.a[last]! - 1;
    return this._deref(offset);
  }
}

/** Caching combinator */
export function withCache<T>(
  dec: Decoder,
  off: offset,
  name: string,
  f: (dec: Decoder, off: offset) => T,
): T {
  // key on the pointed-to value: each reference to a shared value is its own pointer, at its
  // own offset
  off = dec._deref(off);
  let cache = dec.caches.get(name) as Cache<T> | undefined;
  if (cache === undefined) {
    cache = new Map();
    dec.caches.set(name, cache);
  }
  if (cache.has(off)) {
    return cache.get(off) as T;
  }
  const res = f(dec, off);
  cache.set(off, res);
  return res;
}

/** Decode an option type */
export function optional<T>(
  d: Decoder,
  d0: (d: Decoder, off: offset) => T,
  off: offset,
): T | undefined {
  const v = d.shallow_value(off);
  if (v === null) {
    return undefined;
  } else if (Array.isArray(v) && v.length === 1 && typeof v[0] === "number") {
    return d0(d, v[0]);
  } else {
    throw new TwineError({ msg: `expected optional, got ${v}`, offset: off });
  }
}

export function result<T, E>(
  d: Decoder,
  d0: (d: Decoder, o: offset) => T,
  d1: (d: Decoder, o: offset) => E,
  off: offset,
): T | E {
  const c = d.get_cstor(off);
  if (c.args.length !== 1) {
    throw new TwineError({ msg: "expected result with one argument", offset: off });
  }
  if (c.cstor_idx === 0) {
    return d0(d, c.args[0]!);
  } else if (c.cstor_idx === 1) {
    return d1(d, c.args[0]!);
  } else {
    throw new TwineError({ msg: "expected result", offset: off });
  }
}
