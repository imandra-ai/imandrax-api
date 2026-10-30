"""Test the validity of task data and task result data
- task data: matches the IML it comes from, and the uids it refers to are defined in the task's DB
- task result data: is consistent with the task data, e.g. a model gives values to the goal's
  variables, at their types
"""

import dataclasses
import re
import textwrap
from collections import Counter
from collections.abc import Callable
from typing import cast

import pytest
from inline_snapshot import snapshot

from imandrax_api.demo.interface import (
    Client,
    DecompositionRequest,
    DecompositionTask,
    DecompositionTaskResult,
    EvalSrcResponse,
    EvaluationTask,
    EvaluationTaskResult,
    Instance,
    ProofFound,
    ProofObligation,
    ProofObligationTask,
    ProofObligationTaskResult,
    Task,
)
from imandrax_api.demo.mir import (
    DB,
    Apply,
    Decomposition,
    FeasibleStatus,
    Model,
    Symbol,
    Term,
    Type,
    Uid,
    Var,
    Variable,
)

SRC = """
let f (xs: int list) : int list = List.map (fun x -> x + 1) xs
[@@decomp top ~prune:false () |>> prune]

eval (1 + 2)
theorem thm1 (xs: int list) = f xs = List.map (fun x -> x + 1) xs
instance (fun (xs: int list) (y: int) -> f xs <> List.map (fun x -> x + y) xs)
"""

# Setup
# ====================


@pytest.fixture(scope="module")
def tasks(c: Client) -> tuple[Task, ...]:
    eval_res: EvalSrcResponse = c.eval_src(SRC)
    assert eval_res.success, eval_res.errors
    return eval_res.tasks


def get_the_task[T: Task](tasks: tuple[Task, ...], cls: type[T]) -> T:
    (t,) = [t for t in tasks if isinstance(t, cls)]
    return t


def get_the_po(tasks: tuple[Task, ...], is_instance: bool) -> ProofObligationTask:
    (t,) = [
        t
        for t in tasks
        if isinstance(t, ProofObligationTask)
        and t.proof_obligation.is_instance == is_instance
    ]
    return t


def vars_in_subterms(t: Term) -> set[Variable]:
    return {x.var for x in t if isinstance(x, Var)}


def assert_symbols_defined_in_db(t: Term, db: DB) -> None:
    """Every symbol `t` refers to is declared in `db`"""
    uids: set[Uid] = {x.symbol.id for x in t if isinstance(x, Symbol)}
    assert uids, "Term should refer to at least one symbol"
    for u in uids:
        assert db.find_declaration(u) is not None, f"{u} is not declared in the DB"


def _ctor_repr(
    x: object, depth: int = 1, width: int = 80, leaf: Callable[[object], str] = repr
) -> str:
    """Constructor-style repr of a dataclass, expanding `depth` levels of fields

    Laid out like ruff format: a node stays on one line if it fits in `width` columns,
    otherwise it gets one field per line. Unexpanded values are shown with `leaf`.
    """
    if isinstance(x, tuple):
        xs = cast(tuple[object, ...], x)
        elems = [_ctor_repr(e, depth, width - 4, leaf) for e in xs]
        return _layout("(", elems, ")", width, singleton=len(xs) == 1)
    if depth <= 0 or not dataclasses.is_dataclass(x):
        return leaf(x)
    elems = [
        f"{f.name}={_ctor_repr(getattr(x, f.name), depth - 1, width - 5 - len(f.name), leaf)}"
        for f in dataclasses.fields(x)
        if f.repr
    ]
    return _layout(f"{type(x).__name__}(", elems, ")", width)


def _layout(
    open: str, elems: list[str], close: str, width: int, singleton: bool = False
) -> str:
    if not elems:
        return open + close
    flat = f"{open}{', '.join(elems)}{',' if singleton else ''}{close}"
    if len(flat) <= width and "\n" not in flat:
        return flat
    body = ",\n".join(textwrap.indent(e, "    ") for e in elems)
    return f"{open}\n{body},\n{close}"


_HASH = re.compile(r"/[A-Za-z0-9_-]{43}")


def ctor_repr(x: object, depth: int = 1) -> str:
    """`_ctor_repr` with hash normalized"""
    return _ctor_repr(x, depth, leaf=lambda v: _HASH.sub("/<hash>", repr(v)))


def test_task_kinds(tasks: tuple[Task, ...]):
    assert Counter(type(t) for t in tasks) == {
        ProofObligationTask: 2,
        EvaluationTask: 1,
        DecompositionTask: 1,
    }


# Evaluation
# ==========


def test_evaluation_task(tasks: tuple[Task, ...]):
    """`eval (1 + 2)`"""
    t = get_the_task(tasks, EvaluationTask)
    assert t.variables == []

    term = t.term
    assert isinstance(term, Apply)
    assert _ctor_repr(term) == snapshot(
        """\
Apply(
    type=<ConstructedType int>,
    function=<Symbol +>,
    arguments=(<Constant 1>, <Constant 2>),
)\
"""
    )

    res = get_the_task(tasks, EvaluationTask).result
    assert isinstance(res, EvaluationTaskResult)
    assert repr(res.value) == snapshot("Int(value=3)")


# Proof obligations
# =================


def test_theorem(tasks: tuple[Task, ...]):
    """`theorem thm1 (xs: int list) = f xs = List.map (fun x -> x + 1) xs`"""
    t: ProofObligationTask = get_the_po(tasks, is_instance=False)
    assert t.from_sym == "thm1"

    po: ProofObligation = t.proof_obligation
    assert ctor_repr(po) == snapshot(
        """\
ProofObligation(
    description='prove theorem thm1',
    goal=(
        (<Variable xs>,),
        <Apply (= (f/<hash> xs) (List.map/<hash> $lambda/<hash> xs))>,
    ),
    tactic=TermTactic(variables=(<Variable _x_0>,), term=<Apply (Tactic.default _x_0)>),
    is_instance=False,
    timeout=None,
    upto=None,
    verify_kind=<VerifyKind.VERIFY: 'verify'>,
    named_hypotheses=(),
)\
"""
    )

    vars, goal = po.goal
    assert vars_in_subterms(goal) == set(vars), (
        "PO goal should have no free or unused variables"
    )
    assert_symbols_defined_in_db(goal, t.db)

    res = t.result
    assert isinstance(res, ProofObligationTaskResult)
    assert isinstance(res.result, ProofFound)
    assert res.proved
    assert res.model is None, "A proved theorem should have no counter-model"


def test_instance(tasks: tuple[Task, ...]):
    """`instance (fun (xs: int list) (y: int) -> f xs <> List.map (fun x -> x + y) xs)`"""
    t = get_the_po(tasks, is_instance=True)
    assert t.from_sym == snapshot("_instance_7_1")
    po = t.proof_obligation
    assert ctor_repr(po) == snapshot(
        """\
ProofObligation(
    description='prove verify statement _instance_7_1',
    goal=(
        (<Variable xs>, <Variable y>),
        <Apply (<> (f/<hash> xs) (List.map/<hash> ($lambda/<hash> y) xs))>,
    ),
    tactic=DefaultTheoremTactic(max_steps=100, upto=None),
    is_instance=True,
    timeout=None,
    upto=None,
    verify_kind=<VerifyKind.INSTANCE: 'instance'>,
    named_hypotheses=(),
)\
"""
    )

    vars, goal = po.goal
    assert vars_in_subterms(goal) == set(vars), (
        "PO goal should have no free or unused variables"
    )
    assert_symbols_defined_in_db(goal, t.db)

    res = t.result
    assert isinstance(res, ProofObligationTaskResult)
    assert res.found
    assert not res.proved
    assert isinstance(res.result, Instance)

    model: Model | None = res.model
    assert model

    goal_var_types: dict[Uid, Type] = {v.id: v.type for v in vars}
    model_var_types: dict[Uid, Type] = {sym.id: sym.type for sym in model.constants}
    model_value_types: dict[Uid, Type] = {sym.id: value.type for sym, value in model.constants.items()}
    assert model_var_types == goal_var_types, (
        "Model should give values to exactly the goal's variables, at their types"
    )
    assert model_value_types == goal_var_types, (
        "Each model value should have its variable's type"
    )


# Decomposition
# =============


def test_decomposition(tasks: tuple[Task, ...]):
    """`[@@decomp top ~prune:false () |>> prune]` on `f`"""
    t = get_the_task(tasks, DecompositionTask)

    # A pipeline is requested as the term that computes it: `(top ...) |>> prune` applied to `f`
    req = t.decomp
    assert isinstance(req, DecompositionRequest.Term)
    assert ctor_repr(req.term) == snapshot(
        """\
Apply(
    type=<ConstructedType Decomp.t string result>,
    function=<Symbol Decomp.|>>/<hash>>,
    arguments=(
        <Apply (Decomp.top None None None Some false None None ())>,
        <Symbol Decomp.prune>,
        <Constant f>,
    ),
)\
"""
    )
    assert_symbols_defined_in_db(req.term, t.db)

    res = t.result
    assert isinstance(res, DecompositionTaskResult)
    assert res.error is None, res.error

    d: Decomposition | None = res.decomposition
    assert d
    assert ctor_repr(d) == snapshot(
        """\
Decomposition(
    id=<Uid f/<hash>>,
    arguments=(<Variable xs>,),
    regions=(
        <Region constraints: [true] invariant: (List.map/<hash> $lambda/<hash> xs) status: feasible>,
    ),
)\
"""
    )

    f_def = t.db.find_function(d.id)
    assert f_def is not None
    assert d.arguments == tuple(f_def.arguments), (
        "Decomp arguments should be the decomposed function's arguments in the task's DB"
    )

    # `List.map` is not unrolled: a single region, over `f`'s arguments
    (region,) = d.regions
    assert vars_in_subterms(region.invariant) <= set(d.arguments), (
        "Region invariant should only use the decomposition's arguments"
    )

    # A feasible region comes with a model of `f`'s arguments
    assert isinstance(region.status, FeasibleStatus)
    f_arg_types = {a.id: a.type for a in d.arguments}
    region_model = region.status.model
    model_var_types = {sym.id: sym.type for sym in region_model.constants}
    assert model_var_types == f_arg_types, (
        "Region model should give values to exactly f's arguments, at their types"
    )


# Across tasks
# ============


def test_tasks_agree_on_uids(tasks: tuple[Task, ...]):
    """Within a session, `f` is the same uid in every task that refers to it"""
    res = get_the_task(tasks, DecompositionTask).result
    assert isinstance(res, DecompositionTaskResult)
    d = res.decomposition
    assert d is not None
    for is_instance in [False, True]:
        _, goal = get_the_po(tasks, is_instance).proof_obligation.goal
        assert isinstance(goal, Apply)
        f_xs = goal.arguments[0]
        assert isinstance(f_xs, Apply) and isinstance(f_xs.function, Symbol)
        assert f_xs.function.symbol.id == d.id, (
            "f should have the same uid in the PO goal and in the decomposition"
        )
