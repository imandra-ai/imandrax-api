# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Fun_decomp`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import type as mir_type
from ..mir import term as mir_term
from ..common import fun_decomp as common_fun_decomp

__all__ = [
    "FunDecomp",
]

# def Imandrax_api_mir.Fun_decomp.t
type FunDecomp = common_fun_decomp.FunDecomp[mir_term.Term, mir_type.Type]

def FunDecomp_of_twine(d: twine.Decoder, off: int) -> FunDecomp:
    return common_fun_decomp.FunDecomp_of_twine(d=d, off=off, d0=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

