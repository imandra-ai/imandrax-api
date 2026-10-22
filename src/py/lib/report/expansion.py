# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_report.Expansion`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid

__all__ = [
    "Expansion",
]

# def Imandrax_api_report.Expansion.t
@dataclass(slots=True, frozen=True)
class Expansion[Term]:
    f_name: core_uid.Uid
    lhs: Term
    rhs: Term

def Expansion_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], off: int) -> Expansion[Term]:
    decode_Term = d0
    fields = list(d.get_array(off=off))
    f_name = core_uid.Uid_of_twine(d=d, off=fields[0])
    lhs = decode_Term(d=d, off=fields[1])
    rhs = decode_Term(d=d, off=fields[2])
    return Expansion(f_name=f_name, lhs=lhs, rhs=rhs)

