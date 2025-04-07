"use strict";

export type offset = number;

export class TwineError extends Error {
  msg: string;
  offset: number;
  override name: string = "twine error";

  constructor(params: { msg: string; offset: number })  {
    super();
    this.msg = params.msg;
    this.offset = params.offset;
    this.message = `{ msg: ${this.msg}, offset: ${this.offset} }`;
  }

  override toString(): string {
    return `Twine Error ${this.message}`;
  }
}

export type value =
  | null
  | boolean
  | bigint
  | string
  | number
  | Uint8Array
  | Array<[value, value]>
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

  constructor(
    props: {
      dec: Decoder;
      offset: offset;
      num_items: number;
    },
  ) {
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
    const res = [];
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
    const res = [];
    for (const x of this) res.push(x);
    return res;
  }
}

/** A twine decoder */
export class Decoder {
  a: Uint8Array;

  constructor(a: Uint8Array) {
    this.a = a;
  }

  private __first_byte(off: offset): [number, number] {
    const c = this.a[off];
    const high = c >> 4;
    const low = c & 0xf;
    return [high, low];
  }

  /** read an unsigned integer as LEB128, also returns how many bytes were consumed */
  private _leb128(off: offset): [bigint, number] {
    let res = 0n;
    let shift = 0n;
    let n_bytes = 0;
    while (true) {
      n_bytes += 1;
      const x = this.a[off];
      off += 1;
      const cur = x & 0x7F;
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

  /** deref pointers until `off` is not a pointer */
  _deref(off_: offset): offset {
    let off = off_;
    while (true) {
      const [high, low] = this.__first_byte(off);
      if (high == 15) {
        const [p, _] = this.__getint64(off, low);
        off = off - Number(p) - 1;
      } else {
        return off;
      }
    }
  }

  /** skip the current immediate value */
  _skip(off: offset): offset {
    const [high, low] = this.__first_byte(off);
    switch (high) {
      case 0:
        return off + 1;
      case 1:
      case 2: {
        const [_, n_bytes] = this.__getint64(off, low);
        return off + 1 + n_bytes;
      }
      case 3:
        return low === 0 ? off + 5 : off + 9;
      case 4:
      case 5: {
        const [len, n_bytes] = this.__getint64(off, low);
        return off + 1 + n_bytes + Number(len);
      }
      case 6:
      case 7:
      case 8: {
        throw new TwineError({
          msg: `cannot skip over array/dict/tag (high=${high}) at off=${off}`,
          offset: off,
        });
      }
      case 9:
      case 13:
      case 14: {
        throw new TwineError({ msg: `tag ${high} is reserved`, offset: off });
      }
      case 10: {
        const [_, n_bytes] = this.__getint64(off, low);
        return off + 1 + n_bytes;
      }
      case 11:
      case 12: {
        throw {
          msg: `cannot skip over constructor (high=${high}) at off=${off}`,
        };
      }
      case 15: {
        const [_, n_bytes] = this.__getint64(off, low);
        return off + 1 + n_bytes;
      }
      default:
        throw new TwineError({ msg: "invalid low byte", offset: off });
    }
  }

  get_int(off: offset): bigint {
    off = this._deref(off);
    const [high, low] = this.__first_byte(off);
    if (high === 1) {
      const [x, _] = this.__getint64(off, low);
      return x;
    } else if (high === 2) {
      // negative int
      const [x, _] = this.__getint64(off, low);
      return -x - 1n;
    } /* FIXME: how do we parse a bigint from bits...
    else if (high === 5) {
            // bigint
            const bytes = this.get_bytes(off)
            // const sign = bytes == b''1  or bytes[0] & 0b1 == 0 else -1
            // absvalue = int.from_bytes(bytes, byteorder='little', signed=False) >> 1
            // return sign * absvalue
    }
    */
    else {
      throw new TwineError({
        msg: `expected integer, but high=${high} at off=${off}`,
        offset: off,
      });
    }
  }

  get_float(off: offset): number {
    off = this._deref(off);
    const [high, low] = this.__first_byte(off);
    if (high != 3) {
      throw new TwineError({
        msg: `expected float, but high=${high} at off=${off}`,
        offset: off,
      });
    }

    const isf32 = low == 0;
    const isLittleEndian = true;
    const dv = new DataView(this.a.buffer);
    if (isf32) {
      return dv.getFloat32(off + 1, isLittleEndian);
    } else {
      return dv.getFloat64(off + 1, isLittleEndian);
    }
  }

  get_bool(off: offset): boolean {
    off = this._deref(off);
    const [high, low] = this.__first_byte(off);
    if (high !== 0) {
      throw new TwineError({
        msg: `expected bool, but high=${high} at off=${off}`,
        offset: off,
      });
    }

    if (low === 0) return false;
    else if (low === 1) return true;
    else {
      throw new TwineError({
        msg: `expected bool, but high=${high} at off=${off}`,
        offset: off,
      });
    }
  }

  get_null(off: offset): null {
    off = this._deref(off);
    const [high, low] = this.__first_byte(off);
    if (high == 0 && low == 2) {
      return null;
    }
    throw new TwineError({
      msg: `expected bool, but high=${high}, low=${low} at off=${off}`,
      offset: off,
    });
  }

  get_str(off: offset): string {
    off = this._deref(off);
    const [high, low] = this.__first_byte(off);
    if (high != 4) {
      throw new TwineError({
        msg: `expected string, but high=${high} at off=${off}`,
        offset: off,
      });
    }
    const [len, n_bytes] = this.__getint64(off, low);
    off = off + 1 + n_bytes;
    const decoder = new TextDecoder("utf-8");
    const s = decoder.decode(this.a.slice(off, off + Number(len)));
    return s;
  }

  get_bytes(off: offset): Uint8Array {
    off = this._deref(off);
    const [high, low] = this.__first_byte(off);
    if (high != 5) {
      throw new TwineError({
        msg: `expected bytes, but high=${high} at off=${off}`,
        offset: off,
      });
    }
    const [len, n_bytes] = this.__getint64(off, low);
    off = off + 1 + n_bytes;
    return this.a.slice(off, off + Number(len));
  }

  get_array(off: offset): ArrayCursor {
    off = this._deref(off);
    const [high, low] = this.__first_byte(off);
    if (high != 6) {
      throw new TwineError({
        msg: `expected array, but high=${high} at off=${off}`,
        offset: off,
      });
    }
    const [len, n_bytes] = this.__getint64(off, low);
    off = off + 1 + n_bytes;
    return new ArrayCursor({ dec: this, offset: off, num_items: Number(len) });
  }

  get_dict(off: offset): DictCursor {
    off = this._deref(off);
    const [high, low] = this.__first_byte(off);
    if (high != 7) {
      throw new TwineError({
        msg: `expected dict, but high=${high} at off=${off}`,
        offset: off,
      });
    }
    const [len, n_bytes] = this.__getint64(off, low);
    off = off + 1 + n_bytes;
    return new DictCursor({ dec: this, offset: off, num_items: Number(len) });
  }

  get_tag(off: offset): Tag<offset> {
    off = this._deref(off);
    const [high, low] = this.__first_byte(off);
    if (high != 8) {
      throw new TwineError({
        msg: `expected tag, but high=${high} at off=${off}`,
        offset: off,
      });
    }
    const [tag, n_bytes] = this.__getint64(off, low);
    off = off + 1 + n_bytes;
    return new Tag(Number(tag), off);
  }

  get_cstor(off: offset): Cstor<offset> {
    off = this._deref(off);
    const [high, low] = this.__first_byte(off);

    if (high == 10) {
      const [idx, _] = this.__getint64(off, low);
      return new Cstor(
        Number(idx),
        [],
      );
    } else if (
      high == 11
    ) {
      const [idx, n_bytes] = this.__getint64(off, low);
      return new Cstor(
        Number(idx),
        (new ArrayCursor(
          { dec: this, offset: off + 1 + n_bytes, num_items: 1 },
        )).toArray(),
      );
    } else if (
      high == 12
    ) {
      const [idx, n_bytes] = this.__getint64(off, low);
      off = off + 1 + n_bytes;
      const [num_items, n_bytes2] = this._leb128(off);
      return new Cstor(
        Number(idx),
        (new ArrayCursor(
          {
            dec: this,
            offset: off + n_bytes2,
            num_items: Number(num_items),
          },
        )).toArray(),
      );
    } else {
      throw new TwineError({
        msg: `expected constructor (high=${high}) at off=${off}`,
        offset: off,
      });
    }
  }

  /** Read an arbitrary (shallow) value, non-recursively */
  shallow_value(off: offset): shallow_value {
    off = this._deref(off);
    const [high, low] = this.__first_byte(off);
    switch (high) {
      case 0: {
        if (low == 2) {
          return null;
        } else if (high == 0) {
          return false;
        } else if (high == 1) {
          return true;
        } else {
          throw new TwineError({
            msg: `expected true/false/None at off=${off}`,
            offset: off,
          });
        }
      }
      case 1:
      case 2:
        return this.get_int(off);
      case 3:
        return this.get_float(off);
      case 4:
        return this.get_str(off);
      case 5:
        return this.get_bytes(off);
      case 6:
        return this.get_array(off).toArray();
      case 7:
        return this.get_dict(off).toArray();
      case 8:
        return this.get_tag(off);
      case 10:
      case 11:
      case 12:
        return this.get_cstor(off);
      default:
        throw new TwineError({
          msg: `invalid twine value (high=${high}) at off=${off}`,
          offset: off,
        });
    }
  }

  entrypoint(): offset {
    const last = this.a.length - 1;
    const offset = last - Number(this.a[last]) - 1;
    // print(f"offset = 0x{offset:x}")
    return this._deref(offset);
  }
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
  } else if (v instanceof Array && v.length == 1 && typeof (v[0]) == "number") {
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
  if (c.cstor_idx == 0) {
    return d0(d, c.args[0]);
  } else if (c.cstor_idx == 1) {
    return d1(d, c.args[0]);
  } else {
    throw new TwineError({ msg: "expected result", offset: off });
  }
}

// vim:foldmethod=indent:
