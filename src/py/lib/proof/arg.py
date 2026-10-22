# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_proof.Arg`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..common import sequent as common_sequent

__all__ = [
    "A_Term",
    "A_Ty",
    "A_Int",
    "A_String",
    "A_List",
    "A_Dict",
    "A_Seq",
    "Arg",
]

# def Imandrax_api_proof.Arg.t
@dataclass(slots=True, frozen=True)
class A_Term[Term, Ty]:
    arg: Term

def A_Term_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> A_Term[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = decode_Term(d=d, off=_tw_args[0])
    return A_Term(arg=arg)

@dataclass(slots=True, frozen=True)
class A_Ty[Term, Ty]:
    arg: Ty

def A_Ty_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> A_Ty[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = decode_Ty(d=d, off=_tw_args[0])
    return A_Ty(arg=arg)

@dataclass(slots=True, frozen=True)
class A_Int[Term, Ty]:
    arg: int

def A_Int_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> A_Int[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = d.get_int(off=_tw_args[0])
    return A_Int(arg=arg)

@dataclass(slots=True, frozen=True)
class A_String[Term, Ty]:
    arg: str

def A_String_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> A_String[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = d.get_str(off=_tw_args[0])
    return A_String(arg=arg)

@dataclass(slots=True, frozen=True)
class A_List[Term, Ty]:
    arg: list[Arg[Term, Ty]]

def A_List_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> A_List[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = [Arg_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=_tw_args[0])]
    return A_List(arg=arg)

@dataclass(slots=True, frozen=True)
class A_Dict[Term, Ty]:
    arg: list[tuple[str, Arg[Term, Ty]]]

def A_Dict_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> A_Dict[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = [(lambda tup: (d.get_str(off=tup[0]), Arg_of_twine(d=d, off=tup[1], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))))(tuple(d.get_array(off=x))) for x in d.get_array(off=_tw_args[0])]
    return A_Dict(arg=arg)

@dataclass(slots=True, frozen=True)
class A_Seq[Term, Ty]:
    arg: common_sequent.Sequent[Term]

def A_Seq_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> A_Seq[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = common_sequent.Sequent_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)))
    return A_Seq(arg=arg)

type Arg[Term, Ty] = A_Term[Term, Ty] | A_Ty[Term, Ty] | A_Int[Term, Ty] | A_String[Term, Ty] | A_List[Term, Ty] | A_Dict[Term, Ty] | A_Seq[Term, Ty]

def Arg_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> Arg[Term, Ty]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return A_Term_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return A_Ty_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return A_Int_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return A_String_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return A_List_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return A_Dict_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return A_Seq_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Arg, got invalid constructor {idx}')

