# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Typed_symbol`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid
from ..common import type_schema as common_type_schema

__all__ = [
    "TypedSymbol",
]

# def Imandrax_api_common.Typed_symbol.t_poly
@dataclass(slots=True, frozen=True)
class TypedSymbol[Ty]:
    id: core_uid.Uid
    ty: common_type_schema.TypeSchema[Ty]

def TypedSymbol_of_twine[Ty](d: twine.Decoder, d0: twine.DecoderFn[Ty], off: int) -> TypedSymbol[Ty]:
    decode_Ty = d0
    fields = list(d.get_array(off=off))
    id = core_uid.Uid_of_twine(d=d, off=fields[0])
    ty = common_type_schema.TypeSchema_of_twine(d=d, off=fields[1], d0=(lambda d, off: decode_Ty(d=d, off=off)))
    return TypedSymbol(id=id, ty=ty)

