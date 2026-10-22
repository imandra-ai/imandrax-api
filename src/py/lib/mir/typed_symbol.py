# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Typed_symbol`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import type as mir_type
from ..common import typed_symbol as common_typed_symbol

__all__ = [
    "TypedSymbol",
]

# def Imandrax_api_mir.Typed_symbol.t
type TypedSymbol = common_typed_symbol.TypedSymbol[mir_type.Type]

def TypedSymbol_of_twine(d: twine.Decoder, off: int) -> TypedSymbol:
    return common_typed_symbol.TypedSymbol_of_twine(d=d, off=off, d0=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

