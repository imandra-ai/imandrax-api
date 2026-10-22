# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_mir.Type_schema`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..mir import type as mir_type
from ..common import type_schema as common_type_schema

__all__ = [
    "TypeSchema",
]

# def Imandrax_api_mir.Type_schema.t
type TypeSchema = common_type_schema.TypeSchema[mir_type.Type]

def TypeSchema_of_twine(d: twine.Decoder, off: int) -> TypeSchema:
    return common_type_schema.TypeSchema_of_twine(d=d, off=off, d0=(lambda d, off: mir_type.Type_of_twine(d=d, off=off)))

