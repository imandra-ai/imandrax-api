# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Sequent`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import term as mir_term
from ..common import sequent as common_sequent

__all__ = [
    "Sequent",
]

# def Imandrax_api_mir.Sequent.t
type Sequent = common_sequent.Sequent[mir_term.Term]

def Sequent_of_twine(d: twine.Decoder, off: int) -> Sequent:
    return common_sequent.Sequent_of_twine(d=d, off=off, d0=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)))

