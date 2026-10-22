# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Db_ser`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..common import db_op as common_db_op
from ..ca_store import ca_ptr as ca_store_ca_ptr

__all__ = [
    "CaPtr",
    "DbSer",
]

# def Imandrax_api_common.Db_ser.ca_ptr
type CaPtr[A] = ca_store_ca_ptr.CaPtr[A]

def CaPtr_of_twine[A](d: twine.Decoder, d0: twine.DecoderFn[A], off: int) -> CaPtr[A]:
    decode_A = d0
    return ca_store_ca_ptr.CaPtr_of_twine(d=d, off=off, d0=(lambda d, off: decode_A(d=d, off=off)))

# def Imandrax_api_common.Db_ser.t_poly
@dataclass(slots=True, frozen=True)
class DbSer[Term, Ty]:
    ops: list[CaPtr[common_db_op.DbOp[Term, Ty]]]

def DbSer_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> DbSer[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    ops = [CaPtr_of_twine(d=d, off=x, d0=(lambda d, off: common_db_op.DbOp_of_twine(d=d, off=off, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off))))) for x in d.get_array(off=fields[0])]
    return DbSer(ops=ops)

