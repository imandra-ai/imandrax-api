# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_tasks.Eval_task`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import type as mir_type
from ..mir import term as mir_term
from ..core import anchor as core_anchor
from ..common import var as common_var
from ..common import db_ser as common_db_ser

__all__ = [
    "EvalTask",
    "Mir",
]

# def Imandrax_api_tasks.Eval_task.t_poly
@dataclass(slots=True, frozen=True)
class EvalTask[Term, Ty]:
    db: common_db_ser.DbSer[Term, Ty]
    term: tuple[list[common_var.Var[Ty]], Term]
    anchor: core_anchor.Anchor
    timeout: None | int

def EvalTask_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> EvalTask[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    db = common_db_ser.DbSer_of_twine(d=d, off=fields[0], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    term = (lambda tup: ([common_var.Var_of_twine(d=d, off=x, d0=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=tup[0])], decode_Term(d=d, off=tup[1])))(tuple(d.get_array(off=fields[1])))
    anchor = core_anchor.Anchor_of_twine(d=d, off=fields[2])
    timeout = twine.optional(d=d, off=fields[3], d0=lambda d, off: d.get_int(off=off))
    return EvalTask(db=db, term=term, anchor=anchor, timeout=timeout)

# def Imandrax_api_tasks.Eval_task.Mir.t
type Mir = EvalTask[mir_term.Term, mir_type.Type]

def Mir_of_twine(d: twine.Decoder, off: int) -> Mir:
    return EvalTask_of_twine(d=d, off=off, d0=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

