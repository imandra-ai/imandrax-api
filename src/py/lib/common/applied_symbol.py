# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Applied_symbol`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..common import typed_symbol as common_typed_symbol

__all__ = [
    "AppliedSymbol",
]

# def Imandrax_api_common.Applied_symbol.t_poly
@dataclass(slots=True, frozen=True)
class AppliedSymbol[Ty]:
    sym: common_typed_symbol.TypedSymbol[Ty]
    args: list[Ty]
    ty: Ty

def AppliedSymbol_of_twine[Ty](d: twine.Decoder, d0: twine.DecoderFn[Ty], off: int) -> AppliedSymbol[Ty]:
    decode_Ty = d0
    fields = list(d.get_array(off=off))
    sym = common_typed_symbol.TypedSymbol_of_twine(d=d, off=fields[0], d0=(lambda d, off: decode_Ty(d=d, off=off)))
    args = [decode_Ty(d=d, off=x) for x in d.get_array(off=fields[1])]
    ty = decode_Ty(d=d, off=fields[2])
    return AppliedSymbol(sym=sym, args=args, ty=ty)

