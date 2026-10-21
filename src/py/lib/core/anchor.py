# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.Anchor`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import cname as core_cname

__all__ = [
    "Named",
    "Eval",
    "ProofCheck",
    "Decomp",
    "Anchor",
]

# def Imandrax_api.Anchor.t
@dataclass(slots=True, frozen=True)
class Named:
    arg: core_cname.Cname

def Named_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> Named:
    arg = core_cname.Cname_of_twine(d=d, off=_tw_args[0])
    return Named(arg=arg)

@dataclass(slots=True, frozen=True)
class Eval:
    arg: int

def Eval_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> Eval:
    arg = d.get_int(off=_tw_args[0])
    return Eval(arg=arg)

@dataclass(slots=True, frozen=True)
class ProofCheck:
    arg: Anchor

def ProofCheck_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> ProofCheck:
    arg = Anchor_of_twine(d=d, off=_tw_args[0])
    return ProofCheck(arg=arg)

@dataclass(slots=True, frozen=True)
class Decomp:
    arg: Anchor

def Decomp_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> Decomp:
    arg = Anchor_of_twine(d=d, off=_tw_args[0])
    return Decomp(arg=arg)

type Anchor = Named | Eval | ProofCheck | Decomp

def Anchor_of_twine(d: twine.Decoder, off: int) -> Anchor:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return Named_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return Eval_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return ProofCheck_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Decomp_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Anchor, got invalid constructor {idx}')

