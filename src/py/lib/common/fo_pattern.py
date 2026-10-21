# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Fo_pattern`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid
from ..core import const as core_const
from ..common import var as common_var
from ..common import applied_symbol as common_applied_symbol

__all__ = [
    "FO_Any",
    "FO_Bool",
    "FO_Const",
    "FO_Var",
    "FO_App",
    "FO_Cstor",
    "FO_Destruct",
    "FO_IsA",
    "View",
    "FoPattern",
]

# def Imandrax_api_common.Fo_pattern.view
@dataclass(slots=True, frozen=True)
class FO_Any[T, Ty]:
    pass

@dataclass(slots=True, frozen=True)
class FO_Bool[T, Ty]:
    arg: bool

def FO_Bool_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> FO_Bool[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    arg = d.get_bool(off=_tw_args[0])
    return FO_Bool(arg=arg)

@dataclass(slots=True, frozen=True)
class FO_Const[T, Ty]:
    arg: core_const.Const

def FO_Const_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> FO_Const[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    arg = core_const.Const_of_twine(d=d, off=_tw_args[0])
    return FO_Const(arg=arg)

@dataclass(slots=True, frozen=True)
class FO_Var[T, Ty]:
    arg: common_var.Var[Ty]

def FO_Var_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> FO_Var[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    arg = common_var.Var_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Ty(d=d, off=off)))
    return FO_Var(arg=arg)

@dataclass(slots=True, frozen=True)
class FO_App[T, Ty]:
    args: tuple[common_applied_symbol.AppliedSymbol[Ty], list[T]]

def FO_App_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> FO_App[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    cargs = (common_applied_symbol.AppliedSymbol_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Ty(d=d, off=off))), [decode_T(d=d, off=x) for x in d.get_array(off=_tw_args[1])])
    return FO_App(args=cargs)

@dataclass(slots=True, frozen=True)
class FO_Cstor[T, Ty]:
    c: None | common_applied_symbol.AppliedSymbol[Ty]
    args: list[T]
    labels: None | list[core_uid.Uid]


def FO_Cstor_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> FO_Cstor[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    c = twine.optional(d=d, off=_tw_args[0], d0=lambda d, off: common_applied_symbol.AppliedSymbol_of_twine(d=d, off=off, d0=(lambda d, off: decode_Ty(d=d, off=off))))
    args = [decode_T(d=d, off=x) for x in d.get_array(off=_tw_args[1])]
    labels = twine.optional(d=d, off=_tw_args[2], d0=lambda d, off: [core_uid.Uid_of_twine(d=d, off=x) for x in d.get_array(off=off)])
    return FO_Cstor(c=c, args=args, labels=labels)


@dataclass(slots=True, frozen=True)
class FO_Destruct[T, Ty]:
    c: None | common_applied_symbol.AppliedSymbol[Ty]
    i: int
    u: T


def FO_Destruct_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> FO_Destruct[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    c = twine.optional(d=d, off=_tw_args[0], d0=lambda d, off: common_applied_symbol.AppliedSymbol_of_twine(d=d, off=off, d0=(lambda d, off: decode_Ty(d=d, off=off))))
    i = d.get_int(off=_tw_args[1])
    u = decode_T(d=d, off=_tw_args[2])
    return FO_Destruct(c=c, i=i, u=u)


@dataclass(slots=True, frozen=True)
class FO_IsA[T, Ty]:
    c: common_applied_symbol.AppliedSymbol[Ty]
    u: T


def FO_IsA_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> FO_IsA[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    c = common_applied_symbol.AppliedSymbol_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Ty(d=d, off=off)))
    u = decode_T(d=d, off=_tw_args[1])
    return FO_IsA(c=c, u=u)


type View[T, Ty] = FO_Any[T, Ty] | FO_Bool[T, Ty] | FO_Const[T, Ty] | FO_Var[T, Ty] | FO_App[T, Ty] | FO_Cstor[T, Ty] | FO_Destruct[T, Ty] | FO_IsA[T, Ty]

def View_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], off: int) -> View[T, Ty]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return FO_Any[T, Ty]()
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return FO_Bool_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return FO_Const_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return FO_Var_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return FO_App_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return FO_Cstor_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return FO_Destruct_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=7, args=args):
             args = tuple(args)
             return FO_IsA_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected View, got invalid constructor {idx}')

# def Imandrax_api_common.Fo_pattern.t_poly
@dataclass(slots=True, frozen=True)
class FoPattern[Ty]:
    view: View[FoPattern[Ty], Ty]
    ty: Ty

def FoPattern_of_twine[Ty](d: twine.Decoder, d0: twine.DecoderFn[Ty], off: int) -> FoPattern[Ty]:
    decode_Ty = d0
    fields = list(d.get_array(off=off))
    view = View_of_twine(d=d, off=fields[0], d0=(lambda d, off: FoPattern_of_twine(d=d, off=off, d0=(lambda d, off: decode_Ty(d=d, off=off)))), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    ty = decode_Ty(d=d, off=fields[1])
    return FoPattern(view=view, ty=ty)

