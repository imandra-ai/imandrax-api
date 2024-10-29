from __future__ import annotations  # https://peps.python.org/pep-0563/
from dataclasses import dataclass
import struct
import json
from typing import Callable

offset = int


@dataclass
class Error(Exception):
    msg: str


class Decoder:
    """A twine decoder"""

    def __init__(self, a: bytearray | bytes):
        a = bytearray(a)
        self.bs = a

    def __first_byte(self, off: int) -> tuple[int, int]:
        c = self.bs[off]
        high = c >> 4
        low = c & 0xF
        return (high, low)

    def _leb128(self, off: offset) -> tuple[int, int]:
        """
        read an unsigned integer as LEB128, also returns how many bytes were consumed
        """
        res = 0
        shift = 0
        n_bytes = 0
        while True:
            n_bytes += 1
            x = self.bs[off]
            off += 1
            cur = x & 0x7F
            if x != cur:
                res = res | (cur << shift)
                shift += 7
            else:
                res = res | (x << shift)
                return res, n_bytes

    def __getint64(self, off: offset, low: int) -> tuple[int, int]:
        "returns (int, n_bytes_consumed)"
        if low < 15:
            return low, 0
        rest, consumed = self._leb128(off=off + 1)
        return rest + 15, consumed

    def _deref(self, off: offset) -> offset:
        "deref pointers until `off` is not a pointer"
        while True:
            high, low = self.__first_byte(off)
            if high == 15:
                p, _ = self.__getint64(off, low)
                off = off - p - 1
            else:
                return off

    def _skip(self, off: offset) -> offset:
        "skip the current immediate value"
        high, low = self.__first_byte(off=off)
        match high:
            case 0:
                return off + 1
            case 1 | 2:
                _, n_bytes = self.__getint64(off=off, low=low)
                return off + 1 + n_bytes
            case 3:
                return off + 5 if low == 0 else off + 9
            case 4 | 5:
                len, n_bytes = self.__getint64(off=off, low=low)
                return off + 1 + n_bytes + len
            case 6 | 7 | 8:
                raise Error(f"cannot skip over array/dict/tag (high={high}) at off=0x{off:x}")
            case 9 | 13 | 14:
                raise Error(f"tag {high} is reserved")
            case 10:
                _, n_bytes = self.__getint64(off=off, low=low)
                return off + 1 + n_bytes
            case 11 | 12:
                raise Error(f"cannot skip over constructor (high={high}) at off=0x{off:x}")
            case 15:
                _, n_bytes = self.__getint64(off=off, low=low)
                return off + 1 + n_bytes
            case _:
                assert False

    def get_int(self, off: offset) -> int:
        off = self._deref(off=off)
        high, low = self.__first_byte(off)
        if high == 1:
            x, _ = self.__getint64(off=off, low=low)
            return x
        elif high == 2:
            # negative int
            x, _ = self.__getint64(off=off, low=low)
            return -x - 1
        elif high == 5:
            # bigint
            bytes = self.get_bytes(off)
            sign = 1 if bytes == b'' or bytes[0] & 0b1 == 0 else -1
            absvalue = int.from_bytes(bytes, byteorder='little', signed=False) >> 1
            return sign * absvalue
        else:
            raise Error(f"expected integer, but high={high} at off=0x{off:x}")

    def get_bool(self, off: offset) -> bool:
        off = self._deref(off=off)
        high, low = self.__first_byte(off=off)
        if high != 0:
            raise Error(f"expected bool, but high={high} at off=0x{off:x}")
        if low == 0:
            return False
        elif low == 1:
            return True
        else:
            raise Error(f"expected bool, but high={high}, low={low} at off=0x{off:x}")

    def get_null(self, off: offset) -> None:
        off = self._deref(off=off)
        high, low = self.__first_byte(off=off)
        if high == 0 and low == 2:
            return None
        else:
            raise Error(f"expected bool, but high={high}, low={low} at off=0x{off:x}")

    def get_float(self, off: offset) -> float:
        off = self._deref(off=off)
        high, low = self.__first_byte(off=off)
        if high != 3:
            raise Error(f"expected float, but high={high} at off=0x{off:x}")

        isf32 = low == 0
        if isf32:
            return struct.unpack_from("<f", self.bs, offset=off)[0]
        else:
            return struct.unpack_from("<d", self.bs, offset=off)[0]

    def get_str(self, off: offset) -> str:
        off = self._deref(off=off)
        high, low = self.__first_byte(off=off)
        if high != 4:
            raise Error(f"expected string, but high={high} at off=0x{off:x}")
        len, n_bytes = self.__getint64(off=off, low=low)
        off = off + 1 + n_bytes
        s = self.bs[off : off + len].decode("utf8")
        return s

    def get_bytes(self, off: offset) -> bytes:
        off = self._deref(off=off)
        high, low = self.__first_byte(off=off)
        if high != 5:
            raise Error(f"expected bytes, but high={high} at off=0x{off:x}")
        len, n_bytes = self.__getint64(off=off, low=low)
        off = off + 1 + n_bytes
        return bytes(self.bs[off : off + len])

    def get_array(self, off: offset) -> ArrayCursor:
        off = self._deref(off=off)
        high, low = self.__first_byte(off=off)
        if high != 6:
            raise Error(f"expected array, but high={high} at off=0x{off:x}")
        len, n_bytes = self.__getint64(off=off, low=low)
        off = off + 1 + n_bytes
        return ArrayCursor(dec=self, offset=off, num_items=len)

    def get_dict(self, off: offset) -> DictCursor:
        off = self._deref(off=off)
        high, low = self.__first_byte(off=off)
        if high != 7:
            raise Error(f"expected dict, but high={high} at off=0x{off:x}")
        len, n_bytes = self.__getint64(off=off, low=low)
        off = off + 1 + n_bytes
        return DictCursor(dec=self, offset=off, num_items=len)

    def get_tag(self, off: offset) -> Tag[offset]:
        off = self._deref(off=off)
        high, low = self.__first_byte(off=off)
        if high != 8:
            raise Error(f"expected tag, but high={high} at off=0x{off:x}")
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
            raise Error(f"expected constructor (high={high}) at off=0x{off:x}")

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
                    raise Error(f"expected true/false/None at off=0x{off:x}")
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
                raise Error(f"invalid twine value (high={high}) at off=0x{off:x}")

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
                    raise Error(f"expected true/false/None at off=0x{off:x}")
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
                raise Error(f"invalid twine value (high={high}) at off=0x{off:x}")

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


@dataclass(slots=True)
class ArrayCursor(Cursor):
    def __next__(self) -> offset:
        if self.num_items == 0:
            raise StopIteration
        off = self.offset
        self.offset = self.dec._skip(off=self.offset)
        self.num_items -= 1
        return off


@dataclass(slots=True)
class DictCursor(Cursor):
    def __next__(self) -> tuple[offset, offset]:
        if self.num_items == 0:
            raise StopIteration
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
            raise Error(f"expected optional, got {v}")


def value_to_json(v: value) -> str:
    j = json.dumps(v)
    return j


# vim:foldmethod=indent:
