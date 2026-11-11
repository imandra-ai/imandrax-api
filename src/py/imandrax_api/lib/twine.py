# pyright: reportPrivateUsage=false
from __future__ import annotations  # https://peps.python.org/pep-0563/

import json
import struct
from collections.abc import Callable
from dataclasses import dataclass
from typing import Any, Protocol

offset = int


@dataclass
class Error(Exception):
    msg: str


class Decoder:
    """A twine decoder."""

    # per-type cache, keyed by offset; must be per-instance (per-artifact),
    caches: dict[str, dict[offset, Any]]

    def __init__(self, a: bytearray | bytes):
        a = bytearray(a)
        self.bs = a
        self.caches = {}

    def _out_of_bounds(self, off: offset) -> Error:
        return Error(f"offset {off} out of bounds (buffer size {len(self.bs)})")

    def _byte(self, off: offset) -> int:
        "the byte at `off`; raises `Error` if `off` is outside the buffer"
        # a negative index would silently wrap around to the end of the buffer
        if off < 0:
            raise self._out_of_bounds(off)
        try:
            return self.bs[off]
        except IndexError:
            raise self._out_of_bounds(off) from None

    def _slice(self, off: offset, n: int) -> bytearray:
        "the `n` bytes starting at `off`; raises `Error` if they overrun the buffer"
        if off + n > len(self.bs):
            raise Error(
                f"{n} bytes at off=0x{off:x} overrun the buffer (size {len(self.bs)})"
            )
        return self.bs[off : off + n]

    def _check_count(self, at: offset, start: offset, n: int, item_size: int) -> int:
        """
        reject a container at `at` claiming `n` items of at least `item_size` bytes
        each from `start`, if they cannot fit in the rest of the buffer; otherwise
        `tuple(cursor)`/`list(cursor)` would allocate room for all of them up front
        """
        remaining = len(self.bs) - start
        if n * item_size > remaining:
            raise Error(
                f"container at off=0x{at:x} claims {n} items, more than fit in "
                f"the remaining {remaining} bytes"
            )
        return n

    def _leb128(self, off: offset) -> tuple[int, int]:
        """
        read an unsigned integer as LEB128, also returns how many bytes were consumed
        """
        res = 0
        shift = 0
        n_bytes = 0
        while True:
            n_bytes += 1
            x = self._byte(off)
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

    def _head(self, off: offset) -> tuple[offset, int, int]:
        """
        deref pointers from `off`; returns the final offset and its (high, low).

        The decoder's hottest path: every accessor starts here. It reads each
        byte once and inlines `_byte`, so accessors need not re-read the first
        byte after `_deref`.
        """
        bs = self.bs
        while True:
            if off < 0:
                raise self._out_of_bounds(off)
            try:
                c = bs[off]
            except IndexError:
                raise self._out_of_bounds(off) from None
            if c < 0xF0:
                return off, c >> 4, c & 0xF
            low = c & 0xF
            if low < 15:
                off = off - low - 1
            else:
                p, _ = self._leb128(off=off + 1)
                off = off - p - 16

    def _deref(self, off: offset) -> offset:
        "deref pointers until `off` is not a pointer"
        return self._head(off)[0]

    def _skip(self, off: offset) -> offset:
        "skip the current immediate value"
        # runs once per container item: common kinds first, no helper calls
        c = self._byte(off)
        high = c >> 4
        low = c & 0xF
        if high == 15 or high == 1 or high == 2 or high == 10:
            if low < 15:
                return off + 1
            _, n_bytes = self._leb128(off=off + 1)
            return off + 1 + n_bytes
        if high == 4 or high == 5:
            if low < 15:
                return off + 1 + low
            n, n_bytes = self._leb128(off=off + 1)
            return off + 1 + n_bytes + n + 15
        if high == 0:
            return off + 1
        if high == 3:
            return off + 5 if low == 0 else off + 9
        if high == 6 or high == 7 or high == 8:
            raise Error(
                f"cannot skip over array/dict/tag (high={high}) at off=0x{off:x}"
            )
        if high == 11 or high == 12:
            raise Error(f"cannot skip over constructor (high={high}) at off=0x{off:x}")
        raise Error(f"tag {high} is reserved")

    def get_int(self, off: offset) -> int:
        off, high, low = self._head(off)
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
            sign = 1 if bytes == b"" or bytes[0] & 0b1 == 0 else -1
            absvalue = int.from_bytes(bytes, byteorder="little", signed=False) >> 1
            return sign * absvalue
        else:
            raise Error(f"expected integer, but high={high} at off=0x{off:x}")

    def get_bool(self, off: offset) -> bool:
        off, high, low = self._head(off)
        if high != 0:
            raise Error(f"expected bool, but high={high} at off=0x{off:x}")
        if low == 0:
            return False
        elif low == 1:
            return True
        else:
            raise Error(f"expected bool, but high={high}, low={low} at off=0x{off:x}")

    def get_null(self, off: offset) -> None:
        off, high, low = self._head(off)
        if high == 0 and low == 2:
            return
        else:
            raise Error(f"expected null, but high={high}, low={low} at off=0x{off:x}")

    def get_float(self, off: offset) -> float:
        off, high, low = self._head(off)
        if high != 3:
            raise Error(f"expected float, but high={high} at off=0x{off:x}")

        # the payload starts right after the first byte
        isf32 = low == 0
        if isf32:
            return struct.unpack("<f", self._slice(off + 1, 4))[0]
        else:
            return struct.unpack("<d", self._slice(off + 1, 8))[0]

    def get_str(self, off: offset) -> str:
        off, high, low = self._head(off)
        if high != 4:
            raise Error(f"expected string, but high={high} at off=0x{off:x}")
        len, n_bytes = self.__getint64(off=off, low=low)
        payload = self._slice(off + 1 + n_bytes, len)
        try:
            return payload.decode("utf8")
        except UnicodeDecodeError as e:
            raise Error(f"invalid UTF-8 in string at off=0x{off:x}: {e}") from e

    def get_bytes(self, off: offset) -> bytes:
        off, high, low = self._head(off)
        if high != 5:
            raise Error(f"expected bytes, but high={high} at off=0x{off:x}")
        len, n_bytes = self.__getint64(off=off, low=low)
        return bytes(self._slice(off + 1 + n_bytes, len))

    def get_array(self, off: offset) -> ArrayCursor:
        off, high, low = self._head(off)
        if high != 6:
            raise Error(f"expected array, but high={high} at off=0x{off:x}")
        len, n_bytes = self.__getint64(off=off, low=low)
        start = off + 1 + n_bytes
        len = self._check_count(at=off, start=start, n=len, item_size=1)
        return ArrayCursor(dec=self, offset=start, num_items=len)

    def get_dict(self, off: offset) -> DictCursor:
        off, high, low = self._head(off)
        if high != 7:
            raise Error(f"expected dict, but high={high} at off=0x{off:x}")
        len, n_bytes = self.__getint64(off=off, low=low)
        start = off + 1 + n_bytes
        # each entry is a key and a value, at least one byte each
        len = self._check_count(at=off, start=start, n=len, item_size=2)
        return DictCursor(dec=self, offset=start, num_items=len)

    def get_tag(self, off: offset) -> Tag[offset]:
        off, high, low = self._head(off)
        if high != 8:
            raise Error(f"expected tag, but high={high} at off=0x{off:x}")
        tag, n_bytes = self.__getint64(off=off, low=low)
        off = off + 1 + n_bytes
        return Tag[offset](tag=tag, arg=off)

    def get_cstor(self, off: offset) -> Constructor[ArrayCursor]:
        """
        dec.get_cstor(off) returns the constructor index, and a cursor over its arguments
        """
        off, high, low = self._head(off)

        if high == 10:
            idx, _ = self.__getint64(off=off, low=low)
            return Constructor[ArrayCursor](
                idx=idx, args=ArrayCursor(dec=self, offset=off, num_items=0)
            )
        elif high == 11:
            idx, n_bytes = self.__getint64(off=off, low=low)
            start = off + 1 + n_bytes
            self._check_count(at=off, start=start, n=1, item_size=1)
            return Constructor[ArrayCursor](
                idx=idx,
                args=ArrayCursor(dec=self, offset=start, num_items=1),
            )
        elif high == 12:
            idx, n_bytes = self.__getint64(off=off, low=low)
            count_off = off + 1 + n_bytes
            num_items, n_bytes = self._leb128(off=count_off)
            start = count_off + n_bytes
            num_items = self._check_count(at=off, start=start, n=num_items, item_size=1)
            return Constructor[ArrayCursor](
                idx=idx,
                args=ArrayCursor(dec=self, offset=start, num_items=num_items),
            )
        else:
            raise Error(f"expected constructor (high={high}) at off=0x{off:x}")

    def shallow_value(self, off: offset) -> shallow_value:
        """Read an arbitrary (shallow) value, non-recursively"""
        off, high, low = self._head(off)
        match high:
            case 0:
                if low == 2:
                    return None
                elif low == 0:
                    return False
                elif low == 1:
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
                raise Error(f"unexpected pointer after deref at off=0x{off:x}")
            case _:
                raise Error(f"invalid twine value (high={high}) at off=0x{off:x}")

    def value(self, off: offset) -> value:
        """Read an arbitrary value"""
        try:
            return self._value(off=off)
        except RecursionError as e:
            # a container may hold a pointer back to itself, so malformed input
            # can be cyclic; valid input nested deeper than the recursion limit
            # ends up here too
            raise Error(f"value at off=0x{off:x} is cyclic or nested too deeply") from e

    def _value(self, off: offset) -> value:
        off, high, low = self._head(off)
        match high:
            case 0:
                if low == 2:
                    return None
                elif low == 0:
                    return False
                elif low == 1:
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
                return tuple(self._value(off) for off in c)
            case 7:
                c = self.get_dict(off=off)
                d: dict[value, value] = {}
                for k, v in c:
                    key, val = self._value(k), self._value(v)
                    try:
                        d[key] = val
                    except TypeError as e:
                        # e.g. a key that is itself a dict: valid twine, but
                        # not representable as a Python dict key
                        raise Error(f"unhashable dict key at off=0x{k:x}: {e}") from e
                return d
            case 8:
                tag = self.get_tag(off=off)
                return Tag(tag=tag.tag, arg=self._value(tag.arg))
            case 10 | 11 | 12:
                c = self.get_cstor(off=off)
                args: tuple[value, ...] = tuple(self._value(x) for x in c.args)
                return Constructor(idx=c.idx, args=args)
            case 15:
                raise Error(f"unexpected pointer after deref at off=0x{off:x}")
            case _:
                raise Error(f"invalid twine value (high={high}) at off=0x{off:x}")

    def entrypoint(self) -> offset:
        if not self.bs:
            raise Error("empty buffer has no entrypoint")
        last = len(self.bs) - 1
        offset = last - self.bs[last] - 1
        # print(f"offset = 0x{offset:x}")
        return self._deref(off=offset)


def cached(name: str) -> Callable[[DecoderFn[Any]], DecoderFn[Any]]:
    def decorator(f: DecoderFn[Any]) -> DecoderFn[Any]:
        """Decorator for cached functions"""

        def cached_f(d: Decoder, off: offset) -> Any:
            # key on the pointed-to value: each reference to a shared value is
            # its own pointer, at its own offset
            off = d._deref(off=off)
            cache = d.caches.setdefault(name, {})
            if off in cache:
                return cache[off]
            else:
                value = f(d=d, off=off)
                cache[off] = value
                return value

        return cached_f

    return decorator


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


type value = (  # noqa: PYI042
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

type shallow_value = (  # noqa: PYI042
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


class DecoderFn[T](Protocol):
    def __call__(self, d: Decoder, off: int) -> T: ...


def optional[T](d: Decoder, d0: DecoderFn[T], off: offset) -> T | None:
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
