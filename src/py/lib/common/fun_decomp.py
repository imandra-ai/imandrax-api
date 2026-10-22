# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Fun_decomp`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid
from ..common import var as common_var
from ..common import region as common_region

__all__ = [
    "ListWithLen",
    "FunDecomp",
]

# def Imandrax_api_common.Fun_decomp.list_with_len
type ListWithLen[A] = list[A]

def ListWithLen_of_twine[A](d: twine.Decoder, d0: twine.DecoderFn[A], off: int) -> ListWithLen[A]:
    decode_A = d0
    return [decode_A(d=d, off=x) for x in d.get_array(off=off)]

# def Imandrax_api_common.Fun_decomp.t_poly
@dataclass(slots=True, frozen=True)
class FunDecomp[Term, Ty]:
    f_id: core_uid.Uid
    f_args: list[common_var.Var[Ty]]
    regions: ListWithLen[common_region.Region[Term, Ty]]

def FunDecomp_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> FunDecomp[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    f_id = core_uid.Uid_of_twine(d=d, off=fields[0])
    f_args = [common_var.Var_of_twine(d=d, off=x, d0=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=fields[1])]
    regions = ListWithLen_of_twine(d=d, off=fields[2], d0=(lambda d, off: common_region.Region_of_twine(d=d, off=off, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))))
    return FunDecomp(f_id=f_id, f_args=f_args, regions=regions)

