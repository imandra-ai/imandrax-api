# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_ca_store.Key`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt

__all__ = [
    "Key",
]

# def Imandrax_api_ca_store.Key.t
type Key = _rt.WithTag7[str]

def Key_of_twine(d: twine.Decoder, off: int) -> Key:
    return _rt.decode_with_tag(tag=7, d=d, off=off, d0=lambda d, off: d.get_str(off=off))

