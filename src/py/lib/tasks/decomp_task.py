# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_tasks.Decomp_task`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import type as mir_type
from ..mir import term as mir_term
from ..core import anchor as core_anchor
from ..common import fun_decomp as common_fun_decomp
from ..common import decomp as common_decomp
from ..common import db_ser as common_db_ser

__all__ = [
    "EnumerationStyleAdditive",
    "EnumerationStyleMultiplicative",
    "EnumerationStyle",
    "DecompDecomp",
    "DecompTerm",
    "DecompReturn",
    "DecompPrune",
    "DecompMerge",
    "DecompCompoundMerge",
    "DecompCombine",
    "DecompGet",
    "DecompLet",
    "DecompEnumerate",
    "Decomp",
    "DecompTask",
    "MirDecomp",
    "Mir",
]

# def Imandrax_api_tasks.Decomp_task.enumeration_style
@dataclass(slots=True, frozen=True)
class EnumerationStyleAdditive:
    pass

@dataclass(slots=True, frozen=True)
class EnumerationStyleMultiplicative:
    pass

type EnumerationStyle = EnumerationStyleAdditive | EnumerationStyleMultiplicative

def EnumerationStyle_of_twine(d: twine.Decoder, off: int) -> EnumerationStyle:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return EnumerationStyleAdditive()
         case twine.Constructor(idx=1, args=args):
             return EnumerationStyleMultiplicative()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected EnumerationStyle, got invalid constructor {idx}')

# def Imandrax_api_tasks.Decomp_task.decomp_poly
@dataclass(slots=True, frozen=True)
class DecompDecomp[Term, Ty]:
    arg: common_decomp.Decomp

def DecompDecomp_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> DecompDecomp[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = common_decomp.Decomp_of_twine(d=d, off=_tw_args[0])
    return DecompDecomp(arg=arg)

@dataclass(slots=True, frozen=True)
class DecompTerm[Term, Ty]:
    arg: Term

def DecompTerm_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> DecompTerm[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = decode_Term(d=d, off=_tw_args[0])
    return DecompTerm(arg=arg)

@dataclass(slots=True, frozen=True)
class DecompReturn[Term, Ty]:
    arg: common_fun_decomp.FunDecomp[Term, Ty]

def DecompReturn_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> DecompReturn[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = common_fun_decomp.FunDecomp_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    return DecompReturn(arg=arg)

@dataclass(slots=True, frozen=True)
class DecompPrune[Term, Ty]:
    arg: Decomp[Term, Ty]

def DecompPrune_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> DecompPrune[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = Decomp_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    return DecompPrune(arg=arg)

@dataclass(slots=True, frozen=True)
class DecompMerge[Term, Ty]:
    args: tuple[Decomp[Term, Ty], Decomp[Term, Ty]]

def DecompMerge_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> DecompMerge[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    cargs = (Decomp_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))), Decomp_of_twine(d=d, off=_tw_args[1], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))))
    return DecompMerge(args=cargs)

@dataclass(slots=True, frozen=True)
class DecompCompoundMerge[Term, Ty]:
    args: tuple[Decomp[Term, Ty], Decomp[Term, Ty]]

def DecompCompoundMerge_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> DecompCompoundMerge[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    cargs = (Decomp_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))), Decomp_of_twine(d=d, off=_tw_args[1], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))))
    return DecompCompoundMerge(args=cargs)

@dataclass(slots=True, frozen=True)
class DecompCombine[Term, Ty]:
    arg: Decomp[Term, Ty]

def DecompCombine_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> DecompCombine[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = Decomp_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    return DecompCombine(arg=arg)

@dataclass(slots=True, frozen=True)
class DecompGet[Term, Ty]:
    arg: str

def DecompGet_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> DecompGet[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = d.get_str(off=_tw_args[0])
    return DecompGet(arg=arg)

@dataclass(slots=True, frozen=True)
class DecompLet[Term, Ty]:
    bindings: list[tuple[str, Decomp[Term, Ty]]]
    and_then: Decomp[Term, Ty]


def DecompLet_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> DecompLet[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    bindings = [(lambda tup: (d.get_str(off=tup[0]), Decomp_of_twine(d=d, off=tup[1], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))))(tuple(d.get_array(off=x))) for x in d.get_array(off=_tw_args[0])]
    and_then = Decomp_of_twine(d=d, off=_tw_args[1], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    return DecompLet(bindings=bindings, and_then=and_then)


@dataclass(slots=True, frozen=True)
class DecompEnumerate[Term, Ty]:
    d_f: Decomp[Term, Ty]
    ds: list[Decomp[Term, Ty]]
    style: None | EnumerationStyle


def DecompEnumerate_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> DecompEnumerate[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    d_f = Decomp_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    ds = [Decomp_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=_tw_args[1])]
    style = twine.optional(d=d, off=_tw_args[2], d0=lambda d, off: EnumerationStyle_of_twine(d=d, off=off))
    return DecompEnumerate(d_f=d_f, ds=ds, style=style)


type Decomp[Term, Ty] = DecompDecomp[Term, Ty] | DecompTerm[Term, Ty] | DecompReturn[Term, Ty] | DecompPrune[Term, Ty] | DecompMerge[Term, Ty] | DecompCompoundMerge[Term, Ty] | DecompCombine[Term, Ty] | DecompGet[Term, Ty] | DecompLet[Term, Ty] | DecompEnumerate[Term, Ty]

def Decomp_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> Decomp[Term, Ty]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return DecompDecomp_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return DecompTerm_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return DecompReturn_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return DecompPrune_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return DecompMerge_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return DecompCompoundMerge_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return DecompCombine_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=7, args=args):
             args = tuple(args)
             return DecompGet_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=8, args=args):
             args = tuple(args)
             return DecompLet_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=9, args=args):
             args = tuple(args)
             return DecompEnumerate_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Decomp, got invalid constructor {idx}')

# def Imandrax_api_tasks.Decomp_task.t_poly
@dataclass(slots=True, frozen=True)
class DecompTask[Term, Ty]:
    db: common_db_ser.DbSer[Term, Ty]
    decomp: Decomp[Term, Ty]
    anchor: core_anchor.Anchor
    timeout: None | int

def DecompTask_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> DecompTask[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    db = common_db_ser.DbSer_of_twine(d=d, off=fields[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    decomp = Decomp_of_twine(d=d, off=fields[1], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    anchor = core_anchor.Anchor_of_twine(d=d, off=fields[2])
    timeout = twine.optional(d=d, off=fields[3], d0=lambda d, off: d.get_int(off=off))
    return DecompTask(db=db, decomp=decomp, anchor=anchor, timeout=timeout)

# def Imandrax_api_tasks.Decomp_task.Mir.decomp
type MirDecomp = Decomp[mir_term.Term, mir_type.Type]

def MirDecomp_of_twine(d: twine.Decoder, off: int) -> MirDecomp:
    return Decomp_of_twine(d=d, off=off, d0=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

# def Imandrax_api_tasks.Decomp_task.Mir.t
type Mir = DecompTask[mir_term.Term, mir_type.Type]

def Mir_of_twine(d: twine.Decoder, off: int) -> Mir:
    return DecompTask_of_twine(d=d, off=off, d0=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

