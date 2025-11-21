import error_pb2 as _error_pb2
import session_pb2 as _session_pb2
import task_pb2 as _task_pb2
import artmsg_pb2 as _artmsg_pb2
from google.protobuf.internal import containers as _containers
from google.protobuf.internal import enum_type_wrapper as _enum_type_wrapper
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from typing import ClassVar as _ClassVar, Iterable as _Iterable, Mapping as _Mapping, Optional as _Optional, Union as _Union

DESCRIPTOR: _descriptor.FileDescriptor

class EvalResult(int, metaclass=_enum_type_wrapper.EnumTypeWrapper):
    __slots__ = ()
    EVAL_OK: _ClassVar[EvalResult]
    EVAL_ERRORS: _ClassVar[EvalResult]
EVAL_OK: EvalResult
EVAL_ERRORS: EvalResult

class CodeSnippet(_message.Message):
    __slots__ = ("session", "code")
    SESSION_FIELD_NUMBER: _ClassVar[int]
    CODE_FIELD_NUMBER: _ClassVar[int]
    session: _session_pb2.Session
    code: str
    def __init__(self, session: _Optional[_Union[_session_pb2.Session, _Mapping]] = ..., code: _Optional[str] = ...) -> None: ...

class CodeSnippetEvalResult(_message.Message):
    __slots__ = ("res", "duration_s", "tasks", "errors")
    RES_FIELD_NUMBER: _ClassVar[int]
    DURATION_S_FIELD_NUMBER: _ClassVar[int]
    TASKS_FIELD_NUMBER: _ClassVar[int]
    ERRORS_FIELD_NUMBER: _ClassVar[int]
    res: EvalResult
    duration_s: float
    tasks: _containers.RepeatedCompositeFieldContainer[_task_pb2.Task]
    errors: _containers.RepeatedCompositeFieldContainer[_error_pb2.Error]
    def __init__(self, res: _Optional[_Union[EvalResult, str]] = ..., duration_s: _Optional[float] = ..., tasks: _Optional[_Iterable[_Union[_task_pb2.Task, _Mapping]]] = ..., errors: _Optional[_Iterable[_Union[_error_pb2.Error, _Mapping]]] = ...) -> None: ...

class ParseQuery(_message.Message):
    __slots__ = ("code",)
    CODE_FIELD_NUMBER: _ClassVar[int]
    code: str
    def __init__(self, code: _Optional[str] = ...) -> None: ...

class ArtifactListQuery(_message.Message):
    __slots__ = ("task_id",)
    TASK_ID_FIELD_NUMBER: _ClassVar[int]
    task_id: _task_pb2.TaskID
    def __init__(self, task_id: _Optional[_Union[_task_pb2.TaskID, _Mapping]] = ...) -> None: ...

class ArtifactListResult(_message.Message):
    __slots__ = ("kinds",)
    KINDS_FIELD_NUMBER: _ClassVar[int]
    kinds: _containers.RepeatedScalarFieldContainer[str]
    def __init__(self, kinds: _Optional[_Iterable[str]] = ...) -> None: ...

class ArtifactGetQuery(_message.Message):
    __slots__ = ("task_id", "kind")
    TASK_ID_FIELD_NUMBER: _ClassVar[int]
    KIND_FIELD_NUMBER: _ClassVar[int]
    task_id: _task_pb2.TaskID
    kind: str
    def __init__(self, task_id: _Optional[_Union[_task_pb2.TaskID, _Mapping]] = ..., kind: _Optional[str] = ...) -> None: ...

class Artifact(_message.Message):
    __slots__ = ("art",)
    ART_FIELD_NUMBER: _ClassVar[int]
    art: _artmsg_pb2.Art
    def __init__(self, art: _Optional[_Union[_artmsg_pb2.Art, _Mapping]] = ...) -> None: ...

class ArtifactZip(_message.Message):
    __slots__ = ("art_zip",)
    ART_ZIP_FIELD_NUMBER: _ClassVar[int]
    art_zip: bytes
    def __init__(self, art_zip: _Optional[bytes] = ...) -> None: ...
