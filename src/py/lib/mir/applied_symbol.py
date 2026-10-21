# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Applied_symbol`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import type as mir_type
from ..common import applied_symbol as common_applied_symbol

__all__ = [
    "AppliedSymbol",
]

# def Imandrax_api_mir.Applied_symbol.t
type AppliedSymbol = common_applied_symbol.AppliedSymbol[mir_type.Type]

def AppliedSymbol_of_twine(d: twine.Decoder, off: int) -> AppliedSymbol:
    return common_applied_symbol.AppliedSymbol_of_twine(d=d, off=off, d0=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

