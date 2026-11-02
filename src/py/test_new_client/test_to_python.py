"""Tests for `Term.to_python`, `Model.to_python` and the region accessors

The property tests build random values as raw MIR terms, as the server sends them, and check what
`to_python` makes of them, without a server.

The other tests check fixed values against ImandraX's answers:
- `parse_term` of the source converts to the value
- the instance of `fun x -> x = <value>` has the model `{"x": <value>}`
- each region of `let f x = if x = <value> then 1 else 0` has a sample with output 1 exactly when it
  is the value, and given the decomposition's DB, the sample has its inline records' labels
"""

import itertools
import os
from collections.abc import Iterator
from fractions import Fraction

import pytest
from hypothesis import given
from hypothesis import strategies as st

import imandrax_api
from imandrax_api import lib
from imandrax_api.demo.interface import Client, DecompositionResult, DecompositionTask, InstanceResponse
from imandrax_api.demo.mir import DB, Constructed, PyValue, Uid, term_of_lib

TYPES = """
type rec_t = { a: int; b: bool list }
type var_t = A of { x: int; y: string } | B of int * string | C
type nest_t = N of { inner: var_t; k: int } | M
"""

# The labels of the inline records in `TYPES`, by constructor
INLINE_RECORDS = {"A": {"x", "y"}, "N": {"inner", "k"}}


def same(a: PyValue | None, b: PyValue | None) -> bool:
    """Equal and of the same Python types throughout: unlike `==`, `True` is not `1`"""
    if type(a) is not type(b):
        return False
    match a, b:
        case (list(), list()) | (tuple(), tuple()):
            return len(a) == len(b) and all(map(same, a, b))
        case (dict(), dict()):
            return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
        case (Constructed(), Constructed()):
            return a.name == b.name and same(a.args, b.args)
        case _:
            return a == b


# Raw terms, as the server sends them

type RawTerm = lib.Mir_Term
type RawType = lib.Mir_Type


def uid(name: str) -> lib.Uid:
    return lib.Uid(name=name, view=lib.Uid_view_Persistent())


def ty(name: str, *args: RawType) -> RawType:
    return lib.Mir_Type(view=lib.Ty_view_view_Constr(args=(uid(name), list(args))))


def arrows(args: list[RawType], ret: RawType) -> RawType:
    """`args[0] -> ... -> ret`"""
    for a in reversed(args):
        ret = lib.Mir_Type(view=lib.Ty_view_view_Arrow(args=(None, a, ret)))
    return ret


def sym(name: str, t: RawType) -> lib.Mir_Applied_symbol:
    return lib.Common_Applied_symbol_t_poly(
        sym=lib.Common_Typed_symbol_t_poly(id=uid(name), ty=lib.Common_Type_schema_t_poly(params=[], ty=t)),
        args=[],
        ty=t,
    )


def term(view: lib.Mir_Term_view[RawTerm, RawType], t: RawType) -> RawTerm:
    return lib.Mir_Term(view=view, ty=t, sub_anchor=None)


def const(c: lib.Const, t: RawType) -> RawTerm:
    return term(lib.Mir_Term_view_Const(arg=c), t)


def construct(c: str, args: list[RawTerm], t: RawType, labels: list[str] | None = None) -> RawTerm:
    """Constructor `c` of type `t` applied to `args`"""
    return term(
        lib.Mir_Term_view_Construct(
            c=sym(c, arrows([a.ty for a in args], t)),
            args=args,
            labels=None if labels is None else [uid(l) for l in labels],
        ),
        t,
    )


INT, BOOL, STRING, REAL, FLOAT, UNIT = (ty(n) for n in ["int", "bool", "string", "real", "float", "unit"])
REC_T, VAR_T, NEST_T = ty("rec_t"), ty("var_t"), ty("nest_t")


def raw_db() -> DB:
    """A DB with the definitions of the variant types in `TYPES`"""
    db = DB(lib.Common_Db_ser_t_poly(ops=[]), {})
    variants: dict[str, list[tuple[str, list[str] | None, list[RawType]]]] = {
        "var_t": [("A", ["x", "y"], [INT, STRING]), ("B", None, [INT, STRING]), ("C", None, [])],
        "nest_t": [("N", ["inner", "k"], [VAR_T, INT]), ("M", None, [])],
    }
    for name, rows in variants.items():
        db._raw_tys[Uid(uid(name))] = lib.Ty_view_def_poly(  # pyright: ignore[reportPrivateUsage]
            name=uid(name),
            params=[],
            decl=lib.Ty_view_decl_Algebraic(
                arg=[
                    lib.Ty_view_adt_row(c=uid(c), labels=None if ls is None else [uid(l) for l in ls], args=ts, doc=None)
                    for c, ls, ts in rows
                ]
            ),
            clique=None,
            timeout=None,
        )
    return db


# A type of `TYPES`, or ("list" | "option" | "tuple", argument types)
type Ty = str | tuple[str, tuple[Ty, ...]]

types: st.SearchStrategy[Ty] = st.recursive(
    st.sampled_from(["int", "bool", "string", "real", "float", "unit", "rec_t", "var_t", "nest_t"]),
    lambda inner: st.one_of(
        st.tuples(st.sampled_from(["list", "option"]), st.tuples(inner)),
        st.tuples(st.just("tuple"), st.lists(inner, min_size=2, max_size=3).map(tuple)),
    ),
    max_leaves=4,
)


def raw_type(t: Ty) -> RawType:
    match t:
        case str():
            return ty(t)
        case ("tuple", us):
            return lib.Mir_Type(view=lib.Ty_view_view_Tuple(arg=[raw_type(u) for u in us]))
        case (k, us):
            return ty(k, raw_type(us[0]))


@st.composite
def inline_record(
    draw: st.DrawFn,
    c: str,
    fields: dict[str, st.SearchStrategy[tuple[RawTerm, PyValue]]],
    t: RawType,
    drop_labels: bool,
) -> tuple[RawTerm, PyValue]:
    """Constructor `c` applied to an inline record of `fields`, given in declaration order"""
    vs = {k: draw(s) for k, s in fields.items()}
    expected = Constructed(c, ({k: v for k, (_, v) in vs.items()},))
    if drop_labels and draw(st.booleans()):
        # Without labels, as region samples can be, the arguments are in declaration order
        return construct(c, [x for x, _ in vs.values()], t), expected
    # With labels, the arguments can be in any order
    ks = draw(st.permutations(list(vs)))
    return construct(c, [vs[k][0] for k in ks], t, ks), expected


def values(t: Ty, drop_labels: bool) -> st.SearchStrategy[tuple[RawTerm, PyValue]]:
    """Values of type `t`, as raw terms and as the Python value

    If `drop_labels`, inline records can lack their labels."""
    match t:
        case "int":
            return st.integers().map(lambda n: (const(lib.Const_Const_z(arg=n), INT), n))
        case "bool":
            return st.booleans().map(lambda b: (const(lib.Const_Const_bool(arg=b), BOOL), b))
        case "string":
            return st.text().map(lambda s: (const(lib.Const_Const_string(arg=s), STRING), s))
        case "real":
            return st.fractions().map(
                lambda q: (const(lib.Const_Const_q(arg=(q.numerator, q.denominator)), REAL), q)
            )
        case "float":
            return st.floats(allow_nan=False).map(lambda f: (const(lib.Const_Const_float(arg=f), FLOAT), f))
        case "unit":
            return st.just((construct("()", [], UNIT), ()))
        case "rec_t":
            return st.tuples(values("int", drop_labels), values(("list", ("bool",)), drop_labels)).map(
                lambda ab: (
                    term(
                        lib.Mir_Term_view_Record(
                            rows=[(sym("a", INT), ab[0][0]), (sym("b", ab[1][0].ty), ab[1][0])], rest=None
                        ),
                        REC_T,
                    ),
                    {"a": ab[0][1], "b": ab[1][1]},
                )
            )
        case "var_t":
            return st.one_of(
                inline_record("A", {"x": values("int", drop_labels), "y": values("string", drop_labels)}, VAR_T, drop_labels),
                st.tuples(values("int", drop_labels), values("string", drop_labels)).map(
                    lambda p: (construct("B", [p[0][0], p[1][0]], VAR_T), Constructed("B", (p[0][1], p[1][1])))
                ),
                st.just((construct("C", [], VAR_T), Constructed("C"))),
            )
        case "nest_t":
            return st.one_of(
                inline_record("N", {"inner": values("var_t", drop_labels), "k": values("int", drop_labels)}, NEST_T, drop_labels),
                st.just((construct("M", [], NEST_T), Constructed("M"))),
            )
        case ("list", (u,)):

            def raw_list(xs: list[tuple[RawTerm, PyValue]]) -> tuple[RawTerm, PyValue]:
                lt = raw_type(t)
                out = construct("[]", [], lt)
                for x, _ in reversed(xs):
                    out = construct("::", [x, out], lt)
                return out, [v for _, v in xs]

            return st.lists(values(u, drop_labels), max_size=4).map(raw_list)
        case ("option", (u,)):
            return st.one_of(
                st.just((construct("None", [], raw_type(t)), Constructed("None"))),
                values(u, drop_labels).map(
                    lambda x: (construct("Some", [x[0]], raw_type(t)), Constructed("Some", (x[1],)))
                ),
            )
        case ("tuple", us):
            return st.tuples(*(values(u, drop_labels) for u in us)).map(
                lambda xs: (
                    term(lib.Mir_Term_view_Tuple(l=[x for x, _ in xs]), raw_type(t)),
                    tuple(v for _, v in xs),
                )
            )
        case _:
            raise ValueError(t)


@given(types.flatmap(lambda t: values(t, drop_labels=False)))
def test_to_python(tv: tuple[RawTerm, PyValue]):
    raw, expected = tv
    assert same(term_of_lib(raw).to_python(), expected)


@given(types.flatmap(lambda t: values(t, drop_labels=True)))
def test_to_python_with_db_restores_inline_record_labels(tv: tuple[RawTerm, PyValue]):
    raw, expected = tv
    assert same(term_of_lib(raw).to_python(raw_db()), expected)


def test_to_python_without_db_keeps_unlabeled_arguments():
    raw = construct("A", [const(lib.Const_Const_z(arg=1), INT), const(lib.Const_Const_string(arg="a"), STRING)], VAR_T)
    assert same(term_of_lib(raw).to_python(), Constructed("A", (1, "a")))


# Against the server

# Values of the types in `TYPES` and of lists, options and tuples: IML type, source, Python value
EXAMPLES: list[tuple[str, str, PyValue]] = [
    ("int", "(-12345678901234567890)", -12345678901234567890),
    ("bool", "true", True),
    ("string", '"a \\"quoted\\" \\\\ string"', 'a "quoted" \\ string'),
    ("real", "(-1.25)", Fraction(-5, 4)),
    ("unit", "()", ()),
    ("rec_t", "{ a = 1; b = [true; false] }", {"a": 1, "b": [True, False]}),
    # fields out of order, to check labels are paired with the right arguments
    ("var_t", '(A { y = "b"; x = 2 })', Constructed("A", ({"x": 2, "y": "b"},))),
    ("var_t", '(B (3, "c"))', Constructed("B", (3, "c"))),
    ("var_t", "C", Constructed("C")),
    (
        "nest_t",
        '(N { k = 4; inner = A { x = 5; y = "" } })',
        Constructed("N", ({"inner": Constructed("A", ({"x": 5, "y": ""},)), "k": 4},)),
    ),
    ("nest_t", "M", Constructed("M")),
    ("int list", "[]", []),
    ("var_t option list", "[None; Some C]", [Constructed("None"), Constructed("Some", (Constructed("C"),))]),
    ("int * string * bool", '(1, "x", false)', (1, "x", False)),
]

# Values that only `parse_term` gets right: the server mangles non-ASCII and NUL in model strings,
# see the `xfail` tests
PARSE_ONLY_EXAMPLES: list[tuple[str, str, PyValue]] = [
    ("string", '"\\xc3\\xa9\\x00"', "é\x00"),
]

# Values that are not literals, so `parse_term` gives no value, but models do
MODEL_ONLY_EXAMPLES: list[tuple[str, str, PyValue]] = [
    ("real", "(1.0 /. 3.0)", Fraction(1, 3)),
]


def decomposition_db(res: DecompositionResult) -> DB:
    assert isinstance(res.task, DecompositionTask)
    return res.task.db


def constructeds(v: PyValue) -> Iterator[Constructed]:
    """Every `Constructed` in `v`, at any depth"""
    match v:
        case Constructed(args=args):
            yield v
            for a in args:
                yield from constructeds(a)
        case list() | tuple():
            for x in v:
                yield from constructeds(x)
        case dict():
            for x in v.values():
                yield from constructeds(x)
        case _:
            pass


def has_labels(c: Constructed) -> bool:
    """`c`, if it has an inline record, has it as one `dict` with its labels"""
    match c.args:
        case _ if c.name not in INLINE_RECORDS:
            return True
        case (dict() as r,):
            return r.keys() == INLINE_RECORDS[c.name]
        case _:
            return False


def api_key() -> str | None:
    return os.environ.get("IMANDRAX_API_KEY") or os.environ.get("IMANDRA_UNI_KEY")


@pytest.fixture(scope="module")
def client() -> Iterator[Client]:
    """A client whose session has `TYPES` loaded"""
    with Client(url=imandrax_api.url_prod, api_key=api_key(), timeout=120) as c:
        assert c.eval_src(TYPES).success
        yield c


@pytest.mark.parametrize(("ty", "src", "expected"), EXAMPLES + PARSE_ONLY_EXAMPLES)
def test_parse_term_to_python(client: Client, ty: str, src: str, expected: PyValue):
    assert same(client.parse_term(f"({src} : {ty})").to_python(), expected)


@pytest.mark.parametrize(("ty", "src", "expected"), EXAMPLES + MODEL_ONLY_EXAMPLES)
def test_instance_model_to_python(client: Client, ty: str, src: str, expected: PyValue):
    r = client.instance_src(f"fun (x: {ty}) -> x = ({src} : {ty})")
    assert isinstance(r.res, InstanceResponse.Sat) and r.res.instance is not None, r.errors
    model = r.res.instance.model
    assert model is not None
    assert same(model.to_python(), {"x": expected})


def test_to_python_rejects_non_values(client: Client):
    with pytest.raises(ValueError, match="Not a value"):
        client.parse_term("Map.const 0 |> Map.add 1 2").to_python()
    r = client.instance_src("fun (x: real) -> x *. x = 2.0 && x >. 0.0")
    assert isinstance(r.res, InstanceResponse.Sat) and r.res.instance is not None
    model = r.res.instance.model
    assert model is not None
    with pytest.raises(ValueError, match="irrational"):
        model.to_python()


@pytest.mark.xfail(strict=True, reason="the server UTF-8-encodes model strings twice: 'é' comes back as 'Ã©'")
def test_instance_model_non_ascii_string(client: Client):
    r = client.instance_src('fun (x: string) -> x = "\\xc3\\xa9"')
    assert isinstance(r.res, InstanceResponse.Sat) and r.res.instance is not None
    model = r.res.instance.model
    assert model is not None
    assert model.to_python() == {"x": "é"}


@pytest.mark.xfail(strict=True, reason='the server cuts model strings at the first NUL: "a\\000b" comes back as "a"')
def test_instance_model_string_with_nul(client: Client):
    r = client.instance_src('fun (x: string) -> x = "a\\x00b"')
    assert isinstance(r.res, InstanceResponse.Sat) and r.res.instance is not None
    model = r.res.instance.model
    assert model is not None
    assert model.to_python() == {"x": "a\x00b"}


_fresh = itertools.count()


@pytest.mark.parametrize(("ty", "src", "expected"), EXAMPLES + MODEL_ONLY_EXAMPLES)
def test_region_sample_and_strings(client: Client, ty: str, src: str, expected: PyValue):
    f = f"is_it_{next(_fresh)}"
    assert client.eval_src(f"let {f} (x: {ty}) = if x = ({src} : {ty}) then 1 else 0").success
    res = client.decompose(f, prune=True, string_results=True)
    d = res.decomposition
    assert d is not None, res.errors
    db = decomposition_db(res)

    for r in d.regions:
        assert r.constraints_str is not None and len(r.constraints_str) == len(r.constraints)
        assert r.invariant_str in ("0", "1")
        sample = r.sample(db)
        assert sample is not None and sample.keys() == {"x"}
        output = r.sample_output(db)
        assert same(output, 1 if same(sample["x"], expected) else 0)
        assert str(output) == r.invariant_str
    assert any(r.sample_output(db) == 1 for r in d.regions)


def test_region_samples_nested_inline_records_with_db(client: Client):
    """Inline records keep their labels in a list, an option, a tuple, and in another inline record"""
    f = "nested_inline"
    assert client.eval_src(f"""
let {f} (v: var_t option list) (p: var_t * int) (n: nest_t) =
  match v, p, n with
  | [Some (A {{x; _}})], (A _, _), N {{inner = A {{x = x2; _}}; k}} -> if x > 5 && x2 > k then 1 else 0
  | _ -> 2""").success
    res = client.decompose(f, prune=True)
    d = res.decomposition
    assert d is not None, res.errors
    db = decomposition_db(res)

    samples = [s for r in d.regions if (s := r.sample(db)) is not None]
    assert len(samples) == len(d.regions)
    for s in samples:
        bad = [c for c in constructeds(s) if not has_labels(c)]
        assert not bad, bad

    # The region with output 1 nests inline records in all of these ways
    (hit,) = [r for r in d.regions if r.sample_output(db) == 1]
    match hit.sample(db):
        case {
            "v": [Constructed("Some", (Constructed("A", ({"x": int(x), "y": str()},)),))],
            "p": (Constructed("A", ({"x": int(), "y": str()},)), int()),
            "n": Constructed("N", ({"inner": Constructed("A", ({"x": int(x2), "y": str()},)), "k": int(k)},)),
        }:
            assert x > 5 and x2 > k
        case other:
            pytest.fail(f"unexpected sample {other}")


@pytest.mark.parametrize("ty", sorted({ty for ty, _, _ in EXAMPLES}))
def test_region_output_of_identity_is_its_sample(client: Client, ty: str):
    """`let f x = x` returns its sample: given the DB, both come back the same, labels included"""
    f = f"same_{next(_fresh)}"
    assert client.eval_src(f"let {f} (x: {ty}) = x").success
    res = client.decompose(f, prune=True)
    d = res.decomposition
    assert d is not None, res.errors
    db = decomposition_db(res)

    for r in d.regions:
        sample = r.sample(db)
        assert sample is not None and sample.keys() == {"x"}
        assert same(r.sample_output(db), sample["x"])
        assert all(has_labels(c) for c in constructeds(sample["x"]))


def test_region_output_passes_inline_records_through(client: Client):
    """A result that contains part of the sample has the same labels as the sample, given the DB"""
    f = "pass_through"
    assert client.eval_src(f"""
let {f} (v: var_t * nest_t) =
  match v with
  | (A {{x; _}}, N {{inner = A _; k}}) -> if x > k then Some v else None
  | _ -> None""").success
    res = client.decompose(f, prune=True)
    d = res.decomposition
    assert d is not None, res.errors
    db = decomposition_db(res)

    outputs = [(r.sample(db), r.sample_output(db)) for r in d.regions]
    passed_through = [(s, o) for s, o in outputs if isinstance(o, Constructed) and o.name == "Some"]
    assert len(passed_through) == 1
    ((sample, output),) = passed_through
    assert sample is not None
    assert same(output, Constructed("Some", (sample["v"],)))
    assert all(has_labels(c) for c in constructeds(output))
