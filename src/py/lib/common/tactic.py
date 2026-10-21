# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Tactic`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import upto as core_upto
from ..core import uid_set as core_uid_set
from ..common import var as common_var

__all__ = [
    "DefaultTermination",
    "DefaultThm",
    "DefaultTest",
    "Term",
    "Tactic",
]

# def Imandrax_api_common.Tactic.t_poly
@dataclass(slots=True, frozen=True)
class DefaultTermination[_Term, Ty]:
    max_steps: int
    basis: core_uid_set.UidSet


def DefaultTermination_of_twine[_Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[_Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> DefaultTermination[_Term, Ty]:
    decode__Term = d0
    decode_Ty = d1
    max_steps = d.get_int(off=_tw_args[0])
    basis = core_uid_set.UidSet_of_twine(d=d, off=_tw_args[1])
    return DefaultTermination(max_steps=max_steps, basis=basis)


@dataclass(slots=True, frozen=True)
class DefaultThm[_Term, Ty]:
    max_steps: int
    upto: None | core_upto.Upto


def DefaultThm_of_twine[_Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[_Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> DefaultThm[_Term, Ty]:
    decode__Term = d0
    decode_Ty = d1
    max_steps = d.get_int(off=_tw_args[0])
    upto = twine.optional(d=d, off=_tw_args[1], d0=lambda d, off: core_upto.Upto_of_twine(d=d, off=off))
    return DefaultThm(max_steps=max_steps, upto=upto)


@dataclass(slots=True, frozen=True)
class DefaultTest[_Term, Ty]:
    num_steps: None | int
    seed: None | int


def DefaultTest_of_twine[_Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[_Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> DefaultTest[_Term, Ty]:
    decode__Term = d0
    decode_Ty = d1
    num_steps = twine.optional(d=d, off=_tw_args[0], d0=lambda d, off: d.get_int(off=off))
    seed = twine.optional(d=d, off=_tw_args[1], d0=lambda d, off: d.get_int(off=off))
    return DefaultTest(num_steps=num_steps, seed=seed)


@dataclass(slots=True, frozen=True)
class Term[_Term, Ty]:
    arg: tuple[list[common_var.Var[Ty]], _Term]

def Term_of_twine[_Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[_Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> Term[_Term, Ty]:
    decode__Term = d0
    decode_Ty = d1
    arg = (lambda tup: ([common_var.Var_of_twine(d=d, off=x, d0=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=tup[0])], decode__Term(d=d, off=tup[1])))(tuple(d.get_array(off=_tw_args[0])))
    return Term(arg=arg)

type Tactic[_Term, Ty] = DefaultTermination[_Term, Ty] | DefaultThm[_Term, Ty] | DefaultTest[_Term, Ty] | Term[_Term, Ty]

def Tactic_of_twine[_Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[_Term], d1: twine.DecoderFn[Ty], off: int) -> Tactic[_Term, Ty]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return DefaultTermination_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return DefaultThm_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return DefaultTest_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return Term_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Tactic, got invalid constructor {idx}')

