# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Db_ser`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import type as mir_type
from ..mir import term as mir_term
from ..common import db_ser as common_db_ser

__all__ = [
    "DbSer",
]

# def Imandrax_api_mir.Db_ser.t
type DbSer = common_db_ser.DbSer[mir_term.Term, mir_type.Type]

def DbSer_of_twine(d: twine.Decoder, off: int) -> DbSer:
    return common_db_ser.DbSer_of_twine(d=d, off=off, d0=(lambda d, off: mir_term.Term_of_twine(d=d, off=off)), d1=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

