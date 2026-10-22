# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Region`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..common import model as common_model

__all__ = [
    "StatusUnknown",
    "StatusFeasible",
    "StatusFeasibilityCheckFailed",
    "Status",
    "MetaNull",
    "MetaBool",
    "MetaInt",
    "MetaReal",
    "MetaString",
    "MetaAssoc",
    "MetaTerm",
    "MetaList",
    "Meta",
    "Region",
]

# def Imandrax_api_common.Region.status
@dataclass(slots=True, frozen=True)
class StatusUnknown[Term, Ty]:
    pass

@dataclass(slots=True, frozen=True)
class StatusFeasible[Term, Ty]:
    arg: common_model.Model[Term, Ty]

def StatusFeasible_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> StatusFeasible[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = common_model.Model_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    return StatusFeasible(arg=arg)

@dataclass(slots=True, frozen=True)
class StatusFeasibilityCheckFailed[Term, Ty]:
    arg: str

def StatusFeasibilityCheckFailed_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> StatusFeasibilityCheckFailed[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = d.get_str(off=_tw_args[0])
    return StatusFeasibilityCheckFailed(arg=arg)

type Status[Term, Ty] = StatusUnknown[Term, Ty] | StatusFeasible[Term, Ty] | StatusFeasibilityCheckFailed[Term, Ty]

def Status_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> Status[Term, Ty]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return StatusUnknown[Term, Ty]()
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return StatusFeasible_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return StatusFeasibilityCheckFailed_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Status, got invalid constructor {idx}')

# def Imandrax_api_common.Region.meta
@dataclass(slots=True, frozen=True)
class MetaNull[Term]:
    pass

@dataclass(slots=True, frozen=True)
class MetaBool[Term]:
    arg: bool

def MetaBool_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], _tw_args: tuple[int, ...]) -> MetaBool[Term]:
    decode_Term = d0
    arg = d.get_bool(off=_tw_args[0])
    return MetaBool(arg=arg)

@dataclass(slots=True, frozen=True)
class MetaInt[Term]:
    arg: int

def MetaInt_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], _tw_args: tuple[int, ...]) -> MetaInt[Term]:
    decode_Term = d0
    arg = d.get_int(off=_tw_args[0])
    return MetaInt(arg=arg)

@dataclass(slots=True, frozen=True)
class MetaReal[Term]:
    arg: tuple[int, int]

def MetaReal_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], _tw_args: tuple[int, ...]) -> MetaReal[Term]:
    decode_Term = d0
    arg = _rt.decode_q(d=d, off=_tw_args[0])
    return MetaReal(arg=arg)

@dataclass(slots=True, frozen=True)
class MetaString[Term]:
    arg: str

def MetaString_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], _tw_args: tuple[int, ...]) -> MetaString[Term]:
    decode_Term = d0
    arg = d.get_str(off=_tw_args[0])
    return MetaString(arg=arg)

@dataclass(slots=True, frozen=True)
class MetaAssoc[Term]:
    arg: list[tuple[str, Meta[Term]]]

def MetaAssoc_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], _tw_args: tuple[int, ...]) -> MetaAssoc[Term]:
    decode_Term = d0
    arg = [(lambda tup: (d.get_str(off=tup[0]), Meta_of_twine(d=d, off=tup[1], d0=(lambda d, off: decode_Term(d=d, off=off)))))(tuple(d.get_array(off=x))) for x in d.get_array(off=_tw_args[0])]
    return MetaAssoc(arg=arg)

@dataclass(slots=True, frozen=True)
class MetaTerm[Term]:
    arg: Term

def MetaTerm_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], _tw_args: tuple[int, ...]) -> MetaTerm[Term]:
    decode_Term = d0
    arg = decode_Term(d=d, off=_tw_args[0])
    return MetaTerm(arg=arg)

@dataclass(slots=True, frozen=True)
class MetaList[Term]:
    arg: list[Meta[Term]]

def MetaList_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], _tw_args: tuple[int, ...]) -> MetaList[Term]:
    decode_Term = d0
    arg = [Meta_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off))) for x in d.get_array(off=_tw_args[0])]
    return MetaList(arg=arg)

type Meta[Term] = MetaNull[Term] | MetaBool[Term] | MetaInt[Term] | MetaReal[Term] | MetaString[Term] | MetaAssoc[Term] | MetaTerm[Term] | MetaList[Term]

def Meta_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], off: int) -> Meta[Term]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return MetaNull[Term]()
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return MetaBool_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return MetaInt_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return MetaReal_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return MetaString_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return MetaAssoc_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return MetaTerm_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=7, args=args):
             args = tuple(args)
             return MetaList_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Meta, got invalid constructor {idx}')

# def Imandrax_api_common.Region.t_poly
@dataclass(slots=True, frozen=True)
class Region[Term, Ty]:
    constraints: list[Term]
    invariant: Term
    meta: list[tuple[str, Meta[Term]]]
    status: Status[Term, Ty]

def Region_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> Region[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    constraints = [decode_Term(d=d, off=x) for x in d.get_array(off=fields[0])]
    invariant = decode_Term(d=d, off=fields[1])
    meta = [(lambda tup: (d.get_str(off=tup[0]), Meta_of_twine(d=d, off=tup[1], d0=(lambda d, off: decode_Term(d=d, off=off)))))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[2])]
    status = Status_of_twine(d=d, off=fields[3], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    return Region(constraints=constraints, invariant=invariant, meta=meta, status=status)

