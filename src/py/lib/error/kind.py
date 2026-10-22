# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrakit_error.Kind`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt

__all__ = [
    "Kind",
]

# def Imandrakit_error.Kind.t
@dataclass(slots=True, frozen=True)
class Kind:
    name: str

def Kind_of_twine(d: twine.Decoder, off: int) -> Kind:
    x = d.get_str(off=off) # single unboxed field
    return Kind(name=x)

