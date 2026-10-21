# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Pre_trigger`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import term as mir_term
from ..core import as_trigger as core_as_trigger

__all__ = [
    "PreTrigger",
]

# def Imandrax_api_mir.Pre_trigger.t
type PreTrigger = tuple[mir_term.Term, core_as_trigger.AsTrigger]

def PreTrigger_of_twine(d: twine.Decoder, off: int) -> PreTrigger:
    return (lambda tup: (mir_term.Term_of_twine(d=d, off=tup[0]), core_as_trigger.AsTrigger_of_twine(d=d, off=tup[1])))(tuple(d.get_array(off=off)))

