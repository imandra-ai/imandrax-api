# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.Chash`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt

__all__ = [
    "Chash",
]

# def Imandrax_api.Chash.t
type Chash = bytes

def Chash_of_twine(d: twine.Decoder, off:int) -> Chash:
    return d.get_bytes(off=off)

