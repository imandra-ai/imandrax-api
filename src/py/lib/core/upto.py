# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.Upto`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt

__all__ = [
    "NSteps",
    "Upto",
]

# def Imandrax_api.Upto.t
@dataclass(slots=True, frozen=True)
class NSteps:
    arg: int

def NSteps_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> NSteps:
    arg = d.get_int(off=_tw_args[0])
    return NSteps(arg=arg)

type Upto = NSteps

def Upto_of_twine(d: twine.Decoder, off: int) -> Upto:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return NSteps_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Upto, got invalid constructor {idx}')

