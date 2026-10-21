# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Hints`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid
from ..common import var as common_var
from ..common import admission as common_admission

__all__ = [
    "VS_Validate",
    "VS_NoValidate",
    "ValidationStrategy",
    "Hints",
]

# def Imandrax_api_common.Hints.validation_strategy
@dataclass(slots=True, frozen=True)
class VS_Validate[Term, Ty]:
    tactic: None | tuple[list[common_var.Var[Ty]], Term]


def VS_Validate_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> VS_Validate[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    tactic = twine.optional(d=d, off=_tw_args[0], d0=lambda d, off: (lambda tup: ([common_var.Var_of_twine(d=d, off=x, d0=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=tup[0])], decode_Term(d=d, off=tup[1])))(tuple(d.get_array(off=off))))
    return VS_Validate(tactic=tactic)


@dataclass(slots=True, frozen=True)
class VS_NoValidate[Term, Ty]:
    pass

type ValidationStrategy[Term, Ty] = VS_Validate[Term, Ty] | VS_NoValidate[Term, Ty]

def ValidationStrategy_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> ValidationStrategy[Term, Ty]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return VS_Validate_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=1, args=args):
             return VS_NoValidate[Term, Ty]()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected ValidationStrategy, got invalid constructor {idx}')

# def Imandrax_api_common.Hints.t_poly
@dataclass(slots=True, frozen=True)
class Hints[Term, Ty]:
    f_validate_strat: ValidationStrategy[Term, Ty]
    f_unroll_def: None | int
    f_enable: list[core_uid.Uid]
    f_disable: list[core_uid.Uid]
    f_timeout: None | int
    f_admission: None | common_admission.Admission
    f_decomp: None | Term

def Hints_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> Hints[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    f_validate_strat = ValidationStrategy_of_twine(d=d, off=fields[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    f_unroll_def = twine.optional(d=d, off=fields[1], d0=lambda d, off: d.get_int(off=off))
    f_enable = [core_uid.Uid_of_twine(d=d, off=x) for x in d.get_array(off=fields[2])]
    f_disable = [core_uid.Uid_of_twine(d=d, off=x) for x in d.get_array(off=fields[3])]
    f_timeout = twine.optional(d=d, off=fields[4], d0=lambda d, off: d.get_int(off=off))
    f_admission = twine.optional(d=d, off=fields[5], d0=lambda d, off: common_admission.Admission_of_twine(d=d, off=off))
    f_decomp = twine.optional(d=d, off=fields[6], d0=lambda d, off: decode_Term(d=d, off=off))
    return Hints(f_validate_strat=f_validate_strat, f_unroll_def=f_unroll_def, f_enable=f_enable, f_disable=f_disable, f_timeout=f_timeout, f_admission=f_admission, f_decomp=f_decomp)

