# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Term`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import type as mir_type
from ..core import uid as core_uid
from ..core import sub_anchor as core_sub_anchor
from ..core import const as core_const
from ..common import var as common_var
from ..common import applied_symbol as common_applied_symbol

__all__ = [
    "ViewConst",
    "ViewIf",
    "ViewApply",
    "ViewVar",
    "ViewSym",
    "ViewConstruct",
    "ViewDestruct",
    "ViewIsA",
    "ViewTuple",
    "ViewField",
    "ViewTupleField",
    "ViewRecord",
    "ViewCase",
    "ViewSequence",
    "View",
    "Generation",
    "Term",
    "Ser",
    "TermTerm",
]

# def Imandrax_api_mir.Term.view
@dataclass(slots=True, frozen=True)
class ViewConst[T, Ty]:
    arg: core_const.Const

def ViewConst_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ViewConst[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    arg = core_const.Const_of_twine(d=d, off=_tw_args[0])
    return ViewConst(arg=arg)

@dataclass(slots=True, frozen=True)
class ViewIf[T, Ty]:
    args: tuple[T, T, T]

def ViewIf_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ViewIf[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    cargs = (decode_T(d=d, off=_tw_args[0]), decode_T(d=d, off=_tw_args[1]), decode_T(d=d, off=_tw_args[2]))
    return ViewIf(args=cargs)

@dataclass(slots=True, frozen=True)
class ViewApply[T, Ty]:
    f: T
    l: list[T]


def ViewApply_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ViewApply[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    f = decode_T(d=d, off=_tw_args[0])
    l = [decode_T(d=d, off=x) for x in d.get_array(off=_tw_args[1])]
    return ViewApply(f=f, l=l)


@dataclass(slots=True, frozen=True)
class ViewVar[T, Ty]:
    arg: common_var.Var[Ty]

def ViewVar_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ViewVar[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    arg = common_var.Var_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Ty(d=d, off=off)))
    return ViewVar(arg=arg)

@dataclass(slots=True, frozen=True)
class ViewSym[T, Ty]:
    arg: common_applied_symbol.AppliedSymbol[Ty]

def ViewSym_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ViewSym[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    arg = common_applied_symbol.AppliedSymbol_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Ty(d=d, off=off)))
    return ViewSym(arg=arg)

@dataclass(slots=True, frozen=True)
class ViewConstruct[T, Ty]:
    c: common_applied_symbol.AppliedSymbol[Ty]
    args: list[T]
    labels: None | list[core_uid.Uid]


def ViewConstruct_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ViewConstruct[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    c = common_applied_symbol.AppliedSymbol_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Ty(d=d, off=off)))
    args = [decode_T(d=d, off=x) for x in d.get_array(off=_tw_args[1])]
    labels = twine.optional(d=d, off=_tw_args[2], d0=lambda d, off: [core_uid.Uid_of_twine(d=d, off=x) for x in d.get_array(off=off)])
    return ViewConstruct(c=c, args=args, labels=labels)


@dataclass(slots=True, frozen=True)
class ViewDestruct[T, Ty]:
    c: common_applied_symbol.AppliedSymbol[Ty]
    i: int
    t: T


def ViewDestruct_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ViewDestruct[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    c = common_applied_symbol.AppliedSymbol_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Ty(d=d, off=off)))
    i = d.get_int(off=_tw_args[1])
    t = decode_T(d=d, off=_tw_args[2])
    return ViewDestruct(c=c, i=i, t=t)


@dataclass(slots=True, frozen=True)
class ViewIsA[T, Ty]:
    c: common_applied_symbol.AppliedSymbol[Ty]
    t: T


def ViewIsA_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ViewIsA[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    c = common_applied_symbol.AppliedSymbol_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Ty(d=d, off=off)))
    t = decode_T(d=d, off=_tw_args[1])
    return ViewIsA(c=c, t=t)


@dataclass(slots=True, frozen=True)
class ViewTuple[T, Ty]:
    l: list[T]


def ViewTuple_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ViewTuple[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    l = [decode_T(d=d, off=x) for x in d.get_array(off=_tw_args[0])]
    return ViewTuple(l=l)


@dataclass(slots=True, frozen=True)
class ViewField[T, Ty]:
    f: common_applied_symbol.AppliedSymbol[Ty]
    t: T


def ViewField_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ViewField[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    f = common_applied_symbol.AppliedSymbol_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Ty(d=d, off=off)))
    t = decode_T(d=d, off=_tw_args[1])
    return ViewField(f=f, t=t)


@dataclass(slots=True, frozen=True)
class ViewTupleField[T, Ty]:
    i: int
    t: T


def ViewTupleField_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ViewTupleField[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    i = d.get_int(off=_tw_args[0])
    t = decode_T(d=d, off=_tw_args[1])
    return ViewTupleField(i=i, t=t)


@dataclass(slots=True, frozen=True)
class ViewRecord[T, Ty]:
    rows: list[tuple[common_applied_symbol.AppliedSymbol[Ty], T]]
    rest: None | T


def ViewRecord_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ViewRecord[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    rows = [(lambda tup: (common_applied_symbol.AppliedSymbol_of_twine(d=d, off=tup[0], d0=(lambda d, off: decode_Ty(d=d, off=off))), decode_T(d=d, off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=_tw_args[0])]
    rest = twine.optional(d=d, off=_tw_args[1], d0=lambda d, off: decode_T(d=d, off=off))
    return ViewRecord(rows=rows, rest=rest)


@dataclass(slots=True, frozen=True)
class ViewCase[T, Ty]:
    u: T
    cases: list[tuple[common_applied_symbol.AppliedSymbol[Ty], T]]
    default: None | T


def ViewCase_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ViewCase[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    u = decode_T(d=d, off=_tw_args[0])
    cases = [(lambda tup: (common_applied_symbol.AppliedSymbol_of_twine(d=d, off=tup[0], d0=(lambda d, off: decode_Ty(d=d, off=off))), decode_T(d=d, off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=_tw_args[1])]
    default = twine.optional(d=d, off=_tw_args[2], d0=lambda d, off: decode_T(d=d, off=off))
    return ViewCase(u=u, cases=cases, default=default)


@dataclass(slots=True, frozen=True)
class ViewSequence[T, Ty]:
    args: tuple[list[T], T]

def ViewSequence_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ViewSequence[T, Ty]:
    decode_T = d0
    decode_Ty = d1
    cargs = ([decode_T(d=d, off=x) for x in d.get_array(off=_tw_args[0])], decode_T(d=d, off=_tw_args[1]))
    return ViewSequence(args=cargs)

type View[T, Ty] = ViewConst[T, Ty] | ViewIf[T, Ty] | ViewApply[T, Ty] | ViewVar[T, Ty] | ViewSym[T, Ty] | ViewConstruct[T, Ty] | ViewDestruct[T, Ty] | ViewIsA[T, Ty] | ViewTuple[T, Ty] | ViewField[T, Ty] | ViewTupleField[T, Ty] | ViewRecord[T, Ty] | ViewCase[T, Ty] | ViewSequence[T, Ty]

def View_of_twine[T, Ty](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Ty], off: int) -> View[T, Ty]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return ViewConst_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return ViewIf_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return ViewApply_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return ViewVar_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return ViewSym_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return ViewConstruct_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return ViewDestruct_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=7, args=args):
             args = tuple(args)
             return ViewIsA_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=8, args=args):
             args = tuple(args)
             return ViewTuple_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=9, args=args):
             args = tuple(args)
             return ViewField_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=10, args=args):
             args = tuple(args)
             return ViewTupleField_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=11, args=args):
             args = tuple(args)
             return ViewRecord_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=12, args=args):
             args = tuple(args)
             return ViewCase_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=13, args=args):
             args = tuple(args)
             return ViewSequence_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected View, got invalid constructor {idx}')

# def Imandrax_api_mir.Term.generation
type Generation = int

def Generation_of_twine(d: twine.Decoder, off: int) -> Generation:
    return d.get_int(off=off)

# def Imandrax_api_mir.Term.t
@dataclass(slots=True, frozen=True)
class Term:
    view: View[Term, mir_type.Type]
    ty: mir_type.Type
    sub_anchor: None | core_sub_anchor.SubAnchor

@twine.cached(name="Imandrax_api_mir.Term.t")
def Term_of_twine(d: twine.Decoder, off: int) -> Term:
    fields = list(d.get_array(off=off))
    view = View_of_twine(d=d, off=fields[0], d0=(lambda d, off: Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))
    ty = mir_type.Type_of_twine(d=d, off=fields[1])
    sub_anchor = twine.optional(d=d, off=fields[2], d0=lambda d, off: core_sub_anchor.SubAnchor_of_twine(d=d, off=off))
    return Term(view=view, ty=ty, sub_anchor=sub_anchor)

# def Imandrax_api_mir.Term.ser
@dataclass(slots=True, frozen=True)
class Ser:
    view: View[Term, mir_type.Type]
    ty: mir_type.Type
    sub_anchor: None | core_sub_anchor.SubAnchor

def Ser_of_twine(d: twine.Decoder, off: int) -> Ser:
    fields = list(d.get_array(off=off))
    view = View_of_twine(d=d, off=fields[0], d0=(lambda d, off: Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))
    ty = mir_type.Type_of_twine(d=d, off=fields[1])
    sub_anchor = twine.optional(d=d, off=fields[2], d0=lambda d, off: core_sub_anchor.SubAnchor_of_twine(d=d, off=off))
    return Ser(view=view, ty=ty, sub_anchor=sub_anchor)

# def Imandrax_api_mir.Term.term
type TermTerm = Term

def TermTerm_of_twine(d: twine.Decoder, off: int) -> TermTerm:
    return Term_of_twine(d=d, off=off)

