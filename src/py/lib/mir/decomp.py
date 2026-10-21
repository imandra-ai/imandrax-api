# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Decomp`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid_set as core_uid_set
from ..core import uid as core_uid
from ..common import decomp as common_decomp

__all__ = [
    "Decomp",
]

# def Imandrax_api_mir.Decomp.t
@dataclass(slots=True, frozen=True)
class Decomp:
    f_id: core_uid.Uid
    assuming: None | core_uid.Uid
    basis: core_uid_set.UidSet
    rule_specs: core_uid_set.UidSet
    ctx_simp: bool
    lift_bool: common_decomp.LiftBool
    prune: bool

def Decomp_of_twine(d: twine.Decoder, off: int) -> Decomp:
    fields = list(d.get_array(off=off))
    f_id = core_uid.Uid_of_twine(d=d, off=fields[0])
    assuming = twine.optional(d=d, off=fields[1], d0=lambda d, off: core_uid.Uid_of_twine(d=d, off=off))
    basis = core_uid_set.UidSet_of_twine(d=d, off=fields[2])
    rule_specs = core_uid_set.UidSet_of_twine(d=d, off=fields[3])
    ctx_simp = d.get_bool(off=fields[4])
    lift_bool = common_decomp.LiftBool_of_twine(d=d, off=fields[5])
    prune = d.get_bool(off=fields[6])
    return Decomp(f_id=f_id, assuming=assuming, basis=basis, rule_specs=rule_specs, ctx_simp=ctx_simp, lift_bool=lift_bool, prune=prune)

