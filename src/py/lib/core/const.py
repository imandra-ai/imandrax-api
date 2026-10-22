# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.Const`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid

__all__ = [
    "ConstFloat",
    "ConstString",
    "ConstZ",
    "ConstQ",
    "ConstRealApprox",
    "ConstUid",
    "ConstBool",
    "Const",
]

# def Imandrax_api.Const.t
@dataclass(slots=True, frozen=True)
class ConstFloat:
    arg: float

def ConstFloat_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> ConstFloat:
    arg = d.get_float(off=_tw_args[0])
    return ConstFloat(arg=arg)

@dataclass(slots=True, frozen=True)
class ConstString:
    arg: str

def ConstString_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> ConstString:
    arg = d.get_str(off=_tw_args[0])
    return ConstString(arg=arg)

@dataclass(slots=True, frozen=True)
class ConstZ:
    arg: int

def ConstZ_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> ConstZ:
    arg = d.get_int(off=_tw_args[0])
    return ConstZ(arg=arg)

@dataclass(slots=True, frozen=True)
class ConstQ:
    arg: tuple[int, int]

def ConstQ_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> ConstQ:
    arg = _rt.decode_q(d=d, off=_tw_args[0])
    return ConstQ(arg=arg)

@dataclass(slots=True, frozen=True)
class ConstRealApprox:
    arg: str

def ConstRealApprox_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> ConstRealApprox:
    arg = d.get_str(off=_tw_args[0])
    return ConstRealApprox(arg=arg)

@dataclass(slots=True, frozen=True)
class ConstUid:
    arg: core_uid.Uid

def ConstUid_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> ConstUid:
    arg = core_uid.Uid_of_twine(d=d, off=_tw_args[0])
    return ConstUid(arg=arg)

@dataclass(slots=True, frozen=True)
class ConstBool:
    arg: bool

def ConstBool_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> ConstBool:
    arg = d.get_bool(off=_tw_args[0])
    return ConstBool(arg=arg)

type Const = ConstFloat | ConstString | ConstZ | ConstQ | ConstRealApprox | ConstUid | ConstBool

def Const_of_twine(d: twine.Decoder, off: int) -> Const:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return ConstFloat_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return ConstString_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return ConstZ_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return ConstQ_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return ConstRealApprox_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return ConstUid_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return ConstBool_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Const, got invalid constructor {idx}')

