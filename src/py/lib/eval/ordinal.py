# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_eval.Ordinal`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt

__all__ = [
    "Int",
    "Cons",
    "Ordinal",
]

# def Imandrax_api_eval.Ordinal.t
@dataclass(slots=True, frozen=True)
class Int:
    arg: int

def Int_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> Int:
    arg = d.get_int(off=_tw_args[0])
    return Int(arg=arg)

@dataclass(slots=True, frozen=True)
class Cons:
    args: tuple[Ordinal, int, Ordinal]

def Cons_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> Cons:
    cargs = (Ordinal_of_twine(d=d, off=_tw_args[0]), d.get_int(off=_tw_args[1]), Ordinal_of_twine(d=d, off=_tw_args[2]))
    return Cons(args=cargs)

type Ordinal = Int | Cons

def Ordinal_of_twine(d: twine.Decoder, off: int) -> Ordinal:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Int_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Cons_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Ordinal, got invalid constructor {idx}')

