# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.Uid_set`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid

__all__ = [
    "UidSet",
]

# def Imandrax_api.Uid_set.t
type UidSet = set[core_uid.Uid]

def UidSet_of_twine(d: twine.Decoder, off:int) -> UidSet:
    return set(core_uid.Uid_of_twine(d=d, off=x) for x in d.get_array(off=off))

