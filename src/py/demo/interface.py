# pyright: reportPrivateUsage=false
import asyncio
import weakref
from collections.abc import Awaitable
from dataclasses import dataclass, field
from fractions import Fraction
from functools import cached_property
from typing import TYPE_CHECKING, Any, Self, assert_never

import imandrax_api
from imandrax_api import lib

from imandrax_api.bindings import error_pb2, locs_pb2, task_pb2, artmsg_pb2, api_pb2, simple_api_pb2

from evaluation_values import Value, value_of_lib

from mir import *

if TYPE_CHECKING:
    from imandrax_api.client import AsyncClient as AsyncClient_


class ClientGoneError(Exception):
    """Task data was fetched after the client that created the task was garbage-collected"""


class NoClientError(Exception):
    """Task data that is not fetched yet was accessed on a task created without a client"""


class NotFetchedError(Exception):
    """An artifact of a task from an `AsyncClient` was accessed before it was fetched

    Fetch it by accessing the attribute with `await task.awaitable.<attribute>` first
    """

    def __init__(self, task: "Task", kind: str):
        super().__init__(f"artifact {kind!r} of task {task.id} not fetched; use `await task.awaitable.<attribute>` first")
        self.task: Task = task
        self.kind: str = kind


class Error:
    """An error reported by the server"""

    class Message:
        """An error message, with source locations and an optional backtrace"""

        def __init__(self, msg: error_pb2.Error.Message):
            self._raw = msg

        def __str__(self) -> str:
            return f"{self.message}"

        @property
        def message(self) -> str:
            """The message text"""
            return self._raw.msg

        @property
        def locations(self) -> list[locs_pb2.Location]:
            """The source locations the message refers to"""
            return [l for l in self._raw.locs]

        @property
        def backtrace(self) -> str:
            """The backtrace, if any"""
            return self._raw.backtrace

    def __init__(self, error: error_pb2.Error):
        self._raw = error

    def __str__(self) -> str:
        return f"Error: {self.message}"

    def __repr__(self) -> str:
        return f"{self.message}"

    @property
    def message(self) -> Message:
        """The main error message"""
        return Error.Message(self._raw.msg)

    @property
    def kind(self) -> str:
        """The kind of error"""
        return self._raw.kind

    @property
    def stack(self) -> list[Message]:
        """Further messages giving context for the error"""
        return [Error.Message(m) for m in self._raw.stack]

    @property
    def process(self) -> str:
        """The process in which the error occurred"""
        return self._raw.process


class Artifact:
    """A serialized artifact (task data or a task result) fetched from the server"""

    def __init__(self, artifact: artmsg_pb2.Artifact):
        self._raw = artifact

    def __str__(self) -> str:
        return f"{self._raw}"

    @property
    def kind(self) -> str:
        """The artifact kind, e.g. `po_task` or `eval_res`"""
        return self._raw.kind

    @property
    def data(self) -> bytes:
        """The serialized artifact data"""
        return self._raw.data

    @property
    def api_version(self) -> str:
        """The API version the artifact was produced with"""
        return self._raw.api_version

    @property
    def storage(self) -> dict[str, bytes]:
        """Additional stored data the artifact refers to, by key"""
        return {s.key: s.value for s in self._raw.storage}


# Like the classes in `mir`, the classes for library types below are frozen dataclasses
# converted eagerly, keeping the library value in the hidden field `_raw`.


@dataclass(slots=True, frozen=True)
class FunctionInterpretation:
    """The interpretation of a function in a model: a table of cases"""

    arguments: tuple[Var, ...]
    """The function's parameters"""
    return_type: Type
    """The function's return type"""
    cases: dict[tuple[Term, ...], Term]
    """The function's value for specific arguments"""
    else_: Term
    """The function's value for all other arguments"""
    _raw: lib.Common_Model_fi[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Common_Model_fi[lib.Mir_Term, lib.Mir_Type]) -> "FunctionInterpretation":
        return cls(
            arguments=tuple(var_term_of_var(a) for a in x.fi_args),
            return_type=type_of_lib(x.fi_ty_ret),
            cases={tuple(term_of_lib(k) for k in ks): term_of_lib(v) for (ks, v) in x.fi_cases},
            else_=term_of_lib(x.fi_else),
            _raw=x,
        )


class TypeInterpretation:
    """The interpretation of a type in a model"""

    def __init__(self, x: lib.Common_Model_ty_def[lib.Mir_Term, lib.Mir_Type]):
        self._raw = x


@dataclass(slots=True, frozen=True)
class Model:
    """A model, e.g. a counter-model or an instance"""

    types: dict[Type, TypeInterpretation]
    """The interpretations of types"""
    constants: dict[AppliedSymbol, Term]
    """The values of constants"""
    functions: dict[AppliedSymbol, FunctionInterpretation]
    """The interpretations of functions"""
    _raw: lib.Mir_Model = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Model) -> "Model":
        return cls(
            types={type_of_lib(t): TypeInterpretation(d) for (t, d) in x.tys},
            constants={AppliedSymbol.of_lib(s): term_of_lib(t) for (s, t) in x.consts},
            functions={AppliedSymbol.of_lib(s): FunctionInterpretation.of_lib(f) for (s, f) in x.funs},
            _raw=x,
        )

    def __str__(self) -> str:
        return f"types: {self.types} constants: {self.constants} functions: {self.functions}"


class ProofObligationTaskResult:
    """The result of a proof obligation task"""

    @dataclass(slots=True, frozen=True)
    class Subresult:
        """The result for one subgoal of a proof obligation"""

        sub_anchor: lib.Sub_anchor
        """The anchor identifying the subgoal"""
        goal: Sequent
        """The subgoal"""
        sub_goals: tuple[Sequent, ...]
        """The subgoals the goal was split into"""
        res: str | None
        """The result for the subgoal, if any"""
        _raw: lib.Tasks_PO_res_sub_res[lib.Mir_Term] = field(repr=False, compare=False)

        @classmethod
        def of_lib(cls, sr: lib.Tasks_PO_res_sub_res[lib.Mir_Term]) -> "ProofObligationTaskResult.Subresult":
            return cls(
                sub_anchor=sr.sub_anchor,
                goal=Sequent.of_lib(sr.goal),
                sub_goals=tuple(Sequent.of_lib(sg) for sg in sr.sub_goals),
                res=sr.res,
                _raw=sr,
            )

    def __init__(self, artifact: Artifact):
        if artifact.kind != "po_res":
            raise Exception(f"Unexpected artifact kind '{artifact.kind}'")
        self._artifact: Artifact = artifact
        d = lib.read_artifact_data(artifact.data, artifact.kind)
        if not (isinstance(d, lib.Tasks_PO_res_shallow_poly)):
            raise Exception(f"Unexpected result type '{type(d)}'")
        self._data: lib.Tasks_PO_res_Shallow = d

    @property
    def from_(self) -> str:
        """The cstore key of the proof obligation task this is the result for"""
        return self._data.from_.key

    @property
    def proved(self) -> bool:
        """Whether the goal was proved or, for instance queries, an instance found"""
        match self._data.res:
            case lib.Tasks_PO_res_success_Proof():
                return True
            case lib.Tasks_PO_res_success_Instance():
                return True
            case _:
                return False

    @cached_property
    def model(self) -> Model | None:
        """The counter-model if the proof failed, or the instance found, if any"""
        match self._data.res:
            case lib.Tasks_PO_res_error_No_proof(x):
                if x.counter_model is not None:
                    return Model.of_lib(x.counter_model)
                else:
                    return None
            case lib.Tasks_PO_res_success_Instance(x):
                return Model.of_lib(x.model)
            case _:
                return None

    @cached_property
    def subgoals(self) -> list[Sequent] | None:
        """The remaining subgoals, if no proof was found"""
        match self._data.res:
            case lib.Tasks_PO_res_error_No_proof(x):
                return [Sequent.of_lib(sg) for sg in x.subgoals]
            case _:
                return None

    @property
    def proof(self) -> lib.Proof_Proof_term_t_poly[lib.Mir_Term, lib.Mir_Type] | None:
        """The proof term, if a proof was found"""
        match self._data.res:
            case lib.Tasks_PO_res_success_Proof(x):
                return x.proof
            case _:
                return None

    @property
    def anchor(self) -> lib.Anchor | None:
        """The anchor of the proof, if a proof was found"""
        match self._data.res:
            case lib.Tasks_PO_res_success_Proof(x):
                return x.anchor
            case _:
                return None

    @property
    def sub_anchor(self) -> lib.Sub_anchor | None:
        """The sub-anchor of the proof or the failed proof attempt, if any"""
        match self._data.res:
            case lib.Tasks_PO_res_success_Proof(x):
                return x.sub_anchor
            case lib.Tasks_PO_res_error_No_proof(x):
                return x.sub_anchor
            case _:
                return None

    @property
    def result(self) -> lib.Tasks_PO_res_result[
        lib.Tasks_PO_res_success[lib.Mir_Term, lib.Mir_Type], lib.Mir_Term, lib.Mir_Type
    ]:
        """The result as returned by the library"""
        return self._data.res

    @property
    def statistics(self) -> lib.Statistics:
        """Statistics about the proof attempt"""
        return self._data.stats

    @property
    def report(self) -> lib.In_mem_archive[lib.Report_Report]:
        # TODO: translate to something that makes sense in Python
        """The report of the proof attempt"""
        return self._data.report

    @cached_property
    def subresults(self) -> list[list[Subresult]]:
        """The results for the individual subgoals"""
        return [[ProofObligationTaskResult.Subresult.of_lib(s) for s in sl] for sl in self._data.sub_res]

    def __str__(self) -> str:
        return f"proof: {self.proof} subgoals: {self.subgoals} model: {self.model}"


class EvaluationTaskResult:
    """The result of an evaluation task"""

    def __init__(self, artifact: Artifact):
        if artifact.kind != "eval_res":
            raise Exception(f"Unexpected artifact kind '{artifact.kind}'")
        self._artifact: Artifact = artifact
        d = lib.read_artifact_data(artifact.data, artifact.kind)
        if not (isinstance(d, lib.Tasks_Eval_res)):
            raise Exception(f"Unexpected result type '{type(d)}'")
        self._data: lib.Tasks_Eval_res = d

    @cached_property
    def value(self) -> Value:
        """The value the term evaluated to; raises if evaluation failed"""
        match self._data.res:
            case lib.Error_Error_core(_) as e:
                raise Exception(f"'{e}'")
            case lib.Tasks_Eval_res_success(x):
                return value_of_lib(x.v)
            case _:
                raise Exception(f"Unexpected result type '{type(self._data.res)}'")

    @property
    def statistics(self) -> lib.Tasks_Eval_res_stats:
        """Statistics about the evaluation"""
        return self._data.stats

    def __str__(self) -> str:
        return str(self.value)


def _meta_of_lib(m: lib.Common_Region_meta[lib.Mir_Term]) -> "Decomposition.Region.Meta":
    """Convert a library region metadata value into a Python value"""
    match m:
        case lib.Common_Region_meta_Null():
            return None
        case lib.Common_Region_meta_Bool(arg=b):
            return b
        case lib.Common_Region_meta_Int(arg=n):
            return n
        case lib.Common_Region_meta_Real(arg=(num, den)):
            return Fraction(num, den)
        case lib.Common_Region_meta_String(arg=s):
            return s
        case lib.Common_Region_meta_Assoc(arg=kvs):
            return {k: _meta_of_lib(v) for k, v in kvs}
        case lib.Common_Region_meta_Term(arg=t):
            return term_of_lib(t)
        case lib.Common_Region_meta_List(arg=xs):
            return [_meta_of_lib(x) for x in xs]


@dataclass(slots=True, frozen=True)
class Decomposition:
    """A region decomposition of a function"""

    @dataclass(slots=True, frozen=True, repr=False)
    class Region:
        """A region of the input space, given by constraints, and the result in it"""

        type Meta = (
            None
            | bool
            | int
            | Fraction  # real/rational
            | str
            | Term
            | dict[str, Decomposition.Region.Meta]
            | list[Decomposition.Region.Meta]
        )
        """A metadata value attached to a region"""

        constraints: tuple[Term, ...]
        """The constraints on the inputs that define the region"""
        invariant: Term
        """The function's result for inputs in the region"""
        meta: dict[str, Meta]
        """Metadata attached to the region, by name"""
        status: lib.Common_Region_status[lib.Mir_Term, lib.Mir_Type]
        """Whether the region is known to be feasible"""
        _raw: lib.Mir_Region_Region = field(repr=False, compare=False)

        @classmethod
        def of_lib(cls, r: lib.Mir_Region_Region) -> "Decomposition.Region":
            return cls(
                constraints=tuple(term_of_lib(c) for c in r.constraints),
                invariant=term_of_lib(r.invariant),
                meta={k: _meta_of_lib(v) for k, v in r.meta},
                status=r.status,
                _raw=r,
            )

        def __str__(self) -> str:
            constraints = "; ".join(str(c) for c in self.constraints)
            match self.status:
                case lib.Common_Region_status_Unknown():
                    status = "unknown"
                case lib.Common_Region_status_Feasible():
                    status = "feasible"
                case lib.Common_Region_status_Feasibility_check_failed(arg=msg):
                    status = f"feasibility check failed: {msg}"
            return f"constraints: [{constraints}] invariant: {self.invariant} status: {status}"

        def __repr__(self) -> str:
            return f"{type(self).__name__}({self})"

    id: Uid
    """The identifier of the decomposed function"""
    arguments: tuple[Var, ...]
    """The decomposed function's parameters"""
    regions: tuple[Region, ...]
    """The regions"""
    _raw: lib.Mir_Fun_decomp = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, d: lib.Mir_Fun_decomp) -> "Decomposition":
        return cls(
            id=Uid(d.f_id),
            arguments=tuple(var_term_of_var(a) for a in d.f_args),
            regions=tuple(Decomposition.Region.of_lib(r) for r in d.regions),
            _raw=d,
        )

    def __str__(self) -> str:
        return str(list(self.regions))


class DecompositionTaskResult:
    """The result of a decomposition task"""

    def __init__(self, artifact: Artifact):
        if artifact.kind != "decomp_res":
            raise Exception(f"Unexpected artifact kind '{artifact.kind}'")
        self._artifact: Artifact = artifact
        d = lib.read_artifact_data(artifact.data, artifact.kind)
        if not (isinstance(d, lib.Tasks_Decomp_res_shallow_poly)):
            raise Exception(f"Unexpected result type '{type(d)}'")
        self._data: lib.Tasks_Decomp_res_Shallow = d

    @property
    def from_(self) -> str:
        """The cstore key of the decomposition task this is the result for"""
        return self._data.from_.key

    @property
    def _result(self) -> lib.Tasks_Decomp_res_result[lib.Tasks_Decomp_res_success[lib.Mir_Term, lib.Mir_Type]]:
        return self._data.res

    @property
    def statistics(self) -> lib.Statistics:
        """Statistics about the decomposition"""
        return self._data.stats

    @property
    def report(self) -> lib.In_mem_archive[lib.Report_Report]:
        # TODO: translate to something that makes sense in Python
        """The report of the decomposition"""
        return self._data.report

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

    @property
    def anchor(self) -> lib.Anchor | None:
        """The anchor of the decomposition, if it succeeded"""
        match self._result:
            case lib.Tasks_Decomp_res_success(anchor, _):
                return anchor
            case lib.Tasks_Decomp_res_error_Error():
                return None
            case _:
                return None

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

    @property
    def error(self) -> lib.Error_Error_core | None:
        """The error, if the decomposition failed"""
        match self._result:
            case lib.Tasks_Decomp_res_success(_, _):
                return None
            case lib.Tasks_Decomp_res_error_Error(arg):
                return arg
            case _:
                return None

    def __str__(self) -> str:
        if self.decomposition:
            return f"{self.decomposition}"
        else:
            return f"Decomposition error: {self.error}"


class TaskID:
    """A task identifier"""

    def __init__(self, task_id: task_pb2.TaskID):
        self._raw: task_pb2.TaskID = task_id

    def __str__(self) -> str:
        return self._raw.id


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

    `await t.fetch_all()` fetches all of the task's artifacts, after which every attribute can be
    accessed without `t.awaitable`.
    """

    class Kind:
        """The kind of a task"""

        def __init__(self, kind: task_pb2.TaskKind):
            self._raw: task_pb2.TaskKind = kind

        def __str__(self) -> str:
            return task_pb2.TaskKind.Name(self._raw)

        def corresponding_artifact_kind(self) -> str | None:
            """The artifact kind of the data of tasks of this kind, `None` if they have no data"""
            match self._raw:
                case task_pb2.TASK_EVAL:
                    return "eval_task"
                case task_pb2.TASK_CHECK_PO:
                    return "po_task"
                case task_pb2.TASK_PROOF_CHECK:
                    return "proof_check_task"
                case task_pb2.TASK_DECOMP:
                    return "decomp_task"
                case _:
                    return None

        def corresponding_result_artifact_kind(self) -> str | None:
            """The artifact kind of the results of tasks of this kind, `None` if they have no result"""
            match self._raw:
                case task_pb2.TASK_EVAL:
                    return "eval_res"
                case task_pb2.TASK_CHECK_PO:
                    return "po_res"
                case task_pb2.TASK_PROOF_CHECK:
                    return "proof_check_res"
                case task_pb2.TASK_DECOMP:
                    return "decomp_res"
                case _:
                    return None

    def __init__(self, task: task_pb2.Task, client: "Client | AsyncClient | None" = None):
        self._raw: task_pb2.Task = task
        # The task holds only a weak reference to the client, so it does not keep the client alive;
        # fetching after the client is gone raises `ClientGoneError`.
        self._client: weakref.ref[Client | AsyncClient] | None = None if client is None else weakref.ref(client)
        self._artifacts: dict[str, Artifact] = {}
        self._pending: dict[str, asyncio.Future[Artifact]] = {}

    @property
    def id(self) -> TaskID:
        """The task's identifier"""
        return TaskID(self._raw.id)

    @property
    def kind(self) -> Kind:
        """The task's kind"""
        return Task.Kind(self._raw.kind)

    @property
    def awaitable(self) -> AwaitableAttrs:
        """The task's attributes as awaitables that fetch what they need, e.g. `await t.awaitable.result`"""
        return AwaitableAttrs(self)

    @property
    def artifact(self) -> Artifact:
        """The task's data

        Fetched on first access, see `Task`
        """
        kind = self.kind.corresponding_artifact_kind()
        if kind is None:
            raise Exception(f"tasks of kind {self.kind} have no data")
        return self._artifact(kind)

    @cached_property
    def result(self) -> TaskResult:
        """The task's result

        Fetched on first access, see `Task`
        """
        kind = self.kind.corresponding_result_artifact_kind()
        if kind is None:
            raise Exception(f"tasks of kind {self.kind} have no result")
        return _task_result_of_artifact(self._artifact(kind))

    async def fetch_all(self) -> None:
        """Fetch all of the task's artifacts (its data and its result), with either client

        After this, every attribute can be accessed without `t.awaitable`.
        """
        kinds = [self.kind.corresponding_artifact_kind(), self.kind.corresponding_result_artifact_kind()]
        kinds = [k for k in kinds if k is not None and k not in self._artifacts]
        if not kinds:
            return
        if isinstance(self._get_client(), AsyncClient):
            await asyncio.gather(*(self._fetch_async(k) for k in kinds))
        else:
            for k in kinds:
                self._artifact(k)

    def _get_client(self) -> "Client | AsyncClient":
        if self._client is None:
            raise NoClientError(f"task {self.id} has no client to fetch its data with")
        client = self._client()
        if client is None:
            raise ClientGoneError(f"the client of task {self.id} is gone; keep it alive while fetching")
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
    match res.WhichOneof("result"):
        case "error":
            raise Exception(f"{Error(res.error)}")
        case "ok":
            return Artifact(res.ok)
        case _:
            raise Exception("Artifact result has neither `error` nor `ok`")


def _task_result_of_artifact(artifact: Artifact) -> TaskResult:
    match artifact.kind:
        case "po_res":
            return ProofObligationTaskResult(artifact)
        case "eval_res":
            return EvaluationTaskResult(artifact)
        case "decomp_res":
            return DecompositionTaskResult(artifact)
        case _:
            raise Exception(f"Unexpected result artifact kind '{artifact.kind}'")


@dataclass(slots=True, frozen=True)
class DefaultTerminationTactic:
    """The default tactic for termination proofs"""

    max_steps: int
    """The maximum number of proof steps"""
    basis: frozenset[Uid]
    """The function basis of the termination proof"""
    _raw: lib.Mir_Tactic = field(repr=False, compare=False)

    def __str__(self) -> str:
        basis = "{" + ", ".join(sorted(u.full_name for u in self.basis)) + "}"
        return f"DefaultTerminationTactic(max_steps={self.max_steps}, basis={basis})"


@dataclass(slots=True, frozen=True)
class DefaultTheoremTactic:
    """The default tactic for theorems"""

    max_steps: int
    """The maximum number of proof steps"""
    upto: lib.Upto | None
    """The bound for bounded verification, if any"""
    _raw: lib.Mir_Tactic = field(repr=False, compare=False)

    def __str__(self) -> str:
        upto = "None" if self.upto is None else f"{self.upto.arg} steps"
        return f"DefaultTheoremTactic(max_steps={self.max_steps}, upto={upto})"


@dataclass(slots=True, frozen=True)
class DefaultTestTactic:
    """The default tactic for tests"""

    num_steps: int | None
    """The number of test steps, if limited"""
    seed: int | None
    """The random seed, if fixed"""
    _raw: lib.Mir_Tactic = field(repr=False, compare=False)

    def __str__(self) -> str:
        return f"DefaultTestTactic(num_steps={self.num_steps}, seed={self.seed})"


@dataclass(slots=True, frozen=True)
class TermTactic:
    """A tactic given as a term"""

    variables: tuple[Var, ...]
    """The variables bound in the tactic term"""
    term: Term
    """The tactic term"""
    _raw: lib.Mir_Tactic = field(repr=False, compare=False)

    def __str__(self) -> str:
        return str(self.term)


Tactic = DefaultTerminationTactic | DefaultTheoremTactic | DefaultTestTactic | TermTactic
"""A tactic used to discharge a proof obligation"""


def tactic_of_lib(t: lib.Mir_Tactic) -> Tactic:
    """Convert a library tactic into the matching `Tactic` variant"""
    match t:
        case lib.Common_Tactic_t_poly_Default_termination(max_steps=max_steps, basis=basis):
            return DefaultTerminationTactic(max_steps=max_steps, basis=frozenset(Uid(f) for f in basis), _raw=t)
        case lib.Common_Tactic_t_poly_Default_thm(max_steps=max_steps, upto=upto):
            return DefaultTheoremTactic(max_steps=max_steps, upto=upto, _raw=t)
        case lib.Common_Tactic_t_poly_Default_test(num_steps=num_steps, seed=seed):
            return DefaultTestTactic(num_steps=num_steps, seed=seed, _raw=t)
        case lib.Common_Tactic_t_poly_Term(arg=(vs, term)):
            return TermTactic(variables=tuple(var_term_of_var(v) for v in vs), term=term_of_lib(term), _raw=t)
        case _:
            assert_never(t)


@dataclass(slots=True, frozen=True)
class ProofObligation:
    """A proof obligation: a goal to prove and the tactic to use"""

    description: str
    """A description of the proof obligation"""
    goal: tuple[tuple[Var, ...], Term]
    """The goal: its variables and the term to prove"""
    tactic: Tactic
    """The tactic to use"""
    isInstance: bool
    """Whether this is an instance query rather than a proof"""
    anchor: lib.Anchor
    """Where the proof obligation comes from"""
    timeout: int | None
    """The timeout, if any"""
    upto: lib.Upto | None
    """The bound for bounded verification, if any"""
    verify_kind: lib.Common_Verify_kind | None
    """The kind of verification, if any"""
    named_hypotheses: tuple[tuple[str, Term], ...]
    """Named hypotheses available for the proof"""
    _raw: lib.Mir_Proof_obligation = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, po: lib.Mir_Proof_obligation) -> "ProofObligation":
        vs, t = po.goal
        return cls(
            description=po.descr,
            goal=(tuple(var_term_of_var(v) for v in vs), term_of_lib(t)),
            tactic=tactic_of_lib(po.tactic),
            isInstance=po.is_instance,
            anchor=po.anchor,
            timeout=po.timeout,
            upto=po.upto,
            verify_kind=po.verify_kind,
            named_hypotheses=tuple((n, term_of_lib(h)) for (n, h) in po.named_hypotheses),
            _raw=po,
        )


class ProofObligationTask(Task):
    """A proof obligation task"""

    def __init__(self, task: task_pb2.Task, client: "Client | AsyncClient | None" = None):
        assert task.kind == task_pb2.TASK_CHECK_PO
        super().__init__(task, client)

    @cached_property
    def _po_task(self) -> lib.Tasks_PO_task_Mir:
        artifact = self._artifact("po_task")
        d = lib.read_artifact_data(artifact.data, artifact.kind)
        if not (isinstance(d, lib.Tasks_PO_task_t_poly)):
            raise Exception(f"Unexpected task artifact type '{type(d)}'")
        return d

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
    def count(self) -> int | None:
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

    def __init__(self, task: task_pb2.Task, client: "Client | AsyncClient | None" = None):
        assert task.kind == task_pb2.TASK_EVAL
        super().__init__(task, client)

    @cached_property
    def _eval_task(self) -> lib.Tasks_Eval_task_Mir:
        artifact = self._artifact("eval_task")
        d = lib.read_artifact_data(artifact.data, artifact.kind)
        if not (isinstance(d, lib.Tasks_Eval_task_t_poly)):
            raise Exception(f"Unexpected task artifact type '{type(d)}'")
        return d

    @cached_property
    def variables(self) -> list[Var]:
        """The variables bound in the term

        Fetched on first access, see `Task`
        """
        vs, _ = self._eval_task.term
        return [var_term_of_var(v) for v in vs]

    @cached_property
    def term(self) -> Term:
        """The term to evaluate

        Fetched on first access, see `Task`
        """
        _, t = self._eval_task.term
        return term_of_lib(t)

    @property
    def anchor(self) -> lib.Anchor:
        """Where the evaluation comes from

        Fetched on first access, see `Task`
        """
        return self._eval_task.anchor

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


class DecompositionRequest:
    """A decomposition request"""

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
        lift_bool: lib.Common_Decomp_lift_bool
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
        style: lib.Tasks_Decomp_task_enumeration_style | None
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
                lift_bool=a.lift_bool,
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
                style=style,
                _raw=d,
            )
        case _:
            assert_never(d)


class DecompositionTask(Task):
    """A decomposition task"""

    def __init__(self, task: task_pb2.Task, client: "Client | AsyncClient | None" = None):
        assert task.kind == task_pb2.TASK_DECOMP
        super().__init__(task, client)

    @cached_property
    def _decomp_task(self) -> lib.Tasks_Decomp_task_Mir:
        artifact = self._artifact("decomp_task")
        d = lib.read_artifact_data(artifact.data, artifact.kind)
        if not (isinstance(d, lib.Tasks_Decomp_task_t_poly)):
            raise Exception(f"Unexpected task artifact type '{type(d)}'")
        return d

    @cached_property
    def decomp(self) -> DecompositionRequest.Request:
        """The decomposition request

        Fetched on first access, see `Task`
        """
        return decomp_request_of_lib(self._decomp_task.decomp)

    @property
    def anchor(self) -> lib.Anchor:
        """Where the decomposition comes from

        Fetched on first access, see `Task`
        """
        return self._decomp_task.anchor

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


class Origin:
    """Where a task came from"""

    def __init__(self, origin: task_pb2.Origin):
        self._raw: task_pb2.Origin = origin

    @property
    def from_sym(self) -> str:
        """The symbol the task was generated from"""
        return self._raw.from_sym

    @property
    def count(self) -> int:
        """Distinguishes tasks generated from the same symbol"""
        return self._raw.count


class ProofObligationResult:
    """A proof obligation result in an `eval_src` response"""

    def __init__(self, po_result: simple_api_pb2.PO_Res, client: "Client | AsyncClient | None" = None):
        self._raw: simple_api_pb2.PO_Res = po_result
        self._task: Task = task_of_raw(po_result.task, client)

    @property
    def task(self) -> Task:
        """The proof obligation's task"""
        return self._task

    @property
    def origin(self) -> Origin:
        """Where the proof obligation came from"""
        return Origin(self._raw.origin)


class EvaluationResult:
    """The result of an evaluation request"""

    def __init__(self, eval_result: simple_api_pb2.EvalRes):
        self._raw: simple_api_pb2.EvalRes = eval_result

    @property
    def success(self) -> bool:
        """Whether evaluation succeeded"""
        return self._raw.success

    @property
    def errors(self) -> list[Error]:
        """Errors reported during evaluation"""
        return [Error(e) for e in self._raw.errors]


class DecompositionResult:
    """The result of a decomposition request"""

    def __init__(self, decomp_result: simple_api_pb2.DecomposeRes, client: "Client | AsyncClient | None" = None):
        self._raw: simple_api_pb2.DecomposeRes = decomp_result
        self._task: Task = task_of_raw(decomp_result.task, client)

    @property
    def artifact(self) -> Artifact | None:
        """The decomposition artifact"""
        if self._raw.WhichOneof("res") != "artifact": return None
        return Artifact(self._raw.artifact)

    @property
    def task(self) -> Task:
        """The decomposition task"""
        return self._task

    @property
    def errors(self) -> list[Error]:
        """Errors reported during decomposition"""
        return [Error(e) for e in self._raw.errors]


class EvalOutput:
    """The output of an `eval` in evaluated source"""

    def __init__(self, eval_output: simple_api_pb2.EvalOutput):
        self._raw: simple_api_pb2.EvalOutput = eval_output

    @property
    def success(self) -> bool:
        """Whether evaluation succeeded"""
        return self._raw.success

    @property
    def as_ocaml(self) -> str:
        """The value printed as OCaml, if available"""
        return self._raw.value_as_ocaml

    @property
    def errors(self) -> list[Error]:
        """Errors reported during evaluation"""
        return [Error(e) for e in self._raw.errors]


class EvalSrcResponse:
    """The response to an `eval_src` request"""

    def __init__(self, res: simple_api_pb2.EvalRes, client: "Client | AsyncClient | None" = None):
        self._raw: simple_api_pb2.EvalRes = res
        self._tasks: list[Task] = [task_of_raw(t, client) for t in res.tasks]
        self._po_results = [ProofObligationResult(pr, client) for pr in res.po_results]
        self._decomp_results = [DecompositionResult(dr, client) for dr in res.decomp_results]

    def __str__(self) -> str:
        return f"{self._raw}"

    @property
    def success(self) -> bool:
        """Whether the source was processed successfully"""
        return self._raw.success

    @property
    def messages(self) -> list[str]:
        """Messages printed while processing the source"""
        return [m for m in self._raw.messages]

    @property
    def errors(self) -> list[Error]:
        """Errors reported while processing the source"""
        return [Error(e) for e in self._raw.errors]

    @property
    def tasks(self) -> list[Task]:
        """The tasks created while processing the source"""
        return self._tasks

    @property
    def po_results(self) -> list[ProofObligationResult]:
        """The results of the source's proof obligations"""
        return self._po_results

    @property
    def eval_results(self) -> list[EvalOutput]:
        """The outputs of the source's `eval` statements"""
        return [EvalOutput(er) for er in self._raw.eval_results]

    @property
    def decomp_results(self) -> list[DecompositionResult]:
        """The results of the source's decompositions"""
        return self._decomp_results


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

    def status(self):
        """The server's status"""
        return self._client.status()

    def eval_src(self, src: str, **kwargs: Any) -> EvalSrcResponse:
        """Evaluate IML source; other keyword arguments go to `imandrax_api.Client.eval_src`"""
        return EvalSrcResponse(self._client.eval_src(src, **kwargs), self)

    # TODO: Add all the other client functions


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

    async def __aexit__(self, exc_type: Any, exc_val: Any, exc_tb: Any) -> None:
        await self._client.__aexit__(exc_type, exc_val, exc_tb)

    async def status(self):
        """The server's status"""
        return await self._client.status()

    async def eval_src(self, src: str, **kwargs: Any) -> EvalSrcResponse:
        """Evaluate IML source; other keyword arguments go to `imandrax_api.AsyncClient.eval_src`"""
        return EvalSrcResponse(await self._client.eval_src(src, **kwargs), self)

    # TODO: Add all the other client functions
