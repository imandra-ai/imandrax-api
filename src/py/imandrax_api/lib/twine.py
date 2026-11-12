# pyright: reportPrivateUsage=false
from __future__ import annotations  # https://peps.python.org/pep-0563/

import json
import struct
from collections.abc import Callable
from dataclasses import dataclass
from typing import Any, Protocol

offset = int

# Note [Twine Data Format]
# ~~~~~~~~~~~~~~~~~~~~~~~~
# Every twine value starts with one byte. The high nibble is the value's kind, and the
# low nibble holds a small number whose meaning depends on the kind. If the low nibble
# is 0 to 14, that is the number. If it is 15, the number is 15 plus an unsigned
# LEB128 integer stored right after the first byte.
#
#   kind       meaning               the number is       after the first byte
#   ---------  --------------------  ------------------  ------------------------------
#   0          false, true, null     0, 1, 2             nothing
#   1          int >= 0              the int             nothing
#   2          int < 0               -(int + 1)          nothing
#   3          float                 0: f32, else f64    4 or 8 bytes, little-endian
#   4          string                length              UTF-8 bytes
#   5          bytes, or a bigint    length              raw bytes
#   6          array                 item count          the items
#   7          dict                  entry count         key, value, key, value, ...
#   8          tag                   tag number          one value
#   10         constructor, 0 args   constructor index   nothing
#   11         constructor, 1 arg    constructor index   the argument
#   12         constructor, n args   constructor index   LEB128 n, then the arguments
#   15         pointer               distance back       nothing
#   9, 13, 14  reserved
#
# A bigint is a little-endian byte string whose lowest bit is the sign and whose other
# bits are the absolute value.
#
# The decoder relies on three properties of the layout:
#
# - Pointers only go backwards. A pointer at offset `o` holding distance `p` refers to
#   `o - p - 1`. The encoder writes a value after everything it contains, and stores a
#   shared value once, with every reference to it a pointer.
# - Container items are immediate: a scalar, a string, bytes, a pointer, or a
#   constructor without arguments. Arrays, dicts, tags and constructors with arguments
#   are stored elsewhere and referred to through a pointer. So the decoder can step
#   over an item without decoding it (`_skip`).
# - The buffer's last byte locates the root, the top-level value the buffer encodes.
#   If that byte is `k`, the root is `k + 1` bytes before it, after following pointers
#   (`entrypoint`).


@dataclass
class Error(Exception):
    """Twine decoding error"""

    msg: str


class Decoder:
    """Reads twine values from an encoded buffer.

    Every method takes the offset of the value to read, so values can be read in
    any order.

    Attributes:
        bs: The encoded input.
        caches: Results of `cached` decoders, by type name and then by the value's
            offset after following pointers. They belong to one decoder, so cached
            values never leak from one artifact into another.
    """

    caches: dict[str, dict[offset, Any]]

    def __init__(self, a: bytearray | bytes):
        a = bytearray(a)
        self.bs = a
        self.caches = {}

    def _out_of_bounds(self, off: offset) -> Error:
        return Error(f"offset {off} out of bounds (buffer size {len(self.bs)})")

    def _byte(self, off: offset) -> int:
        """Returns the byte at `off`.

        Raises:
            Error: If `off` is outside the buffer.
        """
        # a negative index would silently wrap around to the end of the buffer
        if off < 0:
            raise self._out_of_bounds(off)
        try:
            return self.bs[off]
        except IndexError:
            raise self._out_of_bounds(off) from None

    def _slice(self, off: offset, n: int) -> bytearray:
        """Returns the `n` bytes starting at `off`.

        Raises:
            Error: If the bytes run past the end of the buffer.
        """
        if off + n > len(self.bs):
            raise Error(
                f"{n} bytes at off=0x{off:x} overrun the buffer (size {len(self.bs)})"
            )
        return self.bs[off : off + n]

    def _check_count(self, at: offset, start: offset, n: int, item_size: int) -> int:
        """Checks that a container's items can fit in the rest of the buffer.

        The item count comes from the input and becomes the cursor's `__len__`.
        `list()` and `tuple()` allocate room for that many items up front, so an
        unchecked count lets a few bytes of input request a huge allocation.

        Args:
            at: Offset of the container, for the error message.
            start: Offset of the container's first item.
            n: Number of items the container claims.
            item_size: Smallest possible size of one item, in bytes.

        Returns:
            `n`, unchanged.

        Raises:
            Error: If `n` items of `item_size` bytes do not fit after `start`.
        """
        remaining = len(self.bs) - start
        if n * item_size > remaining:
            raise Error(
                f"container at off=0x{at:x} claims {n} items, more than fit in "
                f"the remaining {remaining} bytes"
            )
        return n

    def _leb128(self, off: offset) -> tuple[int, int]:
        """Reads an unsigned LEB128 integer at `off`.

        Returns:
            The integer, and how many bytes it takes up.
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
        """Reads the number held by a value's first byte.

        Args:
            off: Offset of the value's first byte.
            low: The first byte's low nibble.

        Returns:
            The number, and how many bytes after the first byte it takes up (0 when
            `low < 15`).
        """
        if low < 15:
            return low, 0
        rest, consumed = self._leb128(off=off + 1)
        return rest + 15, consumed

    def _head(self, off: offset) -> tuple[offset, int, int]:
        """Follows pointers from `off` to the value they lead to.

        A shared value is stored once and referred to through pointers, so the
        offset of a container item may need several jumps to reach the value
        itself. Every accessor starts here.

        Args:
            off: Offset of a value, which may be a pointer.

        Returns:
            The offset of the value that is not a pointer, and the high and low
            nibbles of its first byte.
        """
        # the decoder's hottest path: reads each byte once, with `_byte` inlined
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
        """Returns the offset of the value that `off` leads to, following pointers."""
        return self._head(off)[0]

    def _skip(self, off: offset) -> offset:
        """Returns the offset just past the immediate value at `off`, without decoding it.

        Container items are always immediate.

        Raises:
            Error: If the value at `off` is not immediate.
        """
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

    # Scalar accessors
    # ================
    # Each one follows the same steps: call `_head`, check the kind, read the payload.
    # A wrong kind raises Error("expected ..., but high=... at off=...")

    def get_int(self, off: offset) -> int:
        """Reads an integer: kind 1 (non-negative), 2 (negative) or 5 (bigint)."""
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
        """Reads a float, stored as 32 or 64 bits."""
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
        """Reads a UTF-8 string."""
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
        """Reads a byte string."""
        off, high, low = self._head(off)
        if high != 5:
            raise Error(f"expected bytes, but high={high} at off=0x{off:x}")
        len, n_bytes = self.__getint64(off=off, low=low)
        return bytes(self._slice(off + 1 + n_bytes, len))

    # Container accessors
    # ===================
    # These don't decode their contents. They return either an offset or a cursor, and
    # the caller decides how to decode each item.

    def get_array(self, off: offset) -> ArrayCursor:
        """Returns a cursor over the offsets of an array's items."""
        off, high, low = self._head(off)
        if high != 6:
            raise Error(f"expected array, but high={high} at off=0x{off:x}")
        len, n_bytes = self.__getint64(off=off, low=low)
        start = off + 1 + n_bytes
        len = self._check_count(at=off, start=start, n=len, item_size=1)
        return ArrayCursor(dec=self, offset=start, num_items=len)

    def get_dict(self, off: offset) -> DictCursor:
        """Returns a cursor over the key and value offsets of a dict's entries."""
        off, high, low = self._head(off)
        if high != 7:
            raise Error(f"expected dict, but high={high} at off=0x{off:x}")
        len, n_bytes = self.__getint64(off=off, low=low)
        start = off + 1 + n_bytes
        # each entry is a key and a value, at least one byte each
        len = self._check_count(at=off, start=start, n=len, item_size=2)
        return DictCursor(dec=self, offset=start, num_items=len)

    def get_tag(self, off: offset) -> Tag[offset]:
        """Returns a tag's number and the offset of its argument."""
        off, high, low = self._head(off)
        if high != 8:
            raise Error(f"expected tag, but high={high} at off=0x{off:x}")
        tag, n_bytes = self.__getint64(off=off, low=low)
        off = off + 1 + n_bytes
        return Tag[offset](tag=tag, arg=off)

    def get_cstor(self, off: offset) -> Constructor[ArrayCursor]:
        """Returns a constructor's index and a cursor over its arguments' offsets."""
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

    # / End of Container accessors

    def shallow_value(self, off: offset) -> shallow_value:
        """Reads the value at `off`, one level deep.

        Scalars are decoded. Arrays, dicts, tags and constructors hold the offsets
        of their children, which are left undecoded.
        """
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
        """Reads the value at `off` and everything inside it, without a schema.

        Mainly used for debugging and in tests.

        Returns:
            The value as plain Python data: `None`, a bool, int, float, str or
            bytes, a tuple, a dict, a `Tag` or a `Constructor`.

        Raises:
            Error: If the value is cyclic, or nested deeper than Python's recursion
                limit.
        """
        try:
            return self._value(off=off)
        except RecursionError as e:
            # a container may hold a pointer back to itself, so malformed input
            # can be cyclic; valid input nested deeper than the recursion limit
            # ends up here too
            raise Error(f"value at off=0x{off:x} is cyclic or nested too deeply") from e

    def _value(self, off: offset) -> value:
        """The recursive part of `value`."""
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
        """Returns the offset of the root value.

        The root is the top-level value the buffer encodes, such as the whole
        artifact in `read_artifact_data`; every other value is reachable from it.
        The buffer's last byte locates it.
        """
        if not self.bs:
            raise Error("empty buffer has no entrypoint")
        last = len(self.bs) - 1
        offset = last - self.bs[last] - 1
        # print(f"offset = 0x{offset:x}")
        return self._deref(off=offset)


def cached(name: str) -> Callable[[DecoderFn[Any]], DecoderFn[Any]]:
    """Makes a decoder decode each value once per `Decoder`.

    The generated decoders for heavily shared types, such as `Mir_Term` and
    `Mir_Type`, use this, so a shared value is decoded once and every reference to
    it gets the same object.
    Results are stored in `d.caches[name]`, keyed by the value's offset after following pointers.

    Args:
        name: The decoded type's name, which selects its cache.

    Example:
        @twine.cached(name="Imandrax_api_mir.Term.t")
        def Mir_Term_of_twine(d: twine.Decoder, off: int) -> Mir_Term: ...
    """

    def decorator(f: DecoderFn[Any]) -> DecoderFn[Any]:
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
    """A tag number and the value it is attached to."""

    tag: int
    arg: Arg


@dataclass(slots=True, frozen=True)
class Constructor[Args]:
    """A constructor of an algebraic data type: its index and its arguments."""

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
"""a fully decoded value, as returned by `Decoder.value`"""

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
"""a value decoded one level deep, as returned by `Decoder.shallow_value`"""


@dataclass(slots=True)
class Cursor:
    """An iterator over the items of a container, which yields their offsets.

    It can be iterated only once. `len()` gives the number of items left.

    Attributes:
        dec: The decoder that holds the buffer.
        offset: Offset of the next item.
        num_items: How many items are left.
    """

    dec: Decoder
    offset: offset
    num_items: int

    def __iter__(self):
        return self

    def __len__(self) -> int:
        return self.num_items


@dataclass(slots=True)
class ArrayCursor(Cursor):
    """Yields the offset of each item of an array, or argument of a constructor."""

    def __next__(self) -> offset:
        if self.num_items == 0:
            raise StopIteration
        off = self.offset
        self.offset = self.dec._skip(off=self.offset)
        self.num_items -= 1
        return off


@dataclass(slots=True)
class DictCursor(Cursor):
    """Yields the key offset and the value offset of each entry of a dict."""

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
    """A function that decodes the value at `off` as a `T`."""

    def __call__(self, d: Decoder, off: int) -> T: ...


def optional[T](d: Decoder, d0: DecoderFn[T], off: offset) -> T | None:
    """Reads an option: null is `None`, and `Some x` is a one-item array.

    Args:
        d: The decoder.
        d0: Decoder for the value inside `Some`.
        off: Offset of the option.
    """
    match d.shallow_value(off=off):
        case None:
            return None
        case (c,):
            return d0(d=d, off=c)
        case v:
            raise Error(f"expected optional, got {v}")


def value_to_json(v: value) -> str:
    """Encodes a decoded value as JSON."""
    j = json.dumps(v)
    return j


# vim:foldmethod=indent:
