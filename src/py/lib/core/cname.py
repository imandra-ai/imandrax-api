# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.Cname`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import chash as core_chash

__all__ = [
    "CnameT",
    "Cname",
]

# def Imandrax_api.Cname.t_
@dataclass(slots=True, frozen=True)
class CnameT:
    name: str
    chash: core_chash.Chash
    is_key: bool

def CnameT_of_twine(d: twine.Decoder, off: int) -> CnameT:
    fields = list(d.get_array(off=off))
    name = d.get_str(off=fields[0])
    chash = core_chash.Chash_of_twine(d=d, off=fields[1])
    is_key = d.get_bool(off=fields[2])
    return CnameT(name=name, chash=chash, is_key=is_key)

# def Imandrax_api.Cname.t
type Cname = _rt.WithTag6[CnameT]

def Cname_of_twine(d: twine.Decoder, off: int) -> Cname:
    return _rt.decode_with_tag(tag=6, d=d, off=off, d0=lambda d, off: CnameT_of_twine(d=d, off=off))

