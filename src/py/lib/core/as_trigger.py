# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.As_trigger`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt

__all__ = [
    "TrigNone",
    "TrigAnon",
    "TrigNamed",
    "TrigRw",
    "AsTrigger",
]

# def Imandrax_api.As_trigger.t
@dataclass(slots=True, frozen=True)
class TrigNone:
    pass

@dataclass(slots=True, frozen=True)
class TrigAnon:
    pass

@dataclass(slots=True, frozen=True)
class TrigNamed:
    arg: int

def TrigNamed_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> TrigNamed:
    arg = d.get_int(off=_tw_args[0])
    return TrigNamed(arg=arg)

@dataclass(slots=True, frozen=True)
class TrigRw:
    pass

type AsTrigger = TrigNone | TrigAnon | TrigNamed | TrigRw

def AsTrigger_of_twine(d: twine.Decoder, off: int) -> AsTrigger:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return TrigNone()
         case twine.Constructor(idx=1, args=args):
             return TrigAnon()
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return TrigNamed_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=3, args=args):
             return TrigRw()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected AsTrigger, got invalid constructor {idx}')

