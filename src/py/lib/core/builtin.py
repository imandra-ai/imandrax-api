# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.Builtin`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid
from ..core import builtin_data as core_builtin_data

__all__ = [
    "Fun",
    "Ty",
]

# def Imandrax_api.Builtin.Fun.t
@dataclass(slots=True, frozen=True)
class Fun:
    id: core_uid.Uid
    kind: core_builtin_data.Kind
    lassoc: bool
    commutative: bool
    connective: bool

def Fun_of_twine(d: twine.Decoder, off: int) -> Fun:
    fields = list(d.get_array(off=off))
    id = core_uid.Uid_of_twine(d=d, off=fields[0])
    kind = core_builtin_data.Kind_of_twine(d=d, off=fields[1])
    lassoc = d.get_bool(off=fields[2])
    commutative = d.get_bool(off=fields[3])
    connective = d.get_bool(off=fields[4])
    return Fun(id=id, kind=kind, lassoc=lassoc, commutative=commutative, connective=connective)

# def Imandrax_api.Builtin.Ty.t
@dataclass(slots=True, frozen=True)
class Ty:
    id: core_uid.Uid
    kind: core_builtin_data.Kind

def Ty_of_twine(d: twine.Decoder, off: int) -> Ty:
    fields = list(d.get_array(off=off))
    id = core_uid.Uid_of_twine(d=d, off=fields[0])
    kind = core_builtin_data.Kind_of_twine(d=d, off=fields[1])
    return Ty(id=id, kind=kind)

