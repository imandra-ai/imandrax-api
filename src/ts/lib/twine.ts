"use strict";

export type offset = number;

export class TwineError extends Error {
  msg: string;
  offset?: number;

  constructor(params: { msg: string; offset?: number }) {
    super();
    this.msg = params.msg;
    if (params.offset !== undefined) this.offset = params.offset;
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
      const off = this.dec._deref(this.offset);
      this.offset = this.dec._skip(off);
      this.num_items -= 1;
      return { done: this.num_items === 0, value: off };
    }
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
      const off = this.dec._deref(this.offset);
      const off2 = this.dec._skip(off);
      this.offset = this.dec._skip(off2);
      this.num_items -= 1;
      return { done: this.num_items === 0, value: [off, off2] };
    }
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
    } /* TODO:
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
}

/*


    def get_float(self, off: offset) -> float:
        off = self._deref(off=off)
        high, low = self.__first_byte(off=off)
        if high != 3:
            throw new TwineError({msg: `expected float, but high={high} at off=0x{off:x}")

        isf32 = low == 0
        if isf32:
            return struct.unpack_from("<f", self.bs, offset=off)[0]
        else:
            return struct.unpack_from("<d", self.bs, offset=off)[0]

    def get_str(self, off: offset) -> str:
        off = self._deref(off=off)
        high, low = self.__first_byte(off=off)
        if high != 4:
            throw new TwineError({msg: `expected string, but high={high} at off=0x{off:x}")
        len, n_bytes = self.__getint64(off=off, low=low)
        off = off + 1 + n_bytes
        s = self.bs[off : off + len].decode("utf8")
        return s

    def get_array(self, off: offset) -> ArrayCursor:
        off = self._deref(off=off)
        high, low = self.__first_byte(off=off)
        if high != 6:
            throw new TwineError({msg: `expected array, but high={high} at off=0x{off:x}")
        len, n_bytes = self.__getint64(off=off, low=low)
        off = off + 1 + n_bytes
        return ArrayCursor(dec=self, offset=off, num_items=len)

    def get_dict(self, off: offset) -> DictCursor:
        off = self._deref(off=off)
        high, low = self.__first_byte(off=off)
        if high != 7:
            throw new TwineError({msg: `expected dict, but high={high} at off=0x{off:x}")
        len, n_bytes = self.__getint64(off=off, low=low)
        off = off + 1 + n_bytes
        return DictCursor(dec=self, offset=off, num_items=len)

    def get_tag(self, off: offset) -> Tag[offset]:
        off = self._deref(off=off)
        high, low = self.__first_byte(off=off)
        if high != 8:
            throw new TwineError({msg: `expected tag, but high={high} at off=0x{off:x}")
        tag, n_bytes = self.__getint64(off=off, low=low)
        off = off + 1 + n_bytes
        return Tag[offset](tag=tag, arg=off)

    def get_cstor(self, off: offset) -> Constructor[ArrayCursor]:
        """
        dec.get_cstor(off) returns the constructor index, and a cursor over its arguments
        """
        off = self._deref(off=off)
        high, low = self.__first_byte(off=off)

        if high == 10:
            idx, _ = self.__getint64(off=off, low=low)
            return Constructor[ArrayCursor](
                idx=idx, args=ArrayCursor(dec=self, offset=off, num_items=0)
            )
        elif high == 11:
            idx, n_bytes = self.__getint64(off=off, low=low)
            return Constructor[ArrayCursor](
                idx=idx,
                args=ArrayCursor(dec=self, offset=off + 1 + n_bytes, num_items=1),
            )
        elif high == 12:
            idx, n_bytes = self.__getint64(off=off, low=low)
            off = off + 1 + n_bytes
            num_items, n_bytes = self._leb128(off=off)
            return Constructor[ArrayCursor](
                idx=idx,
                args=ArrayCursor(dec=self, offset=off + n_bytes, num_items=num_items),
            )
        else:
            throw new TwineError({msg: `expected constructor (high={high}) at off=0x{off:x}")

    def shallow_value(self, off: offset) -> shallow_value:
        """Read an arbitrary (shallow) value, non-recursively"""
        off = self._deref(off=off)
        high, low = self.__first_byte(off=off)
        match high:
            case 0:
                if low == 2:
                    return None
                elif high == 0:
                    return False
                elif high == 1:
                    return True
                else:
                    throw new TwineError({msg: `expected true/false/None at off=0x{off:x}")
            case 1 | 2:
                return self.get_int(off=off)
            case 3:
                return self.get_float(off=off)
            case 4:
                return self.get_str(off=off)
            case 5:
                return self.get_bytes(off=off)
            case 6:
                c = self.get_array(off=off)
                return tuple(c)
            case 7:
                c = self.get_dict(off=off)
                d = dict(c)
                return d
            case 8:
                return self.get_tag(off=off)
            case 10 | 11 | 12:
                c = self.get_cstor(off=off)
                return Constructor(idx=c.idx, args=tuple(c.args))
            case 15:
                assert False
            case _:
                throw new TwineError({msg: `invalid twine value (high={high}) at off=0x{off:x}")

    def value(self, off: offset) -> value:
        """Read an arbitrary value"""
        off = self._deref(off=off)
        high, low = self.__first_byte(off=off)
        match high:
            case 0:
                if low == 2:
                    return None
                elif high == 0:
                    return False
                elif high == 1:
                    return True
                else:
                    throw new TwineError({msg: `expected true/false/None at off=0x{off:x}")
            case 1 | 2:
                return self.get_int(off=off)
            case 3:
                return self.get_float(off=off)
            case 4:
                return self.get_str(off=off)
            case 5:
                return self.get_bytes(off=off)
            case 6:
                c = self.get_array(off=off)
                return tuple(self.value(off) for off in c)
            case 7:
                c = self.get_dict(off=off)
                d = {self.value(k): self.value(v) for k, v in c}
                return d
            case 8:
                tag = self.get_tag(off=off)
                return Tag(tag=tag.tag, arg=self.value(tag.arg))
            case 10 | 11 | 12:
                c = self.get_cstor(off=off)
                args: tuple[value, ...] = tuple(self.value(x) for x in c.args)
                return Constructor(idx=c.idx, args=args)
            case 15:
                assert False
            case _:
                throw new TwineError({msg: `invalid twine value (high={high}) at off=0x{off:x}")

    def entrypoint(self) -> offset:
        last = len(self.bs) - 1
        offset = last - int(self.bs[last]) - 1
        # print(f"offset = 0x{offset:x}")
        return self._deref(off=offset)


@dataclass(slots=True, frozen=True)
class Tag[Arg]:
    """A tagged value"""

    tag: int
    arg: Arg


@dataclass(slots=True, frozen=True)
class Constructor[Args]:
    """A constructor for an ADT"""

    idx: int
    args: Args


type value = (
    None
    | int
    | str
    | float
    | bytes
    | dict["value", "value"]
    | tuple["value", ...]
    | Constructor[tuple["value", ...]]
    | Tag["value"]
)

type shallow_value = (
    None
    | int
    | str
    | float
    | bytes
    | dict[offset, offset]
    | tuple[offset, ...]
    | Constructor[tuple[offset, ...]]
    | Tag[offset]
)


@dataclass(slots=True)
class Cursor:
    dec: Decoder
    offset: offset
    num_items: int

    def __iter__(self):
        return self

    def __len__(self) -> int:
        return self.num_items


@dataclass(slots=true)
class arraycursor(cursor):
    def __next__(self) -> offset:
        if self.num_items == 0:
            raise stopiteration
        off = self.offset
        self.offset = self.dec._skip(off=self.offset)
        self.num_items -= 1
        return off


@dataclass(slots=true)
class dictcursor(cursor):
    def __next__(self) -> tuple[offset, offset]:
        if self.num_items == 0:
            raise stopiteration
        off_key = self.offset
        self.offset = self.dec._skip(off=self.offset)
        off_value = self.offset
        self.offset = self.dec._skip(off=self.offset)
        self.num_items -= 1
        return off_key, off_value


def optional[T](d: Decoder, d0: Callable[..., T], off: offset) -> T | None:
    match d.shallow_value(off=off):
        case None:
            return None
        case (c,):
            return d0(d=d, off=c)
        case v:
            throw new TwineError({msg: `expected optional, got {v}")


def value_to_json(v: value) -> str:
    j = json.dumps(v)
    return j


*/

// vim:foldmethod=indent:
