# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.Builtin_data`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt

__all__ = [
    "KindLogicCore",
    "KindSpecial",
    "KindTactic",
    "KindDecomp",
    "Kind",
]

# def Imandrax_api.Builtin_data.kind
@dataclass(slots=True, frozen=True)
class KindLogicCore:
    logic_core_name: str


def KindLogicCore_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> KindLogicCore:
    logic_core_name = d.get_str(off=_tw_args[0])
    return KindLogicCore(logic_core_name=logic_core_name)


@dataclass(slots=True, frozen=True)
class KindSpecial:
    tag: str


def KindSpecial_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> KindSpecial:
    tag = d.get_str(off=_tw_args[0])
    return KindSpecial(tag=tag)


@dataclass(slots=True, frozen=True)
class KindTactic:
    tac_name: str


def KindTactic_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> KindTactic:
    tac_name = d.get_str(off=_tw_args[0])
    return KindTactic(tac_name=tac_name)


@dataclass(slots=True, frozen=True)
class KindDecomp:
    decomp_name: str


def KindDecomp_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> KindDecomp:
    decomp_name = d.get_str(off=_tw_args[0])
    return KindDecomp(decomp_name=decomp_name)


type Kind = KindLogicCore | KindSpecial | KindTactic | KindDecomp

def Kind_of_twine(d: twine.Decoder, off: int) -> Kind:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return KindLogicCore_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return KindSpecial_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return KindTactic_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return KindDecomp_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Kind, got invalid constructor {idx}')

