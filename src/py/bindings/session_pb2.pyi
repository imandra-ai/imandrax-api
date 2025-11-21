import utils_pb2 as _utils_pb2
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from typing import ClassVar as _ClassVar, Mapping as _Mapping, Optional as _Optional, Union as _Union

DESCRIPTOR: _descriptor.FileDescriptor

class Session(_message.Message):
    __slots__ = ("id",)
    ID_FIELD_NUMBER: _ClassVar[int]
    id: str
    def __init__(self, id: _Optional[str] = ...) -> None: ...

class SessionCreate(_message.Message):
    __slots__ = ("po_check", "api_version")
    PO_CHECK_FIELD_NUMBER: _ClassVar[int]
    API_VERSION_FIELD_NUMBER: _ClassVar[int]
    po_check: bool
    api_version: str
    def __init__(self, po_check: bool = ..., api_version: _Optional[str] = ...) -> None: ...

class SessionOpen(_message.Message):
    __slots__ = ("id", "api_version")
    ID_FIELD_NUMBER: _ClassVar[int]
    API_VERSION_FIELD_NUMBER: _ClassVar[int]
    id: Session
    api_version: str
    def __init__(self, id: _Optional[_Union[Session, _Mapping]] = ..., api_version: _Optional[str] = ...) -> None: ...
