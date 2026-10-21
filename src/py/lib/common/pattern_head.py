# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Pattern_head`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid

__all__ = [
    "PH_Id",
    "PH_Ty",
    "PH_DatatypeOp",
    "PatternHead",
]

# def Imandrax_api_common.Pattern_head.t_poly
@dataclass(slots=True, frozen=True)
class PH_Id[Ty]:
    arg: core_uid.Uid

def PH_Id_of_twine[Ty](d: twine.Decoder, d0: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> PH_Id[Ty]:
    decode_Ty = d0
    arg = core_uid.Uid_of_twine(d=d, off=_tw_args[0])
    return PH_Id(arg=arg)

@dataclass(slots=True, frozen=True)
class PH_Ty[Ty]:
    arg: Ty

def PH_Ty_of_twine[Ty](d: twine.Decoder, d0: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> PH_Ty[Ty]:
    decode_Ty = d0
    arg = decode_Ty(d=d, off=_tw_args[0])
    return PH_Ty(arg=arg)

@dataclass(slots=True, frozen=True)
class PH_DatatypeOp[Ty]:
    pass

type PatternHead[Ty] = PH_Id[Ty] | PH_Ty[Ty] | PH_DatatypeOp[Ty]

def PatternHead_of_twine[Ty](d: twine.Decoder, d0: twine.DecoderFn[Ty], off: int) -> PatternHead[Ty]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return PH_Id_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return PH_Ty_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=2, args=args):
             return PH_DatatypeOp[Ty]()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected PatternHead, got invalid constructor {idx}')

