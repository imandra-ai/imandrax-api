# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Sequent`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt

__all__ = [
    "Sequent",
]

# def Imandrax_api_common.Sequent.t_poly
@dataclass(slots=True, frozen=True)
class Sequent[Term]:
    hyps: list[tuple[None | str, Term]]
    concls: list[tuple[None | str, Term]]

def Sequent_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], off: int) -> Sequent[Term]:
    decode_Term = d0
    fields = list(d.get_array(off=off))
    hyps = [(lambda tup: (twine.optional(d=d, off=tup[0], d0=lambda d, off: d.get_str(off=off)), decode_Term(d=d, off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[0])]
    concls = [(lambda tup: (twine.optional(d=d, off=tup[0], d0=lambda d, off: d.get_str(off=off)), decode_Term(d=d, off=tup[1])))(tuple(d.get_array(off=x))) for x in d.get_array(off=fields[1])]
    return Sequent(hyps=hyps, concls=concls)

