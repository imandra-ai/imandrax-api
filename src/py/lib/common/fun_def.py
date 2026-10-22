# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Fun_def`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid
from ..core import clique as core_clique
from ..core import builtin as core_builtin
from ..common import var as common_var
from ..common import type_schema as common_type_schema
from ..common import hints as common_hints

__all__ = [
    "FunKindFunDefined",
    "FunKindFunBuiltin",
    "FunKindFunOpaque",
    "FunKind",
    "FunDef",
]

# def Imandrax_api_common.Fun_def.fun_kind
@dataclass(slots=True, frozen=True)
class FunKindFunDefined:
    is_macro: bool
    from_lambda: bool


def FunKindFunDefined_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> FunKindFunDefined:
    is_macro = d.get_bool(off=_tw_args[0])
    from_lambda = d.get_bool(off=_tw_args[1])
    return FunKindFunDefined(is_macro=is_macro, from_lambda=from_lambda)


@dataclass(slots=True, frozen=True)
class FunKindFunBuiltin:
    arg: core_builtin.Fun

def FunKindFunBuiltin_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> FunKindFunBuiltin:
    arg = core_builtin.Fun_of_twine(d=d, off=_tw_args[0])
    return FunKindFunBuiltin(arg=arg)

@dataclass(slots=True, frozen=True)
class FunKindFunOpaque:
    pass

type FunKind = FunKindFunDefined | FunKindFunBuiltin | FunKindFunOpaque

def FunKind_of_twine(d: twine.Decoder, off: int) -> FunKind:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return FunKindFunDefined_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return FunKindFunBuiltin_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=2, args=args):
             return FunKindFunOpaque()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected FunKind, got invalid constructor {idx}')

# def Imandrax_api_common.Fun_def.t_poly
@dataclass(slots=True, frozen=True)
class FunDef[Term, Ty]:
    f_name: core_uid.Uid
    f_ty: common_type_schema.TypeSchema[Ty]
    f_args: list[common_var.Var[Ty]]
    f_body: Term
    f_clique: None | core_clique.Clique
    f_kind: FunKind
    f_hints: common_hints.Hints[Term, Ty]

def FunDef_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> FunDef[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    f_name = core_uid.Uid_of_twine(d=d, off=fields[0])
    f_ty = common_type_schema.TypeSchema_of_twine(d=d, off=fields[1], d0=(lambda d, off: decode_Ty(d=d, off=off)))
    f_args = [common_var.Var_of_twine(d=d, off=x, d0=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=fields[2])]
    f_body = decode_Term(d=d, off=fields[3])
    f_clique = twine.optional(d=d, off=fields[4], d0=lambda d, off: core_clique.Clique_of_twine(d=d, off=off))
    f_kind = FunKind_of_twine(d=d, off=fields[5])
    f_hints = common_hints.Hints_of_twine(d=d, off=fields[6], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    return FunDef(f_name=f_name, f_ty=f_ty, f_args=f_args, f_body=f_body, f_clique=f_clique, f_kind=f_kind, f_hints=f_hints)

