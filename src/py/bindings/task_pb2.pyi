from google.protobuf.internal import enum_type_wrapper as _enum_type_wrapper
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from typing import ClassVar as _ClassVar, Mapping as _Mapping, Optional as _Optional, Union as _Union

DESCRIPTOR: _descriptor.FileDescriptor

class TaskKind(int, metaclass=_enum_type_wrapper.EnumTypeWrapper):
    __slots__ = ()
    TASK_UNSPECIFIED: _ClassVar[TaskKind]
    TASK_EVAL: _ClassVar[TaskKind]
    TASK_CHECK_PO: _ClassVar[TaskKind]
    TASK_PROOF_CHECK: _ClassVar[TaskKind]
    TASK_DECOMP: _ClassVar[TaskKind]
TASK_UNSPECIFIED: TaskKind
TASK_EVAL: TaskKind
TASK_CHECK_PO: TaskKind
TASK_PROOF_CHECK: TaskKind
TASK_DECOMP: TaskKind

class TaskID(_message.Message):
    __slots__ = ("id",)
    ID_FIELD_NUMBER: _ClassVar[int]
    id: str
    def __init__(self, id: _Optional[str] = ...) -> None: ...

class Task(_message.Message):
    __slots__ = ("id", "kind")
    ID_FIELD_NUMBER: _ClassVar[int]
    KIND_FIELD_NUMBER: _ClassVar[int]
    id: TaskID
    kind: TaskKind
    def __init__(self, id: _Optional[_Union[TaskID, _Mapping]] = ..., kind: _Optional[_Union[TaskKind, str]] = ...) -> None: ...

class Origin(_message.Message):
    __slots__ = ("from_sym", "count")
    FROM_SYM_FIELD_NUMBER: _ClassVar[int]
    COUNT_FIELD_NUMBER: _ClassVar[int]
    from_sym: str
    count: int
    def __init__(self, from_sym: _Optional[str] = ..., count: _Optional[int] = ...) -> None: ...
