# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Var`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import type as mir_type
from ..common import var as common_var

__all__ = [
    "Var",
]

# def Imandrax_api_mir.Var.t
type Var = common_var.Var[mir_type.Type]

def Var_of_twine(d: twine.Decoder, off: int) -> Var:
    return common_var.Var_of_twine(d=d, off=off, d0=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

