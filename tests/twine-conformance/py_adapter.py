"""Python adapter for the twine conformance test

Reads one request line at a time on stdin, `<type> <hex bytes>`, and replies
with one S-expression line each.
"""

# pyright: reportPrivateUsage=false
import struct
import sys
from collections.abc import Callable

from imandrax_api.lib import decode_q, twine


def node(d: twine.Decoder, off: int) -> str:
    """The text form of the value at `off`.

    Walks the structure with the decoder's cursors rather than `value()`, so
    dict entries come out in encoding order and keys need not be hashable.
    """
    off, high, low = d._deref(off)
    match high:
        case 0:
            if low == 2:
                d.get_null(off)
                return "null"
            return "(bool true)" if d.get_bool(off) else "(bool false)"
        case 1 | 2:
            return f'(int "{d.get_int(off)}")'
        case 3:
            (bits,) = struct.unpack("<Q", struct.pack("<d", d.get_float(off)))
            return f'(f64 "{bits:016x}")'
        case 4:
            return f'(str "{d.get_str(off).encode("utf-8").hex()}")'
        case 5:
            return f'(blob "{d.get_bytes(off).hex()}")'
        case 6:
            items = [node(d, x) for x in d.get_array(off)]
            return "(" + " ".join(["array", *items]) + ")"
        case 7:
            pairs = [f"({node(d, k)} {node(d, v)})" for k, v in d.get_dict(off)]
            return "(" + " ".join(["dict", *pairs]) + ")"
        case 8:
            t = d.get_tag(off)
            return f"(tag {t.tag} {node(d, t.arg)})"
        case 10 | 11 | 12:
            c = d.get_cstor(off)
            args = [node(d, x) for x in c.args]
            return "(" + " ".join(["cstor", str(c.idx), *args]) + ")"
        case 14:
            return f"(ref {node(d, d.get_ref(off))})"
        case _:
            # let the library reject kinds it does not support
            d.shallow_value(off)
            raise twine.Error(f"no text form for kind {high} at off=0x{off:x}")


def message(s: str) -> str:
    """`s` as a quoted atom: printable ASCII only, without quotes or backslashes."""
    clean = "".join(c if " " <= c <= "~" and c not in '"\\' else "?" for c in s)
    return f'"{clean}"'


def rational(d: twine.Decoder, off: int) -> str:
    num, den = decode_q(d, off)
    return f'(q "{num}" "{den}")'


TYPES: dict[str, Callable[[twine.Decoder, int], str]] = {
    "any": node,
    "int": lambda d, off: f'(int "{d.get_int(off)}")',
    "q": rational,
}
"""How to read the entry point, by the type the bytes represent"""


def reply(ty: str, data: bytes) -> str:
    """The reply line to one request.

    Only decode errors are replies. Any other exception escapes and ends the
    program, which is how a crash is reported.
    """
    decode = TYPES.get(ty)
    if decode is None:
        return f"(unsupported {message(ty)})"
    try:
        d = twine.Decoder(data)
        return decode(d, d.entrypoint())
    except twine.Error as e:
        return f"(error {message(e.msg)})"
    except RecursionError:
        # a container item that points back at the container
        return f"(error {message('value is cyclic or nested too deeply')})"


def main() -> None:
    for line in sys.stdin:
        ty, sep, hex_bytes = line.rstrip("\n").partition(" ")
        if not sep:
            sys.exit(f"malformed request: {line!r}")
        sys.stdout.write(reply(ty, bytes.fromhex(hex_bytes)) + "\n")
        sys.stdout.flush()


if __name__ == "__main__":
    main()
