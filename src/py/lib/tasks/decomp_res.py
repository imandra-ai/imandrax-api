# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_tasks.Decomp_res`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..tasks import decomp_task as tasks_decomp_task
from ..report import report as report_report
from ..mir import type as mir_type
from ..mir import term as mir_term
from ..error import error_core as error_error_core
from ..core import statistics as core_statistics
from ..core import in_mem_archive as core_in_mem_archive
from ..core import anchor as core_anchor
from ..common import fun_decomp as common_fun_decomp
from ..ca_store import ca_ptr as ca_store_ca_ptr

__all__ = [
    "Success",
    "ErrorError",
    "Error",
    "Result",
    "ShallowPoly",
    "FullPoly",
    "Shallow",
    "Full",
]

# def Imandrax_api_tasks.Decomp_res.success
@dataclass(slots=True, frozen=True)
class Success[Term, Ty]:
    anchor: core_anchor.Anchor
    decomp: common_fun_decomp.FunDecomp[Term, Ty]

def Success_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> Success[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    anchor = core_anchor.Anchor_of_twine(d=d, off=fields[0])
    decomp = common_fun_decomp.FunDecomp_of_twine(d=d, off=fields[1], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    return Success(anchor=anchor, decomp=decomp)

# def Imandrax_api_tasks.Decomp_res.error
@dataclass(slots=True, frozen=True)
class ErrorError:
    arg: error_error_core.ErrorCore

def ErrorError_of_twine(d: twine.Decoder, _tw_args: tuple[int, ...]) -> ErrorError:
    arg = error_error_core.ErrorCore_of_twine(d=d, off=_tw_args[0])
    return ErrorError(arg=arg)

type Error = ErrorError

def Error_of_twine(d: twine.Decoder, off: int) -> Error:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return ErrorError_of_twine(d=d, _tw_args=args)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Error, got invalid constructor {idx}')

# def Imandrax_api_tasks.Decomp_res.result
type Result[A] = A | Error

def Result_of_twine[A](d: twine.Decoder, d0: twine.DecoderFn[A], off: int) -> Result[A]:
    decode_A = d0
    return _rt.twine_result(d=d, off=off, d0=lambda d, off: decode_A(d=d, off=off), d1=lambda d, off: Error_of_twine(d=d, off=off))

# def Imandrax_api_tasks.Decomp_res.shallow_poly
@dataclass(slots=True, frozen=True)
class ShallowPoly[Term, Ty]:
    from_: ca_store_ca_ptr.CaPtr[tasks_decomp_task.Decomp[Term, Ty]]
    res: Result[Success[Term, Ty]]
    stats: core_statistics.Statistics
    report: core_in_mem_archive.InMemArchive[report_report.Report]

def ShallowPoly_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> ShallowPoly[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    from_ = ca_store_ca_ptr.CaPtr_of_twine(d=d, off=fields[0], d0=(lambda d, off: tasks_decomp_task.Decomp_of_twine(d=d, off=off, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))))
    res = Result_of_twine(d=d, off=fields[1], d0=(lambda d, off: Success_of_twine(d=d, off=off, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))))
    stats = core_statistics.Statistics_of_twine(d=d, off=fields[2])
    report = core_in_mem_archive.InMemArchive_of_twine(d=d, off=fields[3], d0=(lambda d, off: report_report.Report_of_twine(d=d, off=off)))
    return ShallowPoly(from_=from_, res=res, stats=stats, report=report)

# def Imandrax_api_tasks.Decomp_res.full_poly
@dataclass(slots=True, frozen=True)
class FullPoly[Term, Ty]:
    from_: tasks_decomp_task.Decomp[Term, Ty]
    res: Result[Success[Term, Ty]]
    stats: core_statistics.Statistics
    report: core_in_mem_archive.InMemArchive[report_report.Report]

def FullPoly_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> FullPoly[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    from_ = tasks_decomp_task.Decomp_of_twine(d=d, off=fields[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    res = Result_of_twine(d=d, off=fields[1], d0=(lambda d, off: Success_of_twine(d=d, off=off, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))))
    stats = core_statistics.Statistics_of_twine(d=d, off=fields[2])
    report = core_in_mem_archive.InMemArchive_of_twine(d=d, off=fields[3], d0=(lambda d, off: report_report.Report_of_twine(d=d, off=off)))
    return FullPoly(from_=from_, res=res, stats=stats, report=report)

# def Imandrax_api_tasks.Decomp_res.Shallow.t
type Shallow = ShallowPoly[mir_term.Term, mir_type.Type]

def Shallow_of_twine(d: twine.Decoder, off: int) -> Shallow:
    return ShallowPoly_of_twine(d=d, off=off, d0=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

# def Imandrax_api_tasks.Decomp_res.Full.t
type Full = FullPoly[mir_term.Term, mir_type.Type]

def Full_of_twine(d: twine.Decoder, off: int) -> Full:
    return FullPoly_of_twine(d=d, off=off, d0=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

