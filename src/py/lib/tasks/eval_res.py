# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_tasks.Eval_res`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..eval import value as eval_value
from ..error import error_core as error_error_core

__all__ = [
    "Value",
    "Stats",
    "Success",
    "EvalRes",
]

# def Imandrax_api_tasks.Eval_res.value
type Value = eval_value.Value

def Value_of_twine(d: twine.Decoder, off: int) -> Value:
    return eval_value.Value_of_twine(d=d, off=off)

# def Imandrax_api_tasks.Eval_res.stats
@dataclass(slots=True, frozen=True)
class Stats:
    compile_time: float
    exec_time: float

def Stats_of_twine(d: twine.Decoder, off: int) -> Stats:
    fields = list(d.get_array(off=off))
    compile_time = d.get_float(off=fields[0])
    exec_time = d.get_float(off=fields[1])
    return Stats(compile_time=compile_time, exec_time=exec_time)

# def Imandrax_api_tasks.Eval_res.success
@dataclass(slots=True, frozen=True)
class Success:
    v: Value

def Success_of_twine(d: twine.Decoder, off: int) -> Success:
    x = Value_of_twine(d=d, off=off) # single unboxed field
    return Success(v=x)

# def Imandrax_api_tasks.Eval_res.t
@dataclass(slots=True, frozen=True)
class EvalRes:
    res: error_error_core.ErrorCore | Success
    stats: Stats

def EvalRes_of_twine(d: twine.Decoder, off: int) -> EvalRes:
    fields = list(d.get_array(off=off))
    res = _rt.twine_result(d=d, off=fields[0], d0=lambda d, off: Success_of_twine(d=d, off=off), d1=lambda d, off: error_error_core.ErrorCore_of_twine(d=d, off=off))
    stats = Stats_of_twine(d=d, off=fields[1])
    return EvalRes(res=res, stats=stats)

