"""Property tests for `Term.to_python`, without a server

They build random values as raw MIR terms, in the shapes the server sends, and check what
`to_python` makes of them. `tests/api/py/test_to_python.py` checks fixed values against the server.
"""

from hypothesis import given
from hypothesis import strategies as st

from imandrax_api import lib
from imandrax_api.v2.mir import DB, Constructed, PyValue, Uid, term_of_lib


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


INT, BOOL, STRING, REAL, UNIT = (ty(n) for n in ["int", "bool", "string", "real", "unit"])
REC_T, VAR_T, NEST_T = ty("rec_t"), ty("var_t"), ty("nest_t")


def raw_db() -> DB:
    """A DB with the definitions of `var_t` and `nest_t`, of these types the raw terms stand for:

    type rec_t = { a: int; b: bool list }
    type var_t = A of { x: int; y: string } | B of int * string | C
    type nest_t = N of { inner: var_t; k: int } | M
    """
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


# One of the types above, or ("list" | "option" | "tuple", argument types)
type Ty = str | tuple[str, tuple[Ty, ...]]

types: st.SearchStrategy[Ty] = st.recursive(
    st.sampled_from(["int", "bool", "string", "real", "unit", "rec_t", "var_t", "nest_t"]),
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
    """Constructor `c` applied to an inline record of `fields`

    The arguments are in declaration order, with or without labels, as the server sends them."""
    vs = {k: draw(s) for k, s in fields.items()}
    labels = None if drop_labels and draw(st.booleans()) else list(vs)
    return (
        construct(c, [x for x, _ in vs.values()], t, labels),
        Constructed(c, ({k: v for k, (_, v) in vs.items()},)),
    )


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
