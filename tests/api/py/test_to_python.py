#!/usr/bin/env python3
# pyright: basic
"""Test `to_python` on terms, models and region samples from the server, for fixed values.

`tests/client/py/v2/test_to_python.py` tests `to_python` on random values without a server.
"""

import os
import sys
from collections.abc import Callable, Iterator
from fractions import Fraction

import imandrax_api
from imandrax_api.v2.interface import Client, DecompositionTask, InstanceResponse
from imandrax_api.v2.mir import DB, Constructed, Decomposition, Model, PyValue

TYPES = """
type rec_t = { a: int; b: bool list }
type var_t = A of { x: int; y: string } | B of int * string | C
type nest_t = N of { inner: var_t; k: int } | M
"""

# The labels of the inline records in `TYPES`, by constructor
INLINE_RECORDS = {"A": {"x", "y"}, "N": {"inner", "k"}}

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

# Values that only `parse_term` gets right: the server mangles non-ASCII and NUL in model strings
PARSE_ONLY_EXAMPLES: list[tuple[str, str, PyValue]] = [
    ("string", '"\\xc3\\xa9\\x00"', "é\x00"),
]

# Values that are not literals, so `parse_term` gives no value, but models do
MODEL_ONLY_EXAMPLES: list[tuple[str, str, PyValue]] = [
    ("real", "(1.0 /. 3.0)", Fraction(1, 3)),
]


def check(actual: PyValue | None, expected: PyValue | None, what: str) -> None:
    # `repr`, unlike `==`, tells `True` from `1`
    assert repr(actual) == repr(expected), f"{what}: got {actual!r}, expected {expected!r}"


def raises_value_error(f: Callable[[], object], match: str) -> None:
    try:
        f()
    except ValueError as e:
        assert match in str(e), f"unexpected error: {e}"
    else:
        raise AssertionError(f"expected a ValueError with {match!r}")


def model_of(c: Client, src: str) -> Model:
    r = c.instance_src(src)
    assert isinstance(r.res, InstanceResponse.Sat) and r.res.instance is not None, r.errors
    model = r.res.instance.model
    assert model is not None, f"no model for {src}"
    return model


def decompose(c: Client, f: str, src: str, string_results: bool = False) -> tuple[Decomposition, DB]:
    """The decomposition of `f`, defined by `src`, and its DB"""
    assert c.eval_src(src).success, f"eval_src failed: {src}"
    res = c.decompose(f, prune=True, string_results=string_results)
    assert res.decomposition is not None, res.errors
    assert isinstance(res.task, DecompositionTask)
    return res.decomposition, res.task.db


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


def main():
    url = imandrax_api.url_dev
    auth_token = os.environ.get("IMANDRAX_API_KEY")
    if auth_token is None:
        auth_path = os.path.expanduser("~/.config/imandrax/api_key")

        try:
            with open(auth_path, "r") as f:
                auth_token = f.read().strip()
        except Exception:
            pass
    if auth_token is None:
        print(f"ERROR: API key is not set and could not be from {auth_path}")
        sys.exit(1)

    with Client(url=url, api_key=auth_token, timeout=120) as c:
        assert c.eval_src(TYPES).success, "eval_src of TYPES failed"

        print("1. parse_term")
        for ty, src, expected in EXAMPLES + PARSE_ONLY_EXAMPLES:
            check(c.parse_term(f"({src} : {ty})").to_python(), expected, src)

        print("2. instance models")
        for ty, src, expected in EXAMPLES + MODEL_ONLY_EXAMPLES:
            check(model_of(c, f"fun (x: {ty}) -> x = ({src} : {ty})").to_python(), {"x": expected}, src)

        print("3. non-values")
        raises_value_error(lambda: c.parse_term("Map.const 0 |> Map.add 1 2").to_python(), "Not a value")
        irrational = model_of(c, "fun (x: real) -> x *. x = 2.0 && x >. 0.0")
        raises_value_error(irrational.to_python, "irrational")

        print("4. region samples, outputs and strings")
        for i, (ty, src, expected) in enumerate(EXAMPLES + MODEL_ONLY_EXAMPLES):
            f = f"is_it_{i}"
            d, db = decompose(c, f, f"let {f} (x: {ty}) = if x = ({src} : {ty}) then 1 else 0", string_results=True)
            for r in d.regions:
                assert r.constraints_str is not None and len(r.constraints_str) == len(r.constraints)
                assert r.invariant_str in ("0", "1")
                sample = r.sample(db)
                assert sample is not None and sample.keys() == {"x"}
                output = r.sample_output(db)
                check(output, 1 if repr(sample["x"]) == repr(expected) else 0, src)
                assert str(output) == r.invariant_str
            assert any(r.sample_output(db) == 1 for r in d.regions), f"no region with output 1 for {src}"

        print("5. inline records nested in region samples")
        # in a list, an option, a tuple, and in another inline record
        d, db = decompose(c, "nested_inline", """
let nested_inline (v: var_t option list) (p: var_t * int) (n: nest_t) =
  match v, p, n with
  | [Some (A {x; _})], (A _, _), N {inner = A {x = x2; _}; k} -> if x > 5 && x2 > k then 1 else 0
  | _ -> 2""")
        samples = [s for r in d.regions if (s := r.sample(db)) is not None]
        assert len(samples) == len(d.regions)
        for s in samples:
            bad = [k for k in constructeds(s) if not has_labels(k)]
            assert not bad, bad
        (hit,) = [r for r in d.regions if r.sample_output(db) == 1]
        match hit.sample(db):
            case {
                "v": [Constructed("Some", (Constructed("A", ({"x": int(x), "y": str()},)),))],
                "p": (Constructed("A", ({"x": int(), "y": str()},)), int()),
                "n": Constructed("N", ({"inner": Constructed("A", ({"x": int(x2), "y": str()},)), "k": int(k)},)),
            }:
                assert x > 5 and x2 > k
            case other:
                raise AssertionError(f"unexpected sample {other}")

        print("6. region outputs of the identity")
        # `let f x = x` returns its sample: given the DB, both come back the same, labels included
        for i, ty in enumerate(sorted({ty for ty, _, _ in EXAMPLES})):
            f = f"same_{i}"
            d, db = decompose(c, f, f"let {f} (x: {ty}) = x")
            for r in d.regions:
                sample = r.sample(db)
                assert sample is not None and sample.keys() == {"x"}
                check(r.sample_output(db), sample["x"], ty)
                assert all(has_labels(k) for k in constructeds(sample["x"])), sample

        print("7. region outputs that pass inline records through")
        # a result that contains part of the sample has the same labels as the sample, given the DB
        d, db = decompose(c, "pass_through", """
let pass_through (v: var_t * nest_t) =
  match v with
  | (A {x; _}, N {inner = A _; k}) -> if x > k then Some v else None
  | _ -> None""")
        outputs = [(r.sample(db), r.sample_output(db)) for r in d.regions]
        passed_through = [(s, o) for s, o in outputs if isinstance(o, Constructed) and o.name == "Some"]
        assert len(passed_through) == 1
        ((sample, output),) = passed_through
        assert sample is not None
        check(output, Constructed("Some", (sample["v"],)), "pass_through")
        assert all(has_labels(k) for k in constructeds(output)), output

    print("PASSED")


if __name__ == "__main__":
    main()
