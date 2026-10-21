# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Instantiation_rule`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import type as mir_type
from ..mir import term as mir_term
from ..common import instantiation_rule as common_instantiation_rule

__all__ = [
    "InstantiationRule",
]

# def Imandrax_api_mir.Instantiation_rule.t
type InstantiationRule = common_instantiation_rule.InstantiationRule[mir_term.Term, mir_type.Type]

def InstantiationRule_of_twine(d: twine.Decoder, off: int) -> InstantiationRule:
    return common_instantiation_rule.InstantiationRule_of_twine(d=d, off=off, d0=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

