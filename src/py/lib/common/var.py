# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Var`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid

__all__ = [
    "Var",
]

# def Imandrax_api_common.Var.t_poly
@dataclass(slots=True, frozen=True)
class Var[Ty]:
    id: core_uid.Uid
    ty: Ty

def Var_of_twine[Ty](d: twine.Decoder, d0: twine.DecoderFn[Ty], off: int) -> Var[Ty]:
    decode_Ty = d0
    fields = list(d.get_array(off=off))
    id = core_uid.Uid_of_twine(d=d, off=fields[0])
    ty = decode_Ty(d=d, off=fields[1])
    return Var(id=id, ty=ty)

