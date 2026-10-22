# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_proof.Var_poly`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid

__all__ = [
    "VarPoly",
]

# def Imandrax_api_proof.Var_poly.t
type VarPoly[Ty] = tuple[core_uid.Uid, Ty]

def VarPoly_of_twine[Ty](d: twine.Decoder, d0: twine.DecoderFn[Ty], off: int) -> VarPoly[Ty]:
    decode_Ty = d0
    return (lambda tup: (core_uid.Uid_of_twine(d=d, off=tup[0]), decode_Ty(d=d, off=tup[1])))(tuple(d.get_array(off=off)))

