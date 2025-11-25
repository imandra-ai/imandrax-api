from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from typing import ClassVar as _ClassVar, Mapping as _Mapping, Optional as _Optional, Union as _Union

DESCRIPTOR: _descriptor.FileDescriptor

class Position(_message.Message):
    __slots__ = ("line", "col")
    LINE_FIELD_NUMBER: _ClassVar[int]
    COL_FIELD_NUMBER: _ClassVar[int]
    line: int
    col: int
    def __init__(self, line: _Optional[int] = ..., col: _Optional[int] = ...) -> None: ...

class Location(_message.Message):
    __slots__ = ("file", "start", "stop")
    FILE_FIELD_NUMBER: _ClassVar[int]
    START_FIELD_NUMBER: _ClassVar[int]
    STOP_FIELD_NUMBER: _ClassVar[int]
    file: str
    start: Position
    stop: Position
    def __init__(self, file: _Optional[str] = ..., start: _Optional[_Union[Position, _Mapping]] = ..., stop: _Optional[_Union[Position, _Mapping]] = ...) -> None: ...
