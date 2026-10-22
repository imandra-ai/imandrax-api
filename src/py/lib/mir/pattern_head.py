# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Pattern_head`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import type as mir_type
from ..common import pattern_head as common_pattern_head

__all__ = [
    "PatternHead",
]

# def Imandrax_api_mir.Pattern_head.t
type PatternHead = common_pattern_head.PatternHead[mir_type.Type]

def PatternHead_of_twine(d: twine.Decoder, off: int) -> PatternHead:
    return common_pattern_head.PatternHead_of_twine(d=d, off=off, d0=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

