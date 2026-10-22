# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Rewrite_rule`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid
from ..common import var as common_var
from ..common import pattern_head as common_pattern_head
from ..common import fo_pattern as common_fo_pattern

__all__ = [
    "RewriteRule",
]

# def Imandrax_api_common.Rewrite_rule.t_poly
@dataclass(slots=True, frozen=True)
class RewriteRule[Term, Ty]:
    rw_name: core_uid.Uid
    rw_head: common_pattern_head.PatternHead[Ty]
    rw_lhs: common_fo_pattern.FoPattern[Ty]
    rw_rhs: Term
    rw_guard: list[Term]
    rw_vars: list[common_var.Var[Ty]]
    rw_triggers: list[common_fo_pattern.FoPattern[Ty]]
    rw_perm_restrict: bool
    rw_loop_break: None | common_fo_pattern.FoPattern[Ty]

def RewriteRule_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> RewriteRule[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    rw_name = core_uid.Uid_of_twine(d=d, off=fields[0])
    rw_head = common_pattern_head.PatternHead_of_twine(d=d, off=fields[1], d0=(lambda d, off: decode_Ty(d=d, off=off)))
    rw_lhs = common_fo_pattern.FoPattern_of_twine(d=d, off=fields[2], d0=(lambda d, off: decode_Ty(d=d, off=off)))
    rw_rhs = decode_Term(d=d, off=fields[3])
    rw_guard = [decode_Term(d=d, off=x) for x in d.get_array(off=fields[4])]
    rw_vars = [common_var.Var_of_twine(d=d, off=x, d0=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=fields[5])]
    rw_triggers = [common_fo_pattern.FoPattern_of_twine(d=d, off=x, d0=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=fields[6])]
    rw_perm_restrict = d.get_bool(off=fields[7])
    rw_loop_break = twine.optional(d=d, off=fields[8], d0=lambda d, off: common_fo_pattern.FoPattern_of_twine(d=d, off=off, d0=(lambda d, off: decode_Ty(d=d, off=off))))
    return RewriteRule(rw_name=rw_name, rw_head=rw_head, rw_lhs=rw_lhs, rw_rhs=rw_rhs, rw_guard=rw_guard, rw_vars=rw_vars, rw_triggers=rw_triggers, rw_perm_restrict=rw_perm_restrict, rw_loop_break=rw_loop_break)

