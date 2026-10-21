# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_report.Rtext`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid
from ..common import sequent as common_sequent

__all__ = [
    "Rtext",
    "ItemS",
    "ItemB",
    "ItemI",
    "ItemNewline",
    "ItemSub",
    "ItemL",
    "ItemUid",
    "ItemTerm",
    "ItemSequent",
    "ItemSubst",
    "Item",
]

# def Imandrax_api_report.Rtext.t
type Rtext[Term] = list[Item[Term]]

def Rtext_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], off: int) -> Rtext[Term]:
    decode_Term = d0
    return [Item_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off))) for x in d.get_array(off=off)]

# def Imandrax_api_report.Rtext.item
@dataclass(slots=True, frozen=True)
class ItemS[Term]:
    arg: str

def ItemS_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], _tw_args: tuple[int, ...]) -> ItemS[Term]:
    decode_Term = d0
    arg = d.get_str(off=_tw_args[0])
    return ItemS(arg=arg)

@dataclass(slots=True, frozen=True)
class ItemB[Term]:
    arg: str

def ItemB_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], _tw_args: tuple[int, ...]) -> ItemB[Term]:
    decode_Term = d0
    arg = d.get_str(off=_tw_args[0])
    return ItemB(arg=arg)

@dataclass(slots=True, frozen=True)
class ItemI[Term]:
    arg: str

def ItemI_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], _tw_args: tuple[int, ...]) -> ItemI[Term]:
    decode_Term = d0
    arg = d.get_str(off=_tw_args[0])
    return ItemI(arg=arg)

@dataclass(slots=True, frozen=True)
class ItemNewline[Term]:
    pass

@dataclass(slots=True, frozen=True)
class ItemSub[Term]:
    arg: Rtext[Term]

def ItemSub_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], _tw_args: tuple[int, ...]) -> ItemSub[Term]:
    decode_Term = d0
    arg = Rtext_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)))
    return ItemSub(arg=arg)

@dataclass(slots=True, frozen=True)
class ItemL[Term]:
    arg: list[Rtext[Term]]

def ItemL_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], _tw_args: tuple[int, ...]) -> ItemL[Term]:
    decode_Term = d0
    arg = [Rtext_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off))) for x in d.get_array(off=_tw_args[0])]
    return ItemL(arg=arg)

@dataclass(slots=True, frozen=True)
class ItemUid[Term]:
    arg: core_uid.Uid

def ItemUid_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], _tw_args: tuple[int, ...]) -> ItemUid[Term]:
    decode_Term = d0
    arg = core_uid.Uid_of_twine(d=d, off=_tw_args[0])
    return ItemUid(arg=arg)

@dataclass(slots=True, frozen=True)
class ItemTerm[Term]:
    arg: Term

def ItemTerm_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], _tw_args: tuple[int, ...]) -> ItemTerm[Term]:
    decode_Term = d0
    arg = decode_Term(d=d, off=_tw_args[0])
    return ItemTerm(arg=arg)

@dataclass(slots=True, frozen=True)
class ItemSequent[Term]:
    arg: common_sequent.Sequent[Term]

def ItemSequent_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], _tw_args: tuple[int, ...]) -> ItemSequent[Term]:
    decode_Term = d0
    arg = common_sequent.Sequent_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)))
    return ItemSequent(arg=arg)

@dataclass(slots=True, frozen=True)
class ItemSubst[Term]:
    arg: list[tuple[Term, Term]]

def ItemSubst_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], _tw_args: tuple[int, ...]) -> ItemSubst[Term]:
    decode_Term = d0
    arg = [(lambda tup: (decode_Term(d=d, off=tup[0]), decode_Term(d=d, off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=_tw_args[0])]
    return ItemSubst(arg=arg)

type Item[Term] = ItemS[Term] | ItemB[Term] | ItemI[Term] | ItemNewline[Term] | ItemSub[Term] | ItemL[Term] | ItemUid[Term] | ItemTerm[Term] | ItemSequent[Term] | ItemSubst[Term]

def Item_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], off: int) -> Item[Term]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return ItemS_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return ItemB_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return ItemI_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=3, args=args):
             return ItemNewline[Term]()
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return ItemSub_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return ItemL_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return ItemUid_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=7, args=args):
             args = tuple(args)
             return ItemTerm_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=8, args=args):
             args = tuple(args)
             return ItemSequent_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=9, args=args):
             args = tuple(args)
             return ItemSubst_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Item, got invalid constructor {idx}')

