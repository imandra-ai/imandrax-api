# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.Misc_types`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt

__all__ = [
    "RecFlagRecursive",
    "RecFlagNonrecursive",
    "RecFlag",
    "ApplyLabelNolabel",
    "ApplyLabelLabel",
    "ApplyLabelOptional",
    "ApplyLabel",
]

# def Imandrax_api.Misc_types.rec_flag
@dataclass(slots=True, frozen=True)
class RecFlagRecursive:
    pass

@dataclass(slots=True, frozen=True)
class RecFlagNonrecursive:
    pass

type RecFlag = RecFlagRecursive | RecFlagNonrecursive

def RecFlag_of_twine(d: twine.Decoder, off: int) -> RecFlag:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return RecFlagRecursive()
         case twine.Constructor(idx=1, args=args):
             return RecFlagNonrecursive()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected RecFlag, got invalid constructor {idx}')

# def Imandrax_api.Misc_types.apply_label
@dataclass(slots=True, frozen=True)
class ApplyLabelNolabel:
    pass

@dataclass(slots=True, frozen=True)
class ApplyLabelLabel:
    arg: str

def ApplyLabelLabel_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> ApplyLabelLabel:
    arg = d.get_str(off=_tw_args[0])
    return ApplyLabelLabel(arg=arg)

@dataclass(slots=True, frozen=True)
class ApplyLabelOptional:
    arg: str

def ApplyLabelOptional_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> ApplyLabelOptional:
    arg = d.get_str(off=_tw_args[0])
    return ApplyLabelOptional(arg=arg)

type ApplyLabel = ApplyLabelNolabel | ApplyLabelLabel | ApplyLabelOptional

def ApplyLabel_of_twine(d: twine.Decoder, off: int) -> ApplyLabel:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return ApplyLabelNolabel()
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return ApplyLabelLabel_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return ApplyLabelOptional_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected ApplyLabel, got invalid constructor {idx}')

