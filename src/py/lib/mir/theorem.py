# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Theorem`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import type as mir_type
from ..mir import term as mir_term
from ..common import theorem as common_theorem

__all__ = [
    "Theorem",
]

# def Imandrax_api_mir.Theorem.t
type Theorem = common_theorem.Theorem[mir_term.Term, mir_type.Type]

def Theorem_of_twine(d: twine.Decoder, off: int) -> Theorem:
    return common_theorem.Theorem_of_twine(d=d, off=off, d0=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

