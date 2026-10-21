# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Fo_pattern`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import type as mir_type
from ..common import fo_pattern as common_fo_pattern

__all__ = [
    "FoPattern",
]

# def Imandrax_api_mir.Fo_pattern.t
type FoPattern = common_fo_pattern.FoPattern[mir_type.Type]

def FoPattern_of_twine(d: twine.Decoder, off: int) -> FoPattern:
    return common_fo_pattern.FoPattern_of_twine(d=d, off=off, d0=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

