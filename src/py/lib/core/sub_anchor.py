# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.Sub_anchor`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt

__all__ = [
    "Fname",
    "SubAnchor",
]

# def Imandrax_api.Sub_anchor.fname
type Fname = str

def Fname_of_twine(d: twine.Decoder, off: int) -> Fname:
    return d.get_str(off=off)

# def Imandrax_api.Sub_anchor.t
@dataclass(slots=True, frozen=True)
class SubAnchor:
    fname: Fname
    anchor: int

def SubAnchor_of_twine(d: twine.Decoder, off: int) -> SubAnchor:
    fields = list(d.get_array(off=off))
    fname = Fname_of_twine(d=d, off=fields[0])
    anchor = d.get_int(off=fields[1])
    return SubAnchor(fname=fname, anchor=anchor)

