# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Tactic`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import type as mir_type
from ..mir import term as mir_term
from ..common import tactic as common_tactic

__all__ = [
    "Tactic",
]

# def Imandrax_api_mir.Tactic.t
type Tactic = common_tactic.Tactic[mir_term.Term, mir_type.Type]

def Tactic_of_twine(d: twine.Decoder, off: int) -> Tactic:
    return common_tactic.Tactic_of_twine(d=d, off=off, d0=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

