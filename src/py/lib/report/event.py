# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_report.Event`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt

__all__ = [
    "EL_Atomic",
    "EL_EnterSpan",
    "EL_ExitSpan",
    "TLinear",
    "ET_Atomic",
    "ET_Span",
    "TTree",
]

# def Imandrax_api_report.Event.t_linear
@dataclass(slots=True, frozen=True)
class EL_Atomic[Atomic_ev]:
    ts: float
    ev: Atomic_ev


def EL_Atomic_of_twine[Atomic_ev](d: twine.Decoder, d0: twine.DecoderFn[Atomic_ev], _tw_args: tuple[int, ...]) -> EL_Atomic[Atomic_ev]:
    decode_Atomic_ev = d0
    ts = d.get_float(off=_tw_args[0])
    ev = decode_Atomic_ev(d=d, off=_tw_args[1])
    return EL_Atomic(ts=ts, ev=ev)


@dataclass(slots=True, frozen=True)
class EL_EnterSpan[Atomic_ev]:
    ts: float
    ev: Atomic_ev


def EL_EnterSpan_of_twine[Atomic_ev](d: twine.Decoder, d0: twine.DecoderFn[Atomic_ev], _tw_args: tuple[int, ...]) -> EL_EnterSpan[Atomic_ev]:
    decode_Atomic_ev = d0
    ts = d.get_float(off=_tw_args[0])
    ev = decode_Atomic_ev(d=d, off=_tw_args[1])
    return EL_EnterSpan(ts=ts, ev=ev)


@dataclass(slots=True, frozen=True)
class EL_ExitSpan[Atomic_ev]:
    ts: float


def EL_ExitSpan_of_twine[Atomic_ev](d: twine.Decoder, d0: twine.DecoderFn[Atomic_ev], _tw_args: tuple[int, ...]) -> EL_ExitSpan[Atomic_ev]:
    decode_Atomic_ev = d0
    ts = d.get_float(off=_tw_args[0])
    return EL_ExitSpan(ts=ts)


type TLinear[Atomic_ev] = EL_Atomic[Atomic_ev] | EL_EnterSpan[Atomic_ev] | EL_ExitSpan[Atomic_ev]

def TLinear_of_twine[Atomic_ev](d: twine.Decoder, d0: twine.DecoderFn[Atomic_ev], off: int) -> TLinear[Atomic_ev]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return EL_Atomic_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return EL_EnterSpan_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return EL_ExitSpan_of_twine(d=d, _tw_args=args, d0=d0)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected TLinear, got invalid constructor {idx}')

# def Imandrax_api_report.Event.t_tree
@dataclass(slots=True, frozen=True)
class ET_Atomic[Atomic_ev, Sub]:
    ts: float
    ev: Atomic_ev


def ET_Atomic_of_twine[Atomic_ev, Sub](d: twine.Decoder, d0: twine.DecoderFn[Atomic_ev], d1: twine.DecoderFn[Sub], _tw_args: tuple[int, ...]) -> ET_Atomic[Atomic_ev, Sub]:
    decode_Atomic_ev = d0
    decode_Sub = d1
    ts = d.get_float(off=_tw_args[0])
    ev = decode_Atomic_ev(d=d, off=_tw_args[1])
    return ET_Atomic(ts=ts, ev=ev)


@dataclass(slots=True, frozen=True)
class ET_Span[Atomic_ev, Sub]:
    ts: float
    duration: float
    ev: Atomic_ev
    sub: Sub


def ET_Span_of_twine[Atomic_ev, Sub](d: twine.Decoder, d0: twine.DecoderFn[Atomic_ev], d1: twine.DecoderFn[Sub], _tw_args: tuple[int, ...]) -> ET_Span[Atomic_ev, Sub]:
    decode_Atomic_ev = d0
    decode_Sub = d1
    ts = d.get_float(off=_tw_args[0])
    duration = d.get_float(off=_tw_args[1])
    ev = decode_Atomic_ev(d=d, off=_tw_args[2])
    sub = decode_Sub(d=d, off=_tw_args[3])
    return ET_Span(ts=ts, duration=duration, ev=ev, sub=sub)


type TTree[Atomic_ev, Sub] = ET_Atomic[Atomic_ev, Sub] | ET_Span[Atomic_ev, Sub]

def TTree_of_twine[Atomic_ev, Sub](d: twine.Decoder, d0: twine.DecoderFn[Atomic_ev], d1: twine.DecoderFn[Sub], off: int) -> TTree[Atomic_ev, Sub]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return ET_Atomic_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return ET_Span_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected TTree, got invalid constructor {idx}')

