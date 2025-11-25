import error_pb2 as _error_pb2
import utils_pb2 as _utils_pb2
import session_pb2 as _session_pb2
import artmsg_pb2 as _artmsg_pb2
import task_pb2 as _task_pb2
from google.protobuf.internal import containers as _containers
from google.protobuf.internal import enum_type_wrapper as _enum_type_wrapper
from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from typing import ClassVar as _ClassVar, Iterable as _Iterable, Mapping as _Mapping, Optional as _Optional, Union as _Union

DESCRIPTOR: _descriptor.FileDescriptor

class LiftBool(int, metaclass=_enum_type_wrapper.EnumTypeWrapper):
    __slots__ = ()
    Default: _ClassVar[LiftBool]
    NestedEqualities: _ClassVar[LiftBool]
    Equalities: _ClassVar[LiftBool]
    All: _ClassVar[LiftBool]

class ModelType(int, metaclass=_enum_type_wrapper.EnumTypeWrapper):
    __slots__ = ()
    Counter_example: _ClassVar[ModelType]
    Instance: _ClassVar[ModelType]
Default: LiftBool
NestedEqualities: LiftBool
Equalities: LiftBool
All: LiftBool
Counter_example: ModelType
Instance: ModelType

class SessionCreateReq(_message.Message):
    __slots__ = ("api_version",)
    API_VERSION_FIELD_NUMBER: _ClassVar[int]
    api_version: str
    def __init__(self, api_version: _Optional[str] = ...) -> None: ...

class DecomposeReq(_message.Message):
    __slots__ = ("session", "name", "assuming", "basis", "rule_specs", "prune", "ctx_simp", "lift_bool", "str", "timeout")
    SESSION_FIELD_NUMBER: _ClassVar[int]
    NAME_FIELD_NUMBER: _ClassVar[int]
    ASSUMING_FIELD_NUMBER: _ClassVar[int]
    BASIS_FIELD_NUMBER: _ClassVar[int]
    RULE_SPECS_FIELD_NUMBER: _ClassVar[int]
    PRUNE_FIELD_NUMBER: _ClassVar[int]
    CTX_SIMP_FIELD_NUMBER: _ClassVar[int]
    LIFT_BOOL_FIELD_NUMBER: _ClassVar[int]
    STR_FIELD_NUMBER: _ClassVar[int]
    TIMEOUT_FIELD_NUMBER: _ClassVar[int]
    session: _session_pb2.Session
    name: str
    assuming: str
    basis: _containers.RepeatedScalarFieldContainer[str]
    rule_specs: _containers.RepeatedScalarFieldContainer[str]
    prune: bool
    ctx_simp: bool
    lift_bool: LiftBool
    str: bool
    timeout: int
    def __init__(self, session: _Optional[_Union[_session_pb2.Session, _Mapping]] = ..., name: _Optional[str] = ..., assuming: _Optional[str] = ..., basis: _Optional[_Iterable[str]] = ..., rule_specs: _Optional[_Iterable[str]] = ..., prune: bool = ..., ctx_simp: bool = ..., lift_bool: _Optional[_Union[LiftBool, str]] = ..., str: bool = ..., timeout: _Optional[int] = ...) -> None: ...

class DecomposeReqFull(_message.Message):
    __slots__ = ("session", "decomp", "str", "timeout")
    class ByName(_message.Message):
        __slots__ = ("name", "assuming", "basis", "rule_specs", "prune", "ctx_simp", "lift_bool")
        NAME_FIELD_NUMBER: _ClassVar[int]
        ASSUMING_FIELD_NUMBER: _ClassVar[int]
        BASIS_FIELD_NUMBER: _ClassVar[int]
        RULE_SPECS_FIELD_NUMBER: _ClassVar[int]
        PRUNE_FIELD_NUMBER: _ClassVar[int]
        CTX_SIMP_FIELD_NUMBER: _ClassVar[int]
        LIFT_BOOL_FIELD_NUMBER: _ClassVar[int]
        name: str
        assuming: str
        basis: _containers.RepeatedScalarFieldContainer[str]
        rule_specs: _containers.RepeatedScalarFieldContainer[str]
        prune: bool
        ctx_simp: bool
        lift_bool: LiftBool
        def __init__(self, name: _Optional[str] = ..., assuming: _Optional[str] = ..., basis: _Optional[_Iterable[str]] = ..., rule_specs: _Optional[_Iterable[str]] = ..., prune: bool = ..., ctx_simp: bool = ..., lift_bool: _Optional[_Union[LiftBool, str]] = ...) -> None: ...
    class Prune(_message.Message):
        __slots__ = ("d",)
        D_FIELD_NUMBER: _ClassVar[int]
        d: DecomposeReqFull.Decomp
        def __init__(self, d: _Optional[_Union[DecomposeReqFull.Decomp, _Mapping]] = ...) -> None: ...
    class Combine(_message.Message):
        __slots__ = ("d",)
        D_FIELD_NUMBER: _ClassVar[int]
        d: DecomposeReqFull.Decomp
        def __init__(self, d: _Optional[_Union[DecomposeReqFull.Decomp, _Mapping]] = ...) -> None: ...
    class Merge(_message.Message):
        __slots__ = ("d1", "d2")
        D1_FIELD_NUMBER: _ClassVar[int]
        D2_FIELD_NUMBER: _ClassVar[int]
        d1: DecomposeReqFull.Decomp
        d2: DecomposeReqFull.Decomp
        def __init__(self, d1: _Optional[_Union[DecomposeReqFull.Decomp, _Mapping]] = ..., d2: _Optional[_Union[DecomposeReqFull.Decomp, _Mapping]] = ...) -> None: ...
    class CompoundMerge(_message.Message):
        __slots__ = ("d1", "d2")
        D1_FIELD_NUMBER: _ClassVar[int]
        D2_FIELD_NUMBER: _ClassVar[int]
        d1: DecomposeReqFull.Decomp
        d2: DecomposeReqFull.Decomp
        def __init__(self, d1: _Optional[_Union[DecomposeReqFull.Decomp, _Mapping]] = ..., d2: _Optional[_Union[DecomposeReqFull.Decomp, _Mapping]] = ...) -> None: ...
    class LocalVarBinding(_message.Message):
        __slots__ = ("name", "d")
        NAME_FIELD_NUMBER: _ClassVar[int]
        D_FIELD_NUMBER: _ClassVar[int]
        name: str
        d: DecomposeReqFull.Decomp
        def __init__(self, name: _Optional[str] = ..., d: _Optional[_Union[DecomposeReqFull.Decomp, _Mapping]] = ...) -> None: ...
    class LocalVarLet(_message.Message):
        __slots__ = ("bindings", "and_then")
        BINDINGS_FIELD_NUMBER: _ClassVar[int]
        AND_THEN_FIELD_NUMBER: _ClassVar[int]
        bindings: _containers.RepeatedCompositeFieldContainer[DecomposeReqFull.LocalVarBinding]
        and_then: DecomposeReqFull.Decomp
        def __init__(self, bindings: _Optional[_Iterable[_Union[DecomposeReqFull.LocalVarBinding, _Mapping]]] = ..., and_then: _Optional[_Union[DecomposeReqFull.Decomp, _Mapping]] = ...) -> None: ...
    class LocalVarGet(_message.Message):
        __slots__ = ("name",)
        NAME_FIELD_NUMBER: _ClassVar[int]
        name: str
        def __init__(self, name: _Optional[str] = ...) -> None: ...
    class Decomp(_message.Message):
        __slots__ = ("from_artifact", "by_name", "merge", "compound_merge", "prune", "combine", "get", "set")
        FROM_ARTIFACT_FIELD_NUMBER: _ClassVar[int]
        BY_NAME_FIELD_NUMBER: _ClassVar[int]
        MERGE_FIELD_NUMBER: _ClassVar[int]
        COMPOUND_MERGE_FIELD_NUMBER: _ClassVar[int]
        PRUNE_FIELD_NUMBER: _ClassVar[int]
        COMBINE_FIELD_NUMBER: _ClassVar[int]
        GET_FIELD_NUMBER: _ClassVar[int]
        SET_FIELD_NUMBER: _ClassVar[int]
        from_artifact: _artmsg_pb2.Art
        by_name: DecomposeReqFull.ByName
        merge: DecomposeReqFull.Merge
        compound_merge: DecomposeReqFull.CompoundMerge
        prune: DecomposeReqFull.Prune
        combine: DecomposeReqFull.Combine
        get: DecomposeReqFull.LocalVarGet
        set: DecomposeReqFull.LocalVarLet
        def __init__(self, from_artifact: _Optional[_Union[_artmsg_pb2.Art, _Mapping]] = ..., by_name: _Optional[_Union[DecomposeReqFull.ByName, _Mapping]] = ..., merge: _Optional[_Union[DecomposeReqFull.Merge, _Mapping]] = ..., compound_merge: _Optional[_Union[DecomposeReqFull.CompoundMerge, _Mapping]] = ..., prune: _Optional[_Union[DecomposeReqFull.Prune, _Mapping]] = ..., combine: _Optional[_Union[DecomposeReqFull.Combine, _Mapping]] = ..., get: _Optional[_Union[DecomposeReqFull.LocalVarGet, _Mapping]] = ..., set: _Optional[_Union[DecomposeReqFull.LocalVarLet, _Mapping]] = ...) -> None: ...
    SESSION_FIELD_NUMBER: _ClassVar[int]
    DECOMP_FIELD_NUMBER: _ClassVar[int]
    STR_FIELD_NUMBER: _ClassVar[int]
    TIMEOUT_FIELD_NUMBER: _ClassVar[int]
    session: _session_pb2.Session
    decomp: DecomposeReqFull.Decomp
    str: bool
    timeout: int
    def __init__(self, session: _Optional[_Union[_session_pb2.Session, _Mapping]] = ..., decomp: _Optional[_Union[DecomposeReqFull.Decomp, _Mapping]] = ..., str: bool = ..., timeout: _Optional[int] = ...) -> None: ...

class DecomposeRes(_message.Message):
    __slots__ = ("artifact", "err", "errors", "task")
    ARTIFACT_FIELD_NUMBER: _ClassVar[int]
    ERR_FIELD_NUMBER: _ClassVar[int]
    ERRORS_FIELD_NUMBER: _ClassVar[int]
    TASK_FIELD_NUMBER: _ClassVar[int]
    artifact: _artmsg_pb2.Art
    err: _utils_pb2.Empty
    errors: _containers.RepeatedCompositeFieldContainer[_error_pb2.Error]
    task: _task_pb2.Task
    def __init__(self, artifact: _Optional[_Union[_artmsg_pb2.Art, _Mapping]] = ..., err: _Optional[_Union[_utils_pb2.Empty, _Mapping]] = ..., errors: _Optional[_Iterable[_Union[_error_pb2.Error, _Mapping]]] = ..., task: _Optional[_Union[_task_pb2.Task, _Mapping]] = ...) -> None: ...

class EvalSrcReq(_message.Message):
    __slots__ = ("session", "src", "async_only")
    SESSION_FIELD_NUMBER: _ClassVar[int]
    SRC_FIELD_NUMBER: _ClassVar[int]
    ASYNC_ONLY_FIELD_NUMBER: _ClassVar[int]
    session: _session_pb2.Session
    src: str
    async_only: bool
    def __init__(self, session: _Optional[_Union[_session_pb2.Session, _Mapping]] = ..., src: _Optional[str] = ..., async_only: bool = ...) -> None: ...

class EvalOutput(_message.Message):
    __slots__ = ("success", "value_as_ocaml", "errors")
    SUCCESS_FIELD_NUMBER: _ClassVar[int]
    VALUE_AS_OCAML_FIELD_NUMBER: _ClassVar[int]
    ERRORS_FIELD_NUMBER: _ClassVar[int]
    success: bool
    value_as_ocaml: str
    errors: _containers.RepeatedCompositeFieldContainer[_error_pb2.Error]
    def __init__(self, success: bool = ..., value_as_ocaml: _Optional[str] = ..., errors: _Optional[_Iterable[_Union[_error_pb2.Error, _Mapping]]] = ...) -> None: ...

class EvalRes(_message.Message):
    __slots__ = ("success", "messages", "errors", "tasks", "po_results", "eval_results", "decomp_results")
    SUCCESS_FIELD_NUMBER: _ClassVar[int]
    MESSAGES_FIELD_NUMBER: _ClassVar[int]
    ERRORS_FIELD_NUMBER: _ClassVar[int]
    TASKS_FIELD_NUMBER: _ClassVar[int]
    PO_RESULTS_FIELD_NUMBER: _ClassVar[int]
    EVAL_RESULTS_FIELD_NUMBER: _ClassVar[int]
    DECOMP_RESULTS_FIELD_NUMBER: _ClassVar[int]
    success: bool
    messages: _containers.RepeatedScalarFieldContainer[str]
    errors: _containers.RepeatedCompositeFieldContainer[_error_pb2.Error]
    tasks: _containers.RepeatedCompositeFieldContainer[_task_pb2.Task]
    po_results: _containers.RepeatedCompositeFieldContainer[PO_Res]
    eval_results: _containers.RepeatedCompositeFieldContainer[EvalOutput]
    decomp_results: _containers.RepeatedCompositeFieldContainer[DecomposeRes]
    def __init__(self, success: bool = ..., messages: _Optional[_Iterable[str]] = ..., errors: _Optional[_Iterable[_Union[_error_pb2.Error, _Mapping]]] = ..., tasks: _Optional[_Iterable[_Union[_task_pb2.Task, _Mapping]]] = ..., po_results: _Optional[_Iterable[_Union[PO_Res, _Mapping]]] = ..., eval_results: _Optional[_Iterable[_Union[EvalOutput, _Mapping]]] = ..., decomp_results: _Optional[_Iterable[_Union[DecomposeRes, _Mapping]]] = ...) -> None: ...

class VerifySrcReq(_message.Message):
    __slots__ = ("session", "src", "hints")
    SESSION_FIELD_NUMBER: _ClassVar[int]
    SRC_FIELD_NUMBER: _ClassVar[int]
    HINTS_FIELD_NUMBER: _ClassVar[int]
    session: _session_pb2.Session
    src: str
    hints: str
    def __init__(self, session: _Optional[_Union[_session_pb2.Session, _Mapping]] = ..., src: _Optional[str] = ..., hints: _Optional[str] = ...) -> None: ...

class VerifyNameReq(_message.Message):
    __slots__ = ("session", "name", "hints")
    SESSION_FIELD_NUMBER: _ClassVar[int]
    NAME_FIELD_NUMBER: _ClassVar[int]
    HINTS_FIELD_NUMBER: _ClassVar[int]
    session: _session_pb2.Session
    name: str
    hints: str
    def __init__(self, session: _Optional[_Union[_session_pb2.Session, _Mapping]] = ..., name: _Optional[str] = ..., hints: _Optional[str] = ...) -> None: ...

class InstanceSrcReq(_message.Message):
    __slots__ = ("session", "src", "hints")
    SESSION_FIELD_NUMBER: _ClassVar[int]
    SRC_FIELD_NUMBER: _ClassVar[int]
    HINTS_FIELD_NUMBER: _ClassVar[int]
    session: _session_pb2.Session
    src: str
    hints: str
    def __init__(self, session: _Optional[_Union[_session_pb2.Session, _Mapping]] = ..., src: _Optional[str] = ..., hints: _Optional[str] = ...) -> None: ...

class InstanceNameReq(_message.Message):
    __slots__ = ("session", "name", "hints")
    SESSION_FIELD_NUMBER: _ClassVar[int]
    NAME_FIELD_NUMBER: _ClassVar[int]
    HINTS_FIELD_NUMBER: _ClassVar[int]
    session: _session_pb2.Session
    name: str
    hints: str
    def __init__(self, session: _Optional[_Union[_session_pb2.Session, _Mapping]] = ..., name: _Optional[str] = ..., hints: _Optional[str] = ...) -> None: ...

class Proved(_message.Message):
    __slots__ = ("proof_pp",)
    PROOF_PP_FIELD_NUMBER: _ClassVar[int]
    proof_pp: str
    def __init__(self, proof_pp: _Optional[str] = ...) -> None: ...

class Verified_upto(_message.Message):
    __slots__ = ("msg",)
    MSG_FIELD_NUMBER: _ClassVar[int]
    msg: str
    def __init__(self, msg: _Optional[str] = ...) -> None: ...

class Unsat(_message.Message):
    __slots__ = ("proof_pp",)
    PROOF_PP_FIELD_NUMBER: _ClassVar[int]
    proof_pp: str
    def __init__(self, proof_pp: _Optional[str] = ...) -> None: ...

class Model(_message.Message):
    __slots__ = ("m_type", "src", "artifact")
    M_TYPE_FIELD_NUMBER: _ClassVar[int]
    SRC_FIELD_NUMBER: _ClassVar[int]
    ARTIFACT_FIELD_NUMBER: _ClassVar[int]
    m_type: ModelType
    src: str
    artifact: _artmsg_pb2.Art
    def __init__(self, m_type: _Optional[_Union[ModelType, str]] = ..., src: _Optional[str] = ..., artifact: _Optional[_Union[_artmsg_pb2.Art, _Mapping]] = ...) -> None: ...

class Refuted(_message.Message):
    __slots__ = ("model",)
    MODEL_FIELD_NUMBER: _ClassVar[int]
    model: Model
    def __init__(self, model: _Optional[_Union[Model, _Mapping]] = ...) -> None: ...

class Sat(_message.Message):
    __slots__ = ("model",)
    MODEL_FIELD_NUMBER: _ClassVar[int]
    model: Model
    def __init__(self, model: _Optional[_Union[Model, _Mapping]] = ...) -> None: ...

class CounterSat(_message.Message):
    __slots__ = ("model",)
    MODEL_FIELD_NUMBER: _ClassVar[int]
    model: Model
    def __init__(self, model: _Optional[_Union[Model, _Mapping]] = ...) -> None: ...

class PO_Res(_message.Message):
    __slots__ = ("unknown", "err", "proof", "instance", "verified_upto", "errors", "task", "origin")
    UNKNOWN_FIELD_NUMBER: _ClassVar[int]
    ERR_FIELD_NUMBER: _ClassVar[int]
    PROOF_FIELD_NUMBER: _ClassVar[int]
    INSTANCE_FIELD_NUMBER: _ClassVar[int]
    VERIFIED_UPTO_FIELD_NUMBER: _ClassVar[int]
    ERRORS_FIELD_NUMBER: _ClassVar[int]
    TASK_FIELD_NUMBER: _ClassVar[int]
    ORIGIN_FIELD_NUMBER: _ClassVar[int]
    unknown: _utils_pb2.StringMsg
    err: _utils_pb2.Empty
    proof: Proved
    instance: CounterSat
    verified_upto: Verified_upto
    errors: _containers.RepeatedCompositeFieldContainer[_error_pb2.Error]
    task: _task_pb2.Task
    origin: _task_pb2.Origin
    def __init__(self, unknown: _Optional[_Union[_utils_pb2.StringMsg, _Mapping]] = ..., err: _Optional[_Union[_utils_pb2.Empty, _Mapping]] = ..., proof: _Optional[_Union[Proved, _Mapping]] = ..., instance: _Optional[_Union[CounterSat, _Mapping]] = ..., verified_upto: _Optional[_Union[Verified_upto, _Mapping]] = ..., errors: _Optional[_Iterable[_Union[_error_pb2.Error, _Mapping]]] = ..., task: _Optional[_Union[_task_pb2.Task, _Mapping]] = ..., origin: _Optional[_Union[_task_pb2.Origin, _Mapping]] = ...) -> None: ...

class VerifyRes(_message.Message):
    __slots__ = ("unknown", "err", "proved", "refuted", "verified_upto", "errors", "task")
    UNKNOWN_FIELD_NUMBER: _ClassVar[int]
    ERR_FIELD_NUMBER: _ClassVar[int]
    PROVED_FIELD_NUMBER: _ClassVar[int]
    REFUTED_FIELD_NUMBER: _ClassVar[int]
    VERIFIED_UPTO_FIELD_NUMBER: _ClassVar[int]
    ERRORS_FIELD_NUMBER: _ClassVar[int]
    TASK_FIELD_NUMBER: _ClassVar[int]
    unknown: _utils_pb2.StringMsg
    err: _utils_pb2.Empty
    proved: Proved
    refuted: Refuted
    verified_upto: Verified_upto
    errors: _containers.RepeatedCompositeFieldContainer[_error_pb2.Error]
    task: _task_pb2.Task
    def __init__(self, unknown: _Optional[_Union[_utils_pb2.StringMsg, _Mapping]] = ..., err: _Optional[_Union[_utils_pb2.Empty, _Mapping]] = ..., proved: _Optional[_Union[Proved, _Mapping]] = ..., refuted: _Optional[_Union[Refuted, _Mapping]] = ..., verified_upto: _Optional[_Union[Verified_upto, _Mapping]] = ..., errors: _Optional[_Iterable[_Union[_error_pb2.Error, _Mapping]]] = ..., task: _Optional[_Union[_task_pb2.Task, _Mapping]] = ...) -> None: ...

class InstanceRes(_message.Message):
    __slots__ = ("unknown", "err", "unsat", "sat", "errors", "task")
    UNKNOWN_FIELD_NUMBER: _ClassVar[int]
    ERR_FIELD_NUMBER: _ClassVar[int]
    UNSAT_FIELD_NUMBER: _ClassVar[int]
    SAT_FIELD_NUMBER: _ClassVar[int]
    ERRORS_FIELD_NUMBER: _ClassVar[int]
    TASK_FIELD_NUMBER: _ClassVar[int]
    unknown: _utils_pb2.StringMsg
    err: _utils_pb2.Empty
    unsat: Unsat
    sat: Sat
    errors: _containers.RepeatedCompositeFieldContainer[_error_pb2.Error]
    task: _task_pb2.Task
    def __init__(self, unknown: _Optional[_Union[_utils_pb2.StringMsg, _Mapping]] = ..., err: _Optional[_Union[_utils_pb2.Empty, _Mapping]] = ..., unsat: _Optional[_Union[Unsat, _Mapping]] = ..., sat: _Optional[_Union[Sat, _Mapping]] = ..., errors: _Optional[_Iterable[_Union[_error_pb2.Error, _Mapping]]] = ..., task: _Optional[_Union[_task_pb2.Task, _Mapping]] = ...) -> None: ...

class TypecheckReq(_message.Message):
    __slots__ = ("session", "src")
    SESSION_FIELD_NUMBER: _ClassVar[int]
    SRC_FIELD_NUMBER: _ClassVar[int]
    session: _session_pb2.Session
    src: str
    def __init__(self, session: _Optional[_Union[_session_pb2.Session, _Mapping]] = ..., src: _Optional[str] = ...) -> None: ...

class TypecheckRes(_message.Message):
    __slots__ = ("success", "types", "errors")
    SUCCESS_FIELD_NUMBER: _ClassVar[int]
    TYPES_FIELD_NUMBER: _ClassVar[int]
    ERRORS_FIELD_NUMBER: _ClassVar[int]
    success: bool
    types: str
    errors: _containers.RepeatedCompositeFieldContainer[_error_pb2.Error]
    def __init__(self, success: bool = ..., types: _Optional[str] = ..., errors: _Optional[_Iterable[_Union[_error_pb2.Error, _Mapping]]] = ...) -> None: ...

class OneshotReq(_message.Message):
    __slots__ = ("input", "timeout")
    INPUT_FIELD_NUMBER: _ClassVar[int]
    TIMEOUT_FIELD_NUMBER: _ClassVar[int]
    input: str
    timeout: float
    def __init__(self, input: _Optional[str] = ..., timeout: _Optional[float] = ...) -> None: ...

class OneshotRes(_message.Message):
    __slots__ = ("results", "errors", "stats", "detailed_results")
    class Stats(_message.Message):
        __slots__ = ("time",)
        TIME_FIELD_NUMBER: _ClassVar[int]
        time: float
        def __init__(self, time: _Optional[float] = ...) -> None: ...
    RESULTS_FIELD_NUMBER: _ClassVar[int]
    ERRORS_FIELD_NUMBER: _ClassVar[int]
    STATS_FIELD_NUMBER: _ClassVar[int]
    DETAILED_RESULTS_FIELD_NUMBER: _ClassVar[int]
    results: _containers.RepeatedScalarFieldContainer[str]
    errors: _containers.RepeatedScalarFieldContainer[str]
    stats: OneshotRes.Stats
    detailed_results: _containers.RepeatedScalarFieldContainer[str]
    def __init__(self, results: _Optional[_Iterable[str]] = ..., errors: _Optional[_Iterable[str]] = ..., stats: _Optional[_Union[OneshotRes.Stats, _Mapping]] = ..., detailed_results: _Optional[_Iterable[str]] = ...) -> None: ...

class GetDeclsReq(_message.Message):
    __slots__ = ("session", "name", "str")
    SESSION_FIELD_NUMBER: _ClassVar[int]
    NAME_FIELD_NUMBER: _ClassVar[int]
    STR_FIELD_NUMBER: _ClassVar[int]
    session: _session_pb2.Session
    name: _containers.RepeatedScalarFieldContainer[str]
    str: bool
    def __init__(self, session: _Optional[_Union[_session_pb2.Session, _Mapping]] = ..., name: _Optional[_Iterable[str]] = ..., str: bool = ...) -> None: ...

class DeclWithName(_message.Message):
    __slots__ = ("name", "artifact", "str")
    NAME_FIELD_NUMBER: _ClassVar[int]
    ARTIFACT_FIELD_NUMBER: _ClassVar[int]
    STR_FIELD_NUMBER: _ClassVar[int]
    name: str
    artifact: _artmsg_pb2.Art
    str: str
    def __init__(self, name: _Optional[str] = ..., artifact: _Optional[_Union[_artmsg_pb2.Art, _Mapping]] = ..., str: _Optional[str] = ...) -> None: ...

class GetDeclsRes(_message.Message):
    __slots__ = ("decls", "not_found")
    DECLS_FIELD_NUMBER: _ClassVar[int]
    NOT_FOUND_FIELD_NUMBER: _ClassVar[int]
    decls: _containers.RepeatedCompositeFieldContainer[DeclWithName]
    not_found: _containers.RepeatedScalarFieldContainer[str]
    def __init__(self, decls: _Optional[_Iterable[_Union[DeclWithName, _Mapping]]] = ..., not_found: _Optional[_Iterable[str]] = ...) -> None: ...
