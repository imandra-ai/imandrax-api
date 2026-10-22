# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Elimination_rule`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid
from ..common import var as common_var
from ..common import fo_pattern as common_fo_pattern

__all__ = [
    "EliminationRule",
]

# def Imandrax_api_common.Elimination_rule.t_poly
@dataclass(slots=True, frozen=True)
class EliminationRule[Term, Ty]:
    er_name: core_uid.Uid
    er_guard: list[Term]
    er_lhs: Term
    er_rhs: common_var.Var[Ty]
    er_dests: list[common_fo_pattern.FoPattern[Ty]]
    er_dest_tms: list[Term]

def EliminationRule_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> EliminationRule[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    er_name = core_uid.Uid_of_twine(d=d, off=fields[0])
    er_guard = [decode_Term(d=d, off=x) for x in d.get_array(off=fields[1])]
    er_lhs = decode_Term(d=d, off=fields[2])
    er_rhs = common_var.Var_of_twine(d=d, off=fields[3], d0=(lambda d, off: decode_Ty(d=d, off=off)))
    er_dests = [common_fo_pattern.FoPattern_of_twine(d=d, off=x, d0=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=fields[4])]
    er_dest_tms = [decode_Term(d=d, off=x) for x in d.get_array(off=fields[5])]
    return EliminationRule(er_name=er_name, er_guard=er_guard, er_lhs=er_lhs, er_rhs=er_rhs, er_dests=er_dests, er_dest_tms=er_dest_tms)

