from fractions import Fraction
from typing import Any

import imandrax_api
from imandrax_api import lib

from imandrax_api.bindings import error_pb2, locs_pb2, task_pb2, artmsg_pb2, api_pb2, simple_api_pb2

from evaluation_values import Value, value_of_lib

from mir import *


class NoClientError(Exception):
    """No API client available"""


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


class FunctionInterpretation:
    """The interpretation of a function in a model: a table of cases"""

    def __init__(self, x: lib.Common_Model_fi):
        self._raw = x

    @property
    def arguments(self) -> list[Var]:
        """The function's parameters"""
        return [var_term_of_var(a) for a in self._raw.fi_args]

    @property
    def return_type(self) -> Type:
        """The function's return type"""
        return type_of_lib(self._raw.fi_ty_ret)

    @property
    def cases(self) -> dict[tuple[Term, ...], Term]:
        """The function's value for specific arguments"""
        return {tuple(term_of_lib(k) for k in x): term_of_lib(y) for (x, y) in self._raw.fi_cases}

    @property
    def else_(self) -> Term:
        """The function's value for all other arguments"""
        return term_of_lib(self._raw.fi_else)


class TypeInterpretation:
    """The interpretation of a type in a model"""

    def __init__(self, x: lib.Common_Model_ty_def):
        self._raw = x


class Model:
    """A model, e.g. a counter-model or an instance"""

    def __init__(self, x: lib.Common_Model_t_poly):
        self._raw = x

    @property
    def constants(self) -> dict[AppliedSymbol, Term]:
        """The values of constants"""
        return {AppliedSymbol(s): term_of_lib(t) for (s, t) in self._raw.consts}

    @property
    def functions(self) -> dict[AppliedSymbol, FunctionInterpretation]:
        """The interpretations of functions"""
        return {AppliedSymbol(s): FunctionInterpretation(t) for (s, t) in self._raw.funs}

    @property
    def types(self) -> dict[Type, TypeInterpretation]:
        """The interpretations of types"""
        return {type_of_lib(x): TypeInterpretation(y) for (x, y) in self._raw.tys}

    def __str__(self) -> str:
        return f"types: {self.types} constants: {self.constants} functions: {self.functions}"


class ProofObligationTaskResult:
    """The result of a proof obligation task"""

    class Subresult:
        """The result for one subgoal of a proof obligation"""

        def __init__(self, sr: lib.Tasks_PO_res_sub_res):
            self._raw = sr

        @property
        def sub_anchor(self) -> lib.Sub_anchor:
            """The anchor identifying the subgoal"""
            return self._raw.sub_anchor

        @property
        def goal(self) -> Sequent:
            """The subgoal"""
            return Sequent(self._raw.goal)

        @property
        def sub_goals(self) -> list[Sequent]:
            """The subgoals the goal was split into"""
            return [Sequent(sg) for sg in self._raw.sub_goals]

        @property
        def res(self) -> str | None:
            """The result for the subgoal, if any"""
            return self._raw.res

    def __init__(self, artifact: Artifact):
        if artifact.kind != "po_res":
            raise Exception(f"Unexpected artifact kind '{artifact.kind}'")
        self._artifact: Artifact = artifact
        d = lib.read_artifact_data(artifact.data, artifact.kind)
        if not (isinstance(d, lib.Tasks_PO_res_shallow_poly)):
            raise Exception(f"Unexpected result type '{type(d)}'")
        self._data: lib.Tasks_PO_res_shallow_poly = d

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

    @property
    def model(self) -> Model | None:
        """The counter-model if the proof failed, or the instance found, if any"""
        match self._data.res:
            case lib.Tasks_PO_res_error_No_proof(x):
                if x.counter_model is not None:
                    return Model(x.counter_model)
                else:
                    return None
            case lib.Tasks_PO_res_success_Instance(x):
                return Model(x.model)
            case _:
                return None

    @property
    def subgoals(self) -> list[Sequent] | None:
        """The remaining subgoals, if no proof was found"""
        match self._data.res:
            case lib.Tasks_PO_res_error_No_proof(x):
                return [Sequent(sg) for sg in x.subgoals]
            case _:
                return None

    @property
    def proof(self) -> lib.Proof_Proof_term_t_poly | None:
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
    def result(self) -> lib.Tasks_PO_res_result:
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

    @property
    def subresults(self) -> list[list[Subresult]]:
        """The results for the individual subgoals"""
        return [[ProofObligationTaskResult.Subresult(s) for s in sl] for sl in self._data.sub_res]

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

    @property
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
        if self.value is None:
            return "None"
        return str(self.value)


class Decomposition:
    """A region decomposition of a function"""

    class Region:
        """A region of the input space, given by constraints, and the result in it"""

        class Meta:
            """A metadata value attached to a region"""

            type Value = (
                None
                | bool
                | int
                | Fraction  # real/rational
                | str
                | Term
                | dict[str, Decomposition.Region.Meta.Value]
                | list[Decomposition.Region.Meta.Value]
            )

            def __init__(self, m: lib.Common_Region_meta):
                self._raw = m

            @property
            def value(self) -> Value:
                """The metadata as a Python value"""
                match self._raw:
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
                        return {k: Decomposition.Region.Meta(v).value for k, v in kvs}
                    case lib.Common_Region_meta_Term(arg=t):
                        return term_of_lib(t)
                    case lib.Common_Region_meta_List(arg=xs):
                        return [Decomposition.Region.Meta(x).value for x in xs]

        def __init__(self, r: lib.Common_Region_t_poly):
            self._raw = r

        @property
        def constraints(self) -> list[Term]:
            """The constraints on the inputs that define the region"""
            return [term_of_lib(c) for c in self._raw.constraints]

        @property
        def invariant(self) -> Term:
            """The function's result for inputs in the region"""
            return term_of_lib(self._raw.invariant)

        @property
        def meta(self) -> dict[str, lib.Common_Region_meta]:
            """Metadata attached to the region, by name"""
            return {k: v for k, v in self._raw.meta}

        @property
        def status(self) -> lib.Common_Region_status:
            """Whether the region is known to be feasible"""
            return self._raw.status

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

    def __init__(self, d: lib.Common_Fun_decomp_t_poly):
        self._raw = d

    @property
    def id(self) -> Uid:
        """The identifier of the decomposed function"""
        return Uid(self._raw.f_id)

    @property
    def arguments(self) -> list[Var]:
        """The decomposed function's parameters"""
        return [var_term_of_var(a) for a in self._raw.f_args]

    @property
    def regions(self) -> list[Region]:
        """The regions"""
        return [Decomposition.Region(r) for r in self._raw.regions]

    def __str__(self) -> str:
        return str(self.regions)


class DecompositionTaskResult:
    """The result of a decomposition task"""

    def __init__(self, artifact: Artifact):
        if artifact.kind != "decomp_res":
            raise Exception(f"Unexpected artifact kind '{artifact.kind}'")
        self._artifact: Artifact = artifact
        d = lib.read_artifact_data(artifact.data, artifact.kind)
        if not (isinstance(d, lib.Tasks_Decomp_res_shallow_poly)):
            raise Exception(f"Unexpected result type '{type(d)}'")
        self._data: lib.Tasks_Decomp_res_shallow_poly = d

    @property
    def from_(self) -> str:
        """The cstore key of the decomposition task this is the result for"""
        return self._data.from_.key

    @property
    def _result(self) -> lib.Tasks_Decomp_res_result:
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

    @property
    def decomposition(self) -> Decomposition | None:
        """The decomposition, if it succeeded"""
        match self._result:
            case lib.Tasks_Decomp_res_success(_, decomp):
                return Decomposition(decomp)
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


class Task:
    """A task run by the server, e.g. a proof obligation, evaluation or decomposition"""

    class Kind:
        """The kind of a task"""

        def __init__(self, kind: task_pb2.TaskKind):
            self._raw: task_pb2.TaskKind = kind

        def __str__(self) -> str:
            return task_pb2.TaskKind.Name(self._raw)

        def corresponding_artifact_kind(self) -> str:
            """The artifact kind of the data of tasks of this kind"""
            match self._raw:
                case task_pb2.TASK_UNSPECIFIED:
                    return "unspecified"
                case task_pb2.TASK_EVAL:
                    return "eval_task"
                case task_pb2.TASK_CHECK_PO:
                    return "po_task"
                case task_pb2.TASK_PROOF_CHECK:
                    return "proof_check_task"
                case task_pb2.TASK_DECOMP:
                    return "decomp_task"
                case _:
                    return "unknown"

        def corresponding_result_artifact_kind(self) -> str:
            """The artifact kind of the results of tasks of this kind"""
            match self._raw:
                case task_pb2.TASK_UNSPECIFIED:
                    return "unspecified"
                case task_pb2.TASK_EVAL:
                    return "eval_res"
                case task_pb2.TASK_CHECK_PO:
                    return "po_res"
                case task_pb2.TASK_PROOF_CHECK:
                    return "proof_check_res"
                case task_pb2.TASK_DECOMP:
                    return "decomp_res"
                case _:
                    return "unknown"

    def __init__(self, task: task_pb2.Task, client=None):
        self._raw: task_pb2.Task = task
        self._client: imandrax_api.client.Client | None = client
        self._artifact: Artifact | None = None
        self._result_artifact: Artifact | None = None
        self._result: (
            ProofObligationTaskResult | EvaluationTaskResult | DecompositionTaskResult | None
        ) = None

    @property
    def id(self) -> TaskID:
        """The task's identifier"""
        return TaskID(self._raw.id)

    @property
    def kind(self) -> Kind:
        """The task's kind"""
        return Task.Kind(self._raw.kind)

    @property
    def artifact(self) -> Artifact | None:
        """The task's data, fetched from the server on first use"""
        if self._artifact is not None:
            return self._artifact
        if self._client is None:
            raise NoClientError("cannot get artifact without a client")

        art_req_res: api_pb2.ArtifactResult = self._client.get_artifact(
            self._raw, self.kind.corresponding_artifact_kind()
        )

        match art_req_res.WhichOneof("result"):
            case "error":
                raise Exception(f"{Error(art_req_res.error)}")
            case "ok":
                self._artifact = Artifact(art_req_res.ok)
                return self._artifact

    @property
    def result(self) -> ProofObligationTaskResult | EvaluationTaskResult | DecompositionTaskResult:
        """The task's result, fetched from the server on first use"""
        if self._result is not None:
            return self._result

        if self._result_artifact is None:
            if self._client is None:
                raise NoClientError("cannot get artifact without a client")

            art_req_res: api_pb2.ArtifactResult = self._client.get_artifact(
                self._raw, self.kind.corresponding_result_artifact_kind()
            )

            match art_req_res.WhichOneof("result"):
                case "error":
                    raise Exception(f"{Error(art_req_res.error)}")
                case "ok":
                    self._result_artifact = Artifact(art_req_res.ok)

        assert self._result_artifact

        match self._result_artifact.kind:
            case "po_res":
                r = ProofObligationTaskResult(self._result_artifact)
            case "eval_res":
                r = EvaluationTaskResult(self._result_artifact)
            case "decomp_res":
                r = DecompositionTaskResult(self._result_artifact)
            case _:
                raise Exception(f"Unexpected result artifact kind '{self._result_artifact.kind}'")
        self._result = r
        return r


class Tactic:
    """A tactic used to discharge a proof obligation"""

    def __init__(self, t: lib.Common_Tactic_t_poly):
        self._raw = t

    def __str__(self) -> str:
        return "<tactic>"

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


class DefaultTerminationTactic(Tactic):
    """The default tactic for termination proofs"""

    def __init__(self, t: lib.Common_Tactic_t_poly_Default_termination):
        self._raw = t

    @property
    def max_steps(self) -> int:
        """The maximum number of proof steps"""
        return self._raw.max_steps

    @property
    def basis(self) -> set[Uid]:
        """The function basis of the termination proof"""
        return {Uid(f) for f in self._raw.basis}

    def __str__(self) -> str:
        basis = "{" + ", ".join(sorted(u.full_name for u in self.basis)) + "}"
        return f"DefaultTerminationTactic(max_steps={self.max_steps}, basis={basis})"


class DefaultTheoremTactic(Tactic):
    """The default tactic for theorems"""

    def __init__(self, t: lib.Common_Tactic_t_poly_Default_thm):
        self._raw = t

    @property
    def max_steps(self) -> int:
        """The maximum number of proof steps"""
        return self._raw.max_steps

    @property
    def upto(self) -> lib.Upto | None:
        """The bound for bounded verification, if any"""
        return self._raw.upto

    def __str__(self) -> str:
        upto = "None" if self.upto is None else f"{self.upto.arg} steps"
        return f"DefaultTheoremTactic(max_steps={self.max_steps}, upto={upto})"


class DefaultTestTactic(Tactic):
    """The default tactic for tests"""

    def __init__(self, t: lib.Common_Tactic_t_poly_Default_test):
        self._raw = t

    @property
    def num_steps(self) -> int | None:
        """The number of test steps, if limited"""
        return self._raw.num_steps

    @property
    def seed(self) -> int | None:
        """The random seed, if fixed"""
        return self._raw.seed

    def __str__(self) -> str:
        return f"DefaultTestTactic(num_steps={self.num_steps}, seed={self.seed})"


class TermTactic(Tactic):
    """A tactic given as a term"""

    def __init__(self, t: lib.Common_Tactic_t_poly_Term):
        self._raw = t

    @property
    def variables(self) -> list[Var]:
        """The variables bound in the tactic term"""
        return [var_term_of_var(v) for v in self._raw.arg[0]]

    @property
    def term(self) -> Term:
        """The tactic term"""
        return term_of_lib(self._raw.arg[1])

    def __str__(self) -> str:
        return str(self.term)


def tactic_of_lib(t: lib.Common_Tactic_t_poly) -> Tactic:
    """Wrap a library tactic in the matching `Tactic` subclass"""
    match t:
        case lib.Common_Tactic_t_poly_Default_termination():
            return DefaultTerminationTactic(t)
        case lib.Common_Tactic_t_poly_Default_thm():
            return DefaultTheoremTactic(t)
        case lib.Common_Tactic_t_poly_Default_test():
            return DefaultTestTactic(t)
        case lib.Common_Tactic_t_poly_Term():
            return TermTactic(t)
        case _:
            raise Exception("Unknown tactic")


class ProofObligation:
    """A proof obligation: a goal to prove and the tactic to use"""

    def __init__(self, po: lib.Common_Proof_obligation_t_poly):
        self._raw = po

    @property
    def description(self) -> str:
        """A description of the proof obligation"""
        return self._raw.descr

    @property
    def goal(self) -> tuple[list[Var], Term]:
        """The goal: its variables and the term to prove"""
        vs, t = self._raw.goal
        return ([var_term_of_var(v) for v in vs], term_of_lib(t))

    @property
    def tactic(self) -> Tactic:
        """The tactic to use"""
        return tactic_of_lib(self._raw.tactic)

    @property
    def isInstance(self) -> bool:
        """Whether this is an instance query rather than a proof"""
        return self._raw.is_instance

    @property
    def anchor(self) -> lib.Anchor:
        """Where the proof obligation comes from"""
        return self._raw.anchor

    @property
    def timeout(self) -> int | None:
        """The timeout, if any"""
        return self._raw.timeout

    @property
    def upto(self) -> lib.Upto | None:
        """The bound for bounded verification, if any"""
        return self._raw.upto

    @property
    def verify_kind(self) -> lib.Common_Verify_kind | None:
        """The kind of verification, if any"""
        return self._raw.verify_kind

    @property
    def named_hypotheses(self) -> list[tuple[str, Term]]:
        """Named hypotheses available for the proof"""
        return [(n, term_of_lib(t)) for (n, t) in self._raw.named_hypotheses]


class ProofObligationTask(Task):
    """A proof obligation task"""

    def __init__(self, task: task_pb2.Task, client=None):
        assert task.kind == task_pb2.TASK_CHECK_PO
        super().__init__(task, client)
        self._po_task_cache: lib.Tasks_PO_task_t_poly | None = None
        self._db: DB | None = None

    @property
    def _po_task(self) -> lib.Tasks_PO_task_t_poly:
        if self._po_task_cache is None:
            artifact = self.artifact
            if artifact is None:
                raise Exception("No task artifact available")
            d = lib.read_artifact_data(artifact.data, artifact.kind)
            if not (isinstance(d, lib.Tasks_PO_task_t_poly)):
                raise Exception(f"Unexpected task artifact type '{type(d)}'")
            self._po_task_cache = d
        return self._po_task_cache

    @property
    def proof_obligation(self) -> ProofObligation:
        """The proof obligation to check"""
        return ProofObligation(self._po_task.po)

    @property
    def from_sym(self) -> str:
        """The symbol the proof obligation was generated from"""
        return self._po_task.from_sym

    @property
    def count(self) -> int | None:
        """Distinguishes proof obligations generated from the same symbol"""
        return self._po_task.count

    @property
    def db(self) -> DB | None:
        """The database of declarations and rules the proof obligation is checked in"""
        if self._db is None:
            artifact = self.artifact
            if artifact is None:
                return None
            self._db = DB(self._po_task.db, artifact.storage)
        return self._db


class EvaluationTask(Task):
    """An evaluation task"""

    def __init__(self, task: task_pb2.Task, client=None):
        assert task.kind == task_pb2.TASK_EVAL
        super().__init__(task, client)
        self._eval_task_cache = None

    @property
    def _eval_task(self) -> lib.Tasks_Eval_task_t_poly:
        if self._eval_task_cache is None:
            artifact = self.artifact
            if artifact is None:
                raise Exception("No task artifact available")
            d = lib.read_artifact_data(artifact.data, artifact.kind)
            if not (isinstance(d, lib.Tasks_Eval_task_t_poly)):
                raise Exception(f"Unexpected task artifact type '{type(d)}'")
            self._eval_task_cache = d
        return self._eval_task_cache

    @property
    def variables(self) -> list[Var]:
        """The variables bound in the term"""
        vs, _ = self._eval_task.term
        return [var_term_of_var(v) for v in vs]

    @property
    def term(self) -> Term:
        """The term to evaluate"""
        _, t = self._eval_task.term
        return term_of_lib(t)

    @property
    def anchor(self) -> lib.Anchor:
        """Where the evaluation comes from"""
        return self._eval_task.anchor

    @property
    def timeout(self) -> int | None:
        """The timeout, if any"""
        return self._eval_task.timeout


class DecompositionRequest:
    """A decomposition request"""

    class Request:
        """A description of the decomposition to compute; requests can be combined"""

        def __str__(self) -> str:
            return "<decomposition request>"

        def __repr__(self) -> str:
            return f"{type(self).__name__}({self})"

    class Function(Request):
        """Decompose a function"""

        def __init__(self, d: lib.Tasks_Decomp_task_decomp_poly_Decomp):
            self._raw = d

        @property
        def function(self) -> Uid:
            """The function to decompose"""
            return Uid(self._raw.arg.f_id)

        @property
        def assuming(self) -> Uid | None:
            """The side condition the decomposition assumes, if any"""
            assuming = self._raw.arg.assuming
            return None if assuming is None else Uid(assuming)

        @property
        def basis(self) -> set[Uid]:
            """Functions not to unfold during decomposition"""
            return {Uid(u) for u in self._raw.arg.basis}

        @property
        def rule_specs(self) -> set[Uid]:
            """Rule specs to use during decomposition"""
            return {Uid(u) for u in self._raw.arg.rule_specs}

        @property
        def ctx_simp(self) -> bool:
            """Whether to simplify regions in their context"""
            return self._raw.arg.ctx_simp

        @property
        def lift_bool(self) -> lib.Common_Decomp_lift_bool:
            """How Boolean subterms are lifted into region constraints"""
            return self._raw.arg.lift_bool

        @property
        def prune(self) -> bool:
            """Whether to prune infeasible regions"""
            return self._raw.arg.prune

        def __str__(self) -> str:
            assuming = "" if self.assuming is None else f" ~assuming:{self.assuming}"
            prune = " ~prune:true" if self.prune else ""
            return f"decomp {self.function}{assuming}{prune}"

    class Term(Request):
        """Decompose a term"""

        def __init__(self, d: lib.Tasks_Decomp_task_decomp_poly_Term):
            self._raw = d

        @property
        def term(self) -> Term:
            """The term to decompose"""
            return term_of_lib(self._raw.arg)

        def __str__(self) -> str:
            return f"term {self.term}"

    class Return(Request):
        """An already computed decomposition, returned as is (e.g. as a base case of a merge)"""

        def __init__(self, d: lib.Tasks_Decomp_task_decomp_poly_Return):
            self._raw = d

        @property
        def decomposition(self) -> Decomposition:
            """The decomposition"""
            return Decomposition(self._raw.arg)

        def __str__(self) -> str:
            return f"return <decomposition of {self.decomposition.id}>"

    class Prune(Request):
        """Prune the infeasible regions of a decomposition"""

        def __init__(self, d: lib.Tasks_Decomp_task_decomp_poly_Prune):
            self._raw = d

        @property
        def request(self) -> "DecompositionRequest.Request":
            """The decomposition to prune"""
            return decomp_request_of_lib(self._raw.arg)

        def __str__(self) -> str:
            return f"prune ({self.request})"

    class Merge(Request):
        """Merge two decompositions"""

        def __init__(self, d: lib.Tasks_Decomp_task_decomp_poly_Merge):
            self._raw = d

        @property
        def left(self) -> "DecompositionRequest.Request":
            """The first decomposition"""
            return decomp_request_of_lib(self._raw.args[0])

        @property
        def right(self) -> "DecompositionRequest.Request":
            """The second decomposition"""
            return decomp_request_of_lib(self._raw.args[1])

        def __str__(self) -> str:
            return f"merge ({self.left}) ({self.right})"

    class CompoundMerge(Request):
        """Compound-merge two decompositions"""

        def __init__(self, d: lib.Tasks_Decomp_task_decomp_poly_Compound_merge):
            self._raw = d

        @property
        def left(self) -> "DecompositionRequest.Request":
            """The first decomposition"""
            return decomp_request_of_lib(self._raw.args[0])

        @property
        def right(self) -> "DecompositionRequest.Request":
            """The second decomposition"""
            return decomp_request_of_lib(self._raw.args[1])

        def __str__(self) -> str:
            return f"compound_merge ({self.left}) ({self.right})"

    class Combine(Request):
        """Combine the regions of a decomposition"""

        def __init__(self, d: lib.Tasks_Decomp_task_decomp_poly_Combine):
            self._raw = d

        @property
        def request(self) -> "DecompositionRequest.Request":
            """The decomposition whose regions are combined"""
            return decomp_request_of_lib(self._raw.arg)

        def __str__(self) -> str:
            return f"combine ({self.request})"

    class Get(Request):
        """A decomposition bound by name in an enclosing `Let`"""

        def __init__(self, d: lib.Tasks_Decomp_task_decomp_poly_Get):
            self._raw = d

        @property
        def name(self) -> str:
            """The name of the binding"""
            return self._raw.arg

        def __str__(self) -> str:
            return f"get {self.name}"

    class Let(Request):
        """Bind decompositions to names, for use (via `Get`) in `and_then`"""

        def __init__(self, d: lib.Tasks_Decomp_task_decomp_poly_Let):
            self._raw = d

        @property
        def bindings(self) -> list[tuple[str, "DecompositionRequest.Request"]]:
            """The names and the decompositions bound to them"""
            return [(n, decomp_request_of_lib(d)) for n, d in self._raw.bindings]

        @property
        def and_then(self) -> "DecompositionRequest.Request":
            """The decomposition computed with the bindings in scope"""
            return decomp_request_of_lib(self._raw.and_then)

        def __str__(self) -> str:
            bindings = " and ".join(f"{n} = {d}" for n, d in self.bindings)
            return f"let {bindings} in {self.and_then}"

    class Enumerate(Request):
        """Enumerate the decomposition `d_f` over the decompositions `ds`"""

        def __init__(self, d: lib.Tasks_Decomp_task_decomp_poly_Enumerate):
            self._raw = d

        @property
        def d_f(self) -> "DecompositionRequest.Request":
            """The decomposition to enumerate"""
            return decomp_request_of_lib(self._raw.d_f)

        @property
        def ds(self) -> list["DecompositionRequest.Request"]:
            """The decompositions to enumerate over"""
            return [decomp_request_of_lib(d) for d in self._raw.ds]

        @property
        def style(self) -> lib.Tasks_Decomp_task_enumeration_style | None:
            """Additive or multiplicative enumeration; `None` means additive"""
            return self._raw.style

        def __str__(self) -> str:
            ds = ", ".join(str(d) for d in self.ds)
            return f"enumerate ({self.d_f}) [{ds}]"


def decomp_request_of_lib(d: lib.Tasks_Decomp_task_decomp_poly) -> DecompositionRequest.Request:
    """Wrap a library decomposition request in the matching `Request` subclass"""
    match d:
        case lib.Tasks_Decomp_task_decomp_poly_Decomp():
            return DecompositionRequest.Function(d)
        case lib.Tasks_Decomp_task_decomp_poly_Term():
            return DecompositionRequest.Term(d)
        case lib.Tasks_Decomp_task_decomp_poly_Return():
            return DecompositionRequest.Return(d)
        case lib.Tasks_Decomp_task_decomp_poly_Prune():
            return DecompositionRequest.Prune(d)
        case lib.Tasks_Decomp_task_decomp_poly_Merge():
            return DecompositionRequest.Merge(d)
        case lib.Tasks_Decomp_task_decomp_poly_Compound_merge():
            return DecompositionRequest.CompoundMerge(d)
        case lib.Tasks_Decomp_task_decomp_poly_Combine():
            return DecompositionRequest.Combine(d)
        case lib.Tasks_Decomp_task_decomp_poly_Get():
            return DecompositionRequest.Get(d)
        case lib.Tasks_Decomp_task_decomp_poly_Let():
            return DecompositionRequest.Let(d)
        case lib.Tasks_Decomp_task_decomp_poly_Enumerate():
            return DecompositionRequest.Enumerate(d)
        case _:
            raise Exception("Unknown decomposition request")


class DecompositionTask(Task):
    """A decomposition task"""

    def __init__(self, task: task_pb2.Task, client=None):
        assert task.kind == task_pb2.TASK_DECOMP
        super().__init__(task, client)
        self._decomp_task_cache: lib.Tasks_Decomp_task_t_poly | None = None

    @property
    def _decomp_task(self) -> lib.Tasks_Decomp_task_t_poly:
        if self._decomp_task_cache is None:
            artifact = self.artifact
            if artifact is None:
                raise Exception("No task artifact available")
            d = lib.read_artifact_data(artifact.data, artifact.kind)
            if not (isinstance(d, lib.Tasks_Decomp_task_t_poly)):
                raise Exception(f"Unexpected task artifact type '{type(d)}'")
            self._decomp_task_cache = d
        return self._decomp_task_cache

    @property
    def decomp(self) -> DecompositionRequest.Request:
        """The decomposition request"""
        return decomp_request_of_lib(self._decomp_task.decomp)

    @property
    def anchor(self) -> lib.Anchor:
        """Where the decomposition comes from"""
        return self._decomp_task.anchor

    @property
    def timeout(self) -> int | None:
        """The timeout, if any"""
        return self._decomp_task.timeout


class ProofCheckTask(Task):
    """A proof checking task"""

    def __init__(self, task: task_pb2.Task, client=None):
        assert task.kind == task_pb2.TASK_PROOF_CHECK
        super().__init__(task, client)


def task_of_raw(
    t: task_pb2.Task, client
) -> ProofObligationTask | EvaluationTask | DecompositionTask | Task:
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

    def __init__(self, po_result: simple_api_pb2.PO_Res, client=None):
        self._raw: simple_api_pb2.PO_Res = po_result
        self._client: imandrax_api.client.Client | None = client
        self._task: Task | None = None

    @property
    def task(self) -> Task:
        """The proof obligation's task"""
        if self._task is None:
            self._task = task_of_raw(self._raw.task, client=self._client)
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

    def __init__(self, decomp_result: simple_api_pb2.DecomposeRes, client=None):
        self._raw: simple_api_pb2.DecomposeRes = decomp_result
        self._client: imandrax_api.client.Client | None = client
        self._task: Task | None = None

    @property
    def artifact(self) -> Artifact | None:
        """The decomposition artifact"""
        if self._raw.WhichOneof("res") != "artifact": return None
        return Artifact(self._raw.artifact)

    @property
    def task(self) -> Task:
        """The decomposition task"""
        if self._task is None:
            self._task = task_of_raw(self._raw.task, client=self._client)
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

    def __init__(self, res: simple_api_pb2.EvalRes, client=None):
        self._raw: simple_api_pb2.EvalRes = res
        self._client: imandrax_api.client.Client | None = client
        self._tasks: list[Task] | None = None

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
        if self._tasks is None:
            self._tasks = [task_of_raw(t, client=self._client) for t in self._raw.tasks]
        return self._tasks

    @property
    def po_results(self) -> list[ProofObligationResult]:
        """The results of the source's proof obligations"""
        return [ProofObligationResult(pr, client=self._client) for pr in self._raw.po_results]

    @property
    def eval_results(self) -> list[EvalOutput]:
        """The outputs of the source's `eval` statements"""
        return [EvalOutput(er) for er in self._raw.eval_results]

    @property
    def decomp_results(self) -> list[DecompositionResult]:
        """The results of the source's decompositions"""
        return [DecompositionResult(dr, client=self._client) for dr in self._raw.decomp_results]


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
        return EvalSrcResponse(self._client.eval_src(src, **kwargs), client=self._client)

    # TODO: Add all the other client functions
