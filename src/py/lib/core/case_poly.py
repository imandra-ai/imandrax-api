# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.Case_poly`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid

__all__ = [
    "CasePoly",
]

# def Imandrax_api.Case_poly.t_poly
@dataclass(slots=True, frozen=True)
class CasePoly[T, Var, Sym]:
    case_cstor: Sym
    case_vars: list[Var]
    case_rhs: T
    case_labels: None | list[core_uid.Uid]

def CasePoly_of_twine[T, Var, Sym](d: twine.Decoder, d0: twine.DecoderFn[T], d1: twine.DecoderFn[Var], d2: twine.DecoderFn[Sym], off: int) -> CasePoly[T, Var, Sym]:
    decode_T = d0
    decode_Var = d1
    decode_Sym = d2
    fields = list(d.get_array(off=off))
    case_cstor = decode_Sym(d=d, off=fields[0])
    case_vars = [decode_Var(d=d, off=x) for x in d.get_array(off=fields[1])]
    case_rhs = decode_T(d=d, off=fields[2])
    case_labels = twine.optional(d=d, off=fields[3], d0=lambda d, off: [core_uid.Uid_of_twine(d=d, off=x) for x in d.get_array(off=off)])
    return CasePoly(case_cstor=case_cstor, case_vars=case_vars, case_rhs=case_rhs, case_labels=case_labels)

