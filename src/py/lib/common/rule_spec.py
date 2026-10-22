# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Rule_spec`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..common import pre_trigger as common_pre_trigger
from ..common import fun_def as common_fun_def

__all__ = [
    "RuleSpec",
]

# def Imandrax_api_common.Rule_spec.t_poly
@dataclass(slots=True, frozen=True)
class RuleSpec[Term, Ty]:
    rule_spec_fc: bool
    rule_spec_rewriting: bool
    rule_spec_perm_restrict: bool
    rule_spec_link: common_fun_def.FunDef[Term, Ty]
    rule_spec_triggers: list[common_pre_trigger.PreTrigger[Term]]

def RuleSpec_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> RuleSpec[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    rule_spec_fc = d.get_bool(off=fields[0])
    rule_spec_rewriting = d.get_bool(off=fields[1])
    rule_spec_perm_restrict = d.get_bool(off=fields[2])
    rule_spec_link = common_fun_def.FunDef_of_twine(d=d, off=fields[3], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    rule_spec_triggers = [common_pre_trigger.PreTrigger_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off))) for x in d.get_array(off=fields[4])]
    return RuleSpec(rule_spec_fc=rule_spec_fc, rule_spec_rewriting=rule_spec_rewriting, rule_spec_perm_restrict=rule_spec_perm_restrict, rule_spec_link=rule_spec_link, rule_spec_triggers=rule_spec_triggers)

