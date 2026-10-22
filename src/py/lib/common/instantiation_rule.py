# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Instantiation_rule`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..common import trigger as common_trigger
from ..common import instantiation_rule_kind as common_instantiation_rule_kind
from ..common import fun_def as common_fun_def

__all__ = [
    "InstantiationRule",
]

# def Imandrax_api_common.Instantiation_rule.t_poly
@dataclass(slots=True, frozen=True)
class InstantiationRule[Term, Ty]:
    ir_from: common_fun_def.FunDef[Term, Ty]
    ir_triggers: list[common_trigger.Trigger[Ty]]
    ir_kind: common_instantiation_rule_kind.InstantiationRuleKind

def InstantiationRule_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> InstantiationRule[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    ir_from = common_fun_def.FunDef_of_twine(d=d, off=fields[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    ir_triggers = [common_trigger.Trigger_of_twine(d=d, off=x, d0=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=fields[1])]
    ir_kind = common_instantiation_rule_kind.InstantiationRuleKind_of_twine(d=d, off=fields[2])
    return InstantiationRule(ir_from=ir_from, ir_triggers=ir_triggers, ir_kind=ir_kind)

