# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Db_op`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid
from ..common import trigger as common_trigger
from ..common import rewrite_rule as common_rewrite_rule
from ..common import pattern_head as common_pattern_head
from ..common import instantiation_rule as common_instantiation_rule
from ..common import fun_def as common_fun_def
from ..common import elimination_rule as common_elimination_rule
from ..common import decl as common_decl
from ..common import admission as common_admission

__all__ = [
    "OpEnable",
    "OpDisable",
    "OpAddDecls",
    "OpAddRw",
    "OpAddFcTrigger",
    "OpAddElim",
    "OpAddGenTrigger",
    "OpAddCountFun",
    "OpSetAdmission",
    "OpSetThmAsRw",
    "OpSetThmAsFc",
    "OpSetThmAsElim",
    "OpSetThmAsGen",
    "OpAddInstantiationRule",
    "OpAddRuleSpecFcTriggers",
    "OpAddRuleSpecRw",
    "DbOp",
]

# def Imandrax_api_common.Db_op.t_poly
@dataclass(slots=True, frozen=True)
class OpEnable[Term, Ty]:
    arg: list[core_uid.Uid]

def OpEnable_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> OpEnable[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = [core_uid.Uid_of_twine(d=d, off=x) for x in d.get_array(off=_tw_args[0])]
    return OpEnable(arg=arg)

@dataclass(slots=True, frozen=True)
class OpDisable[Term, Ty]:
    arg: list[core_uid.Uid]

def OpDisable_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> OpDisable[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = [core_uid.Uid_of_twine(d=d, off=x) for x in d.get_array(off=_tw_args[0])]
    return OpDisable(arg=arg)

@dataclass(slots=True, frozen=True)
class OpAddDecls[Term, Ty]:
    arg: list[common_decl.Decl[Term, Ty]]

def OpAddDecls_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> OpAddDecls[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = [common_decl.Decl_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=_tw_args[0])]
    return OpAddDecls(arg=arg)

@dataclass(slots=True, frozen=True)
class OpAddRw[Term, Ty]:
    args: tuple[common_pattern_head.PatternHead[Ty], common_rewrite_rule.RewriteRule[Term, Ty]]

def OpAddRw_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> OpAddRw[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    cargs = (common_pattern_head.PatternHead_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Ty(d=d, off=off))), common_rewrite_rule.RewriteRule_of_twine(d=d, off=_tw_args[1], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))))
    return OpAddRw(args=cargs)

@dataclass(slots=True, frozen=True)
class OpAddFcTrigger[Term, Ty]:
    args: tuple[common_pattern_head.PatternHead[Ty], common_trigger.Trigger[Ty]]

def OpAddFcTrigger_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> OpAddFcTrigger[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    cargs = (common_pattern_head.PatternHead_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Ty(d=d, off=off))), common_trigger.Trigger_of_twine(d=d, off=_tw_args[1], d0=(lambda d, off: decode_Ty(d=d, off=off))))
    return OpAddFcTrigger(args=cargs)

@dataclass(slots=True, frozen=True)
class OpAddElim[Term, Ty]:
    args: tuple[common_pattern_head.PatternHead[Ty], common_elimination_rule.EliminationRule[Term, Ty]]

def OpAddElim_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> OpAddElim[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    cargs = (common_pattern_head.PatternHead_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Ty(d=d, off=off))), common_elimination_rule.EliminationRule_of_twine(d=d, off=_tw_args[1], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))))
    return OpAddElim(args=cargs)

@dataclass(slots=True, frozen=True)
class OpAddGenTrigger[Term, Ty]:
    args: tuple[common_pattern_head.PatternHead[Ty], common_trigger.Trigger[Ty]]

def OpAddGenTrigger_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> OpAddGenTrigger[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    cargs = (common_pattern_head.PatternHead_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Ty(d=d, off=off))), common_trigger.Trigger_of_twine(d=d, off=_tw_args[1], d0=(lambda d, off: decode_Ty(d=d, off=off))))
    return OpAddGenTrigger(args=cargs)

@dataclass(slots=True, frozen=True)
class OpAddCountFun[Term, Ty]:
    args: tuple[core_uid.Uid, common_fun_def.FunDef[Term, Ty]]

def OpAddCountFun_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> OpAddCountFun[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    cargs = (core_uid.Uid_of_twine(d=d, off=_tw_args[0]), common_fun_def.FunDef_of_twine(d=d, off=_tw_args[1], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))))
    return OpAddCountFun(args=cargs)

@dataclass(slots=True, frozen=True)
class OpSetAdmission[Term, Ty]:
    args: tuple[core_uid.Uid, common_admission.Admission]

def OpSetAdmission_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> OpSetAdmission[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    cargs = (core_uid.Uid_of_twine(d=d, off=_tw_args[0]), common_admission.Admission_of_twine(d=d, off=_tw_args[1]))
    return OpSetAdmission(args=cargs)

@dataclass(slots=True, frozen=True)
class OpSetThmAsRw[Term, Ty]:
    args: tuple[core_uid.Uid, list[common_rewrite_rule.RewriteRule[Term, Ty]]]

def OpSetThmAsRw_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> OpSetThmAsRw[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    cargs = (core_uid.Uid_of_twine(d=d, off=_tw_args[0]), [common_rewrite_rule.RewriteRule_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=_tw_args[1])])
    return OpSetThmAsRw(args=cargs)

@dataclass(slots=True, frozen=True)
class OpSetThmAsFc[Term, Ty]:
    args: tuple[core_uid.Uid, list[common_instantiation_rule.InstantiationRule[Term, Ty]]]

def OpSetThmAsFc_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> OpSetThmAsFc[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    cargs = (core_uid.Uid_of_twine(d=d, off=_tw_args[0]), [common_instantiation_rule.InstantiationRule_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=_tw_args[1])])
    return OpSetThmAsFc(args=cargs)

@dataclass(slots=True, frozen=True)
class OpSetThmAsElim[Term, Ty]:
    args: tuple[core_uid.Uid, list[common_elimination_rule.EliminationRule[Term, Ty]]]

def OpSetThmAsElim_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> OpSetThmAsElim[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    cargs = (core_uid.Uid_of_twine(d=d, off=_tw_args[0]), [common_elimination_rule.EliminationRule_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=_tw_args[1])])
    return OpSetThmAsElim(args=cargs)

@dataclass(slots=True, frozen=True)
class OpSetThmAsGen[Term, Ty]:
    args: tuple[core_uid.Uid, common_instantiation_rule.InstantiationRule[Term, Ty]]

def OpSetThmAsGen_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> OpSetThmAsGen[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    cargs = (core_uid.Uid_of_twine(d=d, off=_tw_args[0]), common_instantiation_rule.InstantiationRule_of_twine(d=d, off=_tw_args[1], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))))
    return OpSetThmAsGen(args=cargs)

@dataclass(slots=True, frozen=True)
class OpAddInstantiationRule[Term, Ty]:
    arg: common_instantiation_rule.InstantiationRule[Term, Ty]

def OpAddInstantiationRule_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> OpAddInstantiationRule[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = common_instantiation_rule.InstantiationRule_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    return OpAddInstantiationRule(arg=arg)

@dataclass(slots=True, frozen=True)
class OpAddRuleSpecFcTriggers[Term, Ty]:
    args: tuple[core_uid.Uid, list[common_trigger.Trigger[Ty]]]

def OpAddRuleSpecFcTriggers_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> OpAddRuleSpecFcTriggers[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    cargs = (core_uid.Uid_of_twine(d=d, off=_tw_args[0]), [common_trigger.Trigger_of_twine(d=d, off=x, d0=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=_tw_args[1])])
    return OpAddRuleSpecFcTriggers(args=cargs)

@dataclass(slots=True, frozen=True)
class OpAddRuleSpecRw[Term, Ty]:
    args: tuple[core_uid.Uid, list[common_rewrite_rule.RewriteRule[Term, Ty]]]

def OpAddRuleSpecRw_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> OpAddRuleSpecRw[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    cargs = (core_uid.Uid_of_twine(d=d, off=_tw_args[0]), [common_rewrite_rule.RewriteRule_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=_tw_args[1])])
    return OpAddRuleSpecRw(args=cargs)

type DbOp[Term, Ty] = OpEnable[Term, Ty] | OpDisable[Term, Ty] | OpAddDecls[Term, Ty] | OpAddRw[Term, Ty] | OpAddFcTrigger[Term, Ty] | OpAddElim[Term, Ty] | OpAddGenTrigger[Term, Ty] | OpAddCountFun[Term, Ty] | OpSetAdmission[Term, Ty] | OpSetThmAsRw[Term, Ty] | OpSetThmAsFc[Term, Ty] | OpSetThmAsElim[Term, Ty] | OpSetThmAsGen[Term, Ty] | OpAddInstantiationRule[Term, Ty] | OpAddRuleSpecFcTriggers[Term, Ty] | OpAddRuleSpecRw[Term, Ty]

def DbOp_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> DbOp[Term, Ty]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return OpEnable_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return OpDisable_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return OpAddDecls_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return OpAddRw_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return OpAddFcTrigger_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return OpAddElim_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return OpAddGenTrigger_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=7, args=args):
             args = tuple(args)
             return OpAddCountFun_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=8, args=args):
             args = tuple(args)
             return OpSetAdmission_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=9, args=args):
             args = tuple(args)
             return OpSetThmAsRw_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=10, args=args):
             args = tuple(args)
             return OpSetThmAsFc_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=11, args=args):
             args = tuple(args)
             return OpSetThmAsElim_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=12, args=args):
             args = tuple(args)
             return OpSetThmAsGen_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=13, args=args):
             args = tuple(args)
             return OpAddInstantiationRule_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=14, args=args):
             args = tuple(args)
             return OpAddRuleSpecFcTriggers_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=15, args=args):
             args = tuple(args)
             return OpAddRuleSpecRw_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected DbOp, got invalid constructor {idx}')

