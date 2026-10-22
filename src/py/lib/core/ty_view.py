# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.Ty_view`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid
from ..core import clique as core_clique
from ..core import builtin as core_builtin

__all__ = [
    "AdtRow",
    "RecRow",
    "DeclAlgebraic",
    "DeclRecord",
    "DeclAlias",
    "DeclSkolem",
    "DeclBuiltin",
    "DeclOther",
    "Decl",
    "ViewVar",
    "ViewArrow",
    "ViewTuple",
    "ViewConstr",
    "View",
    "Def",
]

# def Imandrax_api.Ty_view.adt_row
@dataclass(slots=True, frozen=True)
class AdtRow[Id, T]:
    c: Id
    labels: None | list[Id]
    args: list[T]
    doc: None | str

def AdtRow_of_twine[Id, T](d: twine.Decoder, d0: twine.DecoderFn[Id], d1: twine.DecoderFn[T], off: int) -> AdtRow[Id, T]:
    decode_Id = d0
    decode_T = d1
    fields = list(d.get_array(off=off))
    c = decode_Id(d=d, off=fields[0])
    labels = twine.optional(d=d, off=fields[1], d0=lambda d, off: [decode_Id(d=d, off=x) for x in d.get_array(off=off)])
    args = [decode_T(d=d, off=x) for x in d.get_array(off=fields[2])]
    doc = twine.optional(d=d, off=fields[3], d0=lambda d, off: d.get_str(off=off))
    return AdtRow(c=c, labels=labels, args=args, doc=doc)

# def Imandrax_api.Ty_view.rec_row
@dataclass(slots=True, frozen=True)
class RecRow[Id, T]:
    f: Id
    ty: T
    doc: None | str

def RecRow_of_twine[Id, T](d: twine.Decoder, d0: twine.DecoderFn[Id], d1: twine.DecoderFn[T], off: int) -> RecRow[Id, T]:
    decode_Id = d0
    decode_T = d1
    fields = list(d.get_array(off=off))
    f = decode_Id(d=d, off=fields[0])
    ty = decode_T(d=d, off=fields[1])
    doc = twine.optional(d=d, off=fields[2], d0=lambda d, off: d.get_str(off=off))
    return RecRow(f=f, ty=ty, doc=doc)

# def Imandrax_api.Ty_view.decl
@dataclass(slots=True, frozen=True)
class DeclAlgebraic[Id, T, Alias]:
    arg: list[AdtRow[Id, T]]

def DeclAlgebraic_of_twine[Id, T, Alias](d: twine.Decoder, d0: twine.DecoderFn[Id], d1: twine.DecoderFn[T], d2: twine.DecoderFn[Alias], _tw_args: tuple[int, ...]) -> DeclAlgebraic[Id, T, Alias]:
    decode_Id = d0
    decode_T = d1
    decode_Alias = d2
    arg = [AdtRow_of_twine(d=d, off=x, d0=(lambda d, off: decode_Id(d=d, off=off)), d1=(lambda d, off: decode_T(d=d, off=off))) for x in d.get_array(off=_tw_args[0])]
    return DeclAlgebraic(arg=arg)

@dataclass(slots=True, frozen=True)
class DeclRecord[Id, T, Alias]:
    arg: list[RecRow[Id, T]]

def DeclRecord_of_twine[Id, T, Alias](d: twine.Decoder, d0: twine.DecoderFn[Id], d1: twine.DecoderFn[T], d2: twine.DecoderFn[Alias], _tw_args: tuple[int, ...]) -> DeclRecord[Id, T, Alias]:
    decode_Id = d0
    decode_T = d1
    decode_Alias = d2
    arg = [RecRow_of_twine(d=d, off=x, d0=(lambda d, off: decode_Id(d=d, off=off)), d1=(lambda d, off: decode_T(d=d, off=off))) for x in d.get_array(off=_tw_args[0])]
    return DeclRecord(arg=arg)

@dataclass(slots=True, frozen=True)
class DeclAlias[Id, T, Alias]:
    target: Alias
    reexport_def: None | Decl[Id, T, Alias]


def DeclAlias_of_twine[Id, T, Alias](d: twine.Decoder, d0: twine.DecoderFn[Id], d1: twine.DecoderFn[T], d2: twine.DecoderFn[Alias], _tw_args: tuple[int, ...]) -> DeclAlias[Id, T, Alias]:
    decode_Id = d0
    decode_T = d1
    decode_Alias = d2
    target = decode_Alias(d=d, off=_tw_args[0])
    reexport_def = twine.optional(d=d, off=_tw_args[1], d0=lambda d, off: Decl_of_twine(d=d, off=off, d0=(lambda d, off: decode_Id(d=d, off=off)), d1=(lambda d, off: decode_T(d=d, off=off)), d2=(lambda d, off: decode_Alias(d=d, off=off))))
    return DeclAlias(target=target, reexport_def=reexport_def)


@dataclass(slots=True, frozen=True)
class DeclSkolem[Id, T, Alias]:
    pass

@dataclass(slots=True, frozen=True)
class DeclBuiltin[Id, T, Alias]:
    arg: core_builtin.Ty

def DeclBuiltin_of_twine[Id, T, Alias](d: twine.Decoder, d0: twine.DecoderFn[Id], d1: twine.DecoderFn[T], d2: twine.DecoderFn[Alias], _tw_args: tuple[int, ...]) -> DeclBuiltin[Id, T, Alias]:
    decode_Id = d0
    decode_T = d1
    decode_Alias = d2
    arg = core_builtin.Ty_of_twine(d=d, off=_tw_args[0])
    return DeclBuiltin(arg=arg)

@dataclass(slots=True, frozen=True)
class DeclOther[Id, T, Alias]:
    pass

type Decl[Id, T, Alias] = DeclAlgebraic[Id, T, Alias] | DeclRecord[Id, T, Alias] | DeclAlias[Id, T, Alias] | DeclSkolem[Id, T, Alias] | DeclBuiltin[Id, T, Alias] | DeclOther[Id, T, Alias]

def Decl_of_twine[Id, T, Alias](d: twine.Decoder, d0: twine.DecoderFn[Id], d1: twine.DecoderFn[T], d2: twine.DecoderFn[Alias], off: int) -> Decl[Id, T, Alias]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return DeclAlgebraic_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return DeclRecord_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return DeclAlias_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2)
         case twine.Constructor(idx=3, args=args):
             return DeclSkolem[Id, T, Alias]()
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return DeclBuiltin_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2)
         case twine.Constructor(idx=5, args=args):
             return DeclOther[Id, T, Alias]()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Decl, got invalid constructor {idx}')

# def Imandrax_api.Ty_view.view
@dataclass(slots=True, frozen=True)
class ViewVar[Lbl, Var, T]:
    arg: Var

def ViewVar_of_twine[Lbl, Var, T](d: twine.Decoder, d0: twine.DecoderFn[Lbl], d1: twine.DecoderFn[Var], d2: twine.DecoderFn[T], _tw_args: tuple[int, ...]) -> ViewVar[Lbl, Var, T]:
    decode_Lbl = d0
    decode_Var = d1
    decode_T = d2
    arg = decode_Var(d=d, off=_tw_args[0])
    return ViewVar(arg=arg)

@dataclass(slots=True, frozen=True)
class ViewArrow[Lbl, Var, T]:
    args: tuple[Lbl, T, T]

def ViewArrow_of_twine[Lbl, Var, T](d: twine.Decoder, d0: twine.DecoderFn[Lbl], d1: twine.DecoderFn[Var], d2: twine.DecoderFn[T], _tw_args: tuple[int, ...]) -> ViewArrow[Lbl, Var, T]:
    decode_Lbl = d0
    decode_Var = d1
    decode_T = d2
    cargs = (decode_Lbl(d=d, off=_tw_args[0]), decode_T(d=d, off=_tw_args[1]), decode_T(d=d, off=_tw_args[2]))
    return ViewArrow(args=cargs)

@dataclass(slots=True, frozen=True)
class ViewTuple[Lbl, Var, T]:
    arg: list[T]

def ViewTuple_of_twine[Lbl, Var, T](d: twine.Decoder, d0: twine.DecoderFn[Lbl], d1: twine.DecoderFn[Var], d2: twine.DecoderFn[T], _tw_args: tuple[int, ...]) -> ViewTuple[Lbl, Var, T]:
    decode_Lbl = d0
    decode_Var = d1
    decode_T = d2
    arg = [decode_T(d=d, off=x) for x in d.get_array(off=_tw_args[0])]
    return ViewTuple(arg=arg)

@dataclass(slots=True, frozen=True)
class ViewConstr[Lbl, Var, T]:
    args: tuple[core_uid.Uid, list[T]]

def ViewConstr_of_twine[Lbl, Var, T](d: twine.Decoder, d0: twine.DecoderFn[Lbl], d1: twine.DecoderFn[Var], d2: twine.DecoderFn[T], _tw_args: tuple[int, ...]) -> ViewConstr[Lbl, Var, T]:
    decode_Lbl = d0
    decode_Var = d1
    decode_T = d2
    cargs = (core_uid.Uid_of_twine(d=d, off=_tw_args[0]), [decode_T(d=d, off=x) for x in d.get_array(off=_tw_args[1])])
    return ViewConstr(args=cargs)

type View[Lbl, Var, T] = ViewVar[Lbl, Var, T] | ViewArrow[Lbl, Var, T] | ViewTuple[Lbl, Var, T] | ViewConstr[Lbl, Var, T]

def View_of_twine[Lbl, Var, T](d: twine.Decoder, d0: twine.DecoderFn[Lbl], d1: twine.DecoderFn[Var], d2: twine.DecoderFn[T], off: int) -> View[Lbl, Var, T]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return ViewVar_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return ViewArrow_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return ViewTuple_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return ViewConstr_of_twine(d=d, _tw_args=args, d0=d0, d1=d1, d2=d2)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected View, got invalid constructor {idx}')

# def Imandrax_api.Ty_view.def_poly
@dataclass(slots=True, frozen=True)
class Def[Ty]:
    name: core_uid.Uid
    params: list[core_uid.Uid]
    decl: Decl[core_uid.Uid, Ty, typing.Never]
    clique: None | core_clique.Clique
    timeout: None | int

def Def_of_twine[Ty](d: twine.Decoder, d0: twine.DecoderFn[Ty], off: int) -> Def[Ty]:
    decode_Ty = d0
    fields = list(d.get_array(off=off))
    name = core_uid.Uid_of_twine(d=d, off=fields[0])
    params = [core_uid.Uid_of_twine(d=d, off=x) for x in d.get_array(off=fields[1])]
    decl = Decl_of_twine(d=d, off=fields[2], d0=(lambda d, off: core_uid.Uid_of_twine(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)), d2=(lambda d, off: _rt.decode_void(d=d, off=off)))
    clique = twine.optional(d=d, off=fields[3], d0=lambda d, off: core_clique.Clique_of_twine(d=d, off=off))
    timeout = twine.optional(d=d, off=fields[4], d0=lambda d, off: d.get_int(off=off))
    return Def(name=name, params=params, decl=decl, clique=clique, timeout=timeout)

