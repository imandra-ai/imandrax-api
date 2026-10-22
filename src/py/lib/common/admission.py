# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Admission`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid

__all__ = [
    "Admission",
]

# def Imandrax_api_common.Admission.t
@dataclass(slots=True, frozen=True)
class Admission:
    measured_subset: list[str]
    measure_fun: None | core_uid.Uid

def Admission_of_twine(d: twine.Decoder, off: int) -> Admission:
    fields = list(d.get_array(off=off))
    measured_subset = [d.get_str(off=x) for x in d.get_array(off=fields[0])]
    measure_fun = twine.optional(d=d, off=fields[1], d0=lambda d, off: core_uid.Uid_of_twine(d=d, off=off))
    return Admission(measured_subset=measured_subset, measure_fun=measure_fun)

