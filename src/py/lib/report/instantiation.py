# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_report.Instantiation`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid

__all__ = [
    "Instantiation",
]

# def Imandrax_api_report.Instantiation.t
@dataclass(slots=True, frozen=True)
class Instantiation[Term]:
    assertion: Term
    from_rule: core_uid.Uid

def Instantiation_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], off: int) -> Instantiation[Term]:
    decode_Term = d0
    fields = list(d.get_array(off=off))
    assertion = decode_Term(d=d, off=fields[0])
    from_rule = core_uid.Uid_of_twine(d=d, off=fields[1])
    return Instantiation(assertion=assertion, from_rule=from_rule)

