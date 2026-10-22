# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Decl`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import type as mir_type
from ..mir import term as mir_term
from ..common import decl as common_decl

__all__ = [
    "Decl",
]

# def Imandrax_api_mir.Decl.t
type Decl = common_decl.Decl[mir_term.Term, mir_type.Type]

def Decl_of_twine(d: twine.Decoder, off: int) -> Decl:
    return common_decl.Decl_of_twine(d=d, off=off, d0=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

