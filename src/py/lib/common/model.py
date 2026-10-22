# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Model`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid
from ..common import var as common_var
from ..common import applied_symbol as common_applied_symbol

__all__ = [
    "TyDefTyFinite",
    "TyDefTyAliasUnit",
    "TyDef",
    "Fi",
    "Model",
]

# def Imandrax_api_common.Model.ty_def
@dataclass(slots=True, frozen=True)
class TyDefTyFinite[Term, Ty]:
    arg: list[Term]

def TyDefTyFinite_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> TyDefTyFinite[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = [decode_Term(d=d, off=x) for x in d.get_array(off=_tw_args[0])]
    return TyDefTyFinite(arg=arg)

@dataclass(slots=True, frozen=True)
class TyDefTyAliasUnit[Term, Ty]:
    arg: Ty

def TyDefTyAliasUnit_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> TyDefTyAliasUnit[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = decode_Ty(d=d, off=_tw_args[0])
    return TyDefTyAliasUnit(arg=arg)

type TyDef[Term, Ty] = TyDefTyFinite[Term, Ty] | TyDefTyAliasUnit[Term, Ty]

def TyDef_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> TyDef[Term, Ty]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return TyDefTyFinite_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return TyDefTyAliasUnit_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected TyDef, got invalid constructor {idx}')

# def Imandrax_api_common.Model.fi
@dataclass(slots=True, frozen=True)
class Fi[Term, Ty]:
    fi_args: list[common_var.Var[Ty]]
    fi_ty_ret: Ty
    fi_cases: list[tuple[list[Term], Term]]
    fi_else: Term

def Fi_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> Fi[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    fi_args = [common_var.Var_of_twine(d=d, off=x, d0=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=fields[0])]
    fi_ty_ret = decode_Ty(d=d, off=fields[1])
    fi_cases = [(lambda tup: ([decode_Term(d=d, off=x) for x in d.get_array(off=tup[0])], decode_Term(d=d, off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[2])]
    fi_else = decode_Term(d=d, off=fields[3])
    return Fi(fi_args=fi_args, fi_ty_ret=fi_ty_ret, fi_cases=fi_cases, fi_else=fi_else)

# def Imandrax_api_common.Model.t_poly
@dataclass(slots=True, frozen=True)
class Model[Term, Ty]:
    tys: list[tuple[Ty, TyDef[Term, Ty]]]
    consts: list[tuple[common_applied_symbol.AppliedSymbol[Ty], Term]]
    funs: list[tuple[common_applied_symbol.AppliedSymbol[Ty], Fi[Term, Ty]]]
    representable: bool
    completed: bool
    ty_subst: list[tuple[core_uid.Uid, Ty]]

def Model_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> Model[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    tys = [(lambda tup: (decode_Ty(d=d, off=tup[0]), TyDef_of_twine(d=d, off=tup[1], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[0])]
    consts = [(lambda tup: (common_applied_symbol.AppliedSymbol_of_twine(d=d, off=tup[0], d0=(lambda d, off: decode_Ty(d=d, off=off))), decode_Term(d=d, off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[1])]
    funs = [(lambda tup: (common_applied_symbol.AppliedSymbol_of_twine(d=d, off=tup[0], d0=(lambda d, off: decode_Ty(d=d, off=off))), Fi_of_twine(d=d, off=tup[1], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[2])]
    representable = d.get_bool(off=fields[3])
    completed = d.get_bool(off=fields[4])
    ty_subst = [(lambda tup: (core_uid.Uid_of_twine(d=d, off=tup[0]), decode_Ty(d=d, off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[5])]
    return Model(tys=tys, consts=consts, funs=funs, representable=representable, completed=completed, ty_subst=ty_subst)

