"""Test MIR DB
- type / function search features
- prelude declarations should be in the DB
- lifted lambdas can be told apart by their full uid names
- every uid declarations and rules refer to can be found in the DB

Additionally, also test the raw-lib-type->lib-type conversion roundtrip for declarations in the DB
"""

from collections.abc import Iterable

import pytest

from imandrax_api.demo.interface import (
    Client,
    EvalSrcResponse,
    ProofObligationTask,
    Task,
    TypeDefinition,
)
from imandrax_api.demo.mir import (
    DB,
    AlgebraicTypeKind,
    Apply,
    ArrowType,
    BuiltinFunctionKind,
    BuiltinTypeKind,
    ConstructedType,
    Declaration,
    DefinedFunctionKind,
    FunctionDefinition,
    RecordTypeKind,
    Symbol,
    SymbolHead,
    Term,
    TheoremDeclaration,
    TupleType,
    Type,
    TypeDeclaration,
    TypeVariable,
    Uid,
    declaration_of_lib,
    term_of_lib,
)

SRC = """
type shape = Circle of int | Rect of { w: int; h: int }
type point = { x: int; y: int }
type my_int = int

let add_one (x: my_int) : my_int = x + 1
let area (s: shape) : int = match s with Circle r -> 3 * r * r | Rect { w; h } -> w * h
let rec sum (xs: int list) : int = match xs with [] -> 0 | x :: tl -> x + sum tl
let g (x: int) = x + 1
let inc_all (xs: int list) : int list = List.map (fun x -> x + 1) xs
let add_all (y: int) (xs: int list) : int list = List.map (fun x -> x + y) xs

theorem g_gt x = g x > x [@@rw]
theorem sum_nonneg xs = List.for_all (fun x -> x >= 0) xs ==> sum xs >= 0 [@@by auto] [@@fc]
[@@@disable g]

eval (area (Circle 2))
let h (p: point) = p.x + p.y
[@@decomp top ()]

verify (fun x -> h { x; y = 1 } > x)
instance (fun (xs: int list) (y: int) -> inc_all xs <> List.map (fun x -> x * y) xs)

verify true
"""

# Setup
# ====================


def tasks_of_eval_src(c: Client, src: str) -> tuple[Task, ...]:
    eval_res: EvalSrcResponse = c.eval_src(src)
    return eval_res.tasks


@pytest.fixture(scope="module")
def tasks(c: Client) -> tuple[Task, ...]:
    """The tasks of `SRC`"""
    return tasks_of_eval_src(c, SRC)


@pytest.fixture(scope="module")
def db(tasks: tuple[Task, ...]) -> DB:
    """The DB of the final `verify true` in `SRC`"""
    # Tasks come newest first
    assert isinstance(tasks[0], ProofObligationTask)
    return tasks[0].db


def search_uid_by_short_name(db: DB, short_name: str) -> Uid:
    """Search UID in MIR DB by short name. Raises if not found."""
    (uid,) = [u for u in db.decls if u.short_name == short_name]
    return uid


def short_names(uids: Iterable[Uid]) -> set[str]:
    return {u.short_name for u in uids}


# Declarations
# ============


def test_declaration_kinds(db: DB):
    kinds = {
        name: decl.kind
        for name in ["shape", "point", "area", "sum", "g", "g_gt", "sum_nonneg", "h"]
        if (decl := db.find_declaration(search_uid_by_short_name(db, name))) is not None
    }
    assert kinds == {
        "shape": "type",
        "point": "type",
        "area": "function",
        "sum": "function",
        "g": "function",
        "g_gt": "theorem",
        "sum_nonneg": "theorem",
        "h": "function",
    }


def test_theorem_declaration(db: DB):
    # `theorem g_gt x = g x > x [@@rw]`
    g_gt: Uid = search_uid_by_short_name(db, "g_gt")
    g: Uid = search_uid_by_short_name(db, "g")

    decl: Declaration | None = db.find_declaration(g_gt)
    assert isinstance(decl, TheoremDeclaration)

    # A theorem is stored under the uid of its linked function, which is also
    # available through `find_function`.
    linked: FunctionDefinition = decl.function
    assert linked.name == g_gt
    assert db.find_function(g_gt) is not None

    body: Term = linked.body
    assert isinstance(body, Apply)

    # `g` is applied in the body, under the uid it is declared under
    applied: set[Uid] = set()
    for subterm in body:
        if isinstance(subterm, Apply):
            f = subterm.function
            if isinstance(f, Symbol):
                applied.add(f.symbol.id)
    assert g in applied


def test_type_definitions(db: DB):
    # shape variant
    shape: TypeDefinition | None = db.find_type(search_uid_by_short_name(db, "shape"))
    assert shape is not None
    assert isinstance(shape.kind, AlgebraicTypeKind)
    assert [c.name.short_name for c in shape.kind.constructors] == ["Circle", "Rect"]

    # point record
    point: TypeDefinition | None = db.find_type(search_uid_by_short_name(db, "point"))
    assert point is not None
    assert isinstance(point.kind, RecordTypeKind)
    assert [f.name.short_name for f in point.kind.fields] == ["x", "y"]

    # Functions are not types and vice versa
    assert db.find_type(search_uid_by_short_name(db, "area")) is None
    assert db.find_function(search_uid_by_short_name(db, "shape")) is None


def test_type_aliases_are_expanded(db: DB):
    """type alias doesn't show up in the DB, neither as type declaration nor in referenced definition"""
    # `type my_int = int` is not a declaration of its own...
    assert "my_int" not in short_names(db.decls)
    assert db.find_type_re("my_int") == {}
    assert db.find_declaration_re("my_int") == {}

    # ...and declarations using it see `int` instead
    add_one = db.find_function(search_uid_by_short_name(db, "add_one"))
    assert add_one is not None
    assert str(add_one.type) == "int -> int"


def test_find_re_matches_full_name_from_start(db: DB):
    # The full name is `<short name>/<content hash>`
    assert set(db.find_function_re("sum/")) == {search_uid_by_short_name(db, "sum")}
    assert set(db.find_type_re("point/")) == {search_uid_by_short_name(db, "point")}
    assert set(db.find_declaration_re("g_gt/")) == {
        search_uid_by_short_name(db, "g_gt")
    }

    # `re.match` semantics: anchored at the start, not at the end
    assert db.find_function_re("um/") == {}
    assert search_uid_by_short_name(db, "sum_nonneg") in db.find_function_re("sum")


# Rules
# =====


def test_theorem_as_rewrite_rule(db: DB):
    g_gt: Uid = search_uid_by_short_name(db, "g_gt")
    assert len(db.thm_as_rw[g_gt]) == 1
    assert len(db.rule_spec_rw_rules[g_gt]) == 1


def test_theorem_as_forward_chaining_rule(db: DB):
    """`theorem sum_nonneg xs = ... ==> sum xs >= 0 [@@by auto] [@@fc]`"""
    sum_nonneg: Uid = search_uid_by_short_name(db, "sum_nonneg")

    assert len(db.thm_as_fc[sum_nonneg]) == 1, "sum_nonneg should become a fc rule"
    assert sum_nonneg in db.inst_rules, "sum_nonneg should be in inst rules"
    assert len(db.rule_spec_fc[sum_nonneg]) == 1, "sum_nonneg should be in rule spec fc"

    # The trigger is indexed by the head of its pattern, here `sum`
    sum_heads: list[SymbolHead] = [
        h
        for h in db.fc
        if isinstance(h, SymbolHead) and h.uid == search_uid_by_short_name(db, "sum")
    ]
    assert len(sum_heads) == 1, "sum should be a fc trigger head"
    assert len(db.fc[sum_heads[0]]) == 1, "sum should trigger exactly one fc rule"


# Lambdas
# =======


def _lambdas_of_term(t: Term) -> list[Uid]:
    lams: list[Uid] = []
    for term in t:
        term: Term
        if isinstance(term, Symbol) and term.symbol.id.short_name == "$lambda":
            lams.append(term.symbol.id)
    return lams


def _lambdas_of_func_body(fun: FunctionDefinition) -> list[Uid]:
    return _lambdas_of_term(fun.body)


def test_search_lifted_lambdas(tasks: tuple[Task, ...], db: DB):
    """MIR DB should enable disambiguating two lambdas"""
    # 1. `fun x -> x + 1` in `inc_all`
    inc_all: Uid = search_uid_by_short_name(db, "inc_all")
    inc_all_f = db.find_function(inc_all)
    assert inc_all_f is not None
    lambdas_in_inc_all = _lambdas_of_func_body(inc_all_f)
    assert len(lambdas_in_inc_all) == 1

    lambda_inc: FunctionDefinition | None = db.find_function(lambdas_in_inc_all[0])
    assert lambda_inc is not None
    assert "x = (+ x 1)" in repr(lambda_inc)

    # 2. `fun x -> x + y` in `add_all`
    add_all: Uid = search_uid_by_short_name(db, "add_all")
    add_all_f = db.find_function(add_all)
    assert add_all_f is not None
    lambdas_in_add_all = _lambdas_of_func_body(add_all_f)
    assert len(lambdas_in_add_all) == 1

    lambda_add: FunctionDefinition | None = db.find_function(lambdas_in_add_all[0])
    assert lambda_add is not None
    assert "y x = (+ x y)" in repr(lambda_add)

    # 3. `fun x -> x * y` in the goal of the `instance`
    instance: ProofObligationTask
    (instance,) = [
        t
        for t in tasks
        if isinstance(t, ProofObligationTask) and t.proof_obligation.is_instance
    ]
    _vars, goal = instance.proof_obligation.goal
    lambdas_in_goal = _lambdas_of_term(goal)
    assert len(lambdas_in_goal) == 1

    lambda_mul: FunctionDefinition | None = db.find_function(lambdas_in_goal[0])
    assert lambda_mul is not None
    assert "y x = (* x y)" in repr(lambda_mul)

    assert (
        lambda_inc.name.short_name
        == lambda_add.name.short_name
        == lambda_mul.name.short_name
        == "$lambda"
    ), "Lambdas are ambiguous in short name"


# Prelude
# =======


def test_prelude_builtin_types(db: DB):
    for name in ["int", "bool", "float", "real", "string"]:
        ty = db.find_type(search_uid_by_short_name(db, name))
        assert ty is not None
        assert isinstance(ty.kind, BuiltinTypeKind)


def test_prelude_algebraic_types(db: DB):
    constructors = {
        name: [c.name.short_name for c in ty.kind.constructors]
        for name in ["list", "option", "Ordinal.t", "Peano_nat.t"]
        if (ty := db.find_type(search_uid_by_short_name(db, name))) is not None
        and isinstance(ty.kind, AlgebraicTypeKind)
    }
    assert constructors == {
        "list": ["[]", "::"],
        "option": ["None", "Some"],
        "Ordinal.t": ["Ordinal.Int", "Ordinal.Cons"],
        "Peano_nat.t": ["Peano_nat.Z", "Peano_nat.S"],
    }


def test_prelude_builtin_uids_have_no_content_hash(db: DB):
    """Declarations marked `[@@builtin ...]` are referred to by name alone and the others by `<short name>/<content hash>`"""
    for name in ["int", "list", "List.hd", "Ordinal.<<"]:
        assert search_uid_by_short_name(db, name).full_name == name
    for name in ["either", "LChar.t", "List.length", "List.rev"]:
        assert search_uid_by_short_name(db, name).full_name.startswith(f"{name}/")


def test_prelude_functions(db: DB):
    # List.length
    length = db.find_function(search_uid_by_short_name(db, "List.length"))
    assert length is not None
    assert isinstance(length.kind, DefinedFunctionKind)
    assert [str(a) for a in length.arguments] == ["l"]
    assert str(length.type).endswith(" list -> int")
    # A recursive function is in its own clique
    assert length.clique == {length.name}

    # List.hd
    hd = db.find_function(search_uid_by_short_name(db, "List.hd"))
    assert hd is not None
    assert isinstance(hd.kind, BuiltinFunctionKind)

    # id
    ident = db.find_function(search_uid_by_short_name(db, "id"))
    assert ident is not None
    assert ident.clique is None


def test_prelude_theorems_and_rules(db: DB):
    theorems = short_names(
        u for u, d in db.decls.items() if isinstance(d, TheoremDeclaration)
    )
    for name in [
        # `[@@imandra_axiom]`s are theorems too
        "Int.mod_eq_emod",
        "List.append_to_nil",
        "List.append_single",
        "List.len_nonnegative",
        "List.len_zero_is_empty",
        "List.len_append",
        "LString.len_pos",
        "LString.len_zero_inversion",
    ]:
        assert name in theorems

    # `[@@rw]` / `[@@rewrite]` theorems
    rw = short_names(db.thm_as_rw)
    for name in [
        "List.append_to_nil",
        "List.append_single",
        "List.len_zero_is_empty",
        "List.len_append",
    ]:
        assert name in rw

    # `[@@fc]` theorems
    fc = short_names(db.thm_as_fc)
    for name in [
        "List.len_nonnegative",
        "LString.len_pos",
        "LString.len_zero_inversion",
    ]:
        assert name in fc


# Disabled symbols
# ====================


def test_disabled_symbols(db: DB):
    assert [u.short_name for u in db.disabled] == ["g"]


@pytest.mark.xfail(
    strict=True,
    reason="disabled uids are generative (e.g. `g/19390`), not the content hashed uid `g` is declared under",
)
def test_disabled_symbols_resolve_to_declarations(db: DB):
    assert db.disabled == {search_uid_by_short_name(db, "g")}


# References
# ==========


def test_lookups_agree_with_declarations(db: DB):
    """`find_function` and `find_type` find what each declaration declares"""
    for uid, decl in db.decls.items():
        match decl:
            case TypeDeclaration(type=ty):
                assert db.find_type(uid) == ty, uid
            case _:
                assert db.find_function(uid) == decl.function, uid


def test_symbols_resolve_to_declarations(db: DB):
    """Every symbol a function refers to is declared in the DB"""
    bodies = [
        d.function.body for d in db.decls.values() if not isinstance(d, TypeDeclaration)
    ]
    symbols = {x.symbol.id for body in bodies for x in body if isinstance(x, Symbol)}
    assert symbols
    assert {u for u in symbols if db.find_declaration(u) is None} == set()


def constructed_types(ty: Type) -> Iterable[ConstructedType]:
    match ty:
        case ArrowType(domain=d, codomain=cd):
            yield from constructed_types(d)
            yield from constructed_types(cd)
        case TupleType(elements=ts):
            for t in ts:
                yield from constructed_types(t)
        case ConstructedType(arguments=ts):
            yield ty
            for t in ts:
                yield from constructed_types(t)
        case TypeVariable():
            pass


def test_type_constructors_resolve_to_type_definitions(db: DB):
    """Every type constructor in a function's type or terms is defined in the DB"""
    functions = [
        d.function for d in db.decls.values() if not isinstance(d, TypeDeclaration)
    ]
    types = [f.type for f in functions] + [x.type for f in functions for x in f.body]
    constructors = {t.constructor for ty in types for t in constructed_types(ty)}
    assert constructors
    assert {u for u in constructors if db.find_type(u) is None} == set()


def test_rules_refer_to_theorems(db: DB):
    """Rules and triggers are derived from theorems, which they refer to by uid"""
    uids = [
        *db.thm_as_rw,
        *db.thm_as_fc,
        *db.thm_as_elim,
        *db.thm_as_gen,
        *db.inst_rules,
    ]
    uids += [r.name for rs in db.rw_rules.values() for r in rs]
    uids += [
        t.instantiation_rule_name
        for ts in [*db.fc.values(), *db.gen.values()]
        for t in ts
    ]
    assert uids
    for u in uids:
        assert isinstance(db.find_declaration(u), TheoremDeclaration), u


# ====================


def test_every_declaration_converts_from_raw_lib_types(db: DB):
    """Test raw lib type conversion for all declarations in DB"""
    assert len(db.decls) > 100
    for uid, decl in db.decls.items():
        assert isinstance(decl, Declaration)
        assert decl.id == uid
        # Declarations compare and hash by structure: converting the same library declaration
        # again gives an equal declaration with the same hash
        decl_again = declaration_of_lib(decl._raw)  # pyright: ignore[reportPrivateUsage]
        assert decl_again == decl and hash(decl_again) == hash(decl)

        match decl:
            case TypeDeclaration(type=ty):
                ty_again = TypeDefinition.of_lib(ty._raw)  # pyright: ignore[reportPrivateUsage]
                assert ty_again == ty and hash(ty_again) == hash(ty)
            case _:
                # Same for terms
                body = decl.function.body
                again = term_of_lib(body._raw)  # pyright: ignore[reportPrivateUsage]
                assert again == body and hash(again) == hash(body)
                for t in body:
                    assert isinstance(t, Term)
                    hash(t)
