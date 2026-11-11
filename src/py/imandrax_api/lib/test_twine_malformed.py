# pyright: reportPrivateUsage=false
"""
Robustness of the twine decoder on malformed input.

Contract: for any bytes and any offset, every public `Decoder` method either
returns a value or raises `twine.Error`. It never raises anything else, and
never returns data read from outside the buffer.
"""

from collections.abc import Callable
from pathlib import Path
from typing import Any

import pytest
from hypothesis import given, settings
from hypothesis import strategies as st

from . import twine

CURR_DIR = Path(__file__).parent

CORPUS: dict[str, bytes] = {
    name: (CURR_DIR / "test_data" / name).read_bytes()
    for name in ("typereg.twine", "pubsub.twine")
}


def ok_or_twine_error(f: Callable[[], Any]) -> None:
    """Run `f`; anything other than a result or `twine.Error` fails the test."""
    try:
        f()
    except twine.Error:
        pass


def _drain(c: twine.ArrayCursor | twine.DictCursor, d: twine.Decoder) -> None:
    """Iterate a cursor fully, decoding every item it yields."""
    if isinstance(c, twine.DictCursor):
        for k, v in c:
            d.value(off=k)
            d.value(off=v)
    else:
        for off in c:
            d.value(off=off)


def _decode_with(d: twine.Decoder, method: str, off: int) -> None:
    match method:
        case "get_array" | "get_dict":
            _drain(getattr(d, method)(off=off), d)
        case "get_cstor":
            _drain(d.get_cstor(off=off).args, d)
        case "get_tag":
            d.value(off=d.get_tag(off=off).arg)
        case _:
            getattr(d, method)(off=off)


PUBLIC_METHODS = [
    "value",
    "shallow_value",
    "get_int",
    "get_bool",
    "get_null",
    "get_float",
    "get_str",
    "get_bytes",
    "get_array",
    "get_dict",
    "get_tag",
    "get_cstor",
]


# Regressions
# ===========


@pytest.mark.parametrize(
    "data",
    [
        pytest.param(b"", id="empty-buffer"),
        pytest.param(b"\x3f", id="f64-without-payload"),
        pytest.param(b"\x30\x00", id="f32-truncated-payload"),
        pytest.param(b"\x41\xff", id="invalid-utf8"),
        pytest.param(b"\x41", id="str-runs-past-end"),
        pytest.param(b"\x52\x00", id="bytes-runs-past-end"),
        pytest.param(b"\xf0\x15", id="pointer-before-start"),
        pytest.param(b"\x1f", id="leb128-past-end"),
        pytest.param(b"\x1f\x80", id="leb128-unterminated"),
        pytest.param(b"\x62\x11", id="array-items-past-end"),
        # an array whose only item is a pointer back to the array itself
        pytest.param(b"\x61\xf0", id="cyclic-array"),
    ],
)
def test_malformed_raises_twine_error(data: bytes):
    d = twine.Decoder(data)
    with pytest.raises(twine.Error):
        d.value(off=0)


@pytest.mark.parametrize(
    "data",
    [
        pytest.param(b"", id="empty-buffer"),
        pytest.param(b"\x05", id="pointer-before-start"),
    ],
)
def test_entrypoint_malformed_raises_twine_error(data: bytes):
    with pytest.raises(twine.Error):
        twine.Decoder(data).entrypoint()


@pytest.mark.parametrize("off", [-1, 1, 100])
def test_offset_out_of_range_raises_twine_error(off: int):
    d = twine.Decoder(b"\x11")
    with pytest.raises(twine.Error):
        d.get_int(off=off)


def test_unhashable_dict_key_raises_twine_error():
    # A dict whose key is itself a dict is valid twine, but cannot be a key of a
    # Python `dict`. Layout: [0] empty dict `{}`; [1] dict with one entry whose
    # key is a pointer back to [0] and whose value is int 1.
    d = twine.Decoder(b"\x70\x71\xf1\x11")
    with pytest.raises(twine.Error):
        d.value(off=1)


# Properties
# ==========


@given(st.binary(max_size=256))
def test_prop_entrypoint_value(data: bytes):
    d = twine.Decoder(data)
    ok_or_twine_error(lambda: d.value(off=d.entrypoint()))


@st.composite
def buffer_offset_method(draw: st.DrawFn) -> tuple[bytes, int, str]:
    data = draw(st.binary(min_size=1, max_size=256))
    off = draw(st.integers(min_value=0, max_value=len(data) - 1))
    method = draw(st.sampled_from(PUBLIC_METHODS))
    return data, off, method


@given(buffer_offset_method())
def test_prop_any_offset_any_method(case: tuple[bytes, int, str]):
    data, off, method = case
    d = twine.Decoder(data)
    ok_or_twine_error(lambda: _decode_with(d, method, off))


@st.composite
def mutated_corpus(draw: st.DrawFn) -> bytes:
    data = bytearray(CORPUS[draw(st.sampled_from(sorted(CORPUS)))])
    for _ in range(draw(st.integers(min_value=1, max_value=4))):
        pos = draw(st.integers(min_value=0, max_value=len(data) - 1))
        match draw(st.sampled_from(["truncate", "overwrite", "insert", "delete"])):
            case "truncate":
                del data[pos:]
            case "overwrite":
                data[pos] = draw(st.integers(min_value=0, max_value=255))
            case "insert":
                data.insert(pos, draw(st.integers(min_value=0, max_value=255)))
            case _:  # "delete"
                del data[pos]
        if not data:
            break
    return bytes(data)


@settings(deadline=None)
@given(mutated_corpus())
def test_prop_mutated_corpus(data: bytes):
    d = twine.Decoder(data)
    ok_or_twine_error(lambda: d.value(off=d.entrypoint()))
