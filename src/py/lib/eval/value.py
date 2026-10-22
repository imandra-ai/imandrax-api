# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_eval.Value`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import top_fun as mir_top_fun
from ..eval import ordinal as eval_ordinal
from ..core import uid as core_uid

__all__ = [
    "CstorDescriptor",
    "RecordDescriptor",
    "V_True",
    "V_False",
    "V_Int",
    "V_Real",
    "V_String",
    "V_Cstor",
    "V_Tuple",
    "V_Record",
    "V_QuotedTerm",
    "V_Uid",
    "V_Closure",
    "V_Custom",
    "V_Ordinal",
    "View",
    "ErasedClosure",
    "Value",
]

# def Imandrax_api_eval.Value.cstor_descriptor
@dataclass(slots=True, frozen=True)
class CstorDescriptor:
    cd_idx: int
    cd_name: core_uid.Uid

def CstorDescriptor_of_twine(d: twine.Decoder, off: int) -> CstorDescriptor:
    fields = list(d.get_array(off=off))
    cd_idx = d.get_int(off=fields[0])
    cd_name = core_uid.Uid_of_twine(d=d, off=fields[1])
    return CstorDescriptor(cd_idx=cd_idx, cd_name=cd_name)

# def Imandrax_api_eval.Value.record_descriptor
@dataclass(slots=True, frozen=True)
class RecordDescriptor:
    rd_name: core_uid.Uid
    rd_fields: list[core_uid.Uid]

def RecordDescriptor_of_twine(d: twine.Decoder, off: int) -> RecordDescriptor:
    fields = list(d.get_array(off=off))
    rd_name = core_uid.Uid_of_twine(d=d, off=fields[0])
    rd_fields = [core_uid.Uid_of_twine(d=d, off=x) for x in d.get_array(off=fields[1])]
    return RecordDescriptor(rd_name=rd_name, rd_fields=rd_fields)

# def Imandrax_api_eval.Value.view
@dataclass(slots=True, frozen=True)
class V_True[V, Closure]:
    pass

@dataclass(slots=True, frozen=True)
class V_False[V, Closure]:
    pass

@dataclass(slots=True, frozen=True)
class V_Int[V, Closure]:
    arg: int

def V_Int_of_twine[V, Closure](d: twine.Decoder, d0: twine.DecoderFn[V], d1: twine.DecoderFn[Closure], _tw_args: tuple[int, ...]) -> V_Int[V, Closure]:
    decode_V = d0
    decode_Closure = d1
    arg = d.get_int(off=_tw_args[0])
    return V_Int(arg=arg)

@dataclass(slots=True, frozen=True)
class V_Real[V, Closure]:
    arg: tuple[int, int]

def V_Real_of_twine[V, Closure](d: twine.Decoder, d0: twine.DecoderFn[V], d1: twine.DecoderFn[Closure], _tw_args: tuple[int, ...]) -> V_Real[V, Closure]:
    decode_V = d0
    decode_Closure = d1
    arg = _rt.decode_q(d=d, off=_tw_args[0])
    return V_Real(arg=arg)

@dataclass(slots=True, frozen=True)
class V_String[V, Closure]:
    arg: str

def V_String_of_twine[V, Closure](d: twine.Decoder, d0: twine.DecoderFn[V], d1: twine.DecoderFn[Closure], _tw_args: tuple[int, ...]) -> V_String[V, Closure]:
    decode_V = d0
    decode_Closure = d1
    arg = d.get_str(off=_tw_args[0])
    return V_String(arg=arg)

@dataclass(slots=True, frozen=True)
class V_Cstor[V, Closure]:
    args: tuple[CstorDescriptor, list[V]]

def V_Cstor_of_twine[V, Closure](d: twine.Decoder, d0: twine.DecoderFn[V], d1: twine.DecoderFn[Closure], _tw_args: tuple[int, ...]) -> V_Cstor[V, Closure]:
    decode_V = d0
    decode_Closure = d1
    cargs = (CstorDescriptor_of_twine(d=d, off=_tw_args[0]), [decode_V(d=d, off=x) for x in d.get_array(off=_tw_args[1])])
    return V_Cstor(args=cargs)

@dataclass(slots=True, frozen=True)
class V_Tuple[V, Closure]:
    arg: list[V]

def V_Tuple_of_twine[V, Closure](d: twine.Decoder, d0: twine.DecoderFn[V], d1: twine.DecoderFn[Closure], _tw_args: tuple[int, ...]) -> V_Tuple[V, Closure]:
    decode_V = d0
    decode_Closure = d1
    arg = [decode_V(d=d, off=x) for x in d.get_array(off=_tw_args[0])]
    return V_Tuple(arg=arg)

@dataclass(slots=True, frozen=True)
class V_Record[V, Closure]:
    args: tuple[RecordDescriptor, list[V]]

def V_Record_of_twine[V, Closure](d: twine.Decoder, d0: twine.DecoderFn[V], d1: twine.DecoderFn[Closure], _tw_args: tuple[int, ...]) -> V_Record[V, Closure]:
    decode_V = d0
    decode_Closure = d1
    cargs = (RecordDescriptor_of_twine(d=d, off=_tw_args[0]), [decode_V(d=d, off=x) for x in d.get_array(off=_tw_args[1])])
    return V_Record(args=cargs)

@dataclass(slots=True, frozen=True)
class V_QuotedTerm[V, Closure]:
    arg: mir_top_fun.TopFun

def V_QuotedTerm_of_twine[V, Closure](d: twine.Decoder, d0: twine.DecoderFn[V], d1: twine.DecoderFn[Closure], _tw_args: tuple[int, ...]) -> V_QuotedTerm[V, Closure]:
    decode_V = d0
    decode_Closure = d1
    arg = mir_top_fun.TopFun_of_twine(d=d, off=_tw_args[0])
    return V_QuotedTerm(arg=arg)

@dataclass(slots=True, frozen=True)
class V_Uid[V, Closure]:
    arg: core_uid.Uid

def V_Uid_of_twine[V, Closure](d: twine.Decoder, d0: twine.DecoderFn[V], d1: twine.DecoderFn[Closure], _tw_args: tuple[int, ...]) -> V_Uid[V, Closure]:
    decode_V = d0
    decode_Closure = d1
    arg = core_uid.Uid_of_twine(d=d, off=_tw_args[0])
    return V_Uid(arg=arg)

@dataclass(slots=True, frozen=True)
class V_Closure[V, Closure]:
    arg: Closure

def V_Closure_of_twine[V, Closure](d: twine.Decoder, d0: twine.DecoderFn[V], d1: twine.DecoderFn[Closure], _tw_args: tuple[int, ...]) -> V_Closure[V, Closure]:
    decode_V = d0
    decode_Closure = d1
    arg = decode_Closure(d=d, off=_tw_args[0])
    return V_Closure(arg=arg)

@dataclass(slots=True, frozen=True)
class V_Custom[V, Closure]:
    arg: _rt.Custom_value

def V_Custom_of_twine[V, Closure](d: twine.Decoder, d0: twine.DecoderFn[V], d1: twine.DecoderFn[Closure], _tw_args: tuple[int, ...]) -> V_Custom[V, Closure]:
    decode_V = d0
    decode_Closure = d1
    arg = _rt.decode_custom_value(d=d, off=_tw_args[0])
    return V_Custom(arg=arg)

@dataclass(slots=True, frozen=True)
class V_Ordinal[V, Closure]:
    arg: eval_ordinal.Ordinal

def V_Ordinal_of_twine[V, Closure](d: twine.Decoder, d0: twine.DecoderFn[V], d1: twine.DecoderFn[Closure], _tw_args: tuple[int, ...]) -> V_Ordinal[V, Closure]:
    decode_V = d0
    decode_Closure = d1
    arg = eval_ordinal.Ordinal_of_twine(d=d, off=_tw_args[0])
    return V_Ordinal(arg=arg)

type View[V, Closure] = V_True[V, Closure] | V_False[V, Closure] | V_Int[V, Closure] | V_Real[V, Closure] | V_String[V, Closure] | V_Cstor[V, Closure] | V_Tuple[V, Closure] | V_Record[V, Closure] | V_QuotedTerm[V, Closure] | V_Uid[V, Closure] | V_Closure[V, Closure] | V_Custom[V, Closure] | V_Ordinal[V, Closure]

def View_of_twine[V, Closure](d: twine.Decoder, d0: twine.DecoderFn[V], d1: twine.DecoderFn[Closure], off: int) -> View[V, Closure]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             return V_True[V, Closure]()
         case twine.Constructor(idx=1, args=args):
             return V_False[V, Closure]()
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return V_Int_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return V_Real_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=4, args=args):
             args = tuple(args)
             return V_String_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=5, args=args):
             args = tuple(args)
             return V_Cstor_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=6, args=args):
             args = tuple(args)
             return V_Tuple_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=7, args=args):
             args = tuple(args)
             return V_Record_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=8, args=args):
             args = tuple(args)
             return V_QuotedTerm_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=9, args=args):
             args = tuple(args)
             return V_Uid_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=10, args=args):
             args = tuple(args)
             return V_Closure_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=11, args=args):
             args = tuple(args)
             return V_Custom_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=12, args=args):
             args = tuple(args)
             return V_Ordinal_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected View, got invalid constructor {idx}')

# def Imandrax_api_eval.Value.erased_closure
@dataclass(slots=True, frozen=True)
class ErasedClosure:
    missing: int

def ErasedClosure_of_twine(d: twine.Decoder, off: int) -> ErasedClosure:
    fields = list(d.get_array(off=off))
    missing = d.get_int(off=fields[0])
    return ErasedClosure(missing=missing)

# def Imandrax_api_eval.Value.t
@dataclass(slots=True, frozen=True)
class Value:
    v: View[Value, ErasedClosure]

def Value_of_twine(d: twine.Decoder, off: int) -> Value:
    x = View_of_twine(d=d, off=off, d0=(lambda d, off: Value_of_twine(d=d, off=off)), d1=(lambda d, off: ErasedClosure_of_twine(d=d, off=off))) # single unboxed field
    return Value(v=x)

