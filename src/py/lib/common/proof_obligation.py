# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Proof_obligation`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import upto as core_upto
from ..core import anchor as core_anchor
from ..common import verify as common_verify
from ..common import var as common_var
from ..common import tactic as common_tactic

__all__ = [
    "ProofObligation",
]

# def Imandrax_api_common.Proof_obligation.t_poly
@dataclass(slots=True, frozen=True)
class ProofObligation[Term, Ty]:
    descr: str
    goal: tuple[list[common_var.Var[Ty]], Term]
    tactic: common_tactic.Tactic[Term, Ty]
    is_instance: bool
    anchor: core_anchor.Anchor
    timeout: None | int
    upto: None | core_upto.Upto
    verify_kind: None | common_verify.Kind
    named_hypotheses: list[tuple[str, Term]]

def ProofObligation_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> ProofObligation[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    descr = d.get_str(off=fields[0])
    goal = (lambda tup: ([common_var.Var_of_twine(d=d, off=x, d0=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=tup[0])], decode_Term(d=d, off=tup[1])))(tuple(d.get_array(off=fields[1])))
    tactic = common_tactic.Tactic_of_twine(d=d, off=fields[2], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    is_instance = d.get_bool(off=fields[3])
    anchor = core_anchor.Anchor_of_twine(d=d, off=fields[4])
    timeout = twine.optional(d=d, off=fields[5], d0=lambda d, off: d.get_int(off=off))
    upto = twine.optional(d=d, off=fields[6], d0=lambda d, off: core_upto.Upto_of_twine(d=d, off=off))
    verify_kind = twine.optional(d=d, off=fields[7], d0=lambda d, off: common_verify.Kind_of_twine(d=d, off=off))
    named_hypotheses = [(lambda tup: (d.get_str(off=tup[0]), decode_Term(d=d, off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[8])]
    return ProofObligation(descr=descr, goal=goal, tactic=tactic, is_instance=is_instance, anchor=anchor, timeout=timeout, upto=upto, verify_kind=verify_kind, named_hypotheses=named_hypotheses)

