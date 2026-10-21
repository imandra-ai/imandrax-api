# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_tasks.PO_task`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import type as mir_type
from ..mir import term as mir_term
from ..common import proof_obligation as common_proof_obligation
from ..common import db_ser as common_db_ser

__all__ = [
    "POTask",
    "Mir",
]

# def Imandrax_api_tasks.PO_task.t_poly
@dataclass(slots=True, frozen=True)
class POTask[Term, Ty]:
    from_sym: str
    count: int
    db: common_db_ser.DbSer[Term, Ty]
    po: common_proof_obligation.ProofObligation[Term, Ty]

def POTask_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> POTask[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    from_sym = d.get_str(off=fields[0])
    count = d.get_int(off=fields[1])
    db = common_db_ser.DbSer_of_twine(d=d, off=fields[2], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    po = common_proof_obligation.ProofObligation_of_twine(d=d, off=fields[3], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))
    return POTask(from_sym=from_sym, count=count, db=db, po=po)

# def Imandrax_api_tasks.PO_task.Mir.t
type Mir = POTask[mir_term.Term, mir_type.Type]

def Mir_of_twine(d: twine.Decoder, off: int) -> Mir:
    return POTask_of_twine(d=d, off=off, d0=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

