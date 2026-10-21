# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.Uid`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import cname as core_cname
from ..core import builtin_data as core_builtin_data

__all__ = [
    "GenKindLocal",
    "GenKindToBeRewritten",
    "GenKind",
    "ViewGenerative",
    "ViewPersistent",
    "ViewCname",
    "ViewBuiltin",
    "View",
    "Uid",
]

# def Imandrax_api.Uid.gen_kind
@dataclass(slots=True, frozen=True)
class GenKindLocal:
    pass

@dataclass(slots=True, frozen=True)
class GenKindToBeRewritten:
    pass

type GenKind = GenKindLocal | GenKindToBeRewritten

def GenKind_of_twine(d: twine.Decoder, off: int) -> GenKind:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return GenKindLocal()
         case twine.Constructor(idx=1, args=args):
             return GenKindToBeRewritten()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected GenKind, got invalid constructor {idx}')

# def Imandrax_api.Uid.view
@dataclass(slots=True, frozen=True)
class ViewGenerative:
    id: int
    gen_kind: GenKind


def ViewGenerative_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> ViewGenerative:
    id = d.get_int(off=_tw_args[0])
    gen_kind = GenKind_of_twine(d=d, off=_tw_args[1])
    return ViewGenerative(id=id, gen_kind=gen_kind)


@dataclass(slots=True, frozen=True)
class ViewPersistent:
    pass

@dataclass(slots=True, frozen=True)
class ViewCname:
    cname: core_cname.Cname


def ViewCname_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> ViewCname:
    cname = core_cname.Cname_of_twine(d=d, off=_tw_args[0])
    return ViewCname(cname=cname)


@dataclass(slots=True, frozen=True)
class ViewBuiltin:
    kind: core_builtin_data.Kind


def ViewBuiltin_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> ViewBuiltin:
    kind = core_builtin_data.Kind_of_twine(d=d, off=_tw_args[0])
    return ViewBuiltin(kind=kind)


type View = ViewGenerative | ViewPersistent | ViewCname | ViewBuiltin

def View_of_twine(d: twine.Decoder, off: int) -> View:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return ViewGenerative_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=1, args=args):
             return ViewPersistent()
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return ViewCname_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return ViewBuiltin_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected View, got invalid constructor {idx}')

# def Imandrax_api.Uid.t
@dataclass(slots=True, frozen=True)
class Uid:
    name: str
    view: View

def Uid_of_twine(d: twine.Decoder, off: int) -> Uid:
    fields = list(d.get_array(off=off))
    name = d.get_str(off=fields[0])
    view = View_of_twine(d=d, off=fields[1])
    return Uid(name=name, view=view)

