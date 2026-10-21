# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Verify`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import upto as core_upto
from ..common import var as common_var
from ..common import fun_def as common_fun_def

__all__ = [
    "K_Verify",
    "K_Instance",
    "K_Test",
    "Kind",
    "Verify",
]

# def Imandrax_api_common.Verify.kind
@dataclass(slots=True, frozen=True)
class K_Verify:
    pass

@dataclass(slots=True, frozen=True)
class K_Instance:
    pass

@dataclass(slots=True, frozen=True)
class K_Test:
    pass

type Kind = K_Verify | K_Instance | K_Test

def Kind_of_twine(d: twine.Decoder, off: int) -> Kind:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return K_Verify()
         case twine.Constructor(idx=1, args=args):
             return K_Instance()
         case twine.Constructor(idx=2, args=args):
             return K_Test()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Kind, got invalid constructor {idx}')

# def Imandrax_api_common.Verify.t_poly
@dataclass(slots=True, frozen=True)
class Verify[Term, Ty]:
    verify_link: common_fun_def.FunDef[Term, Ty]
    verify_simplify: bool
    verify_nonlin: bool
    verify_upto: None | core_upto.Upto
    verify_kind: Kind
    verify_minimize: list[Term]
    verify_by: None | tuple[list[common_var.Var[Ty]], Term]

def Verify_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> Verify[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    verify_link = common_fun_def.FunDef_of_twine(d=d, off=fields[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    verify_simplify = d.get_bool(off=fields[1])
    verify_nonlin = d.get_bool(off=fields[2])
    verify_upto = twine.optional(d=d, off=fields[3], d0=lambda d, off: core_upto.Upto_of_twine(d=d, off=off))
    verify_kind = Kind_of_twine(d=d, off=fields[4])
    verify_minimize = [decode_Term(d=d, off=x) for x in d.get_array(off=fields[5])]
    verify_by = twine.optional(d=d, off=fields[6], d0=lambda d, off: (lambda tup: ([common_var.Var_of_twine(d=d, off=x, d0=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=tup[0])], decode_Term(d=d, off=tup[1])))(tuple(d.get_array(off=off))))
    return Verify(verify_link=verify_link, verify_simplify=verify_simplify, verify_nonlin=verify_nonlin, verify_upto=verify_upto, verify_kind=verify_kind, verify_minimize=verify_minimize, verify_by=verify_by)

