# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_ca_store.Ca_ptr`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..ca_store import key as ca_store_key

__all__ = [
    "Raw",
    "CaPtr",
]

# def Imandrax_api_ca_store.Ca_ptr.Raw.t
@dataclass(slots=True, frozen=True)
class Raw:
    key: ca_store_key.Key

def Raw_of_twine(d: twine.Decoder, off: int) -> Raw:
    x = ca_store_key.Key_of_twine(d=d, off=off) # single unboxed field
    return Raw(key=x)

# def Imandrax_api_ca_store.Ca_ptr.t
type CaPtr[A] = Raw

def CaPtr_of_twine[A](d: twine.Decoder, d0: twine.DecoderFn[A], off: int) -> CaPtr[A]:
    decode_A = d0
    return Raw_of_twine(d=d, off=off)

