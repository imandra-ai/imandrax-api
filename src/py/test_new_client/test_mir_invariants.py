"""Test the invariants of MIR data: relationships between MIR objects that must hold

1. Typing: every term is well-typed, e.g. an application's arguments have the types its
   function expects, and a match's arms all have the match's type
2. Polymorphism: an applied symbol's type is its type schema instantiated at its type
   arguments, and a type constructor gets as many type arguments as it has parameters
3. Scoping: functions, goals and model function interpretations only use the variables they
   bind; a function's type is that of its arguments and body; theorems and verify statements
   are bool
4. Agreement with type definitions: constructors and fields belong to the type of the term
   they apply to; cliques of mutually recursive functions are symmetric
5. Rules: rewrite rules relate two terms of the same type, under bool guards, and their
   variables are bound by their left-hand side
6. Uids: declarations never have generative uids; a function's uid is builtin, content-addressed
   or persistent, as its kind requires; only top-level functions and types are content-addressed
   keys
7. Models and regions: model values are ground and typed; function interpretations, region
   constraints and invariants agree with the functions they interpret or decompose

Whether the uids MIR refers to can be found in the DB is tested in `test_mir_db.py`.

Each check runs over everything of its kind: every declaration in the task's DB, prelude
included, and the terms in task data and results.
"""
# ai-disclosure: ai-generated

import dataclasses
from collections.abc import Iterable, Iterator

import pytest

from imandrax_api import lib
from imandrax_api.demo.interface import (
    Client,
    DecompositionTask,
    DecompositionTaskResult,
    EvalSrcResponse,
    ProofObligationTask,
    ProofObligationTaskResult,
    Task,
    TypeDeclaration,
)
from imandrax_api.demo.mir import (
    DB,
    AlgebraicTypeKind,
    AppliedSymbol,
    Apply,
    ApplyPattern,
    ArrowType,
    BoolConst,
    BuiltinFunctionKind,
    Case,
    Constant,
    Construct,
    ConstructedType,
    ConstructorDefinition,
    ConstructPattern,
    Decomposition,
    DefinedFunctionKind,
    Destruct,
    DestructPattern,
    Field,
    FoPattern,
    FunctionDefinition,
    If,
    IntConst,
    IsA,
    IsAPattern,
    OpaqueFunctionKind,
    RationalConst,
    Record,
    RecordTypeKind,
    RewriteRule,
    Sequence,
    StringConst,
    Symbol,
    Term,
    TheoremDeclaration,
    Tuple,
    TupleField,
    TupleType,
    Type,
    TypeVariable,
    Uid,
    Var,
    Variable,
    VarPattern,
    VerifyDeclaration,
)

SRC = """
type shape = Circle of int | Rect of { w: int; h: int }
type point = { x: int; y: int }
type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree

let area (s: shape) : int = match s with Circle r -> 3 * r * r | Rect { w; h } -> w * h
let move (p: point) = { p with x = p.x + 1 }
let rec size (t: 'a tree) : int = match t with Leaf -> 0 | Node (l, _, r) -> size l + 1 + size r
let swap (p: int * bool) : bool * int = let (a, b) = p in (b, a)
let rec even n = if n <= 0 then true else odd (n - 1)
and odd n = if n <= 0 then false else even (n - 1)
let add_all (y: int) (xs: int list) : int list = List.map (fun x -> x + y) xs
let ext : int -> int = fun x -> x [@@opaque]

theorem add_comm x y = x + y = y + x [@@rw]
theorem size_nonneg (t: int tree) = size t >= 0 [@@by auto] [@@fc]

let h (p: point) = if p.x > 0 then p.x else p.y
[@@decomp top ()]
let get_or (d: int) (o: int option) = match o with Some x -> x | None -> d
[@@decomp top ()]

verify (fun x -> h { x; y = 1 } > x)
instance (fun () -> ext 1 = 5 && ext 2 = 7)
verify true
"""

# Setup
# ====================


@pytest.fixture(scope="module")
def tasks(c: Client) -> tuple[Task, ...]:
    eval_res: EvalSrcResponse = c.eval_src(SRC)
    assert eval_res.success and not eval_res.errors, eval_res.errors
    return eval_res.tasks


@pytest.fixture(scope="module")
def db(tasks: tuple[Task, ...]) -> DB:
    """The DB of the final `verify true` in `SRC`"""
    # Tasks come newest first
    assert isinstance(tasks[0], ProofObligationTask)
    return tasks[0].db


@pytest.fixture(scope="module")
def functions(db: DB) -> list[FunctionDefinition]:
    """Every function in the DB, including those linked to theorems and verify statements"""
    return [d.function for d in db.decls.values() if not isinstance(d, TypeDeclaration)]


@pytest.fixture(scope="module")
def rewrite_rules(db: DB) -> list[RewriteRule]:
    rules = [r for rs in db.rw_rules.values() for r in rs]
    rules += [r for rs in db.thm_as_rw.values() for r in rs]
    rules += [r for rs in db.rule_spec_rw_rules.values() for r in rs]
    return rules


@pytest.fixture(scope="module")
def po_tasks(tasks: tuple[Task, ...]) -> list[ProofObligationTask]:
    return [t for t in tasks if isinstance(t, ProofObligationTask)]


@pytest.fixture(scope="module")
def po_results(
    po_tasks: list[ProofObligationTask],
) -> list[tuple[str, ProofObligationTaskResult]]:
    results: list[tuple[str, ProofObligationTaskResult]] = []
    for t in po_tasks:
        res = t.result
        assert isinstance(res, ProofObligationTaskResult)
        results.append((f"PO {t.from_sym}", res))
    return results


@pytest.fixture(scope="module")
def decompositions(
    tasks: tuple[Task, ...],
) -> list[tuple[DecompositionTask, Decomposition]]:
    ds: list[tuple[DecompositionTask, Decomposition]] = []
    for t in tasks:
        if isinstance(t, DecompositionTask):
            res = t.result
            assert isinstance(res, DecompositionTaskResult)
            assert res.decomposition is not None, res.error
            ds.append((t, res.decomposition))
    return ds


@pytest.fixture(scope="module")
def terms(
    functions: list[FunctionDefinition],
    rewrite_rules: list[RewriteRule],
    po_tasks: list[ProofObligationTask],
    po_results: list[tuple[str, ProofObligationTaskResult]],
    decompositions: list[tuple[DecompositionTask, Decomposition]],
) -> list[tuple[str, Term]]:
    """Every top-level term, with where it comes from: function bodies, rewrite rules, PO goals,
    subgoals, models and regions"""
    ts: list[tuple[str, Term]] = []
    for f in functions:
        if isinstance(f.kind, DefinedFunctionKind):
            ts.append((f"function {f.name}", f.body))
    for r in rewrite_rules:
        ts += [(f"rewrite rule {r.name}", t) for t in [r.rhs, *r.guard]]
    for t in po_tasks:
        ts.append((f"PO {t.from_sym}", t.proof_obligation.goal_body))
    for where, res in po_results:
        for sr in (sr for srs in res.subresults for sr in srs):
            for sq in [sr.goal, *sr.sub_goals]:
                ts += [
                    (f"{where} subgoal", t)
                    for t in [*sq.hypothesis_terms, *sq.conclusion_terms]
                ]
        if (m := res.model) is not None:
            ts += [(f"{where} model", t) for t in m.constants.values()]
            for fi in m.functions.values():
                ts += [
                    (f"{where} model", t)
                    for case in fi.cases
                    for t in [*case.guards, case.rhs]
                ]
                ts.append((f"{where} model", fi.else_))
    for _, d in decompositions:
        for region in d.regions:
            ts += [
                (f"region of {d.id}", t)
                for t in [*region.constraints, region.invariant]
            ]
    return ts


@pytest.fixture(scope="module")
def subterms(terms: list[tuple[str, Term]]) -> list[tuple[str, Term]]:
    """Every subterm of `terms`, with where its top-level term comes from"""
    return [(where, x) for where, t in terms for x in t]


def subterms_of[T](
    subterms: list[tuple[str, Term]], cls: type[T]
) -> list[tuple[str, T]]:
    """The subterms of class `cls`; asserts there is at least one, so checks on them are not vacuous"""
    xs = [(where, x) for where, x in subterms if isinstance(x, cls)]
    assert xs, f"No {cls.__name__} subterm to check"
    return xs


def assert_no_failures(failures: list[str]) -> None:
    assert not failures, f"{len(failures)} failures, e.g.:\n" + "\n".join(failures[:10])


def is_bool(ty: Type) -> bool:
    return (
        isinstance(ty, ConstructedType)
        and ty.constructor.short_name == "bool"
        and not ty.arguments
    )


def arrow_parts(ty: Type, n: int) -> tuple[list[Type], Type] | None:
    """`ty` as `d1 -> ... -> dn -> result`, `([d1, ..., dn], result)`; `None` if it has fewer arrows"""
    domains: list[Type] = []
    for _ in range(n):
        if not isinstance(ty, ArrowType):
            return None
        domains.append(ty.domain)
        ty = ty.codomain
    return domains, ty


def all_arrow_parts(ty: Type) -> tuple[list[Type], Type]:
    """`ty` as `d1 -> ... -> dn -> result`, with all of its arrows"""
    domains: list[Type] = []
    while isinstance(ty, ArrowType):
        domains.append(ty.domain)
        ty = ty.codomain
    return domains, ty


def substitute(ty: Type, s: dict[Uid, Type]) -> Type:
    """`ty` with its type variables replaced as in `s`"""
    match ty:
        case TypeVariable(name=n):
            return s.get(n, ty)
        case ArrowType(domain=d, codomain=cd):
            return dataclasses.replace(
                ty, domain=substitute(d, s), codomain=substitute(cd, s)
            )
        case TupleType(elements=es):
            return dataclasses.replace(ty, elements=tuple(substitute(e, s) for e in es))
        case ConstructedType(arguments=args):
            return dataclasses.replace(
                ty, arguments=tuple(substitute(a, s) for a in args)
            )


def types_in(ty: Type) -> Iterator[Type]:
    """`ty` and all of the types it is built from"""
    yield ty
    match ty:
        case ArrowType(domain=d, codomain=cd):
            yield from types_in(d)
            yield from types_in(cd)
        case TupleType(elements=ts) | ConstructedType(arguments=ts):
            for t in ts:
                yield from types_in(t)
        case TypeVariable():
            pass


def free_vars(ts: Iterable[Term]) -> set[Variable]:
    return {x.var for t in ts for x in t if isinstance(x, Var)}


def pattern_vars(p: FoPattern) -> set[Variable]:
    match p:
        case VarPattern(variable=v):
            return {v}
        case ApplyPattern(arguments=ps) | ConstructPattern(arguments=ps):
            return {v for q in ps for v in pattern_vars(q)}
        case DestructPattern(pattern=q) | IsAPattern(pattern=q):
            return pattern_vars(q)
        case _:
            return set()


def constructor_definition(db: DB, ty: Type, c: Uid) -> ConstructorDefinition | None:
    """The definition of constructor `c` in the algebraic type `ty`, if it is one of its constructors"""
    if (
        not isinstance(ty, ConstructedType)
        or (td := db.find_type(ty.constructor)) is None
    ):
        return None
    if not isinstance(td.kind, AlgebraicTypeKind):
        return None
    return next((cd for cd in td.kind.constructors if cd.name == c), None)


def is_field_of(db: DB, ty: Type, f: Uid) -> bool:
    """Whether `f` is a field of the record type `ty`"""
    if (
        not isinstance(ty, ConstructedType)
        or (td := db.find_type(ty.constructor)) is None
    ):
        return False
    return isinstance(td.kind, RecordTypeKind) and f in {
        fd.name for fd in td.kind.fields
    }


# Terms are well-typed
# ====================


def test_variables_and_symbols_have_their_types(subterms: list[tuple[str, Term]]):
    failures = [
        f"{where}: {x} : {x.type}, but its variable is : {x.var.type}"
        for where, x in subterms_of(subterms, Var)
        if x.type != x.var.type
    ]
    failures += [
        f"{where}: {x} : {x.type}, but its symbol is : {x.symbol.type}"
        for where, x in subterms_of(subterms, Symbol)
        if x.type != x.symbol.type
    ]
    assert_no_failures(failures)


def test_applications_are_well_typed(subterms: list[tuple[str, Term]]):
    """Applying `f : d1 -> ... -> dn -> r` to arguments of types `d1, ..., dn` gives an `r`

    Functions are curried, so `r` can itself be a function type.
    """
    failures: list[str] = []
    for where, x in subterms_of(subterms, Apply):
        parts = arrow_parts(x.function.type, len(x.arguments))
        if parts is None:
            failures.append(
                f"{where}: {x}: {x.function.type} takes fewer than {len(x.arguments)} arguments"
            )
            continue
        domains, result = parts
        if [a.type for a in x.arguments] != domains or result != x.type:
            failures.append(
                f"{where}: {x} : {x.type}, with function : {x.function.type}"
            )
    assert_no_failures(failures)


def test_conditionals_are_well_typed(subterms: list[tuple[str, Term]]):
    failures = [
        f"{where}: {x}"
        for where, x in subterms_of(subterms, If)
        if not is_bool(x.condition.type)
        or x.then_branch.type != x.type
        or x.else_branch.type != x.type
    ]
    assert_no_failures(failures)


def test_tuples_are_well_typed(subterms: list[tuple[str, Term]]):
    failures = [
        f"{where}: {x} : {x.type}"
        for where, x in subterms_of(subterms, Tuple)
        if not (
            isinstance(x.type, TupleType)
            and x.type.elements == tuple(e.type for e in x.elements)
        )
    ]
    for where, x in subterms_of(subterms, TupleField):
        ty = x.term.type
        if not (
            isinstance(ty, TupleType)
            and x.index < len(ty.elements)
            and ty.elements[x.index] == x.type
        ):
            failures.append(f"{where}: {x} : {x.type}, of a tuple : {ty}")
    assert_no_failures(failures)


def test_constructions_are_well_typed(subterms: list[tuple[str, Term]], db: DB):
    """A constructor applied to its arguments builds a value of its type, which defines it"""
    failures: list[str] = []
    for where, x in subterms_of(subterms, Construct):
        parts = arrow_parts(x.constructor.type, len(x.arguments))
        if parts is None or parts != ([a.type for a in x.arguments], x.type):
            failures.append(
                f"{where}: {x} : {x.type}, with constructor : {x.constructor.type}"
            )
        cd = constructor_definition(db, x.type, x.constructor.id)
        if cd is None:
            failures.append(
                f"{where}: {x}: {x.constructor.id} is not a constructor of {x.type}"
            )
        elif len(cd.arguments) != len(x.arguments):
            failures.append(
                f"{where}: {x}: {x.constructor.id} takes {len(cd.arguments)} arguments"
            )
    assert_no_failures(failures)


def test_destructions_are_well_typed(subterms: list[tuple[str, Term]], db: DB):
    """`Destruct(c, i, t)` is the `i`-th argument of `t`, a value of the type that defines `c`"""
    failures: list[str] = []
    for where, x in subterms_of(subterms, Destruct):
        domains, result = all_arrow_parts(x.constructor.type)
        if not (
            x.index < len(domains)
            and domains[x.index] == x.type
            and result == x.term.type
        ):
            failures.append(
                f"{where}: {x} : {x.type}, with constructor : {x.constructor.type}"
            )
        if constructor_definition(db, x.term.type, x.constructor.id) is None:
            failures.append(
                f"{where}: {x}: {x.constructor.id} is not a constructor of {x.term.type}"
            )
    assert_no_failures(failures)


def test_constructor_tests_are_well_typed(subterms: list[tuple[str, Term]], db: DB):
    """`IsA(c, t)` is bool, and `c` is a constructor of `t`'s type

    These occur in region constraints, e.g. `Is_a(Some, o)`, not in function bodies, where matches
    are `Case` terms.
    """
    failures = [
        f"{where}: {x}"
        for where, x in subterms_of(subterms, IsA)
        if not is_bool(x.type)
        or constructor_definition(db, x.term.type, x.constructor.id) is None
    ]
    assert_no_failures(failures)


def test_records_are_well_typed(subterms: list[tuple[str, Term]], db: DB):
    """A field `f : record -> ty` of a record type is read from, and set in, values of that type"""
    failures: list[str] = []
    for where, x in subterms_of(subterms, Field):
        f = x.field
        if arrow_parts(f.type, 1) != ([x.term.type], x.type):
            failures.append(f"{where}: {x} : {x.type}, with field : {f.type}")
        if not is_field_of(db, x.term.type, f.id):
            failures.append(f"{where}: {x}: {f.id} is not a field of {x.term.type}")
    for where, x in subterms_of(subterms, Record):
        if x.rest is not None and x.rest.type != x.type:
            failures.append(f"{where}: {x}: updates a {x.rest.type} into a {x.type}")
        for f, v in x.rows:
            if arrow_parts(f.type, 1) != ([x.type], v.type):
                failures.append(
                    f"{where}: {x}: {f.id} = {v} : {v.type}, with field : {f.type}"
                )
            if not is_field_of(db, x.type, f.id):
                failures.append(f"{where}: {x}: {f.id} is not a field of {x.type}")
    assert_no_failures(failures)


def test_matches_are_well_typed(subterms: list[tuple[str, Term]], db: DB):
    """Every arm of a match has the match's type, and matches a constructor of the scrutinee's type"""
    failures: list[str] = []
    for where, x in subterms_of(subterms, Case):
        for c, arm in x.cases:
            if arm.type != x.type:
                failures.append(
                    f"{where}: {x}: arm {c.id} : {arm.type}, but the match is : {x.type}"
                )
            if constructor_definition(db, x.scrutinee.type, c.id) is None:
                failures.append(
                    f"{where}: {x}: {c.id} is not a constructor of {x.scrutinee.type}"
                )
        if x.default is not None and x.default.type != x.type:
            failures.append(
                f"{where}: {x}: default : {x.default.type}, but the match is : {x.type}"
            )
    assert_no_failures(failures)


def test_sequences_are_well_typed(subterms: list[tuple[str, Term]]):
    failures = [
        f"{where}: {x} : {x.type}, but its last term is : {x.last.type}"
        for where, x in subterms_of(subterms, Sequence)
        if x.last.type != x.type
    ]
    assert_no_failures(failures)


def test_constants_have_their_types(subterms: list[tuple[str, Term]]):
    expected: dict[type, str] = {
        IntConst: "int",
        BoolConst: "bool",
        StringConst: "string",
        RationalConst: "real",
    }
    failures: list[str] = []
    for where, x in subterms_of(subterms, Constant):
        name = expected.get(type(x.value))
        if name is None:
            continue
        if not (
            isinstance(x.type, ConstructedType)
            and x.type.constructor.short_name == name
        ):
            failures.append(f"{where}: {x} : {x.type}, expected {name}")
    assert_no_failures(failures)


# Applied symbols and types
# =========================


def applied_symbols(x: Term) -> list[AppliedSymbol]:
    match x:
        case Symbol(symbol=s):
            return [s]
        case Construct(constructor=c) | Destruct(constructor=c) | IsA(constructor=c):
            return [c]
        case Field(field=f):
            return [f]
        case Record(rows=rows):
            return [f for f, _ in rows]
        case Case(cases=arms):
            return [c for c, _ in arms]
        case _:
            return []


def test_applied_symbols_instantiate_their_schemas(subterms: list[tuple[str, Term]]):
    """An applied symbol's type is its type schema, with its parameters replaced by its type arguments"""
    failures: list[str] = []
    for where, x in subterms:
        for s in applied_symbols(x):
            schema = s.symbol.type_schema
            if len(s.type_arguments) != len(schema.parameters):
                failures.append(
                    f"{where}: {s}: {len(s.type_arguments)} type arguments for {schema.parameters}"
                )
                continue
            expected = substitute(
                schema.type, dict(zip(schema.parameters, s.type_arguments))
            )
            if expected != s.type:
                failures.append(f"{where}: {s}, expected : {expected}")
    assert_no_failures(failures)


def test_constructed_types_have_their_arity(
    subterms: list[tuple[str, Term]], functions: list[FunctionDefinition], db: DB
):
    """A type constructor is applied to as many type arguments as its definition has parameters"""
    types = [(where, x.type) for where, x in subterms]
    types += [(f"function {f.name}", f.type) for f in functions]
    for td in (d.type for d in db.decls.values() if isinstance(d, TypeDeclaration)):
        match td.kind:
            case AlgebraicTypeKind(constructors=cds):
                types += [(f"type {td.name}", t) for cd in cds for t in cd.arguments]
            case RecordTypeKind(fields=fds):
                types += [(f"type {td.name}", fd.type) for fd in fds]
            case _:
                pass
    failures: list[str] = []
    for where, ty in types:
        for t in types_in(ty):
            if (
                not isinstance(t, ConstructedType)
                or (td := db.find_type(t.constructor)) is None
            ):
                continue
            if len(t.arguments) != len(td.parameters):
                failures.append(
                    f"{where}: {t}, but {td.name} has parameters {td.parameters}"
                )
    assert_no_failures(failures)


# Functions and declarations
# ==========================


def test_function_arguments_are_distinct(functions: list[FunctionDefinition]):
    failures = [
        f"{f.name}: {f.arguments}"
        for f in functions
        if len({a.id for a in f.arguments}) != len(f.arguments)
    ]
    assert_no_failures(failures)


# Uses variables of the function it was lifted from; see the xfail test below
_LIFTED_WITH_FREE_VARS = "$sub.Decomp.enumerate_all.lift"


def test_function_bodies_only_use_their_arguments(functions: list[FunctionDefinition]):
    failures = [
        f"{f.name}: uses {free_vars([f.body]) - set(f.arguments)}"
        for f in functions
        if isinstance(f.kind, DefinedFunctionKind)
        and f.name.short_name != _LIFTED_WITH_FREE_VARS
        and not free_vars([f.body]) <= set(f.arguments)
    ]
    assert_no_failures(failures)


@pytest.mark.xfail(
    strict=True,
    reason=f"`{_LIFTED_WITH_FREE_VARS}` uses `d0`, `des` and `style` of `Decomp.enumerate_all`, "
    "which are not among its arguments",
)
def test_lifted_function_only_uses_its_arguments(functions: list[FunctionDefinition]):
    (f,) = [f for f in functions if f.name.short_name == _LIFTED_WITH_FREE_VARS]
    assert free_vars([f.body]) <= set(f.arguments)


def test_function_types_match_arguments_and_body(functions: list[FunctionDefinition]):
    """A function `f x1 ... xn = body` has type `type(x1) -> ... -> type(xn) -> type(body)`"""
    failures = [
        f"{f.name} : {f.type}, with arguments {[str(a.type) for a in f.arguments]} and body : {f.body.type}"
        for f in functions
        if isinstance(f.kind, DefinedFunctionKind)
        and arrow_parts(f.type, len(f.arguments))
        != ([a.type for a in f.arguments], f.body.type)
    ]
    assert_no_failures(failures)


def test_function_type_variables_are_its_type_parameters(
    functions: list[FunctionDefinition],
):
    failures: list[str] = []
    for f in functions:
        type_vars = {t.name for t in types_in(f.type) if isinstance(t, TypeVariable)}
        if not type_vars <= set(f.type_parameters):
            failures.append(
                f"{f.name} : {f.type}, with type parameters {f.type_parameters}"
            )
    assert_no_failures(failures)


def test_theorems_and_verify_statements_are_bool(db: DB):
    decls = [
        d
        for d in db.decls.values()
        if isinstance(d, TheoremDeclaration | VerifyDeclaration)
    ]
    assert decls
    failures = [
        f"{d.id}: {d.function.body.type}"
        for d in decls
        if not is_bool(d.function.body.type)
    ]
    assert_no_failures(failures)


def test_cliques_are_symmetric(functions: list[FunctionDefinition], db: DB):
    """Every function of a clique of mutually recursive functions has the same clique, itself included"""
    cliques = [f for f in functions if f.clique is not None]
    assert cliques
    failures: list[str] = []
    for f in cliques:
        assert f.clique is not None
        if f.name not in f.clique:
            failures.append(f"{f.name} is not in its clique {f.clique}")
        for g in f.clique:
            if (gd := db.find_function(g)) is None or gd.clique != f.clique:
                failures.append(
                    f"{f.name} has {g} in its clique, but not the other way around"
                )
    assert_no_failures(failures)


# Uids
# ====


def declared_uids(db: DB) -> list[tuple[str, Uid]]:
    """The uids that declarations introduce: functions, types, constructors and fields"""
    uids: list[tuple[str, Uid]] = []
    for d in db.decls.values():
        match d:
            case TypeDeclaration(type=td):
                uids.append(("type", td.name))
                match td.kind:
                    case AlgebraicTypeKind(constructors=cds):
                        uids += [("constructor", cd.name) for cd in cds]
                    case RecordTypeKind(fields=fds):
                        uids += [("field", fd.name) for fd in fds]
                    case _:
                        pass
            case _:
                uids.append(("function", d.function.name))
    return uids


def test_declared_uids_are_not_generative(db: DB):
    """Generative uids, e.g. `x/123`, are for local variables only"""
    failures = [
        f"{kind} {u}"
        for kind, u in declared_uids(db)
        if isinstance(u._raw.view, lib.Uid_view_Generative)  # pyright: ignore[reportPrivateUsage]
    ]
    assert_no_failures(failures)


def test_content_addressed_uids_name_their_declaration(db: DB):
    """A content-addressed uid has its name; it is a key for a top-level function or type, not for
    a constructor or a field, which are defined as part of their type"""
    failures: list[str] = []
    for kind, u in declared_uids(db):
        if (cname := u.cname) is None:
            continue
        if cname.name != u.short_name:
            failures.append(f"{kind} {u}: content-addressed as {cname.name}")
        if cname.is_key != (kind in ("function", "type")):
            failures.append(f"{kind} {u}: is_key={cname.is_key}")
    assert_no_failures(failures)


def test_function_uids_match_their_kind(functions: list[FunctionDefinition]):
    """Builtin functions have builtin uids; defined functions are builtin or content-addressed;
    opaque functions, with no definition to hash, have persistent uids"""
    failures: list[str] = []
    for f in functions:
        u = f.name
        view = u._raw.view  # pyright: ignore[reportPrivateUsage]
        match f.kind:
            case BuiltinFunctionKind():
                ok = u.builtin_kind is not None
            case DefinedFunctionKind():
                ok = u.builtin_kind is not None or u.cname is not None
            case OpaqueFunctionKind():
                ok = isinstance(view, lib.Uid_view_Persistent)
        if not ok:
            failures.append(
                f"{u}: a {type(f.kind).__name__} with a {type(view).__name__} uid"
            )
    assert_no_failures(failures)


# Rules
# =====


def test_rewrite_rules_are_well_formed(rewrite_rules: list[RewriteRule]):
    """`lhs = rhs if guard`: both sides have the same type, the guards are bool, and the rule's
    variables are those of `lhs`, which bind all the variables of `rhs`"""
    assert rewrite_rules
    failures: list[str] = []
    for r in rewrite_rules:
        lhs_vars = pattern_vars(r.lhs)
        if r.lhs.type != r.rhs.type:
            failures.append(f"{r.name}: lhs : {r.lhs.type}, but rhs : {r.rhs.type}")
        if set(r.variables) != lhs_vars:
            failures.append(
                f"{r.name}: variables {r.variables}, but lhs binds {lhs_vars}"
            )
        if not free_vars([r.rhs]) <= lhs_vars:
            failures.append(
                f"{r.name}: rhs uses {free_vars([r.rhs]) - lhs_vars}, which lhs does not bind"
            )
        failures += [
            f"{r.name}: guard {g} : {g.type}" for g in r.guard if not is_bool(g.type)
        ]
    assert_no_failures(failures)


# Task data and results
# =====================


def test_goals_are_bool_and_only_use_their_variables(
    po_tasks: list[ProofObligationTask],
):
    """A goal can leave variables unused, e.g. a termination goal `terminates f` for `f x`"""
    failures: list[str] = []
    for t in po_tasks:
        po = t.proof_obligation
        if not is_bool(po.goal_body.type):
            failures.append(f"PO {t.from_sym}: goal : {po.goal_body.type}")
        if not free_vars([po.goal_body]) <= set(po.goal_variables):
            failures.append(
                f"PO {t.from_sym}: goal uses {free_vars([po.goal_body]) - set(po.goal_variables)}"
            )
    assert_no_failures(failures)


def test_subgoals_are_bool(po_results: list[tuple[str, ProofObligationTaskResult]]):
    failures = [
        f"{where}: {t} : {t.type}"
        for where, res in po_results
        for sr in (sr for srs in res.subresults for sr in srs)
        for sq in [sr.goal, *sr.sub_goals]
        for t in [*sq.hypothesis_terms, *sq.conclusion_terms]
        if not is_bool(t.type)
    ]
    assert_no_failures(failures)


def test_model_constants_are_ground_values_of_their_types(
    po_results: list[tuple[str, ProofObligationTaskResult]],
):
    constants = [
        (where, s, v)
        for where, res in po_results
        if res.model
        for s, v in res.model.constants.items()
    ]
    assert constants
    failures = [
        f"{where}: {s} = {v} uses variables"
        for where, s, v in constants
        if free_vars([v])
    ]
    failures += [
        f"{where}: {s} = {v} : {v.type}"
        for where, s, v in constants
        if v.type != s.type
    ]
    assert_no_failures(failures)


def test_model_function_interpretations_are_well_typed(
    po_results: list[tuple[str, ProofObligationTaskResult]],
):
    """A function `f : d1 -> ... -> dn -> r` is interpreted over arguments of types `d1, ..., dn`,
    by cases with bool guards and values of type `r`, which only use those arguments"""
    interpretations = [
        (where, s, fi)
        for where, res in po_results
        if res.model
        for s, fi in res.model.functions.items()
    ]
    assert interpretations
    failures: list[str] = []
    for where, s, fi in interpretations:
        if arrow_parts(s.type, len(fi.arguments)) != (
            [a.type for a in fi.arguments],
            fi.return_type,
        ):
            failures.append(
                f"{where}: {s}, interpreted over {fi.arguments} returning {fi.return_type}"
            )
        for case in fi.cases:
            failures += [
                f"{where}: {s}: guard {g} : {g.type}"
                for g in case.guards
                if not is_bool(g.type)
            ]
        values = [case.rhs for case in fi.cases] + [fi.else_]
        failures += [
            f"{where}: {s}: value {v} : {v.type}"
            for v in values
            if v.type != fi.return_type
        ]
        used = free_vars([*values, *(g for case in fi.cases for g in case.guards)])
        if not used <= set(fi.arguments):
            failures.append(f"{where}: {s}: uses {used - set(fi.arguments)}")
    assert_no_failures(failures)


def test_regions_are_consistent_with_their_function(
    decompositions: list[tuple[DecompositionTask, Decomposition]],
):
    """A region's constraints are bool conditions on the function's arguments, and its invariant is
    the function's result"""
    assert decompositions
    failures: list[str] = []
    for t, d in decompositions:
        f = t.db.find_function(d.id)
        assert f is not None
        assert d.regions
        for region in d.regions:
            for c in region.constraints:
                if not is_bool(c.type):
                    failures.append(f"{d.id}: constraint {c} : {c.type}")
            if not free_vars(region.constraints) <= set(d.arguments):
                failures.append(
                    f"{d.id}: constraints use {free_vars(region.constraints) - set(d.arguments)}"
                )
            if region.invariant.type != f.body.type:
                failures.append(
                    f"{d.id}: invariant : {region.invariant.type}, but {f.name} returns {f.body.type}"
                )
    assert_no_failures(failures)
