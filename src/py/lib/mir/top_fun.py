# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Top_fun`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import var as mir_var
from ..mir import term as mir_term

__all__ = [
    "TopFun",
]

# def Imandrax_api_mir.Top_fun.t
type TopFun = tuple[list[mir_var.Var], mir_term.Term]

def TopFun_of_twine(d: twine.Decoder, off: int) -> TopFun:
    return (lambda tup: ([mir_var.Var_of_twine(d=d, off=x) for x in d.get_array(off=tup[0])], mir_term.Term_of_twine(d=d, off=tup[1])))(tuple(d.get_array(off=off)))

