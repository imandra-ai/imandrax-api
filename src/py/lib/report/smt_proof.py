# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_report.Smt_proof`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..report import instantiation as report_instantiation
from ..report import expansion as report_expansion
from ..core import logic_fragment as core_logic_fragment

__all__ = [
    "SmtProof",
]

# def Imandrax_api_report.Smt_proof.t
@dataclass(slots=True, frozen=True)
class SmtProof[Term]:
    logic: core_logic_fragment.LogicFragment
    unsat_core: list[Term]
    expansions: list[report_expansion.Expansion[Term]]
    instantiations: list[report_instantiation.Instantiation[Term]]

def SmtProof_of_twine[Term](d: twine.Decoder, d0: twine.DecoderFn[Term], off: int) -> SmtProof[Term]:
    decode_Term = d0
    fields = list(d.get_array(off=off))
    logic = core_logic_fragment.LogicFragment_of_twine(d=d, off=fields[0])
    unsat_core = [decode_Term(d=d, off=x) for x in d.get_array(off=fields[1])]
    expansions = [report_expansion.Expansion_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off))) for x in d.get_array(off=fields[2])]
    instantiations = [report_instantiation.Instantiation_of_twine(d=d, off=x, d0=(lambda d, off: decode_Term(d=d, off=off))) for x in d.get_array(off=fields[3])]
    return SmtProof(logic=logic, unsat_core=unsat_core, expansions=expansions, instantiations=instantiations)

