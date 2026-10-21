# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Fun_def`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import type as mir_type
from ..mir import term as mir_term
from ..common import fun_def as common_fun_def

__all__ = [
    "FunDef",
]

# def Imandrax_api_mir.Fun_def.t
type FunDef = common_fun_def.FunDef[mir_term.Term, mir_type.Type]

def FunDef_of_twine(d: twine.Decoder, off: int) -> FunDef:
    return common_fun_def.FunDef_of_twine(d=d, off=off, d0=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

