# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_tasks.PO_res`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..report import report as report_report
from ..proof import proof_term as proof_proof_term
from ..mir import type as mir_type
from ..mir import term as mir_term
from ..mir import sequent as mir_sequent
from ..error import error_core as error_error_core
from ..core import upto as core_upto
from ..core import sub_anchor as core_sub_anchor
from ..core import statistics as core_statistics
from ..core import in_mem_archive as core_in_mem_archive
from ..core import anchor as core_anchor
from ..common import sequent as common_sequent
from ..common import proof_obligation as common_proof_obligation
from ..common import model as common_model
from ..ca_store import ca_ptr as ca_store_ca_ptr

__all__ = [
    "SubRes",
    "ProofFound",
    "VerifiedUpto",
    "Instance",
    "NoProof",
    "Unsat",
    "SuccessProof",
    "SuccessInstance",
    "SuccessVerifiedUpto",
    "SuccessTestOk",
    "Success",
    "ErrorNoProof",
    "ErrorUnsat",
    "ErrorInvalidModel",
    "ErrorError",
    "Error",
    "Result",
    "ShallowPoly",
    "FullPoly",
    "Shallow",
    "Full",
]

# def Imandrax_api_tasks.PO_res.sub_res
@dataclass(slots=True, frozen=True)
class SubRes[Term]:
    sub_anchor: core_sub_anchor.SubAnchor
    goal: common_sequent.Sequent[Term]
    sub_goals: list[common_sequent.Sequent[Term]]
    res: None | str

def SubRes_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], off: int) -> SubRes[Term]:
    decode_Term = d0
    fields = list(d.get_array(off=off))
    sub_anchor = core_sub_anchor.SubAnchor_of_twine(d=d, off=fields[0])
    goal = common_sequent.Sequent_of_twine(d=d, off=fields[1], d0=(lambda d, off: decode_Term(d=d, off=off)))
    sub_goals = [common_sequent.Sequent_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off))) for x in d.get_array(off=fields[2])]
    res = _rt.twine_result(d=d, off=fields[3], d0=lambda d, off: d.get_null(off=off), d1=lambda d, off: d.get_str(off=off))
    return SubRes(sub_anchor=sub_anchor, goal=goal, sub_goals=sub_goals, res=res)

# def Imandrax_api_tasks.PO_res.proof_found
@dataclass(slots=True, frozen=True)
class ProofFound[Term, Ty]:
    anchor: core_anchor.Anchor
    proof: proof_proof_term.ProofTerm[Term, Ty]
    sub_anchor: None | core_sub_anchor.SubAnchor

def ProofFound_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> ProofFound[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    anchor = core_anchor.Anchor_of_twine(d=d, off=fields[0])
    proof = proof_proof_term.ProofTerm_of_twine(d=d, off=fields[1], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    sub_anchor = twine.optional(d=d, off=fields[2], d0=lambda d, off: core_sub_anchor.SubAnchor_of_twine(d=d, off=off))
    return ProofFound(anchor=anchor, proof=proof, sub_anchor=sub_anchor)

# def Imandrax_api_tasks.PO_res.verified_upto
@dataclass(slots=True, frozen=True)
class VerifiedUpto:
    anchor: core_anchor.Anchor
    upto: core_upto.Upto

def VerifiedUpto_of_twine(d: twine.Decoder, off: int) -> VerifiedUpto:
    fields = list(d.get_array(off=off))
    anchor = core_anchor.Anchor_of_twine(d=d, off=fields[0])
    upto = core_upto.Upto_of_twine(d=d, off=fields[1])
    return VerifiedUpto(anchor=anchor, upto=upto)

# def Imandrax_api_tasks.PO_res.instance
@dataclass(slots=True, frozen=True)
class Instance[Term, Ty]:
    anchor: core_anchor.Anchor
    model: common_model.Model[Term, Ty]

def Instance_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> Instance[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    anchor = core_anchor.Anchor_of_twine(d=d, off=fields[0])
    model = common_model.Model_of_twine(d=d, off=fields[1], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    return Instance(anchor=anchor, model=model)

# def Imandrax_api_tasks.PO_res.no_proof
@dataclass(slots=True, frozen=True)
class NoProof[Term, Ty]:
    err: error_error_core.ErrorCore
    counter_model: None | common_model.Model[Term, Ty]
    subgoals: list[mir_sequent.Sequent]
    sub_anchor: None | core_sub_anchor.SubAnchor

def NoProof_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> NoProof[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    err = error_error_core.ErrorCore_of_twine(d=d, off=fields[0])
    counter_model = twine.optional(d=d, off=fields[1], d0=lambda d, off: common_model.Model_of_twine(d=d, off=off, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))))
    subgoals = [mir_sequent.Sequent_of_twine(d=d, off=x) for x in d.get_array(off=fields[2])]
    sub_anchor = twine.optional(d=d, off=fields[3], d0=lambda d, off: core_sub_anchor.SubAnchor_of_twine(d=d, off=off))
    return NoProof(err=err, counter_model=counter_model, subgoals=subgoals, sub_anchor=sub_anchor)

# def Imandrax_api_tasks.PO_res.unsat
@dataclass(slots=True, frozen=True)
class Unsat[Term, Ty]:
    anchor: core_anchor.Anchor
    err: error_error_core.ErrorCore
    proof: proof_proof_term.ProofTerm[Term, Ty]
    sub_anchor: None | core_sub_anchor.SubAnchor

def Unsat_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> Unsat[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    anchor = core_anchor.Anchor_of_twine(d=d, off=fields[0])
    err = error_error_core.ErrorCore_of_twine(d=d, off=fields[1])
    proof = proof_proof_term.ProofTerm_of_twine(d=d, off=fields[2], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    sub_anchor = twine.optional(d=d, off=fields[3], d0=lambda d, off: core_sub_anchor.SubAnchor_of_twine(d=d, off=off))
    return Unsat(anchor=anchor, err=err, proof=proof, sub_anchor=sub_anchor)

# def Imandrax_api_tasks.PO_res.success
@dataclass(slots=True, frozen=True)
class SuccessProof[Term, Ty]:
    arg: ProofFound[Term, Ty]

def SuccessProof_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> SuccessProof[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = ProofFound_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    return SuccessProof(arg=arg)

@dataclass(slots=True, frozen=True)
class SuccessInstance[Term, Ty]:
    arg: Instance[Term, Ty]

def SuccessInstance_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> SuccessInstance[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = Instance_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    return SuccessInstance(arg=arg)

@dataclass(slots=True, frozen=True)
class SuccessVerifiedUpto[Term, Ty]:
    arg: VerifiedUpto

def SuccessVerifiedUpto_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> SuccessVerifiedUpto[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = VerifiedUpto_of_twine(d=d, off=_tw_args[0])
    return SuccessVerifiedUpto(arg=arg)

@dataclass(slots=True, frozen=True)
class SuccessTestOk[Term, Ty]:
    pass

type Success[Term, Ty] = SuccessProof[Term, Ty] | SuccessInstance[Term, Ty] | SuccessVerifiedUpto[Term, Ty] | SuccessTestOk[Term, Ty]

def Success_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> Success[Term, Ty]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return SuccessProof_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return SuccessInstance_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return SuccessVerifiedUpto_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=3, args=args):
             return SuccessTestOk[Term, Ty]()
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Success, got invalid constructor {idx}')

# def Imandrax_api_tasks.PO_res.error
@dataclass(slots=True, frozen=True)
class ErrorNoProof[Term, Ty]:
    arg: NoProof[Term, Ty]

def ErrorNoProof_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ErrorNoProof[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = NoProof_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    return ErrorNoProof(arg=arg)

@dataclass(slots=True, frozen=True)
class ErrorUnsat[Term, Ty]:
    arg: Unsat[Term, Ty]

def ErrorUnsat_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ErrorUnsat[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = Unsat_of_twine(d=d, off=_tw_args[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    return ErrorUnsat(arg=arg)

@dataclass(slots=True, frozen=True)
class ErrorInvalidModel[Term, Ty]:
    args: tuple[error_error_core.ErrorCore, common_model.Model[Term, Ty]]

def ErrorInvalidModel_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ErrorInvalidModel[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    cargs = (error_error_core.ErrorCore_of_twine(d=d, off=_tw_args[0]), common_model.Model_of_twine(d=d, off=_tw_args[1], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))))
    return ErrorInvalidModel(args=cargs)

@dataclass(slots=True, frozen=True)
class ErrorError[Term, Ty]:
    arg: error_error_core.ErrorCore

def ErrorError_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], _tw_args: tuple[int, ...]) -> ErrorError[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    arg = error_error_core.ErrorCore_of_twine(d=d, off=_tw_args[0])
    return ErrorError(arg=arg)

type Error[Term, Ty] = ErrorNoProof[Term, Ty] | ErrorUnsat[Term, Ty] | ErrorInvalidModel[Term, Ty] | ErrorError[Term, Ty]

def Error_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> Error[Term, Ty]:
    match d.get_cstor(off=off):
         case twine.Constructor(idx=0, args=args):
             args = tuple(args)
             return ErrorNoProof_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=1, args=args):
             args = tuple(args)
             return ErrorUnsat_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=2, args=args):
             args = tuple(args)
             return ErrorInvalidModel_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=3, args=args):
             args = tuple(args)
             return ErrorError_of_twine(d=d, _tw_args=args, d0=d0, d1=d1)
         case twine.Constructor(idx=idx):
             raise twine.Error(f'expected Error, got invalid constructor {idx}')

# def Imandrax_api_tasks.PO_res.result
type Result[A, Term, Ty] = A | Error[Term, Ty]

def Result_of_twine[A, Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[A], d1: twine.DecoderFn[Term], d2: twine.DecoderFn[Ty], off: int) -> Result[A, Term, Ty]:
    decode_A = d0
    decode_Term = d1
    decode_Ty = d2
    return _rt.twine_result(d=d, off=off, d0=lambda d, off: decode_A(d=d, off=off), d1=lambda d, off: Error_of_twine(d=d, off=off, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))))

# def Imandrax_api_tasks.PO_res.shallow_poly
@dataclass(slots=True, frozen=True)
class ShallowPoly[Term, Ty]:
    from_: ca_store_ca_ptr.CaPtr[common_proof_obligation.ProofObligation[Term, Ty]]
    res: Result[Success[Term, Ty], Term, Ty]
    stats: core_statistics.Statistics
    report: core_in_mem_archive.InMemArchive[report_report.Report]
    sub_res: list[list[SubRes[Term]]]

def ShallowPoly_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> ShallowPoly[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    from_ = ca_store_ca_ptr.CaPtr_of_twine(d=d, off=fields[0], d0=(lambda d, off: common_proof_obligation.ProofObligation_of_twine(d=d, off=off, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))))
    res = Result_of_twine(d=d, off=fields[1], d0=(lambda d, off: Success_of_twine(d=d, off=off, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))), d1=(lambda d, off: decode_Term(d=d, off=off)), d2=(lambda d, off: decode_Ty(d=d, off=off)))
    stats = core_statistics.Statistics_of_twine(d=d, off=fields[2])
    report = core_in_mem_archive.InMemArchive_of_twine(d=d, off=fields[3], d0=(lambda d, off: report_report.Report_of_twine(d=d, off=off)))
    sub_res = [[SubRes_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off))) for x in d.get_array(off=x)] for x in d.get_array(off=fields[4])]
    return ShallowPoly(from_=from_, res=res, stats=stats, report=report, sub_res=sub_res)

# def Imandrax_api_tasks.PO_res.full_poly
@dataclass(slots=True, frozen=True)
class FullPoly[Term, Ty]:
    from_: common_proof_obligation.ProofObligation[Term, Ty]
    res: Result[Success[Term, Ty], Term, Ty]
    stats: core_statistics.Statistics
    report: core_in_mem_archive.InMemArchive[report_report.Report]
    sub_res: list[list[SubRes[Term]]]

def FullPoly_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> FullPoly[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    from_ = common_proof_obligation.ProofObligation_of_twine(d=d, off=fields[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    res = Result_of_twine(d=d, off=fields[1], d0=(lambda d, off: Success_of_twine(d=d, off=off, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))), d1=(lambda d, off: decode_Term(d=d, off=off)), d2=(lambda d, off: decode_Ty(d=d, off=off)))
    stats = core_statistics.Statistics_of_twine(d=d, off=fields[2])
    report = core_in_mem_archive.InMemArchive_of_twine(d=d, off=fields[3], d0=(lambda d, off: report_report.Report_of_twine(d=d, off=off)))
    sub_res = [[SubRes_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off))) for x in d.get_array(off=x)] for x in d.get_array(off=fields[4])]
    return FullPoly(from_=from_, res=res, stats=stats, report=report, sub_res=sub_res)

# def Imandrax_api_tasks.PO_res.Shallow.t
type Shallow = ShallowPoly[mir_term.Term, mir_type.Type]

def Shallow_of_twine(d: twine.Decoder, off: int) -> Shallow:
    return ShallowPoly_of_twine(d=d, off=off, d0=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

# def Imandrax_api_tasks.PO_res.full.t
type Full = FullPoly[mir_term.Term, mir_type.Type]

def Full_of_twine(d: twine.Decoder, off: int) -> Full:
    return FullPoly_of_twine(d=d, off=off, d0=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

