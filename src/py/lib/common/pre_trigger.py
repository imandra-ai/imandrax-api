# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Pre_trigger`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import as_trigger as core_as_trigger

__all__ = [
    "PreTrigger",
]

# def Imandrax_api_common.Pre_trigger.t_poly
type PreTrigger[Term] = tuple[Term, core_as_trigger.AsTrigger]

def PreTrigger_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], off: int) -> PreTrigger[Term]:
    decode_Term = d0
    return (lambda tup: (decode_Term(d=d, off=tup[0]), core_as_trigger.AsTrigger_of_twine(d=d, off=tup[1])))(tuple(d.get_array(off=off)))

