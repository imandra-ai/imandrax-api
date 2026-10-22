# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrakit_error.Error_core`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..error import kind as error_kind

__all__ = [
    "Message",
    "Stack",
    "ErrorCore",
]

# def Imandrakit_error.Error_core.message
@dataclass(slots=True, frozen=True)
class Message:
    msg: str
    data: None
    bt: None | str

def Message_of_twine(d: twine.Decoder, off: int) -> Message:
    fields = list(d.get_array(off=off))
    msg = d.get_str(off=fields[0])
    data = None
    bt = twine.optional(d=d, off=fields[2], d0=lambda d, off: d.get_str(off=off))
    return Message(msg=msg, data=data, bt=bt)

# def Imandrakit_error.Error_core.stack
type Stack = list[Message]

def Stack_of_twine(d: twine.Decoder, off: int) -> Stack:
    return [Message_of_twine(d=d, off=x) for x in d.get_array(off=off)]

# def Imandrakit_error.Error_core.t
@dataclass(slots=True, frozen=True)
class ErrorCore:
    process: str
    kind: error_kind.Kind
    msg: Message
    stack: Stack

def ErrorCore_of_twine(d: twine.Decoder, off: int) -> ErrorCore:
    fields = list(d.get_array(off=off))
    process = d.get_str(off=fields[0])
    kind = error_kind.Kind_of_twine(d=d, off=fields[1])
    msg = Message_of_twine(d=d, off=fields[2])
    stack = Stack_of_twine(d=d, off=fields[3])
    return ErrorCore(process=process, kind=kind, msg=msg, stack=stack)

