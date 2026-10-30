# pyright: reportPrivateUsage=false
import asyncio
import json
import re
import weakref
from collections.abc import Awaitable
from dataclasses import dataclass, field
from enum import StrEnum
from functools import cached_property
from types import TracebackType
from typing import TYPE_CHECKING, Any, Literal, Self, TypeAliasType, assert_never, ClassVar, cast, get_origin

import imandrax_api
from imandrax_api import lib
from imandrax_api.bindings import (
    api_pb2,
    artmsg_pb2,
    error_pb2,
    locs_pb2,
    simple_api_pb2,
    system_pb2,
    task_pb2,
)

from .errors import (
    ClientGoneError,
    NoClientError,
    NotFetchedError,
    ServerError,
    UnexpectedResponseError,
)
from .evaluation_values import Value, value_of_lib
from .mir import *
from .proof import ProofTerm, proof_term_of_lib
from .report import Report

if TYPE_CHECKING:
    from imandrax_api.client import AsyncClient as AsyncClient_

    from . import decomp


@dataclass(slots=True, frozen=True)
class Location:
    """A source location"""

    file: str | None
    start: tuple[int, int]
    """The start, as `(line, column)`"""
    stop: tuple[int, int]
    """The end, as `(line, column)`"""
    _raw: locs_pb2.Location = field(repr=False, compare=False)

    @classmethod
    def of_raw(cls, x: locs_pb2.Location) -> "Location":
        return cls(
            file=x.file if x.HasField("file") else None,
            start=(x.start.line, x.start.col),
            stop=(x.stop.line, x.stop.col),
            _raw=x,
        )

    def __str__(self) -> str:
        (l1, c1), (l2, c2) = self.start, self.stop
        return f"{self.file or '<none>'}:{l1}:{c1}-{l2}:{c2}"


@dataclass(slots=True, frozen=True)
class Error:
    """An error reported by the server"""

    @dataclass(slots=True, frozen=True)
    class Message:
        """An error message, with source locations and an optional backtrace"""

        message: str
        """The message text"""
        locations: tuple[Location, ...]
        """The source locations the message refers to"""
        backtrace: str | None = field(repr=False)
        """The backtrace, if any"""
        _raw: error_pb2.Error.Message = field(repr=False, compare=False)

        @classmethod
        def of_raw(cls, x: error_pb2.Error.Message) -> "Error.Message":
            return cls(
                message=x.msg,
                locations=tuple(Location.of_raw(l) for l in x.locs),
                backtrace=x.backtrace if x.HasField("backtrace") else None,
                _raw=x,
            )

        def __str__(self) -> str:
            return self.message

    kind: str
    """The kind of error, e.g. `TypeErr`"""
    message: Message
    """The main error message"""
    stack: tuple[Message, ...]
    """Further messages giving context for the error"""
    process: str | None
    """The process in which the error occurred, if known"""
    _raw: error_pb2.Error = field(repr=False, compare=False)

    @classmethod
    def of_raw(cls, x: error_pb2.Error) -> "Error":
        # The server sends the kind printed as an OCaml record, `{ Kind.name = "TypeErr" }`
        m = re.fullmatch(r'\{ Kind\.name = "(.*)" \}', x.kind)
        return cls(
            kind=x.kind if m is None else m.group(1),
            message=Error.Message.of_raw(x.msg),
            stack=tuple(Error.Message.of_raw(m) for m in x.stack),
            process=x.process if x.HasField("process") else None,
            _raw=x,
        )

    def __str__(self) -> str:
        return f"{self.kind}: {self.message}"

    def __repr__(self) -> str:
        return f"Error(kind={self.kind!r}, message={self.message.message!r})"


@dataclass(slots=True, frozen=True)
class Artifact:
    """A serialized artifact (task data or a task result) fetched from the server"""

    kind: str
    """The artifact kind, e.g. `po_task` or `eval_res`"""
    data: bytes = field(repr=False)
    """The serialized artifact data"""
    api_version: str
    """The API version the artifact was produced with"""
    storage: dict[str, bytes] = field(repr=False)
    """Additional stored data the artifact refers to, by key"""
    _raw: artmsg_pb2.Artifact = field(repr=False, compare=False)

    @classmethod
    def of_raw(cls, x: artmsg_pb2.Artifact) -> "Artifact":
        return cls(
            kind=x.kind,
            data=x.data,
            api_version=x.api_version,
            storage={s.key: s.value for s in x.storage},
            _raw=x,
        )

    def decode_as[T](self, expected_type: type[T]) -> T:
        """Decode the data as `expected_type`

        Args:
            expected_type: The class the data should decode to. Pass a generic class specialized,
                e.g. `lib.Common_Model_t_poly[lib.Mir_Term, lib.Mir_Type]`, to get a fully typed
                result. Only the class is checked; the type arguments are not.

        Raises:
            UnexpectedResponseError: if the artifact kind is unknown, or the data does not decode to
                the `expected_type`.
            TypeError: if `expected_type` is a type alias, e.g. `lib.Mir_Model`, not a class.
        """
        if isinstance(expected_type, TypeAliasType):  # pyright: ignore[reportUnnecessaryIsInstance]
            value = expected_type.__value__
            hint = f"pass the class it names, `{value}`" if isinstance(get_origin(value), type) else "it is a union"
            raise TypeError(f"`{expected_type.__name__}` is a type alias, not a class: {hint}")
        if self.kind not in lib.artifact_decoders:
            raise UnexpectedResponseError(f"Unknown artifact kind '{self.kind}'")
        d = lib.read_artifact_data(self.data, self.kind)
        cls = get_origin(expected_type) or expected_type  # `Foo[A, B]` -> `Foo`; plain `Foo` stays
        if not isinstance(d, cls):
            raise UnexpectedResponseError(f"Artifact of kind '{self.kind}' decoded to unexpected type '{type(d)}'")
        # `isinstance` cannot narrow to `T` here, as it checks the class without type arguments
        return cast(T, d)

    def __repr__(self) -> str:
        return f"Artifact(kind={self.kind!r}, data=<{len(self.data)} bytes>, api_version={self.api_version!r})"


@dataclass(slots=True, frozen=True)
class Statistics:
    """Tactic Execution Statistics"""

    time_s: float
    """Execution time"""
    tactic: tuple[tuple[str, str], ...] | None
    """Tactic-level statistics"""
    _raw: lib.Statistics = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Statistics) -> "Statistics":
        return cls(
            time_s=x.time_s,
            tactic=None if x.tactic is None else tuple((k, v) for k, v in x.tactic),
            _raw=x,
        )


@dataclass(slots=True, frozen=True)
class ErrorMessage:
    message: str
    backtrace: str | None
    _raw: lib.Error_Error_core_message = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Error_Error_core_message) -> "ErrorMessage":
        return cls(message=x.msg, backtrace=x.bt, _raw=x)

    def __str__(self) -> str:
        return self.message


@dataclass(slots=True, frozen=True)
class ErrorCore:
    process: str
    kind: str
    message: ErrorMessage
    stack: tuple[ErrorMessage, ...]
    _raw: lib.Error_Error_core = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Error_Error_core) -> "ErrorCore":
        return cls(
            process=x.process,
            kind=x.kind.name,
            message=ErrorMessage.of_lib(x.msg),
            stack=tuple(ErrorMessage.of_lib(m) for m in x.stack),
            _raw=x,
        )

    def __str__(self) -> str:
        return f"{self.kind}: {self.message}"


@dataclass(slots=True, frozen=True)
class ProofFound:
    """Type returned on success for verify"""

    proof: ProofTerm
    """Proof term."""
    _raw: lib.Tasks_PO_res_proof_found[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class VerifiedUpto:
    """Type returned on success for verify"""

    upto: int
    _raw: lib.Tasks_PO_res_verified_upto = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class Instance:
    """Success case for instance"""

    model: Model
    _raw: lib.Tasks_PO_res_instance[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class TestOk:
    """Test didn't find a counter-example"""

    _raw: lib.Tasks_PO_res_success[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


ProofObligationSuccess = ProofFound | Instance | VerifiedUpto | TestOk


@dataclass(slots=True, frozen=True)
class NoProof:
    """Error case for verify (the PO failed)"""

    error: ErrorCore
    counter_model: Model | None
    subgoals: tuple[Sequent, ...]
    _raw: lib.Tasks_PO_res_no_proof[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class Unsat:
    """Error case for instance"""

    error: ErrorCore
    proof: ProofTerm
    """Proof term for unsat."""
    _raw: lib.Tasks_PO_res_unsat[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class InvalidModel:
    """Model validation failure"""

    error: ErrorCore
    model: Model
    _raw: lib.Tasks_PO_res_error[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class ProofObligationError:
    error: ErrorCore
    _raw: lib.Tasks_PO_res_error[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


ProofObligationFailure = NoProof | Unsat | InvalidModel | ProofObligationError


def proof_obligation_result_of_lib(
    x: lib.Tasks_PO_res_result[lib.Tasks_PO_res_success[lib.Mir_Term, lib.Mir_Type], lib.Mir_Term, lib.Mir_Type],
) -> ProofObligationSuccess | ProofObligationFailure:
    """Convert a library proof obligation result into the matching success or failure variant"""
    match x:
        case lib.Tasks_PO_res_success_Proof(arg=r):
            return ProofFound(
                proof=proof_term_of_lib(r.proof),
                _raw=r,
            )
        case lib.Tasks_PO_res_success_Instance(arg=r):
            return Instance(model=Model.of_lib(r.model), _raw=r)
        case lib.Tasks_PO_res_success_Verified_upto(arg=r):
            return VerifiedUpto(upto=upto_of_lib(r.upto), _raw=r)
        case lib.Tasks_PO_res_success_Test_ok():
            return TestOk(_raw=x)
        case lib.Tasks_PO_res_error_No_proof(arg=r):
            return NoProof(
                error=ErrorCore.of_lib(r.err),
                counter_model=None if r.counter_model is None else Model.of_lib(r.counter_model),
                subgoals=tuple(Sequent.of_lib(sg) for sg in r.subgoals),
                _raw=r,
            )
        case lib.Tasks_PO_res_error_Unsat(arg=r):
            return Unsat(
                error=ErrorCore.of_lib(r.err),
                proof=proof_term_of_lib(r.proof),
                _raw=r,
            )
        case lib.Tasks_PO_res_error_Invalid_model(args=(e, m)):
            return InvalidModel(error=ErrorCore.of_lib(e), model=Model.of_lib(m), _raw=x)
        case lib.Tasks_PO_res_error_Error(arg=e):
            return ProofObligationError(error=ErrorCore.of_lib(e), _raw=x)


class ProofObligationTaskResult:
    """The result of a proof obligation task"""

    @dataclass(slots=True, frozen=True)
    class Subresult:
        """The result for one subgoal of a proof obligation"""

        goal: Sequent
        """The subgoal"""
        sub_goals: tuple[Sequent, ...]
        """The subgoals the goal was split into"""
        res: str | None
        """`None` if the subgoal was handled successfully, otherwise the error message"""
        _raw: lib.Tasks_PO_res_sub_res[lib.Mir_Term] = field(repr=False, compare=False)

        @classmethod
        def of_lib(cls, sr: lib.Tasks_PO_res_sub_res[lib.Mir_Term]) -> "ProofObligationTaskResult.Subresult":
            return cls(
                goal=Sequent.of_lib(sr.goal),
                sub_goals=tuple(Sequent.of_lib(sg) for sg in sr.sub_goals),
                res=sr.res,
                _raw=sr,
            )

    def __init__(self, artifact: Artifact):
        if artifact.kind != "po_res":
            raise ValueError(f"Expected an artifact of kind 'po_res', got '{artifact.kind}'")
        self._artifact: Artifact = artifact
        self._data = artifact.decode_as(lib.Tasks_PO_res_shallow_poly[lib.Mir_Term, lib.Mir_Type])

    @property
    def from_(self) -> str:
        """The cstore key of the proof obligation task this is the result for"""
        return self._data.from_.key

    @cached_property
    def result(self) -> ProofObligationSuccess | ProofObligationFailure:
        """The result"""
        return proof_obligation_result_of_lib(self._data.res)

    @property
    def proved(self) -> bool:
        """Whether the goal was proved

        Verifying up to a bound (`VerifiedUpto`) or testing without finding a counter-example
        (`TestOk`) is not a proof.
        """
        return isinstance(self.result, ProofFound)

    @property
    def found(self) -> bool:
        """Whether an instance was found, for instance queries"""
        return isinstance(self.result, Instance)

    @property
    def error(self) -> ErrorCore | None:
        """The error, if the proof obligation failed"""
        match self.result:
            case NoProof(error=e) | Unsat(error=e) | InvalidModel(error=e) | ProofObligationError(error=e):
                return e
            case _:
                return None

    @property
    def model(self) -> Model | None:
        """The counter-model if the proof failed, or the instance found, if any

        A model that failed validation (`InvalidModel`) is not included; it is in `result`.
        """
        match self.result:
            case NoProof(counter_model=m):
                return m
            case Instance(model=m):
                return m
            case _:
                return None

    @property
    def subgoals(self) -> list[Sequent] | None:
        """The remaining subgoals, if no proof was found"""
        match self.result:
            case NoProof(subgoals=sgs):
                return list(sgs)
            case _:
                return None

    @property
    def proof(self) -> ProofTerm | None:
        """The proof term, if any: of the goal, or for instance queries, of the goal having no instance"""
        match self.result:
            case ProofFound(proof=p) | Unsat(proof=p):
                return p
            case _:
                return None

    @cached_property
    def statistics(self) -> Statistics:
        """Statistics about the proof attempt"""
        return Statistics.of_lib(self._data.stats)

    @cached_property
    def report(self) -> Report:
        """The report of the proof attempt"""
        return Report.of_archive(self._data.report)

    @cached_property
    def subresults(self) -> list[list[Subresult]]:
        """The results for the individual subgoals"""
        return [[ProofObligationTaskResult.Subresult.of_lib(s) for s in sl] for sl in self._data.sub_res]

    def __str__(self) -> str:
        return f"proof: {self.proof}\nsubgoals: {self.subgoals}\nmodel: {self.model}"

    def __repr__(self) -> str:
        # Shows `proved` once `result` has been accessed and cached
        if "result" not in self.__dict__:
            return f"ProofObligationTaskResult(from_={self.from_!r})"
        return f"ProofObligationTaskResult(from_={self.from_!r}, proved={self.proved})"


@dataclass(slots=True, frozen=True)
class EvaluationStatistics:
    """Evaluation statistics for the whole task"""

    compile_time: float
    exec_time: float
    _raw: lib.Tasks_Eval_res_stats = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Tasks_Eval_res_stats) -> "EvaluationStatistics":
        return cls(compile_time=x.compile_time, exec_time=x.exec_time, _raw=x)


class EvaluationTaskResult:
    """The result of an evaluation task"""

    def __init__(self, artifact: Artifact):
        if artifact.kind != "eval_res":
            raise ValueError(f"Expected an artifact of kind 'eval_res', got '{artifact.kind}'")
        self._artifact: Artifact = artifact
        self._data = artifact.decode_as(lib.Tasks_Eval_res)

    @property
    def success(self) -> bool:
        """Whether the evaluation succeeded"""
        return isinstance(self._data.res, lib.Tasks_Eval_res_success)

    @cached_property
    def value(self) -> Value | None:
        """The value the term evaluated to, if the evaluation succeeded"""
        match self._data.res:
            case lib.Tasks_Eval_res_success(x):
                return value_of_lib(x.v)
            case _:
                return None

    @cached_property
    def error(self) -> ErrorCore | None:
        """The error, if the evaluation failed"""
        match self._data.res:
            case lib.Error_Error_core(_) as e:
                return ErrorCore.of_lib(e)
            case _:
                return None

    @cached_property
    def statistics(self) -> EvaluationStatistics:
        """Statistics about the evaluation"""
        return EvaluationStatistics.of_lib(self._data.stats)

    def __str__(self) -> str:
        if self.success:
            return str(self.value)
        else:
            return f"Evaluation error: {self.error}"

    def __repr__(self) -> str:
        return f"EvaluationTaskResult(success={self.success})"


class DecompositionTaskResult:
    """The result of a decomposition task"""

    def __init__(self, artifact: Artifact):
        if artifact.kind != "decomp_res":
            raise ValueError(f"Expected an artifact of kind 'decomp_res', got '{artifact.kind}'")
        self._artifact: Artifact = artifact
        self._data = artifact.decode_as(lib.Tasks_Decomp_res_shallow_poly[lib.Mir_Term, lib.Mir_Type])

    @property
    def from_(self) -> str:
        """The cstore key of the decomposition task this is the result for"""
        return self._data.from_.key

    @property
    def _result(self) -> lib.Tasks_Decomp_res_result[lib.Tasks_Decomp_res_success[lib.Mir_Term, lib.Mir_Type]]:
        return self._data.res

    @cached_property
    def statistics(self) -> Statistics:
        """Statistics about the decomposition"""
        return Statistics.of_lib(self._data.stats)

    @cached_property
    def report(self) -> Report:
        """The report of the decomposition"""
        return Report.of_archive(self._data.report)

    @property
    def success(self) -> bool:
        """Whether the decomposition succeeded"""
        match self._result:
            case lib.Tasks_Decomp_res_success():
                return True
            case lib.Tasks_Decomp_res_error_Error():
                return False
            case _:
                return False

    @cached_property
    def decomposition(self) -> Decomposition | None:
        """The decomposition, if it succeeded"""
        match self._result:
            case lib.Tasks_Decomp_res_success(_, decomp):
                return Decomposition.of_lib(decomp)
            case lib.Tasks_Decomp_res_error_Error():
                return None
            case _:
                return None

    @cached_property
    def error(self) -> ErrorCore | None:
        """The error, if the decomposition failed"""
        match self._result:
            case lib.Tasks_Decomp_res_success(_, _):
                return None
            case lib.Tasks_Decomp_res_error_Error(arg):
                return ErrorCore.of_lib(arg)
            case _:
                return None

    def __str__(self) -> str:
        if self.decomposition:
            return f"{self.decomposition}"
        else:
            return f"Decomposition error: {self.error}"

    def __repr__(self) -> str:
        return f"DecompositionTaskResult(from_={self.from_!r}, success={self.success})"


@dataclass(slots=True, frozen=True)
class TaskID:
    """A task identifier"""
    id: str
    _raw: task_pb2.TaskID = field(repr=False, compare=False)

    @classmethod
    def of_raw(cls, x: task_pb2.TaskID) -> "TaskID":
        return cls(id=x.id, _raw=x)

    def __str__(self) -> str:
        return self.id


type TaskResult = ProofObligationTaskResult | EvaluationTaskResult | DecompositionTaskResult


class AwaitableAttrs:
    """Attribute access on a task that first fetches the artifacts the attribute needs

    `await t.awaitable.x` evaluates `t.x`, fetching with the task's client any artifact that is
    not loaded yet. The result is typed `Any`; once awaited, `t.x` itself is typed and can be
    accessed without `await`.
    """

    def __init__(self, task: "Task"):
        self._task = task

    def __getattr__(self, name: str) -> Awaitable[Any]:
        return self._task._get_attr_fetching(name)


class Task:
    """A task run by the server, e.g. a proof obligation, evaluation or decomposition

    The task's artifacts (its data, its result, ...) are fetched from the server on first access,
    with the client the task came from.
    - With a `Client`, accessing a property like `t.result` fetches what it needs
    - With an `AsyncClient`, await it once with `await t.awaitable.result`; after that, `t.result`
      can be accessed as usual. Accessing it before raises `NotFetchedError`.
    - With no client, nothing is fetched; accessing an artifact raises `NoClientError`.

    `t.set_client(client)` sets the client to fetch with, e.g. after the original one is gone.

    `await t.fetch_all()` fetches all of the task's artifacts, after which every attribute can be
    accessed without `t.awaitable`.

    Tasks are equal when their ids are. Task ids are content-addressed, so equal tasks describe
    the same work, even when they come from different clients; each still fetches its artifacts
    on its own.
    """

    _artifact_kind: ClassVar[str | None] = None
    """The artifact kind of the task's data, `None` if it is not known for the task's kind"""
    _result_artifact_kind: ClassVar[str | None] = None
    """The artifact kind of the task's result, `None` if it is not known for the task's kind"""

    def __init__(self, task: task_pb2.Task, client: "Client | AsyncClient | None" = None):
        # A plain `Task` is only for task kinds without a subclass, whose artifact kinds are not
        # known; other kinds need their subclass, which `task_of_raw` picks
        if type(self) is Task and task.kind in (
            task_pb2.TASK_EVAL,
            task_pb2.TASK_CHECK_PO,
            task_pb2.TASK_PROOF_CHECK,
            task_pb2.TASK_DECOMP,
        ):
            raise ValueError(
                f"Tasks of kind {task_pb2.TaskKind.Name(task.kind)} need their `Task` subclass; use `task_of_raw`"
            )
        self._raw: task_pb2.Task = task
        # The task holds only a weak reference to the client, so it does not keep the client alive;
        # fetching after the client is gone raises `ClientGoneError`.
        self._client: weakref.ref[Client | AsyncClient] | None = None if client is None else weakref.ref(client)
        self._artifacts: dict[str, Artifact] = {}
        self._pending: dict[str, asyncio.Future[Artifact]] = {}

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Task):
            return NotImplemented
        return self._raw.id.id == other._raw.id.id

    def __hash__(self) -> int:
        return hash(self._raw.id.id)

    def __repr__(self) -> str:
        return f"{type(self).__name__}(id={self._raw.id.id!r})"

    @property
    def id(self) -> TaskID:
        """The task's identifier"""
        return TaskID.of_raw(self._raw.id)

    @property
    def kind(self) -> Literal["eval", "check_po", "proof_check", "decomp", "unspecified"]:
        match self._raw.kind:
            case task_pb2.TASK_EVAL:
                return "eval"
            case task_pb2.TASK_CHECK_PO:
                return "check_po"
            case task_pb2.TASK_PROOF_CHECK:
                return "proof_check"
            case task_pb2.TASK_DECOMP:
                return "decomp"
            case task_pb2.TASK_UNSPECIFIED | _:
                return "unspecified"

    @property
    def awaitable(self) -> AwaitableAttrs:
        """The task's attributes as awaitables that fetch what they need, e.g. `await t.awaitable.result`"""
        return AwaitableAttrs(self)

    @property
    def artifact(self) -> Artifact:
        """The task's data

        Fetched on first access, see `Task`
        """
        kind = self._artifact_kind
        if kind is None:
            raise UnexpectedResponseError(f"No known data artifact kind for tasks of kind {self._raw.kind}")
        return self._artifact(kind)

    @cached_property
    def result(self) -> TaskResult:
        """The task's result

        Fetched on first access, see `Task`
        """
        kind = self._result_artifact_kind
        if kind is None:
            raise UnexpectedResponseError(f"No known result artifact kind for tasks of kind {self._raw.kind}")
        return _task_result_of_artifact(self._artifact(kind))

    async def fetch_all(self) -> None:
        """Fetch all of the task's artifacts (its data and its result), with either client

        After this, every attribute can be accessed without `t.awaitable`.
        """
        kinds = [self._artifact_kind, self._result_artifact_kind]
        kinds = [k for k in kinds if k is not None and k not in self._artifacts]
        if not kinds:
            return
        if isinstance(self._get_client(), AsyncClient):
            await asyncio.gather(*(self._fetch_async(k) for k in kinds))
        else:
            for k in kinds:
                self._artifact(k)

    def set_client(self, client: "Client | AsyncClient") -> None:
        self._client = weakref.ref(client)

    def _get_client(self) -> "Client | AsyncClient":
        if self._client is None:
            raise NoClientError(
                f"task {self.id} has no client to fetch its data with; set one with `task.set_client(client)`"
            )
        client = self._client()
        if client is None:
            raise ClientGoneError(
                f"the client of task {self.id} is gone; keep it alive while fetching, "
                "or set another with `task.set_client(client)`"
            )
        return client

    def _artifact(self, kind: str) -> Artifact:
        """The artifact of kind `kind`, fetched with a `Client` if not fetched yet

        With an `AsyncClient`, raises `NotFetchedError` if not fetched yet
        """
        if kind not in self._artifacts:
            client = self._get_client()
            if isinstance(client, AsyncClient):
                raise NotFetchedError(self, kind)
            art_req_res = client._client.get_artifact(self._raw, kind)
            self._artifacts[kind] = _artifact_of_result(art_req_res)
        return self._artifacts[kind]

    async def _get_attr_fetching(self, name: str) -> Any:
        """`getattr(self, name)`, first fetching any artifacts the attribute needs"""
        while True:
            try:
                return getattr(self, name)
            except NotFetchedError as e:
                # Fetching would not help if the artifact is of another task, or already fetched
                if e.task is not self or e.kind in self._artifacts:
                    raise
                await self._fetch_async(e.kind)

    async def _fetch_async(self, kind: str) -> None:
        """Fetch the artifact of kind `kind` with the task's `AsyncClient`"""
        client = self._get_client()
        assert isinstance(client, AsyncClient)

        async def get_artifact() -> Artifact:
            art_req_res = await client._client.get_artifact(self._raw, kind)
            return _artifact_of_result(art_req_res)

        # Concurrent first accesses share one request; a failed request is not cached, so the
        # next access retries
        if kind not in self._pending:
            self._pending[kind] = asyncio.ensure_future(get_artifact())
        try:
            self._artifacts[kind] = await self._pending[kind]
        finally:
            self._pending.pop(kind, None)


def _artifact_of_result(res: api_pb2.ArtifactResult) -> Artifact:
    match (res_tag := res.WhichOneof("result")):
        case "error":
            raise ServerError(Error.of_raw(res.error))
        case "ok":
            return Artifact.of_raw(res.ok)
        case _:
            raise UnexpectedResponseError(f"Artifact result has neither `error` nor `ok`: {res_tag}")


def _task_result_of_artifact(artifact: Artifact) -> TaskResult:
    match artifact.kind:
        case "po_res":
            return ProofObligationTaskResult(artifact)
        case "eval_res":
            return EvaluationTaskResult(artifact)
        case "decomp_res":
            return DecompositionTaskResult(artifact)
        case _:
            raise UnexpectedResponseError(f"Unexpected result artifact kind '{artifact.kind}'")


@dataclass(slots=True, frozen=True)
class ProofObligation:
    """A proof obligation: a goal to prove and the tactic to use"""

    description: str
    """A description of the proof obligation"""
    # CR: should we create a property for goal[0] and goal[1]
    goal: tuple[tuple[Variable, ...], Term]
    """The goal, `fun variables -> body`"""
    tactic: Tactic
    """The tactic to use"""
    is_instance: bool
    """Whether this is an instance query rather than a proof"""
    timeout: int | None
    """The timeout, if any"""
    upto: int | None
    """The bound for bounded verification, if any"""
    verify_kind: VerifyKind | None
    """The kind of verification, if any"""
    named_hypotheses: tuple[tuple[str, Term], ...]
    """Named hypotheses available for the proof"""
    _raw: lib.Mir_Proof_obligation = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, po: lib.Mir_Proof_obligation) -> "ProofObligation":
        vs, t = po.goal
        return cls(
            description=po.descr,
            goal=(tuple(Variable.of_lib(v) for v in vs), term_of_lib(t)),
            tactic=tactic_of_lib(po.tactic),
            is_instance=po.is_instance,
            timeout=po.timeout,
            upto=None if po.upto is None else upto_of_lib(po.upto),
            verify_kind=None if po.verify_kind is None else verify_kind_of_lib(po.verify_kind),
            named_hypotheses=tuple((n, term_of_lib(h)) for (n, h) in po.named_hypotheses),
            _raw=po,
        )

    @property
    def goal_variables(self) -> tuple[Variable, ...]:
        """The variables bound in the goal"""
        return self.goal[0]

    @property
    def goal_body(self) -> Term:
        """The goal's body, the term to prove"""
        return self.goal[1]


class ProofObligationTask(Task):
    """A proof obligation task"""

    _artifact_kind = "po_task"
    _result_artifact_kind = "po_res"

    def __init__(self, task: task_pb2.Task, client: "Client | AsyncClient | None" = None):
        assert task.kind == task_pb2.TASK_CHECK_PO
        super().__init__(task, client)

    @cached_property
    def _po_task(self) -> lib.Tasks_PO_task_Mir:
        return self._artifact("po_task").decode_as(lib.Tasks_PO_task_t_poly[lib.Mir_Term, lib.Mir_Type])

    @cached_property
    def proof_obligation(self) -> ProofObligation:
        """The proof obligation to check

        Fetched on first access, see `Task`
        """
        return ProofObligation.of_lib(self._po_task.po)

    @property
    def from_sym(self) -> str:
        """The symbol the proof obligation was generated from

        Fetched on first access, see `Task`
        """
        return self._po_task.from_sym

    @property
    def count(self) -> int:
        """Distinguishes proof obligations generated from the same symbol

        Fetched on first access, see `Task`
        """
        return self._po_task.count

    @cached_property
    def db(self) -> DB:
        """The database of declarations and rules the proof obligation is checked in

        Fetched on first access, see `Task`
        """
        return DB(self._po_task.db, self._artifact("po_task").storage)


class EvaluationTask(Task):
    """An evaluation task"""

    _artifact_kind = "eval_task"
    _result_artifact_kind = "eval_res"

    def __init__(self, task: task_pb2.Task, client: "Client | AsyncClient | None" = None):
        assert task.kind == task_pb2.TASK_EVAL
        super().__init__(task, client)

    @cached_property
    def _eval_task(self) -> lib.Tasks_Eval_task_Mir:
        return self._artifact("eval_task").decode_as(lib.Tasks_Eval_task_t_poly[lib.Mir_Term, lib.Mir_Type])

    @cached_property
    def variables(self) -> list[Variable]:
        """The variables bound in the term

        Fetched on first access, see `Task`
        """
        vs, _ = self._eval_task.term
        return [Variable.of_lib(v) for v in vs]

    @cached_property
    def term(self) -> Term:
        """The term to evaluate

        Fetched on first access, see `Task`
        """
        _, t = self._eval_task.term
        return term_of_lib(t)

    @property
    def timeout(self) -> int | None:
        """The timeout, if any

        Fetched on first access, see `Task`
        """
        return self._eval_task.timeout

    @cached_property
    def db(self) -> DB:
        """The database of declarations and rules the term is evaluated in

        Fetched on first access, see `Task`
        """
        return DB(self._eval_task.db, self._artifact("eval_task").storage)


class LiftBool(StrEnum):
    DEFAULT = "default"
    """Includes the rules [x1 && x2] --> [if x1 then x2 else false] [x1 || x2] -->
    [if x1 then true else x2] [x1 ==> x2] --> [if x1 then x2 else true]"""
    NESTED_EQUALITIES = "nested_equalities"
    """Extends [Default] with the rules [(x = y) = z] --> [if x = y then z else not z]
    [z = (x = y)] --> [if z then (x = y) else not (x = y)]"""
    EQUALITIES = "equalities"
    """Extends [Default] with the rule [x = y] --> [if x = y then true else false]"""
    ALL = "all"
    """Extends [Default] with the rule [(t : bool)] --> [if t then true else false]"""


def lift_bool_of_lib(x: lib.Common_Decomp_lift_bool) -> LiftBool:
    """Convert a library `lift_bool` into the matching `LiftBool`"""
    match x:
        case lib.Common_Decomp_lift_bool_Default():
            return LiftBool.DEFAULT
        case lib.Common_Decomp_lift_bool_Nested_equalities():
            return LiftBool.NESTED_EQUALITIES
        case lib.Common_Decomp_lift_bool_Equalities():
            return LiftBool.EQUALITIES
        case lib.Common_Decomp_lift_bool_All():
            return LiftBool.ALL


class EnumerationStyle(StrEnum):
    ADDITIVE = "additive"
    MULTIPLICATIVE = "multiplicative"


def enumeration_style_of_lib(x: lib.Tasks_Decomp_task_enumeration_style) -> EnumerationStyle:
    """Convert a library enumeration style into the matching `EnumerationStyle`"""
    match x:
        case lib.Tasks_Decomp_task_enumeration_style_Additive():
            return EnumerationStyle.ADDITIVE
        case lib.Tasks_Decomp_task_enumeration_style_Multiplicative():
            return EnumerationStyle.MULTIPLICATIVE


class DecompositionRequest:
    """A decomposition request, as resolved by the server for a task (`DecompositionTask.decomp`)"""

    @dataclass(slots=True, frozen=True)
    class Function:
        """Decompose a function"""

        function: Uid
        """The function to decompose"""
        assuming: Uid | None
        """The side condition the decomposition assumes, if any"""
        basis: frozenset[Uid]
        """Functions not to unfold during decomposition"""
        rule_specs: frozenset[Uid]
        """Rule specs to use during decomposition"""
        ctx_simp: bool
        """Whether to simplify regions in their context"""
        lift_bool: LiftBool
        """How Boolean subterms are lifted into region constraints"""
        prune: bool
        """Whether to prune infeasible regions"""
        _raw: lib.Tasks_Decomp_task_Mir_decomp = field(repr=False, compare=False)

        def __str__(self) -> str:
            assuming = "" if self.assuming is None else f" ~assuming:{self.assuming}"
            prune = " ~prune:true" if self.prune else ""
            return f"decomp {self.function}{assuming}{prune}"

    @dataclass(slots=True, frozen=True)
    class Term:
        """Decompose a term"""

        term: Term
        """The term to decompose"""
        _raw: lib.Tasks_Decomp_task_Mir_decomp = field(repr=False, compare=False)

        def __str__(self) -> str:
            return f"term {self.term}"

    @dataclass(slots=True, frozen=True)
    class Return:
        """An already computed decomposition, returned as is (e.g. as a base case of a merge)"""

        decomposition: Decomposition
        """The decomposition"""
        _raw: lib.Tasks_Decomp_task_Mir_decomp = field(repr=False, compare=False)

        def __str__(self) -> str:
            return f"return <decomposition of {self.decomposition.id}>"

    @dataclass(slots=True, frozen=True)
    class Prune:
        """Prune the infeasible regions of a decomposition"""

        request: "DecompositionRequest.Request"
        """The decomposition to prune"""
        _raw: lib.Tasks_Decomp_task_Mir_decomp = field(repr=False, compare=False)

        def __str__(self) -> str:
            return f"prune ({self.request})"

    @dataclass(slots=True, frozen=True)
    class Merge:
        """Merge two decompositions"""

        left: "DecompositionRequest.Request"
        """The first decomposition"""
        right: "DecompositionRequest.Request"
        """The second decomposition"""
        _raw: lib.Tasks_Decomp_task_Mir_decomp = field(repr=False, compare=False)

        def __str__(self) -> str:
            return f"merge ({self.left}) ({self.right})"

    @dataclass(slots=True, frozen=True)
    class CompoundMerge:
        """Compound-merge two decompositions"""

        left: "DecompositionRequest.Request"
        """The first decomposition"""
        right: "DecompositionRequest.Request"
        """The second decomposition"""
        _raw: lib.Tasks_Decomp_task_Mir_decomp = field(repr=False, compare=False)

        def __str__(self) -> str:
            return f"compound_merge ({self.left}) ({self.right})"

    @dataclass(slots=True, frozen=True)
    class Combine:
        """Combine the regions of a decomposition"""

        request: "DecompositionRequest.Request"
        """The decomposition whose regions are combined"""
        _raw: lib.Tasks_Decomp_task_Mir_decomp = field(repr=False, compare=False)

        def __str__(self) -> str:
            return f"combine ({self.request})"

    @dataclass(slots=True, frozen=True)
    class Get:
        """A decomposition bound by name in an enclosing `Let`"""

        name: str
        """The name of the binding"""
        _raw: lib.Tasks_Decomp_task_Mir_decomp = field(repr=False, compare=False)

        def __str__(self) -> str:
            return f"get {self.name}"

    @dataclass(slots=True, frozen=True)
    class Let:
        """Bind decompositions to names, for use (via `Get`) in `and_then`"""

        bindings: tuple[tuple[str, "DecompositionRequest.Request"], ...]
        """The names and the decompositions bound to them"""
        and_then: "DecompositionRequest.Request"
        """The decomposition computed with the bindings in scope"""
        _raw: lib.Tasks_Decomp_task_Mir_decomp = field(repr=False, compare=False)

        def __str__(self) -> str:
            bindings = " and ".join(f"{n} = {d}" for n, d in self.bindings)
            return f"let {bindings} in {self.and_then}"

    @dataclass(slots=True, frozen=True)
    class Enumerate:
        """Enumerate the decomposition `d_f` over the decompositions `ds`"""

        d_f: "DecompositionRequest.Request"
        """The decomposition to enumerate"""
        ds: tuple["DecompositionRequest.Request", ...]
        """The decompositions to enumerate over"""
        style: EnumerationStyle | None
        """Additive or multiplicative enumeration; `None` means additive"""
        _raw: lib.Tasks_Decomp_task_Mir_decomp = field(repr=False, compare=False)

        def __str__(self) -> str:
            ds = ", ".join(str(d) for d in self.ds)
            return f"enumerate ({self.d_f}) [{ds}]"

    Request = Function | Term | Return | Prune | Merge | CompoundMerge | Combine | Get | Let | Enumerate
    """A description of the decomposition to compute; requests can be combined"""


def decomp_request_of_lib(d: lib.Tasks_Decomp_task_Mir_decomp) -> DecompositionRequest.Request:
    """Convert a library decomposition request into the matching `Request` variant"""
    match d:
        case lib.Tasks_Decomp_task_decomp_poly_Decomp(arg=a):
            return DecompositionRequest.Function(
                function=Uid(a.f_id),
                assuming=None if a.assuming is None else Uid(a.assuming),
                basis=frozenset(Uid(u) for u in a.basis),
                rule_specs=frozenset(Uid(u) for u in a.rule_specs),
                ctx_simp=a.ctx_simp,
                lift_bool=lift_bool_of_lib(a.lift_bool),
                prune=a.prune,
                _raw=d,
            )
        case lib.Tasks_Decomp_task_decomp_poly_Term(arg=t):
            return DecompositionRequest.Term(term=term_of_lib(t), _raw=d)
        case lib.Tasks_Decomp_task_decomp_poly_Return(arg=fd):
            return DecompositionRequest.Return(decomposition=Decomposition.of_lib(fd), _raw=d)
        case lib.Tasks_Decomp_task_decomp_poly_Prune(arg=r):
            return DecompositionRequest.Prune(request=decomp_request_of_lib(r), _raw=d)
        case lib.Tasks_Decomp_task_decomp_poly_Merge(args=(l, r)):
            return DecompositionRequest.Merge(left=decomp_request_of_lib(l), right=decomp_request_of_lib(r), _raw=d)
        case lib.Tasks_Decomp_task_decomp_poly_Compound_merge(args=(l, r)):
            return DecompositionRequest.CompoundMerge(
                left=decomp_request_of_lib(l), right=decomp_request_of_lib(r), _raw=d
            )
        case lib.Tasks_Decomp_task_decomp_poly_Combine(arg=r):
            return DecompositionRequest.Combine(request=decomp_request_of_lib(r), _raw=d)
        case lib.Tasks_Decomp_task_decomp_poly_Get(arg=name):
            return DecompositionRequest.Get(name=name, _raw=d)
        case lib.Tasks_Decomp_task_decomp_poly_Let(bindings=bindings, and_then=and_then):
            return DecompositionRequest.Let(
                bindings=tuple((n, decomp_request_of_lib(b)) for n, b in bindings),
                and_then=decomp_request_of_lib(and_then),
                _raw=d,
            )
        case lib.Tasks_Decomp_task_decomp_poly_Enumerate(d_f=d_f, ds=ds, style=style):
            return DecompositionRequest.Enumerate(
                d_f=decomp_request_of_lib(d_f),
                ds=tuple(decomp_request_of_lib(x) for x in ds),
                style=None if style is None else enumeration_style_of_lib(style),
                _raw=d,
            )
        case _:
            assert_never(d)


class DecompositionTask(Task):
    """A decomposition task"""

    _artifact_kind = "decomp_task"
    _result_artifact_kind = "decomp_res"

    def __init__(self, task: task_pb2.Task, client: "Client | AsyncClient | None" = None):
        assert task.kind == task_pb2.TASK_DECOMP
        super().__init__(task, client)

    @cached_property
    def _decomp_task(self) -> lib.Tasks_Decomp_task_Mir:
        return self._artifact("decomp_task").decode_as(lib.Tasks_Decomp_task_t_poly[lib.Mir_Term, lib.Mir_Type])

    @cached_property
    def decomp(self) -> DecompositionRequest.Request:
        """The decomposition request

        Fetched on first access, see `Task`
        """
        return decomp_request_of_lib(self._decomp_task.decomp)

    @property
    def timeout(self) -> int | None:
        """The timeout, if any

        Fetched on first access, see `Task`
        """
        return self._decomp_task.timeout

    @cached_property
    def db(self) -> DB:
        """The database of declarations and rules the decomposition is computed in

        Fetched on first access, see `Task`
        """
        return DB(self._decomp_task.db, self._artifact("decomp_task").storage)


class ProofCheckTask(Task):
    """A proof checking task"""

    # The API defines no artifact kinds for proof checking
    _artifact_kind = None
    _result_artifact_kind = None

    def __init__(self, task: task_pb2.Task, client: "Client | AsyncClient | None" = None):
        assert task.kind == task_pb2.TASK_PROOF_CHECK
        super().__init__(task, client)


def task_of_raw(t: task_pb2.Task, client: "Client | AsyncClient | None" = None) -> Task:
    """Wrap a task in the matching `Task` subclass"""
    match t.kind:
        case task_pb2.TASK_CHECK_PO:
            return ProofObligationTask(t, client)
        case task_pb2.TASK_EVAL:
            return EvaluationTask(t, client)
        case task_pb2.TASK_DECOMP:
            return DecompositionTask(t, client)
        case task_pb2.TASK_PROOF_CHECK:
            return ProofCheckTask(t, client)
        case _:
            return Task(t, client)


@dataclass(slots=True, frozen=True)
class Origin:
    """Where a task came from"""

    from_sym: str
    """The symbol the task was generated from"""
    count: int
    """Distinguishes tasks generated from the same symbol"""
    _raw: task_pb2.Origin = field(repr=False, compare=False)

    @classmethod
    def of_raw(cls, x: task_pb2.Origin) -> "Origin":
        return cls(from_sym=x.from_sym, count=x.count, _raw=x)


@dataclass(slots=True, frozen=True)
class ProofObligationResult:
    """A proof obligation result in an `eval_src` response"""

    @dataclass(slots=True, frozen=True)
    class Unknown:
        """The proof obligation could not be decided"""

        message: str

    @dataclass(slots=True, frozen=True)
    class Err:
        """Checking failed; the errors are in `ProofObligationResult.errors`"""

    @dataclass(slots=True, frozen=True)
    class Proof:
        """The goal was proved"""

        proof_pp: str | None
        """The pretty-printed proof, if the server sent it"""

    @dataclass(slots=True, frozen=True)
    class Instance:
        """A model was found: an instance of an `instance` goal, or a counter-example to a theorem
        or `verify` goal (reported with an error)"""

        model: "ModelOutput | None"
        """The model, if the server sent it"""

    @dataclass(slots=True, frozen=True)
    class VerifiedUpto:
        """The goal was verified up to a bound"""

        message: str | None

    @dataclass(slots=True, frozen=True)
    class TestOk:
        """Testing found no counter-example"""

    Res = Unknown | Err | Proof | Instance | VerifiedUpto | TestOk
    """The outcome of the proof obligation"""

    res: Res | None
    """The outcome of the proof obligation, `None` if the server sent none"""
    errors: tuple[Error, ...]
    """Errors reported while checking the proof obligation"""
    task: Task
    """The proof obligation's task"""
    origin: Origin
    """Where the proof obligation came from"""
    _raw: simple_api_pb2.PO_Res = field(repr=False, compare=False)

    @classmethod
    def of_raw(cls, x: simple_api_pb2.PO_Res, client: "Client | AsyncClient | None" = None) -> "ProofObligationResult":
        res: ProofObligationResult.Res | None
        match x.WhichOneof("res"):
            case "unknown":
                res = ProofObligationResult.Unknown(message=x.unknown.msg)
            case "err":
                res = ProofObligationResult.Err()
            case "proof":
                res = ProofObligationResult.Proof(proof_pp=x.proof.proof_pp if x.proof.HasField("proof_pp") else None)
            case "instance":
                res = ProofObligationResult.Instance(
                    model=ModelOutput.of_raw(x.instance.model) if x.instance.HasField("model") else None
                )
            case "verified_upto":
                res = ProofObligationResult.VerifiedUpto(
                    message=x.verified_upto.msg if x.verified_upto.HasField("msg") else None
                )
            case "test_ok":
                res = ProofObligationResult.TestOk()
            case _:
                res = None
        return cls(
            res=res,
            errors=tuple(Error.of_raw(e) for e in x.errors),
            task=task_of_raw(x.task, client),
            origin=Origin.of_raw(x.origin),
            _raw=x,
        )

    @property
    def outcome(self) -> Literal["unknown", "err", "proof", "instance", "verified_upto", "test_ok"] | None:
        """One of `unknown`, `err`, `proof`, `instance`, `verified_upto` and `test_ok`"""
        match self.res:
            case ProofObligationResult.Unknown():
                return "unknown"
            case ProofObligationResult.Err():
                return "err"
            case ProofObligationResult.Proof():
                return "proof"
            case ProofObligationResult.Instance():
                return "instance"
            case ProofObligationResult.VerifiedUpto():
                return "verified_upto"
            case ProofObligationResult.TestOk():
                return "test_ok"
            case None:
                return None

    @property
    def proved(self) -> bool:
        """Whether the goal was proved"""
        return isinstance(self.res, ProofObligationResult.Proof)

    @property
    def found(self) -> bool:
        """Whether a model was found: an instance, or a counter-example to a theorem or `verify` goal"""
        return isinstance(self.res, ProofObligationResult.Instance)

    @property
    def proof_pp(self) -> str | None:
        """The pretty-printed proof, if the goal was proved and the server sent it"""
        return self.res.proof_pp if isinstance(self.res, ProofObligationResult.Proof) else None

    @property
    def model(self) -> "ModelOutput | None":
        """The model, if one was found and the server sent it"""
        return self.res.model if isinstance(self.res, ProofObligationResult.Instance) else None

    @property
    def message(self) -> str | None:
        """The message for an `unknown` or `verified_upto` outcome, if any"""
        match self.res:
            case ProofObligationResult.Unknown(message=m) | ProofObligationResult.VerifiedUpto(message=m):
                return m
            case _:
                return None


# Not slotted for cached_property
@dataclass(frozen=True)
class DecompositionResult:
    """The result of a decomposition request"""

    artifact: Artifact | None
    """The decomposition artifact, None if decomp has error"""
    task: Task
    """The decomposition task"""
    errors: tuple[Error, ...]
    """Errors reported during decomposition"""
    _raw: simple_api_pb2.DecomposeRes = field(repr=False, compare=False)

    @classmethod
    def of_raw(
        cls, x: simple_api_pb2.DecomposeRes, client: "Client | AsyncClient | None" = None
    ) -> "DecompositionResult":
        return cls(
            artifact=Artifact.of_raw(x.artifact) if x.WhichOneof("res") == "artifact" else None,
            task=task_of_raw(x.task, client),
            errors=tuple(Error.of_raw(e) for e in x.errors),
            _raw=x,
        )

    @property
    def success(self) -> bool:
        """Whether the decomposition succeeded"""
        return self.artifact is not None

    @cached_property
    def decomposition(self) -> Decomposition | None:
        """The decomposition, decoded from `artifact` on first access, if the request succeeded"""
        if self.artifact is None:
            return None
        return Decomposition.of_lib(self.artifact.decode_as(lib.Common_Fun_decomp_t_poly[lib.Mir_Term, lib.Mir_Type]))


@dataclass(slots=True, frozen=True)
class EvalOutput:
    """The output of an `eval` in evaluated source"""

    success: bool
    """Whether evaluation succeeded"""
    as_ocaml: str | None
    """The value printed as OCaml, if available"""
    errors: tuple[Error, ...]
    """Errors reported during evaluation"""
    _raw: simple_api_pb2.EvalOutput = field(repr=False, compare=False)

    @classmethod
    def of_raw(cls, x: simple_api_pb2.EvalOutput) -> "EvalOutput":
        return cls(
            success=x.success,
            as_ocaml=x.value_as_ocaml if x.HasField("value_as_ocaml") else None,
            errors=tuple(Error.of_raw(e) for e in x.errors),
            _raw=x,
        )


@dataclass(slots=True, frozen=True)
class EvalSrcResponse:
    """The response to an `eval_src` request"""

    success: bool
    """Whether the request succeeded; errors in the source are reported in `errors`"""
    messages: tuple[str, ...]
    """Messages printed while processing the source"""
    errors: tuple[Error, ...]
    """Errors reported while processing the source"""
    tasks: tuple[Task, ...]
    """The tasks created while processing the source"""
    po_results: tuple[ProofObligationResult, ...]
    """The results of the source's proof obligations"""
    eval_results: tuple[EvalOutput, ...]
    """The outputs of the source's `eval` statements"""
    decomp_results: tuple[DecompositionResult, ...]
    """The results of the source's decompositions"""
    _raw: simple_api_pb2.EvalRes = field(repr=False, compare=False)

    @classmethod
    def of_raw(cls, x: simple_api_pb2.EvalRes, client: "Client | AsyncClient | None" = None) -> "EvalSrcResponse":
        return cls(
            success=x.success,
            messages=tuple(x.messages),
            errors=tuple(Error.of_raw(e) for e in x.errors),
            tasks=tuple(task_of_raw(t, client) for t in x.tasks),
            po_results=tuple(ProofObligationResult.of_raw(r, client) for r in x.po_results),
            eval_results=tuple(EvalOutput.of_raw(r) for r in x.eval_results),
            decomp_results=tuple(DecompositionResult.of_raw(r, client) for r in x.decomp_results),
            _raw=x,
        )


# Not slotted for cached_property
@dataclass(frozen=True)
class ModelOutput:
    """A model returned by `verify_*`, `instance_*` or `test_*`"""

    kind: Literal["counter_example", "instance"]
    """Whether the model is a counter-example or an instance"""
    src: str
    """The model as IML source"""
    _raw: simple_api_pb2.Model = field(repr=False, compare=False)

    @classmethod
    def of_raw(cls, x: simple_api_pb2.Model) -> "ModelOutput":
        kind: Literal["counter_example", "instance"]
        match x.m_type:
            case simple_api_pb2.Counter_example:
                kind = "counter_example"
            case simple_api_pb2.Instance:
                kind = "instance"
            case _:
                raise UnexpectedResponseError(f"Unexpected model type '{x.m_type}'")
        return cls(kind=kind, src=x.src, _raw=x)

    def __str__(self) -> str:
        return self.src

    @cached_property
    def model(self) -> Model | None:
        """The model, decoded from its artifact on first access, if the server sent one"""
        if not self._raw.HasField("artifact"):
            return None
        artifact = Artifact.of_raw(self._raw.artifact)
        return Model.of_lib(artifact.decode_as(lib.Common_Model_t_poly[lib.Mir_Term, lib.Mir_Type]))


@dataclass(slots=True, frozen=True)
class VerifyResponse:
    """The result of a `verify_src` or `verify_name` request"""

    @dataclass(slots=True, frozen=True)
    class Unknown:
        """Verification could not decide the goal"""

        message: str

    @dataclass(slots=True, frozen=True)
    class Err:
        """Verification failed; the errors are in `VerifyResponse.errors`"""

    @dataclass(slots=True, frozen=True)
    class Proved:
        """The goal was proved"""

        proof_pp: str | None
        """The pretty-printed proof, if the server sent it"""

    @dataclass(slots=True, frozen=True)
    class Refuted:
        """A counter-example was found"""

        counter_example: ModelOutput | None
        """The counter-example, if the server sent it"""

    @dataclass(slots=True, frozen=True)
    class VerifiedUpto:
        """The goal was verified up to a bound"""

        message: str | None

    Res = Unknown | Err | Proved | Refuted | VerifiedUpto
    """The outcome of verification"""

    res: Res | None
    """The outcome of verification, `None` if the server sent none"""
    # CR: can `None` ever happens?
    errors: tuple[Error, ...]
    """Errors reported during verification"""
    task: Task
    """The verification task"""
    _raw: simple_api_pb2.VerifyRes = field(repr=False, compare=False)

    @classmethod
    def of_raw(cls, x: simple_api_pb2.VerifyRes, client: "Client | AsyncClient | None" = None) -> "VerifyResponse":
        res: VerifyResponse.Res | None
        match x.WhichOneof("res"):
            case "unknown":
                res = VerifyResponse.Unknown(message=x.unknown.msg)
            case "err":
                res = VerifyResponse.Err()
            case "proved":
                res = VerifyResponse.Proved(proof_pp=x.proved.proof_pp if x.proved.HasField("proof_pp") else None)
            case "refuted":
                res = VerifyResponse.Refuted(
                    counter_example=ModelOutput.of_raw(x.refuted.model) if x.refuted.HasField("model") else None
                )
            case "verified_upto":
                res = VerifyResponse.VerifiedUpto(
                    message=x.verified_upto.msg if x.verified_upto.HasField("msg") else None
                )
            case _:
                res = None
        return cls(
            res=res,
            errors=tuple(Error.of_raw(e) for e in x.errors),
            task=task_of_raw(x.task, client),
            _raw=x,
        )

    @property
    def outcome(self) -> Literal["unknown", "err", "proved", "refuted", "verified_upto"] | None:
        """One of `unknown`, `err`, `proved`, `refuted` and `verified_upto`"""
        match self.res:
            case VerifyResponse.Unknown():
                return "unknown"
            case VerifyResponse.Err():
                return "err"
            case VerifyResponse.Proved():
                return "proved"
            case VerifyResponse.Refuted():
                return "refuted"
            case VerifyResponse.VerifiedUpto():
                return "verified_upto"
            case None:
                return None

    @property
    def proved(self) -> bool:
        """Whether the goal was proved"""
        return isinstance(self.res, VerifyResponse.Proved)

    @property
    def refuted(self) -> bool:
        """Whether a counter-example was found"""
        return isinstance(self.res, VerifyResponse.Refuted)

    @property
    def proof_pp(self) -> str | None:
        """The pretty-printed proof, if the goal was proved and the server sent it"""
        return self.res.proof_pp if isinstance(self.res, VerifyResponse.Proved) else None

    @property
    def counter_example(self) -> ModelOutput | None:
        """The counter-example, if the goal was refuted"""
        return self.res.counter_example if isinstance(self.res, VerifyResponse.Refuted) else None

    @property
    def message(self) -> str | None:
        """The message for an `unknown` or `verified_upto` outcome, if any"""
        match self.res:
            case VerifyResponse.Unknown(message=m) | VerifyResponse.VerifiedUpto(message=m):
                return m
            case _:
                return None


@dataclass(slots=True, frozen=True)
class InstanceResponse:
    """The result of an `instance_src` or `instance_name` request"""

    @dataclass(slots=True, frozen=True)
    class Unknown:
        """The instance search could not decide the goal"""

        message: str

    @dataclass(slots=True, frozen=True)
    class Err:
        """The instance search failed; the errors are in `InstanceResponse.errors`"""

    @dataclass(slots=True, frozen=True)
    class Unsat:
        """The goal has no instance"""

        proof_pp: str | None
        """The pretty-printed proof of unsatisfiability, if the server sent it"""

    @dataclass(slots=True, frozen=True)
    class Sat:
        """An instance was found"""

        instance: ModelOutput | None
        """The instance, if the server sent it"""

    Res = Unknown | Err | Unsat | Sat
    """The outcome of the instance search"""

    res: Res | None
    """The outcome of the instance search, `None` if the server sent none"""
    errors: tuple[Error, ...]
    """Errors reported during the instance search"""
    task: Task
    """The instance task"""
    _raw: simple_api_pb2.InstanceRes = field(repr=False, compare=False)

    @classmethod
    def of_raw(cls, x: simple_api_pb2.InstanceRes, client: "Client | AsyncClient | None" = None) -> "InstanceResponse":
        res: InstanceResponse.Res | None
        match x.WhichOneof("res"):
            case "unknown":
                res = InstanceResponse.Unknown(message=x.unknown.msg)
            case "err":
                res = InstanceResponse.Err()
            case "unsat":
                res = InstanceResponse.Unsat(proof_pp=x.unsat.proof_pp if x.unsat.HasField("proof_pp") else None)
            case "sat":
                res = InstanceResponse.Sat(instance=ModelOutput.of_raw(x.sat.model) if x.sat.HasField("model") else None)
            case _:
                res = None
        return cls(
            res=res,
            errors=tuple(Error.of_raw(e) for e in x.errors),
            task=task_of_raw(x.task, client),
            _raw=x,
        )

    @property
    def outcome(self) -> Literal["unknown", "err", "unsat", "sat"] | None:
        """One of `unknown`, `err`, `unsat` and `sat`"""
        match self.res:
            case InstanceResponse.Unknown():
                return "unknown"
            case InstanceResponse.Err():
                return "err"
            case InstanceResponse.Unsat():
                return "unsat"
            case InstanceResponse.Sat():
                return "sat"
            case None:
                return None

    @property
    def found(self) -> bool:
        """Whether an instance was found"""
        return isinstance(self.res, InstanceResponse.Sat)

    @property
    def instance(self) -> ModelOutput | None:
        """The instance, if one was found"""
        return self.res.instance if isinstance(self.res, InstanceResponse.Sat) else None

    @property
    def proof_pp(self) -> str | None:
        """The pretty-printed proof of unsatisfiability, if any"""
        return self.res.proof_pp if isinstance(self.res, InstanceResponse.Unsat) else None

    @property
    def message(self) -> str | None:
        """The message for an `unknown` outcome"""
        return self.res.message if isinstance(self.res, InstanceResponse.Unknown) else None


@dataclass(slots=True, frozen=True)
class TestResponse:
    """The result of a `test_src` or `test_name` request"""

    __test__ = False  # otherwise pytest will collect this as test

    @dataclass(slots=True, frozen=True)
    class Err:
        """Testing failed, or found no counter-example; the errors are in `TestResponse.errors`

        Testing that finds no counter-example is reported this way, with an error of kind
        `NoCounterExample`
        """

    @dataclass(slots=True, frozen=True)
    class CounterExample:
        """A counter-example was found"""

        counter_example: ModelOutput | None
        """The counter-example, if the server sent it"""

    Res = Err | CounterExample
    """The outcome of testing"""

    res: Res | None
    """The outcome of testing, `None` if the server sent none"""
    errors: tuple[Error, ...]
    """Errors reported during testing"""
    task: Task
    """The test task"""
    _raw: simple_api_pb2.TestRes = field(repr=False, compare=False)

    @classmethod
    def of_raw(cls, x: simple_api_pb2.TestRes, client: "Client | AsyncClient | None" = None) -> "TestResponse":
        res: TestResponse.Res | None
        match x.WhichOneof("res"):
            case "err":
                res = TestResponse.Err()
            case "counter_example":
                res = TestResponse.CounterExample(
                    counter_example=(
                        ModelOutput.of_raw(x.counter_example.model) if x.counter_example.HasField("model") else None
                    )
                )
            case _:
                res = None
        return cls(
            res=res,
            errors=tuple(Error.of_raw(e) for e in x.errors),
            task=task_of_raw(x.task, client),
            _raw=x,
        )

    @property
    def outcome(self) -> Literal["err", "counter_example"] | None:
        """One of `err` and `counter_example`

        Testing that finds no counter-example is reported as `err`, with an error of kind
        `NoCounterExample`
        """
        match self.res:
            case TestResponse.Err():
                return "err"
            case TestResponse.CounterExample():
                return "counter_example"
            case None:
                return None

    @property
    def refuted(self) -> bool:
        """Whether a counter-example was found"""
        return isinstance(self.res, TestResponse.CounterExample)

    @property
    def counter_example(self) -> ModelOutput | None:
        """The counter-example, if one was found"""
        return self.res.counter_example if isinstance(self.res, TestResponse.CounterExample) else None


@dataclass(slots=True, frozen=True)
class TypecheckResponse:
    """The result of a `typecheck` request"""

    success: bool
    """Whether the source typechecked"""
    types: Any
    """The inferred types, decoded from JSON"""
    errors: tuple[Error, ...]
    """Errors reported during typechecking"""
    _raw: simple_api_pb2.TypecheckRes = field(repr=False, compare=False)

    @classmethod
    def of_raw(cls, x: simple_api_pb2.TypecheckRes) -> "TypecheckResponse":
        return cls(
            success=x.success,
            types=json.loads(x.types) if x.types else None,
            errors=tuple(Error.of_raw(e) for e in x.errors),
            _raw=x,
        )


@dataclass(slots=True, frozen=True)
class OneshotResponse:
    """The result of a `oneshot` request"""

    results: tuple[str, ...]
    """The results, as strings"""
    detailed_results: tuple[str, ...]
    """The results, in more detail"""
    errors: tuple[str, ...]
    """The errors, as strings"""
    time_s: float
    """The time the request took on the server, in seconds"""
    _raw: simple_api_pb2.OneshotRes = field(repr=False, compare=False)

    @classmethod
    def of_raw(cls, x: simple_api_pb2.OneshotRes) -> "OneshotResponse":
        return cls(
            results=tuple(x.results),
            detailed_results=tuple(x.detailed_results),
            errors=tuple(x.errors),
            time_s=x.stats.time,
            _raw=x,
        )


@dataclass(slots=True, frozen=True)
class CodeSnippetResponse:
    """The result of an `eval_code_snippet` request"""

    res: Literal["ok", "errors"]
    """The evaluation status reported by the server; `errors` can be non-empty even when it is `"ok"`"""
    duration_s: float
    """The time evaluation took, in seconds"""
    tasks: tuple[Task, ...]
    """The tasks created during evaluation"""
    errors: tuple[Error, ...]
    """Errors reported during evaluation"""
    _raw: api_pb2.CodeSnippetEvalResult = field(repr=False, compare=False)

    @classmethod
    def of_raw(
        cls, x: api_pb2.CodeSnippetEvalResult, client: "Client | AsyncClient | None" = None
    ) -> "CodeSnippetResponse":
        res: Literal["ok", "errors"]
        match x.res:
            case api_pb2.EVAL_OK:
                res = "ok"
            case api_pb2.EVAL_ERRORS:
                res = "errors"
            case _:
                raise UnexpectedResponseError(f"Unexpected eval result '{x.res}'")
        return cls(
            res=res,
            duration_s=x.duration_s,
            tasks=tuple(task_of_raw(t, client) for t in x.tasks),
            errors=tuple(Error.of_raw(e) for e in x.errors),
            _raw=x,
        )


@dataclass(slots=True, frozen=True)
class ServerVersion:
    """The server's version"""

    version: str
    git_version: str | None
    _raw: system_pb2.VersionResponse = field(repr=False, compare=False)

    @classmethod
    def of_raw(cls, x: system_pb2.VersionResponse) -> "ServerVersion":
        return cls(version=x.version, git_version=x.git_version if x.HasField("git_version") else None, _raw=x)


def _artifact_kinds_of_result(res: api_pb2.ArtifactListResult) -> list[str]:
    match res.WhichOneof("result"):
        case "error":
            raise ServerError(Error.of_raw(res.error))
        case "ok":
            return list(res.ok.kinds)
        case _:
            raise UnexpectedResponseError("Artifact list result has neither `error` nor `ok`")


def _artifact_zip_of_result(res: api_pb2.ArtifactZipResult) -> bytes:
    match res.WhichOneof("result"):
        case "error":
            raise ServerError(Error.of_raw(res.error))
        case "ok":
            return res.ok.art_zip
        case _:
            raise UnexpectedResponseError("Artifact zip result has neither `error` nor `ok`")


class Client:
    """A client for the ImandraX API"""

    def __init__(
        self,
        url: str = imandrax_api.client.url_prod,
        server_path_prefix: str = "/api/v1",
        auth_token: str | None = None,
        api_key: str | None = None,
        timeout: int = 30,
        session_id: str | None = None,
        create_if_not_found: bool = False,
    ):
        self._client = imandrax_api.Client(
            url=url,
            server_path_prefix=server_path_prefix,
            auth_token=auth_token,
            api_key=api_key,
            timeout=timeout,
            session_id=session_id,
            create_if_not_found=create_if_not_found,
        )

    def __enter__(self) -> Self:
        return self

    def __exit__(self, *_: object) -> None:
        self._client.__exit__()

    def status(self) -> str:
        return self._client.status().msg

    def eval_src(
        self,
        src: str,
        timeout: float | None = None,
        async_only: bool | None = None,
        task_filter: list[str] | None = None,
    ) -> EvalSrcResponse:
        """Evaluate IML source

        `async_only` returns without waiting for task results; `task_filter` holds glob patterns
        selecting the tasks to start, see `imandrax_api.Client.eval_src`
        """
        return EvalSrcResponse.of_raw(
            self._client.eval_src(
                src, timeout=timeout, async_only=async_only, task_filter=task_filter
            ),
            self,
        )

    @property
    def session_id(self) -> str:
        """The ID of the client's session"""
        return self._client.session_id

    def decompose(
        self,
        name: str,
        assuming: str | None = None,
        basis: list[str] | None = None,
        rule_specs: list[str] | None = None,
        prune: bool | None = None,
        ctx_simp: bool | None = None,
        lift_bool: simple_api_pb2.LiftBool | None = None,
        timeout: float | None = None,
        string_results: bool | None = None,
        compute_timeout: int | None = None,
    ) -> DecompositionResult:
        """Decompose the function `name`; see `imandrax_api.Client.decompose`"""
        return DecompositionResult.of_raw(
            self._client.decompose(
                name,
                assuming=assuming,
                basis=basis,
                rule_specs=rule_specs,
                prune=prune,
                ctx_simp=ctx_simp,
                lift_bool=lift_bool,
                timeout=timeout,
                string_results=string_results,
                compute_timeout=compute_timeout,
            ),
            self,
        )

    def decompose_full(
        self,
        # TODO: we should have a Decomp combinator class here?
        d: "decomp.Decomp",
        timeout: float | None = None,
        string_results: bool | None = None,
        compute_timeout: int | None = None,
    ) -> DecompositionResult:
        return DecompositionResult.of_raw(
            self._client.decompose_full(
                d,
                timeout=timeout,
                string_results=string_results,
                compute_timeout=compute_timeout,
            ),
            self,
        )

    def verify_src(
        self, src: str, hints: str | None = None, timeout: float | None = None
    ) -> VerifyResponse:
        """Verify the goal given as IML source"""
        return VerifyResponse.of_raw(
            self._client.verify_src(src, hints=hints, timeout=timeout), self
        )

    def verify_name(
        self, name: str, hints: str | None = None, timeout: float | None = None
    ) -> VerifyResponse:
        """Verify the predicate `name`"""
        return VerifyResponse.of_raw(
            self._client.verify_name(name, hints=hints, timeout=timeout), self
        )

    def instance_src(
        self, src: str, hints: str | None = None, timeout: float | None = None
    ) -> InstanceResponse:
        """Search for an instance of the goal given as IML source"""
        return InstanceResponse.of_raw(
            self._client.instance_src(src, hints=hints, timeout=timeout), self
        )

    def instance_name(
        self, name: str, hints: str | None = None, timeout: float | None = None
    ) -> InstanceResponse:
        """Search for an instance of the predicate `name`"""
        return InstanceResponse.of_raw(
            self._client.instance_name(name, hints=hints, timeout=timeout), self
        )

    def test_src(
        self, src: str, seed: int | None = None, timeout: float | None = None
    ) -> TestResponse:
        """Test the goal given as IML source with random inputs"""
        return TestResponse.of_raw(self._client.test_src(src, seed=seed, timeout=timeout), self)

    def test_name(
        self, name: str, seed: int | None = None, timeout: float | None = None
    ) -> TestResponse:
        """Test the predicate `name` with random inputs"""
        return TestResponse.of_raw(
            self._client.test_name(name, seed=seed, timeout=timeout), self
        )

    def typecheck(self, src: str, timeout: float | None = None) -> TypecheckResponse:
        """Typecheck IML source, adding its definitions to the session"""
        return TypecheckResponse.of_raw(self._client.typecheck(src, timeout=timeout))

    def oneshot(
        self,
        input: str,
        compute_timeout: float | None = None,
        timeout: float | None = None,
    ) -> OneshotResponse:
        """Evaluate IML code in a sessionless, self-contained request"""
        return OneshotResponse.of_raw(
            self._client.oneshot(
                input, compute_timeout=compute_timeout, timeout=timeout
            )
        )

    def eval_code_snippet(
        self,
        code: str,
        task_filter: list[str] | None = None,
        timeout: float | None = None,
    ) -> CodeSnippetResponse:
        """Evaluate a code snippet; `task_filter` selects tasks to start, as in `eval_src`"""
        return CodeSnippetResponse.of_raw(
            self._client.eval_code_snippet(
                code, task_filter=task_filter, timeout=timeout
            ),
            self,
        )

    def parse_term(self, code: str, timeout: float | None = None) -> Term:
        """Parse and typecheck a term"""
        artifact = _artifact_of_result(self._client.parse_term(code, timeout=timeout))
        return term_of_lib(artifact.decode_as(lib.Mir_Term))

    def parse_type(self, code: str, timeout: float | None = None) -> Type:
        """Parse and typecheck a type"""
        artifact = _artifact_of_result(self._client.parse_type(code, timeout=timeout))
        return type_of_lib(artifact.decode_as(lib.Mir_Type))

    def list_artifacts(self, task: Task, timeout: float | None = None) -> list[str]:
        """The kinds of the artifacts available for `task`"""
        return _artifact_kinds_of_result(
            self._client.list_artifacts(task._raw, timeout=timeout)
        )

    def get_artifact(
        self, task: Task, kind: str, timeout: float | None = None
    ) -> Artifact:
        """The artifact of kind `kind` of `task`"""
        return _artifact_of_result(
            self._client.get_artifact(task._raw, kind, timeout=timeout)
        )

    def get_artifact_zip(
        self, task: Task, kind: str, timeout: float | None = None
    ) -> bytes:
        """The artifact of kind `kind` of `task`, as a zip file"""
        return _artifact_zip_of_result(
            self._client.get_artifact_zip(task._raw, kind, timeout=timeout)
        )

    def keep_session_alive(self, timeout: float | None = None) -> None:
        """Make sure the session remains active"""
        self._client.keep_session_alive(timeout=timeout)

    def version(self, timeout: float | None = None) -> ServerVersion:
        """The server's version"""
        return ServerVersion.of_raw(self._client.version(timeout=timeout))


class AsyncClient:
    """An asynchronous client for the ImandraX API; use it as `async with AsyncClient(...) as c`

    Needs the optional `aiohttp` dependency."""

    def __init__(
        self,
        url: str = imandrax_api.client.url_prod,
        server_path_prefix: str = "/api/v1",
        auth_token: str | None = None,
        api_key: str | None = None,
        timeout: int = 30,
        session_id: str | None = None,
        create_if_not_found: bool = False,
    ):
        self._client: AsyncClient_ = imandrax_api.client.AsyncClient(
            url=url,
            server_path_prefix=server_path_prefix,
            auth_token=auth_token,
            api_key=api_key,
            timeout=timeout,
            session_id=session_id,
            create_if_not_found=create_if_not_found,
        )

    async def __aenter__(self) -> Self:
        await self._client.__aenter__()
        return self

    async def __aexit__(
        self,
        exc_type: type[BaseException] | None,
        exc_val: BaseException | None,
        exc_tb: TracebackType | None,
    ) -> None:
        await self._client.__aexit__(exc_type, exc_val, exc_tb)

    async def status(self) -> str:
        return (await self._client.status()).msg

    async def eval_src(
        self,
        src: str,
        timeout: float | None = None,
        async_only: bool | None = None,
        task_filter: list[str] | None = None,
    ) -> EvalSrcResponse:
        """Evaluate IML source

        `async_only` returns without waiting for task results; `task_filter` holds glob patterns
        selecting the tasks to start, see `imandrax_api.Client.eval_src`
        """
        return EvalSrcResponse.of_raw(
            await self._client.eval_src(
                src, timeout=timeout, async_only=async_only, task_filter=task_filter
            ),
            self,
        )

    @property
    def session_id(self) -> str | None:
        """The ID of the client's session"""
        return self._client.session_id

    async def decompose(
        self,
        name: str,
        assuming: str | None = None,
        basis: list[str] | None = None,
        rule_specs: list[str] | None = None,
        prune: bool | None = None,
        ctx_simp: bool | None = None,
        lift_bool: simple_api_pb2.LiftBool | None = None,
        timeout: float | None = None,
        string_results: bool | None = None,
        compute_timeout: int | None = None,
    ) -> DecompositionResult:
        """Decompose the function `name`; see `imandrax_api.Client.decompose`"""
        return DecompositionResult.of_raw(
            await self._client.decompose(
                name,
                assuming=assuming,
                basis=basis,
                rule_specs=rule_specs,
                prune=prune,
                ctx_simp=ctx_simp,
                lift_bool=lift_bool,
                timeout=timeout,
                string_results=string_results,
                compute_timeout=compute_timeout,
            ),
            self,
        )

    async def decompose_full(
        self,
        d: "decomp.Decomp",
        timeout: float | None = None,
        string_results: bool | None = None,
        compute_timeout: int | None = None,
    ) -> DecompositionResult:
        return DecompositionResult.of_raw(
            await self._client.decompose_full(
                d,
                timeout=timeout,
                string_results=string_results,
                compute_timeout=compute_timeout,
            ),
            self,
        )

    async def verify_src(
        self, src: str, hints: str | None = None, timeout: float | None = None
    ) -> VerifyResponse:
        """Verify the goal given as IML source"""
        return VerifyResponse.of_raw(
            await self._client.verify_src(src, hints=hints, timeout=timeout), self
        )

    async def verify_name(
        self, name: str, hints: str | None = None, timeout: float | None = None
    ) -> VerifyResponse:
        """Verify the predicate `name`"""
        return VerifyResponse.of_raw(
            await self._client.verify_name(name, hints=hints, timeout=timeout), self
        )

    async def instance_src(
        self, src: str, hints: str | None = None, timeout: float | None = None
    ) -> InstanceResponse:
        """Search for an instance of the goal given as IML source"""
        return InstanceResponse.of_raw(
            await self._client.instance_src(src, hints=hints, timeout=timeout), self
        )

    async def instance_name(
        self, name: str, hints: str | None = None, timeout: float | None = None
    ) -> InstanceResponse:
        """Search for an instance of the predicate `name`"""
        return InstanceResponse.of_raw(
            await self._client.instance_name(name, hints=hints, timeout=timeout), self
        )

    async def test_src(
        self, src: str, seed: int | None = None, timeout: float | None = None
    ) -> TestResponse:
        """Test the goal given as IML source with random inputs"""
        return TestResponse.of_raw(
            await self._client.test_src(src, seed=seed, timeout=timeout), self
        )

    async def test_name(
        self, name: str, seed: int | None = None, timeout: float | None = None
    ) -> TestResponse:
        """Test the predicate `name` with random inputs"""
        return TestResponse.of_raw(
            await self._client.test_name(name, seed=seed, timeout=timeout), self
        )

    async def typecheck(
        self, src: str, timeout: float | None = None
    ) -> TypecheckResponse:
        """Typecheck IML source, adding its definitions to the session"""
        return TypecheckResponse.of_raw(await self._client.typecheck(src, timeout=timeout))

    async def oneshot(
        self,
        input: str,
        compute_timeout: float | None = None,
        timeout: float | None = None,
    ) -> OneshotResponse:
        """Evaluate IML code in a sessionless, self-contained request"""
        return OneshotResponse.of_raw(
            await self._client.oneshot(
                input, compute_timeout=compute_timeout, timeout=timeout
            )
        )

    async def eval_code_snippet(
        self,
        code: str,
        task_filter: list[str] | None = None,
        timeout: float | None = None,
    ) -> CodeSnippetResponse:
        """Evaluate a code snippet; `task_filter` selects tasks to start, as in `eval_src`"""
        return CodeSnippetResponse.of_raw(
            await self._client.eval_code_snippet(
                code, task_filter=task_filter, timeout=timeout
            ),
            self,
        )

    async def parse_term(self, code: str, timeout: float | None = None) -> Term:
        """Parse and typecheck a term"""
        artifact = _artifact_of_result(await self._client.parse_term(code, timeout=timeout))
        return term_of_lib(artifact.decode_as(lib.Mir_Term))

    async def parse_type(self, code: str, timeout: float | None = None) -> Type:
        """Parse and typecheck a type"""
        artifact = _artifact_of_result(await self._client.parse_type(code, timeout=timeout))
        return type_of_lib(artifact.decode_as(lib.Mir_Type))

    async def list_artifacts(
        self, task: Task, timeout: float | None = None
    ) -> list[str]:
        """The kinds of the artifacts available for `task`"""
        return _artifact_kinds_of_result(
            await self._client.list_artifacts(task._raw, timeout=timeout)
        )

    async def get_artifact(
        self, task: Task, kind: str, timeout: float | None = None
    ) -> Artifact:
        """The artifact of kind `kind` of `task`"""
        return _artifact_of_result(
            await self._client.get_artifact(task._raw, kind, timeout=timeout)
        )

    async def get_artifact_zip(
        self, task: Task, kind: str, timeout: float | None = None
    ) -> bytes:
        """The artifact of kind `kind` of `task`, as a zip file"""
        return _artifact_zip_of_result(
            await self._client.get_artifact_zip(task._raw, kind, timeout=timeout)
        )

    async def keep_session_alive(self, timeout: float | None = None) -> None:
        """Make sure the session remains active"""
        await self._client.keep_session_alive(timeout=timeout)

    async def version(self, timeout: float | None = None) -> ServerVersion:
        """The server's version"""
        return ServerVersion.of_raw(await self._client.version(timeout=timeout))
