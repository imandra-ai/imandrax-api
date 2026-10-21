# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api.In_mem_archive`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt

__all__ = [
    "Raw",
    "InMemArchive",
]

# def Imandrax_api.In_mem_archive.raw
@dataclass(slots=True, frozen=True)
class Raw:
    ty: str
    compressed: bool
    data: bytes

def Raw_of_twine(d: twine.Decoder, off: int) -> Raw:
    fields = list(d.get_array(off=off))
    ty = d.get_str(off=fields[0])
    compressed = d.get_bool(off=fields[1])
    data = d.get_bytes(off=fields[2])
    return Raw(ty=ty, compressed=compressed, data=data)

# def Imandrax_api.In_mem_archive.t
type InMemArchive[A] = Raw

def InMemArchive_of_twine[A](d: twine.Decoder, d0: twine.DecoderFn[A], off: int) -> InMemArchive[A]:
    decode_A = d0
    return Raw_of_twine(d=d, off=off)

