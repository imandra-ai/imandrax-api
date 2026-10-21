# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.Statistics`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt

__all__ = [
    "Statistics",
]

# def Imandrax_api.Statistics.t
@dataclass(slots=True, frozen=True)
class Statistics:
    time_s: float
    tactic: None | list[tuple[str, str]]

def Statistics_of_twine(d: twine.Decoder, off: int) -> Statistics:
    fields = list(d.get_array(off=off))
    time_s = d.get_float(off=fields[0])
    tactic = twine.optional(d=d, off=fields[1], d0=lambda d, off: [(lambda tup: (d.get_str(off=tup[0]), d.get_str(off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=off)])
    return Statistics(time_s=time_s, tactic=tactic)

