# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Type`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid_set as core_uid_set
from ..core import uid as core_uid
from ..core import ty_view as core_ty_view

__all__ = [
    "Var",
    "Clique",
    "Generation",
    "Type",
    "Ser",
    "Def",
]

# def Imandrax_api_mir.Type.var
type Var = core_uid.Uid

def Var_of_twine(d: twine.Decoder, off: int) -> Var:
    return core_uid.Uid_of_twine(d=d, off=off)

# def Imandrax_api_mir.Type.clique
type Clique = core_uid_set.UidSet

def Clique_of_twine(d: twine.Decoder, off: int) -> Clique:
    return core_uid_set.UidSet_of_twine(d=d, off=off)

# def Imandrax_api_mir.Type.generation
type Generation = int

def Generation_of_twine(d: twine.Decoder, off: int) -> Generation:
    return d.get_int(off=off)

# def Imandrax_api_mir.Type.t
@dataclass(slots=True, frozen=True)
class Type:
    view: core_ty_view.View[None, Var, Type]

@twine.cached(name="Imandrax_api_mir.Type.t")
def Type_of_twine(d: twine.Decoder, off: int) -> Type:
    x = core_ty_view.View_of_twine(d=d, off=off, d0=(lambda d, off: d.get_null(off=off)), d1=(lambda d, off: Var_of_twine(d=d, off=off)), d2=(lambda d, off: Type_of_twine(d=d, off=off))) # single unboxed field
    return Type(view=x)

# def Imandrax_api_mir.Type.ser
@dataclass(slots=True, frozen=True)
class Ser:
    view: core_ty_view.View[None, Var, Type]

def Ser_of_twine(d: twine.Decoder, off: int) -> Ser:
    x = core_ty_view.View_of_twine(d=d, off=off, d0=(lambda d, off: d.get_null(off=off)), d1=(lambda d, off: Var_of_twine(d=d, off=off)), d2=(lambda d, off: Type_of_twine(d=d, off=off))) # single unboxed field
    return Ser(view=x)

# def Imandrax_api_mir.Type.def
type Def = core_ty_view.Def[Type]

def Def_of_twine(d: twine.Decoder, off: int) -> Def:
    return core_ty_view.Def_of_twine(d=d, off=off, d0=(lambda d, off: Type_of_twine(d=d, off=off)))

