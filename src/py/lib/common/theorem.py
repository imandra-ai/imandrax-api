# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Theorem`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..common import var as common_var
from ..common import pre_trigger as common_pre_trigger
from ..common import fun_def as common_fun_def

__all__ = [
    "Theorem",
]

# def Imandrax_api_common.Theorem.t_poly
@dataclass(slots=True, frozen=True)
class Theorem[Term, Ty]:
    thm_link: common_fun_def.FunDef[Term, Ty]
    thm_rewriting: bool
    thm_perm_restrict: bool
    thm_fc: bool
    thm_elim: bool
    thm_gen: bool
    thm_triggers: list[common_pre_trigger.PreTrigger[Term]]
    thm_is_axiom: bool
    thm_by: tuple[list[common_var.Var[Ty]], Term]
    thm_named_hypotheses: list[tuple[str, Term]]

def Theorem_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> Theorem[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    thm_link = common_fun_def.FunDef_of_twine(d=d, off=fields[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    thm_rewriting = d.get_bool(off=fields[1])
    thm_perm_restrict = d.get_bool(off=fields[2])
    thm_fc = d.get_bool(off=fields[3])
    thm_elim = d.get_bool(off=fields[4])
    thm_gen = d.get_bool(off=fields[5])
    thm_triggers = [common_pre_trigger.PreTrigger_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off))) for x in d.get_array(off=fields[6])]
    thm_is_axiom = d.get_bool(off=fields[7])
    thm_by = (lambda tup: ([common_var.Var_of_twine(d=d, off=x, d0=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=tup[0])], decode_Term(d=d, off=tup[1])))(tuple(d.get_array(off=fields[8])))
    thm_named_hypotheses = [(lambda tup: (d.get_str(off=tup[0]), decode_Term(d=d, off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[9])]
    return Theorem(thm_link=thm_link, thm_rewriting=thm_rewriting, thm_perm_restrict=thm_perm_restrict, thm_fc=thm_fc, thm_elim=thm_elim, thm_gen=thm_gen, thm_triggers=thm_triggers, thm_is_axiom=thm_is_axiom, thm_by=thm_by, thm_named_hypotheses=thm_named_hypotheses)

