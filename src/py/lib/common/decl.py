# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Decl`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import ty_view as core_ty_view
from ..common import verify as common_verify
from ..common import theorem as common_theorem
from ..common import rule_spec as common_rule_spec
from ..common import fun_def as common_fun_def

__all__ = [
    "Fun",
    "Ty",
    "Theorem",
    "RuleSpec",
    "Verify",
    "Decl",
]

# def Imandrax_api_common.Decl.t_poly
@dataclass(slots=True, frozen=True)
class Fun[Term, _Ty]:
    arg: common_fun_def.FunDef[Term, _Ty]

def Fun_of_twine[Term, _Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[_Ty], _tw_args: tuple[int, ...]) -> Fun[Term, _Ty]:
    decode_Term = d0
    decode__Ty = d1
    arg = common_fun_def.FunDef_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode__Ty(d=d, off=off)))
    return Fun(arg=arg)

@dataclass(slots=True, frozen=True)
class Ty[Term, _Ty]:
    arg: core_ty_view.Def[_Ty]

def Ty_of_twine[Term, _Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[_Ty], _tw_args: tuple[int, ...]) -> Ty[Term, _Ty]:
    decode_Term = d0
    decode__Ty = d1
    arg = core_ty_view.Def_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode__Ty(d=d, off=off)))
    return Ty(arg=arg)

@dataclass(slots=True, frozen=True)
class Theorem[Term, _Ty]:
    arg: common_theorem.Theorem[Term, _Ty]

def Theorem_of_twine[Term, _Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[_Ty], _tw_args: tuple[int, ...]) -> Theorem[Term, _Ty]:
    decode_Term = d0
    decode__Ty = d1
    arg = common_theorem.Theorem_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode__Ty(d=d, off=off)))
    return Theorem(arg=arg)

@dataclass(slots=True, frozen=True)
class RuleSpec[Term, _Ty]:
    arg: common_rule_spec.RuleSpec[Term, _Ty]

def RuleSpec_of_twine[Term, _Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[_Ty], _tw_args: tuple[int, ...]) -> RuleSpec[Term, _Ty]:
    decode_Term = d0
    decode__Ty = d1
    arg = common_rule_spec.RuleSpec_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode__Ty(d=d, off=off)))
    return RuleSpec(arg=arg)

@dataclass(slots=True, frozen=True)
class Verify[Term, _Ty]:
    arg: common_verify.Verify[Term, _Ty]

def Verify_of_twine[Term, _Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[_Ty], _tw_args: tuple[int, ...]) -> Verify[Term, _Ty]:
    decode_Term = d0
    decode__Ty = d1
    arg = common_verify.Verify_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode__Ty(d=d, off=off)))
    return Verify(arg=arg)

type Decl[Term, _Ty] = Fun[Term, _Ty] | Ty[Term, _Ty] | Theorem[Term, _Ty] | RuleSpec[Term, _Ty] | Verify[Term, _Ty]

def Decl_of_twine[Term, _Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[_Ty], off: int) -> Decl[Term, _Ty]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Fun_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Ty_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return Theorem_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return RuleSpec_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return Verify_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Decl, got invalid constructor {idx}')

