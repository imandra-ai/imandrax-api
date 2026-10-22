# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.Logic_fragment`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt

__all__ = [
    "LogicFragment",
]

# def Imandrax_api.Logic_fragment.t
type LogicFragment = int

def LogicFragment_of_twine(d: twine.Decoder, off: int) -> LogicFragment:
    return d.get_int(off=off)

