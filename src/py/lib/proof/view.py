# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_proof.View`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..proof import var_poly as proof_var_poly
from ..proof import arg as proof_arg
from ..core import uid as core_uid

__all__ = [
    "T_Assume",
    "T_Subst",
    "T_Deduction",
    "T_Rule",
    "View",
]

# def Imandrax_api_proof.View.t
@dataclass(slots=True, frozen=True)
class T_Assume[Term, Ty, Proof]:
    pass

@dataclass(slots=True, frozen=True)
class T_Subst[Term, Ty, Proof]:
    t_subst: list[tuple[proof_var_poly.VarPoly[Ty], Term]]
    ty_subst: list[tuple[core_uid.Uid, Ty]]
    premise: Proof


def T_Subst_of_twine[Term, Ty, Proof](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Proof], _tw_args: tuple[int, ...]) -> T_Subst[Term, Ty, Proof]:
    decode_Term = d0
    decode_Ty = d1
    decode_Proof = d2
    t_subst = [(lambda tup: (proof_var_poly.VarPoly_of_twine(d=d, off=tup[0], d0=(lambda d, off: decode_Ty(d=d, off=off))), decode_Term(d=d, off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=_tw_args[0])]
    ty_subst = [(lambda tup: (core_uid.Uid_of_twine(d=d, off=tup[0]), decode_Ty(d=d, off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=_tw_args[1])]
    premise = decode_Proof(d=d, off=_tw_args[2])
    return T_Subst(t_subst=t_subst, ty_subst=ty_subst, premise=premise)


@dataclass(slots=True, frozen=True)
class T_Deduction[Term, Ty, Proof]:
    premises: list[tuple[str, list[Proof]]]


def T_Deduction_of_twine[Term, Ty, Proof](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Proof], _tw_args: tuple[int, ...]) -> T_Deduction[Term, Ty, Proof]:
    decode_Term = d0
    decode_Ty = d1
    decode_Proof = d2
    premises = [(lambda tup: (d.get_str(off=tup[0]), [decode_Proof(d=d, off=x) for x in d.get_array(off=tup[1])]))(tuple(d.get_array(off=x))) for x in d.get_array(off=_tw_args[0])]
    return T_Deduction(premises=premises)


@dataclass(slots=True, frozen=True)
class T_Rule[Term, Ty, Proof]:
    rule: str
    args: list[proof_arg.Arg[Term, Ty]]


def T_Rule_of_twine[Term, Ty, Proof](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Proof], _tw_args: tuple[int, ...]) -> T_Rule[Term, Ty, Proof]:
    decode_Term = d0
    decode_Ty = d1
    decode_Proof = d2
    rule = d.get_str(off=_tw_args[0])
    args = [proof_arg.Arg_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=_tw_args[1])]
    return T_Rule(rule=rule, args=args)


type View[Term, Ty, Proof] = T_Assume[Term, Ty, Proof] | T_Subst[Term, Ty, Proof] | T_Deduction[Term, Ty, Proof] | T_Rule[Term, Ty, Proof]

def View_of_twine[Term, Ty, Proof](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], d2: twine.DecoderFn[Proof], off: int) -> View[Term, Ty, Proof]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return T_Assume[Term, Ty, Proof]()
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return T_Subst_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return T_Deduction_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return T_Rule_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected View, got invalid constructor {idx}')

