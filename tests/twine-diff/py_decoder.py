"""Python decoder program for the twine differential test

Reads framed requests on stdin and replies with one S-expression line each.
"""

# pyright: reportPrivateUsage=false
import struct
import sys

from imandrax_api.lib import twine


def node(d: twine.Decoder, off: int) -> str:
    """The text form of the value at `off`.

    Walks the structure with the decoder's cursors rather than `value()`, so
    dict entries come out in encoding order and keys need not be hashable.
    """
    off, high, low = d._head(off)
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
        case _:
            # let the library reject kinds it does not support
            d.shallow_value(off)
            raise twine.Error(f"no text form for kind {high} at off=0x{off:x}")


def message(s: str) -> str:
    """`s` as a quoted atom: printable ASCII only, without quotes or backslashes."""
    clean = "".join(c if " " <= c <= "~" and c not in '"\\' else "?" for c in s)
    return f'"{clean}"'


def reply(mode: bytes, data: bytes) -> str:
    try:
        d = twine.Decoder(data)
        entry = d.entrypoint()
        if mode == b"v":
            return node(d, entry)
        if mode == b"i":
            return f'(int "{d.get_int(entry)}")'
        return f"(error crash {message(f'unknown mode {mode!r}')})"
    except twine.Error as e:
        return f"(error decode {message(e.msg)})"
    except RecursionError:
        # a container item that points back at the container
        return f"(error decode {message('value is cyclic or nested too deeply')})"
    except Exception as e:  # noqa: BLE001 - any other exception is a crash, by design
        return f"(error crash {message(f'{type(e).__name__}: {e}')})"


def main() -> None:
    stdin = sys.stdin.buffer
    while True:
        head = stdin.read(5)
        if not head:
            return
        if len(head) < 5:
            sys.exit("truncated request header")
        n = int.from_bytes(head[1:5], "big")
        data = stdin.read(n)
        if len(data) < n:
            sys.exit("truncated request body")
        sys.stdout.write(reply(head[0:1], data) + "\n")
        sys.stdout.flush()


if __name__ == "__main__":
    main()
