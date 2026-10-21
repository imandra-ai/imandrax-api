# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_report.Atomic_event`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..report import smt_proof as report_smt_proof
from ..report import rtext as report_rtext
from ..mir import type as mir_type
from ..mir import term as mir_term
from ..common import var as common_var
from ..common import sequent as common_sequent
from ..common import rewrite_rule as common_rewrite_rule
from ..common import model as common_model
from ..common import instantiation_rule as common_instantiation_rule

__all__ = [
    "Model",
    "E_Message",
    "E_Title",
    "E_EnterWaterfall",
    "E_EnterTactic",
    "E_RwSuccess",
    "E_RwFail",
    "E_InstSuccess",
    "E_WaterfallCheckpoint",
    "E_InductionScheme",
    "E_AttackSubgoal",
    "E_SimplifyT",
    "E_SimplifyClause",
    "E_ProvedBySmt",
    "E_RefutedBySmt",
    "E_FunExpansion",
    "AtomicEvent",
    "Mir",
]

# def Imandrax_api_report.Atomic_event.model
type Model[Term, Ty] = common_model.Model[Term, Ty]

def Model_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> Model[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    return common_model.Model_of_twine(d=d, off=off, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))

# def Imandrax_api_report.Atomic_event.poly
@dataclass(slots=True, frozen=True)
class E_Message[Term, Ty, Term2, Ty2]:
    arg: report_rtext.Rtext[Term]

def E_Message_of_twine[Term, Ty, Term2, Ty2](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Term2], d3: twine.DecoderFn[Ty2], _tw_args: tuple[int, ...]) -> E_Message[Term, Ty, Term2, Ty2]:
    decode_Term = d0
    decode_Ty = d1
    decode_Term2 = d2
    decode_Ty2 = d3
    arg = report_rtext.Rtext_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)))
    return E_Message(arg=arg)

@dataclass(slots=True, frozen=True)
class E_Title[Term, Ty, Term2, Ty2]:
    arg: str

def E_Title_of_twine[Term, Ty, Term2, Ty2](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Term2], d3: twine.DecoderFn[Ty2], _tw_args: tuple[int, ...]) -> E_Title[Term, Ty, Term2, Ty2]:
    decode_Term = d0
    decode_Ty = d1
    decode_Term2 = d2
    decode_Ty2 = d3
    arg = d.get_str(off=_tw_args[0])
    return E_Title(arg=arg)

@dataclass(slots=True, frozen=True)
class E_EnterWaterfall[Term, Ty, Term2, Ty2]:
    vars: list[common_var.Var[Ty]]
    goal: Term


def E_EnterWaterfall_of_twine[Term, Ty, Term2, Ty2](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Term2], d3: twine.DecoderFn[Ty2], _tw_args: tuple[int, ...]) -> E_EnterWaterfall[Term, Ty, Term2, Ty2]:
    decode_Term = d0
    decode_Ty = d1
    decode_Term2 = d2
    decode_Ty2 = d3
    vars = [common_var.Var_of_twine(d=d, off=x, d0=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=_tw_args[0])]
    goal = decode_Term(d=d, off=_tw_args[1])
    return E_EnterWaterfall(vars=vars, goal=goal)


@dataclass(slots=True, frozen=True)
class E_EnterTactic[Term, Ty, Term2, Ty2]:
    arg: str

def E_EnterTactic_of_twine[Term, Ty, Term2, Ty2](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Term2], d3: twine.DecoderFn[Ty2], _tw_args: tuple[int, ...]) -> E_EnterTactic[Term, Ty, Term2, Ty2]:
    decode_Term = d0
    decode_Ty = d1
    decode_Term2 = d2
    decode_Ty2 = d3
    arg = d.get_str(off=_tw_args[0])
    return E_EnterTactic(arg=arg)

@dataclass(slots=True, frozen=True)
class E_RwSuccess[Term, Ty, Term2, Ty2]:
    args: tuple[common_rewrite_rule.RewriteRule[Term2, Ty2], Term, Term]

def E_RwSuccess_of_twine[Term, Ty, Term2, Ty2](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Term2], d3: twine.DecoderFn[Ty2], _tw_args: tuple[int, ...]) -> E_RwSuccess[Term, Ty, Term2, Ty2]:
    decode_Term = d0
    decode_Ty = d1
    decode_Term2 = d2
    decode_Ty2 = d3
    cargs = (common_rewrite_rule.RewriteRule_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term2(d=d, off=off)), d1=(lambda d, off: decode_Ty2(d=d, off=off))), decode_Term(d=d, off=_tw_args[1]), decode_Term(d=d, off=_tw_args[2]))
    return E_RwSuccess(args=cargs)

@dataclass(slots=True, frozen=True)
class E_RwFail[Term, Ty, Term2, Ty2]:
    args: tuple[common_rewrite_rule.RewriteRule[Term2, Ty2], Term, str]

def E_RwFail_of_twine[Term, Ty, Term2, Ty2](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Term2], d3: twine.DecoderFn[Ty2], _tw_args: tuple[int, ...]) -> E_RwFail[Term, Ty, Term2, Ty2]:
    decode_Term = d0
    decode_Ty = d1
    decode_Term2 = d2
    decode_Ty2 = d3
    cargs = (common_rewrite_rule.RewriteRule_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term2(d=d, off=off)), d1=(lambda d, off: decode_Ty2(d=d, off=off))), decode_Term(d=d, off=_tw_args[1]), d.get_str(off=_tw_args[2]))
    return E_RwFail(args=cargs)

@dataclass(slots=True, frozen=True)
class E_InstSuccess[Term, Ty, Term2, Ty2]:
    args: tuple[common_instantiation_rule.InstantiationRule[Term2, Ty2], Term]

def E_InstSuccess_of_twine[Term, Ty, Term2, Ty2](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Term2], d3: twine.DecoderFn[Ty2], _tw_args: tuple[int, ...]) -> E_InstSuccess[Term, Ty, Term2, Ty2]:
    decode_Term = d0
    decode_Ty = d1
    decode_Term2 = d2
    decode_Ty2 = d3
    cargs = (common_instantiation_rule.InstantiationRule_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term2(d=d, off=off)), d1=(lambda d, off: decode_Ty2(d=d, off=off))), decode_Term(d=d, off=_tw_args[1]))
    return E_InstSuccess(args=cargs)

@dataclass(slots=True, frozen=True)
class E_WaterfallCheckpoint[Term, Ty, Term2, Ty2]:
    arg: list[common_sequent.Sequent[Term]]

def E_WaterfallCheckpoint_of_twine[Term, Ty, Term2, Ty2](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Term2], d3: twine.DecoderFn[Ty2], _tw_args: tuple[int, ...]) -> E_WaterfallCheckpoint[Term, Ty, Term2, Ty2]:
    decode_Term = d0
    decode_Ty = d1
    decode_Term2 = d2
    decode_Ty2 = d3
    arg = [common_sequent.Sequent_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off))) for x in d.get_array(off=_tw_args[0])]
    return E_WaterfallCheckpoint(arg=arg)

@dataclass(slots=True, frozen=True)
class E_InductionScheme[Term, Ty, Term2, Ty2]:
    arg: Term

def E_InductionScheme_of_twine[Term, Ty, Term2, Ty2](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Term2], d3: twine.DecoderFn[Ty2], _tw_args: tuple[int, ...]) -> E_InductionScheme[Term, Ty, Term2, Ty2]:
    decode_Term = d0
    decode_Ty = d1
    decode_Term2 = d2
    decode_Ty2 = d3
    arg = decode_Term(d=d, off=_tw_args[0])
    return E_InductionScheme(arg=arg)

@dataclass(slots=True, frozen=True)
class E_AttackSubgoal[Term, Ty, Term2, Ty2]:
    name: str
    goal: common_sequent.Sequent[Term]
    depth: int


def E_AttackSubgoal_of_twine[Term, Ty, Term2, Ty2](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Term2], d3: twine.DecoderFn[Ty2], _tw_args: tuple[int, ...]) -> E_AttackSubgoal[Term, Ty, Term2, Ty2]:
    decode_Term = d0
    decode_Ty = d1
    decode_Term2 = d2
    decode_Ty2 = d3
    name = d.get_str(off=_tw_args[0])
    goal = common_sequent.Sequent_of_twine(d=d, off=_tw_args[1], d0=(lambda d, off: decode_Term(d=d, off=off)))
    depth = d.get_int(off=_tw_args[2])
    return E_AttackSubgoal(name=name, goal=goal, depth=depth)


@dataclass(slots=True, frozen=True)
class E_SimplifyT[Term, Ty, Term2, Ty2]:
    args: tuple[Term, Term]

def E_SimplifyT_of_twine[Term, Ty, Term2, Ty2](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Term2], d3: twine.DecoderFn[Ty2], _tw_args: tuple[int, ...]) -> E_SimplifyT[Term, Ty, Term2, Ty2]:
    decode_Term = d0
    decode_Ty = d1
    decode_Term2 = d2
    decode_Ty2 = d3
    cargs = (decode_Term(d=d, off=_tw_args[0]), decode_Term(d=d, off=_tw_args[1]))
    return E_SimplifyT(args=cargs)

@dataclass(slots=True, frozen=True)
class E_SimplifyClause[Term, Ty, Term2, Ty2]:
    args: tuple[Term, list[Term]]

def E_SimplifyClause_of_twine[Term, Ty, Term2, Ty2](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Term2], d3: twine.DecoderFn[Ty2], _tw_args: tuple[int, ...]) -> E_SimplifyClause[Term, Ty, Term2, Ty2]:
    decode_Term = d0
    decode_Ty = d1
    decode_Term2 = d2
    decode_Ty2 = d3
    cargs = (decode_Term(d=d, off=_tw_args[0]), [decode_Term(d=d, off=x) for x in d.get_array(off=_tw_args[1])])
    return E_SimplifyClause(args=cargs)

@dataclass(slots=True, frozen=True)
class E_ProvedBySmt[Term, Ty, Term2, Ty2]:
    args: tuple[Term, report_smt_proof.SmtProof[Term]]

def E_ProvedBySmt_of_twine[Term, Ty, Term2, Ty2](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Term2], d3: twine.DecoderFn[Ty2], _tw_args: tuple[int, ...]) -> E_ProvedBySmt[Term, Ty, Term2, Ty2]:
    decode_Term = d0
    decode_Ty = d1
    decode_Term2 = d2
    decode_Ty2 = d3
    cargs = (decode_Term(d=d, off=_tw_args[0]), report_smt_proof.SmtProof_of_twine(d=d, off=_tw_args[1], d0=(lambda d, off: decode_Term(d=d, off=off))))
    return E_ProvedBySmt(args=cargs)

@dataclass(slots=True, frozen=True)
class E_RefutedBySmt[Term, Ty, Term2, Ty2]:
    args: tuple[Term, None | common_model.Model[Term, Ty]]

def E_RefutedBySmt_of_twine[Term, Ty, Term2, Ty2](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Term2], d3: twine.DecoderFn[Ty2], _tw_args: tuple[int, ...]) -> E_RefutedBySmt[Term, Ty, Term2, Ty2]:
    decode_Term = d0
    decode_Ty = d1
    decode_Term2 = d2
    decode_Ty2 = d3
    cargs = (decode_Term(d=d, off=_tw_args[0]), twine.optional(d=d, off=_tw_args[1], d0=lambda d, off: common_model.Model_of_twine(d=d, off=off, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))))
    return E_RefutedBySmt(args=cargs)

@dataclass(slots=True, frozen=True)
class E_FunExpansion[Term, Ty, Term2, Ty2]:
    args: tuple[Term, Term]

def E_FunExpansion_of_twine[Term, Ty, Term2, Ty2](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Term2], d3: twine.DecoderFn[Ty2], _tw_args: tuple[int, ...]) -> E_FunExpansion[Term, Ty, Term2, Ty2]:
    decode_Term = d0
    decode_Ty = d1
    decode_Term2 = d2
    decode_Ty2 = d3
    cargs = (decode_Term(d=d, off=_tw_args[0]), decode_Term(d=d, off=_tw_args[1]))
    return E_FunExpansion(args=cargs)

type AtomicEvent[Term, Ty, Term2, Ty2] = E_Message[Term, Ty, Term2, Ty2] | E_Title[Term, Ty, Term2, Ty2] | E_EnterWaterfall[Term, Ty, Term2, Ty2] | E_EnterTactic[Term, Ty, Term2, Ty2] | E_RwSuccess[Term, Ty, Term2, Ty2] | E_RwFail[Term, Ty, Term2, Ty2] | E_InstSuccess[Term, Ty, Term2, Ty2] | E_WaterfallCheckpoint[Term, Ty, Term2, Ty2] | E_InductionScheme[Term, Ty, Term2, Ty2] | E_AttackSubgoal[Term, Ty, Term2, Ty2] | E_SimplifyT[Term, Ty, Term2, Ty2] | E_SimplifyClause[Term, Ty, Term2, Ty2] | E_ProvedBySmt[Term, Ty, Term2, Ty2] | E_RefutedBySmt[Term, Ty, Term2, Ty2] | E_FunExpansion[Term, Ty, Term2, Ty2]

def AtomicEvent_of_twine[Term, Ty, Term2, Ty2](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Term2], d3: twine.DecoderFn[Ty2], off: int) -> AtomicEvent[Term, Ty, Term2, Ty2]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return E_Message_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2, d3=d3)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return E_Title_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2, d3=d3)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return E_EnterWaterfall_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2, d3=d3)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return E_EnterTactic_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2, d3=d3)
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return E_RwSuccess_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2, d3=d3)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return E_RwFail_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2, d3=d3)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return E_InstSuccess_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2, d3=d3)
         case twine.Constructor(idx=7, args=args):
             args = tuple(args)
             return E_WaterfallCheckpoint_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2, d3=d3)
         case twine.Constructor(idx=8, args=args):
             args = tuple(args)
             return E_InductionScheme_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2, d3=d3)
         case twine.Constructor(idx=9, args=args):
             args = tuple(args)
             return E_AttackSubgoal_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2, d3=d3)
         case twine.Constructor(idx=10, args=args):
             args = tuple(args)
             return E_SimplifyT_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2, d3=d3)
         case twine.Constructor(idx=11, args=args):
             args = tuple(args)
             return E_SimplifyClause_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2, d3=d3)
         case twine.Constructor(idx=12, args=args):
             args = tuple(args)
             return E_ProvedBySmt_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2, d3=d3)
         case twine.Constructor(idx=13, args=args):
             args = tuple(args)
             return E_RefutedBySmt_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2, d3=d3)
         case twine.Constructor(idx=14, args=args):
             args = tuple(args)
             return E_FunExpansion_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2, d3=d3)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected AtomicEvent, got invalid constructor {idx}')

# def Imandrax_api_report.Atomic_event.Mir.t
type Mir = AtomicEvent[mir_term.Term, mir_type.Type, mir_term.Term, mir_type.Type]

def Mir_of_twine(d: twine.Decoder, off: int) -> Mir:
    return AtomicEvent_of_twine(d=d, off=off, d0=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)), d2=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)), d3=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

