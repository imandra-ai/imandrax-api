# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Instantiation_rule_kind`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt

__all__ = [
    "IR_ForwardChaining",
    "IR_Generalization",
    "InstantiationRuleKind",
]

# def Imandrax_api_common.Instantiation_rule_kind.t
@dataclass(slots=True, frozen=True)
class IR_ForwardChaining:
    pass

@dataclass(slots=True, frozen=True)
class IR_Generalization:
    pass

type InstantiationRuleKind = IR_ForwardChaining | IR_Generalization

def InstantiationRuleKind_of_twine(d: twine.Decoder, off: int) -> InstantiationRuleKind:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return IR_ForwardChaining()
         case twine.Constructor(idx=1, args=args):
             return IR_Generalization()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected InstantiationRuleKind, got invalid constructor {idx}')

