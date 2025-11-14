import utils_pb2 as _utils_pb2
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from typing import ClassVar as _ClassVar, Optional as _Optional

DESCRIPTOR: _descriptor.FileDescriptor

class Gc_stats(_message.Message):
    __slots__ = ("heap_size_B", "major_collections", "minor_collections")
    HEAP_SIZE_B_FIELD_NUMBER: _ClassVar[int]
    MAJOR_COLLECTIONS_FIELD_NUMBER: _ClassVar[int]
    MINOR_COLLECTIONS_FIELD_NUMBER: _ClassVar[int]
    heap_size_B: int
    major_collections: int
    minor_collections: int
    def __init__(self, heap_size_B: _Optional[int] = ..., major_collections: _Optional[int] = ..., minor_collections: _Optional[int] = ...) -> None: ...

class VersionResponse(_message.Message):
    __slots__ = ("version", "git_version")
    VERSION_FIELD_NUMBER: _ClassVar[int]
    GIT_VERSION_FIELD_NUMBER: _ClassVar[int]
    version: str
    git_version: str
    def __init__(self, version: _Optional[str] = ..., git_version: _Optional[str] = ...) -> None: ...
