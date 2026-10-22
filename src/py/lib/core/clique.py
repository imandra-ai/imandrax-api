# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.Clique`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid_set as core_uid_set

__all__ = [
    "Clique",
]

# def Imandrax_api.Clique.t
type Clique = core_uid_set.UidSet

def Clique_of_twine(d: twine.Decoder, off: int) -> Clique:
    return core_uid_set.UidSet_of_twine(d=d, off=off)

