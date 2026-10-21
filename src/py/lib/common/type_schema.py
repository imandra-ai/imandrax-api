# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Type_schema`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid

__all__ = [
    "TypeSchema",
]

# def Imandrax_api_common.Type_schema.t_poly
@dataclass(slots=True, frozen=True)
class TypeSchema[Ty]:
    params: list[core_uid.Uid]
    ty: Ty

def TypeSchema_of_twine[Ty](d: twine.Decoder, d0: twine.DecoderFn[Ty], off: int) -> TypeSchema[Ty]:
    decode_Ty = d0
    fields = list(d.get_array(off=off))
    params = [core_uid.Uid_of_twine(d=d, off=x) for x in d.get_array(off=fields[0])]
    ty = decode_Ty(d=d, off=fields[1])
    return TypeSchema(params=params, ty=ty)

