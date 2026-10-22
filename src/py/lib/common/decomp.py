# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Decomp`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid_set as core_uid_set
from ..core import uid as core_uid

__all__ = [
    "LiftBoolDefault",
    "LiftBoolNestedEqualities",
    "LiftBoolEqualities",
    "LiftBoolAll",
    "LiftBool",
    "Decomp",
]

# def Imandrax_api_common.Decomp.lift_bool
@dataclass(slots=True, frozen=True)
class LiftBoolDefault:
    pass

@dataclass(slots=True, frozen=True)
class LiftBoolNestedEqualities:
    pass

@dataclass(slots=True, frozen=True)
class LiftBoolEqualities:
    pass

@dataclass(slots=True, frozen=True)
class LiftBoolAll:
    pass

type LiftBool = LiftBoolDefault | LiftBoolNestedEqualities | LiftBoolEqualities | LiftBoolAll

def LiftBool_of_twine(d: twine.Decoder, off: int) -> LiftBool:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return LiftBoolDefault()
         case twine.Constructor(idx=1, args=args):
             return LiftBoolNestedEqualities()
         case twine.Constructor(idx=2, args=args):
             return LiftBoolEqualities()
         case twine.Constructor(idx=3, args=args):
             return LiftBoolAll()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected LiftBool, got invalid constructor {idx}')

# def Imandrax_api_common.Decomp.t_
@dataclass(slots=True, frozen=True)
class Decomp:
    f_id: core_uid.Uid
    assuming: None | core_uid.Uid
    basis: core_uid_set.UidSet
    rule_specs: core_uid_set.UidSet
    ctx_simp: bool
    lift_bool: LiftBool
    prune: bool

def Decomp_of_twine(d: twine.Decoder, off: int) -> Decomp:
    fields = list(d.get_array(off=off))
    f_id = core_uid.Uid_of_twine(d=d, off=fields[0])
    assuming = twine.optional(d=d, off=fields[1], d0=lambda d, off: core_uid.Uid_of_twine(d=d, off=off))
    basis = core_uid_set.UidSet_of_twine(d=d, off=fields[2])
    rule_specs = core_uid_set.UidSet_of_twine(d=d, off=fields[3])
    ctx_simp = d.get_bool(off=fields[4])
    lift_bool = LiftBool_of_twine(d=d, off=fields[5])
    prune = d.get_bool(off=fields[6])
    return Decomp(f_id=f_id, assuming=assuming, basis=basis, rule_specs=rule_specs, ctx_simp=ctx_simp, lift_bool=lift_bool, prune=prune)

