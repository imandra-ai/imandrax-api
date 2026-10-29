"""Property tests for `Term.to_python`, `Model.to_python` and the region accessors

Each test draws a random IML type and a random value of it, both as IML source and as the Python
value `to_python` should give, and checks ImandraX's answers against it:
- `parse_term` of the source converts to the value
- the instance of `fun x -> x = <value>` has the model `{"x": <value>}`
- each region of `let f x = if x = <value> then 1 else 0` has a sample with output 1 exactly when it
  is the value
"""

import itertools
import os
from collections.abc import Iterator
from fractions import Fraction

import pytest
from hypothesis import HealthCheck, given, settings
from hypothesis import strategies as st

import imandrax_api
from imandrax_api.demo.interface import Client, InstanceResponse
from imandrax_api.demo.mir import Constructed, PyValue

TYPES = """
type rec_t = { a: int; b: bool list }
type var_t = A of { x: int; y: string } | B of int * string | C
"""

# An IML type: a name, or ("list" | "option" | "tuple", argument types)
type Ty = str | tuple[str, tuple[Ty, ...]]

types: st.SearchStrategy[Ty] = st.recursive(
    st.sampled_from(["int", "bool", "string", "real", "unit", "rec_t", "var_t"]),
    lambda inner: st.one_of(
        st.tuples(st.sampled_from(["list", "option"]), st.tuples(inner)),
        st.tuples(st.just("tuple"), st.lists(inner, min_size=2, max_size=3).map(tuple)),
    ),
    max_leaves=4,
)


def iml_type(t: Ty) -> str:
    match t:
        case str():
            return t
        case ("tuple", us):
            return "(" + " * ".join(iml_type(u) for u in us) + ")"
        case (k, us):
            return f"({iml_type(us[0])}) {k}"


def iml_string(s: str) -> str:
    """`s` as an IML string literal, its UTF-8 bytes escaped beyond printable ASCII"""
    out = ""
    for b in s.encode():
        c = chr(b)
        out += "\\" + c if c in '"\\' else c if 32 <= b < 127 else f"\\x{b:02x}"
    return f'"{out}"'


def iml_real(q: Fraction) -> str:
    """`q` as an IML real: a literal if it has a finite decimal expansion, else a division"""
    for k in range(20):
        if (q * 10**k).denominator == 1:
            digits = str(abs(q.numerator * 10**k // q.denominator)).rjust(k + 1, "0")
            return f"({'-' if q < 0 else ''}{digits[: len(digits) - k]}.{digits[len(digits) - k :]})"
    return f"({q.numerator}.0 /. {q.denominator}.0)"


def values(t: Ty, via_model: bool) -> st.SearchStrategy[tuple[str, PyValue]]:
    """Values of type `t`, as IML source and as the Python value

    If `via_model`, the source need not be a literal (any real), and strings are ASCII without NUL, as
    the server mangles other strings in models, see the `xfail` tests."""
    match t:
        case "int":
            return st.integers().map(lambda n: (f"({n})", n))
        case "bool":
            return st.booleans().map(lambda b: (str(b).lower(), b))
        case "string":
            chars = st.characters(min_codepoint=1, max_codepoint=127) if via_model else st.characters(codec="utf-8")
            return st.text(chars).map(
                lambda s: (iml_string(s), s)
            )
        case "real":
            decimals = st.tuples(st.integers(), st.integers(0, 6)).map(lambda nk: Fraction(nk[0], 10 ** nk[1]))
            return (st.fractions() if via_model else decimals).map(lambda q: (iml_real(q), q))
        case "unit":
            return st.just(("()", ()))
        case "rec_t":
            return st.tuples(values("int", via_model), values(("list", ("bool",)), via_model)).map(
                lambda ab: (f"{{ a = {ab[0][0]}; b = {ab[1][0]} }}", {"a": ab[0][1], "b": ab[1][1]})
            )
        case "var_t":
            return st.one_of(
                st.tuples(values("int", via_model), values("string", via_model), st.booleans()).map(
                    lambda p: (
                        # either field order, to check labels are paired with the right arguments
                        f"(A {{ x = {p[0][0]}; y = {p[1][0]} }})"
                        if p[2]
                        else f"(A {{ y = {p[1][0]}; x = {p[0][0]} }})",
                        Constructed("A", ({"x": p[0][1], "y": p[1][1]},)),
                    )
                ),
                st.tuples(values("int", via_model), values("string", via_model)).map(
                    lambda p: (f"(B ({p[0][0]}, {p[1][0]}))", Constructed("B", (p[0][1], p[1][1])))
                ),
                st.just(("C", Constructed("C"))),
            )
        case ("list", (u,)):
            return st.lists(values(u, via_model), max_size=4).map(
                lambda xs: ("[" + "; ".join(s for s, _ in xs) + "]", [v for _, v in xs])
            )
        case ("option", (u,)):
            return st.one_of(
                st.just(("None", Constructed("None"))),
                values(u, via_model).map(lambda x: (f"(Some {x[0]})", Constructed("Some", (x[1],)))),
            )
        case ("tuple", us):
            return st.tuples(*(values(u, via_model) for u in us)).map(
                lambda xs: ("(" + ", ".join(s for s, _ in xs) + ")", tuple(v for _, v in xs))
            )
        case _:
            raise ValueError(t)


def typed_values(via_model: bool) -> st.SearchStrategy[tuple[str, str, PyValue]]:
    """An IML type, a value of it as IML source, and that value in Python"""
    return types.flatmap(lambda t: values(t, via_model).map(lambda v: (iml_type(t), *v)))


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


def drop_labels(v: PyValue) -> PyValue:
    """`v` with the inline record of `A` as plain arguments, as region samples can drop its labels,
    see `test_region_sample_inline_record_labels`"""
    match v:
        case Constructed("A", (dict() as r,)):
            return Constructed("A", tuple(drop_labels(x) for x in r.values()))
        case Constructed(name, args):
            return Constructed(name, tuple(drop_labels(a) for a in args))
        case list():
            return [drop_labels(x) for x in v]
        case tuple():
            return tuple(drop_labels(x) for x in v)
        case dict():
            return {k: drop_labels(x) for k, x in v.items()}
        case _:
            return v


def api_key() -> str | None:
    return os.environ.get("IMANDRAX_API_KEY") or os.environ.get("IMANDRA_UNI_KEY")


@pytest.fixture(scope="module")
def client() -> Iterator[Client]:
    """A client whose session has `TYPES` loaded"""
    with Client(url=imandrax_api.url_prod, api_key=api_key(), timeout=120) as c:
        assert c.eval_src(TYPES).success
        yield c


# Each example is one or more round trips to the server. Set PBT_SCALE=10 for a deeper run.
def slow(max_examples: int) -> settings:
    n = max_examples * int(os.environ.get("PBT_SCALE", "1"))
    return settings(max_examples=n, deadline=None, suppress_health_check=[HealthCheck.too_slow])


@slow(100)
@given(typed_values(via_model=False))
def test_parse_term_to_python(client: Client, tv: tuple[str, str, PyValue]):
    ty, src, expected = tv
    assert same(client.parse_term(f"({src} : {ty})").to_python(), expected)


@slow(30)
@given(typed_values(via_model=True))
def test_instance_model_to_python(client: Client, tv: tuple[str, str, PyValue]):
    ty, src, expected = tv
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


@slow(20)
@given(typed_values(via_model=True))
def test_region_sample_and_strings(client: Client, tv: tuple[str, str, PyValue]):
    ty, src, expected = tv
    f = f"is_it_{next(_fresh)}"
    assert client.eval_src(f"let {f} (x: {ty}) = if x = ({src} : {ty}) then 1 else 0").success
    res = client.decompose(f, prune=True, string_results=True)
    d = res.decomposition
    assert d is not None, res.errors

    for r in d.regions:
        assert r.constraints_str is not None and len(r.constraints_str) == len(r.constraints)
        assert r.invariant_str in ("0", "1")
        sample = r.sample
        assert sample is not None and sample.keys() == {"x"}
        is_it = same(drop_labels(sample["x"]), drop_labels(expected))
        assert same(r.sample_output, 1 if is_it else 0)
        assert str(r.sample_output) == r.invariant_str
    assert any(r.sample_output == 1 for r in d.regions)


@pytest.mark.xfail(strict=True, reason='region samples can drop inline-record labels: A {x = 6; y = ""} comes back as A (6, "")')
def test_region_sample_inline_record_labels(client: Client):
    assert client.eval_src("let a_x (v: var_t) = match v with A {x; _} -> if x > 5 then 1 else 0 | _ -> 2").success
    d = client.decompose("a_x", prune=True).decomposition
    assert d is not None
    samples = [r.sample["v"] for r in d.regions if r.sample is not None]
    as_ = [s for s in samples if isinstance(s, Constructed) and s.name == "A"]
    assert len(as_) == 2
    assert all(len(a.args) == 1 and isinstance(a.args[0], dict) for a in as_)
