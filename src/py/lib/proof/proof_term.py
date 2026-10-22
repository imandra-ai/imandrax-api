# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_proof.Proof_term`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..proof import view as proof_view
from ..common import sequent as common_sequent

__all__ = [
    "ProofTerm",
]

# def Imandrax_api_proof.Proof_term.t_poly
@dataclass(slots=True, frozen=True)
class ProofTerm[Term, Ty]:
    id: int
    concl: common_sequent.Sequent[Term]
    view: proof_view.View[Term, Ty, ProofTerm[Term, Ty]]

def ProofTerm_of_twine[Term, Ty](d: twine.Decoder, d0: twine.DecoderFn[Term], d1: twine.DecoderFn[Ty], off: int) -> ProofTerm[Term, Ty]:
    decode_Term = d0
    decode_Ty = d1
    fields = list(d.get_array(off=off))
    id = d.get_int(off=fields[0])
    concl = common_sequent.Sequent_of_twine(d=d, off=fields[1], d0=(lambda d, off: decode_Term(d=d, off=off)))
    view = proof_view.View_of_twine(d=d, off=fields[2], d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)), d2=(lambda d, off: ProofTerm_of_twine(d=d, off=off, d0=(lambda d, off: decode_Term(d=d, off=off)), d1=(lambda d, off: decode_Ty(d=d, off=off)))))
    return ProofTerm(id=id, concl=concl, view=view)

