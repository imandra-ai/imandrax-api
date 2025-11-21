from google.protobuf.internal import containers as _containers
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from typing import ClassVar as _ClassVar, Iterable as _Iterable, Mapping as _Mapping, Optional as _Optional, Union as _Union

DESCRIPTOR: _descriptor.FileDescriptor

class StorageEntry(_message.Message):
    __slots__ = ("key", "value")
    KEY_FIELD_NUMBER: _ClassVar[int]
    VALUE_FIELD_NUMBER: _ClassVar[int]
    key: str
    value: bytes
    def __init__(self, key: _Optional[str] = ..., value: _Optional[bytes] = ...) -> None: ...

class Art(_message.Message):
    __slots__ = ("kind", "data", "api_version", "storage")
    KIND_FIELD_NUMBER: _ClassVar[int]
    DATA_FIELD_NUMBER: _ClassVar[int]
    API_VERSION_FIELD_NUMBER: _ClassVar[int]
    STORAGE_FIELD_NUMBER: _ClassVar[int]
    kind: str
    data: bytes
    api_version: str
    storage: _containers.RepeatedCompositeFieldContainer[StorageEntry]
    def __init__(self, kind: _Optional[str] = ..., data: _Optional[bytes] = ..., api_version: _Optional[str] = ..., storage: _Optional[_Iterable[_Union[StorageEntry, _Mapping]]] = ...) -> None: ...
