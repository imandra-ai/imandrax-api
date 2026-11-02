import locs_pb2 as _locs_pb2
from google.protobuf.internal import containers as _containers
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from typing import ClassVar as _ClassVar, Iterable as _Iterable, Mapping as _Mapping, Optional as _Optional, Union as _Union

DESCRIPTOR: _descriptor.FileDescriptor

class Error(_message.Message):
    __slots__ = ("msg", "kind", "stack", "process")
    class Message(_message.Message):
        __slots__ = ("msg", "locs", "backtrace")
        MSG_FIELD_NUMBER: _ClassVar[int]
        LOCS_FIELD_NUMBER: _ClassVar[int]
        BACKTRACE_FIELD_NUMBER: _ClassVar[int]
        msg: str
        locs: _containers.RepeatedCompositeFieldContainer[_locs_pb2.Location]
        backtrace: str
        def __init__(self, msg: _Optional[str] = ..., locs: _Optional[_Iterable[_Union[_locs_pb2.Location, _Mapping]]] = ..., backtrace: _Optional[str] = ...) -> None: ...
    MSG_FIELD_NUMBER: _ClassVar[int]
    KIND_FIELD_NUMBER: _ClassVar[int]
    STACK_FIELD_NUMBER: _ClassVar[int]
    PROCESS_FIELD_NUMBER: _ClassVar[int]
    msg: Error.Message
    kind: str
    stack: _containers.RepeatedCompositeFieldContainer[Error.Message]
    process: str
    def __init__(self, msg: _Optional[_Union[Error.Message, _Mapping]] = ..., kind: _Optional[str] = ..., stack: _Optional[_Iterable[_Union[Error.Message, _Mapping]]] = ..., process: _Optional[str] = ...) -> None: ...
