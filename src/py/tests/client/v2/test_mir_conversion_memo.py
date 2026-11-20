"""Test that converting lib data keeps the sharing of MIR terms and types

The twine decoder returns one lib object for every reference to a shared term or type, so the
lib data is a graph. Converting it should give one client object per lib object, instead of
expanding the graph into a tree.

The lib data is built by hand, sharing objects the way the decoder does.
"""

from typing import Any

import pytest

from imandrax_api import lib
from imandrax_api.v2._lib_memo import lib_memo
from imandrax_api.v2.mir import (
    DB,
    Apply,
    ArrowType,
    Decomposition,
    FunctionDeclaration,
    Uid,
    term_of_lib,
)
from imandrax_api.v2.proof import DeductionProof, proof_term_of_lib


def mk_uid(name: str) -> lib.Uid:
    return lib.Uid(name=name, view=lib.Uid_view_Persistent())


def mk_constr(name: str) -> lib.Mir_Type:
    return lib.Mir_Type(view=lib.Ty_view_view_Constr(args=(mk_uid(name), [])))


def mk_arrow(dom: lib.Mir_Type, cod: lib.Mir_Type) -> lib.Mir_Type:
    return lib.Mir_Type(view=lib.Ty_view_view_Arrow(args=(None, dom, cod)))


def mk_var(v: lib.Mir_Var) -> lib.Mir_Term:
    return lib.Mir_Term(view=lib.Mir_Term_view_Var(arg=v), ty=v.ty, sub_anchor=None)


def mk_app(f: lib.Mir_Term, *args: lib.Mir_Term, ty: lib.Mir_Type) -> lib.Mir_Term:
    return lib.Mir_Term(
        view=lib.Mir_Term_view_Apply(f=f, l=list(args)), ty=ty, sub_anchor=None
    )


INT = mk_constr("int")
BOOL = mk_constr("bool")
X_VAR: lib.Mir_Var = lib.Common_Var_t_poly(id=mk_uid("x"), ty=INT)
X = mk_var(X_VAR)
LT = mk_var(
    lib.Common_Var_t_poly(id=mk_uid("<"), ty=mk_arrow(INT, mk_arrow(INT, BOOL)))
)
X_LT_X = mk_app(LT, X, X, ty=BOOL)
"""`x < x`: `x` is referenced twice, and `int` four times"""


# Terms
# ====================


def test_term_shares_subterms_and_types() -> None:
    t = term_of_lib(X_LT_X)
    assert isinstance(t, Apply)
    x1, x2 = t.arguments
    assert x1 is x2, "`x` should convert once"
    lt_type = t.function.type
    assert isinstance(lt_type, ArrowType)
    assert lt_type.domain is x1.type, "`int` should convert once"


def test_separate_conversions_dont_share() -> None:
    """The memo is per conversion: converting the same lib term twice gives two client terms"""
    assert term_of_lib(X_LT_X) is not term_of_lib(X_LT_X)


# Decomp
# ====================


def mk_region(*constraints: lib.Mir_Term) -> lib.Mir_Region_Region:
    return lib.Common_Region_t_poly(
        constraints=list(constraints),
        invariant=X,
        meta=[],
        status=lib.Common_Region_status_Unknown(),
    )


def test_decomposition_shares_across_regions() -> None:
    d = Decomposition.of_lib(
        lib.Common_Fun_decomp_t_poly(
            f_id=mk_uid("f"),
            f_args=[X_VAR],
            regions=[mk_region(X_LT_X), mk_region(X_LT_X, X_LT_X)],
        )
    )
    r1, r2 = d.regions
    assert r1.constraints[0] is r2.constraints[0] is r2.constraints[1]
    assert r1.invariant is r2.invariant
    assert d.arguments[0].type is r1.invariant.type


# Proof term
# ====================


def mk_assume(
    concl: lib.Mir_Term, id: int
) -> lib.Proof_Proof_term_t_poly[lib.Mir_Term, lib.Mir_Type]:
    return lib.Proof_Proof_term_t_poly(
        id=id,
        concl=lib.Common_Sequent_t_poly(hyps=[], concls=[(None, concl)]),
        view=lib.Proof_View_T_assume(),
    )


def test_proof_term_shares_across_steps() -> None:
    p = proof_term_of_lib(
        lib.Proof_Proof_term_t_poly(
            id=0,
            concl=lib.Common_Sequent_t_poly(hyps=[], concls=[(None, X_LT_X)]),
            view=lib.Proof_View_T_deduction(
                premises=[("p", [mk_assume(X_LT_X, 1), mk_assume(X_LT_X, 2)])]
            ),
        )
    )
    assert isinstance(p, DeductionProof)
    ((_, (p1, p2)),) = p.premises
    concls = [q.conclusion.conclusions[0][1] for q in (p, p1, p2)]
    assert concls[0] is concls[1] is concls[2]


# DB
# ====================


def mk_fun(name: str, body: lib.Mir_Term) -> lib.Mir_Decl:
    return lib.Common_Decl_t_poly_Fun(
        arg=lib.Common_Fun_def_t_poly(
            f_name=mk_uid(name),
            f_ty=lib.Common_Type_schema_t_poly(params=[], ty=mk_arrow(INT, BOOL)),
            f_args=[X_VAR],
            f_body=body,
            f_clique=None,
            f_kind=lib.Common_Fun_def_fun_kind_Fun_defined(
                is_macro=False, from_lambda=False
            ),
            f_hints=lib.Common_Hints_t_poly(
                f_validate_strat=lib.Common_Hints_validation_strategy_VS_no_validate(),
                f_unroll_def=None,
                f_enable=[],
                f_disable=[],
                f_timeout=None,
                f_admission=None,
                f_decomp=None,
            ),
        )
    )


def mk_db(monkeypatch: pytest.MonkeyPatch, *decls: lib.Mir_Decl) -> DB:
    """A DB of one operation adding `decls`, bypassing the twine decoding of the operation"""
    op = lib.Common_Db_op_t_poly_Op_add_decls(arg=list(decls))

    class Decoder:
        def __init__(self, _: bytes) -> None:
            pass

        def entrypoint(self) -> int:
            return 0

    monkeypatch.setattr(lib.twine, "Decoder", Decoder)

    def of_twine(**_: Any) -> Any:
        return op

    monkeypatch.setattr(lib, "Common_Db_op_t_poly_of_twine", of_twine)
    ds: lib.Mir_Db_ser = lib.Common_Db_ser_t_poly[lib.Mir_Term, lib.Mir_Type](
        ops=[lib.Ca_store_Ca_ptr_Raw(key="op")]
    )
    return DB(ds, {"op": b""})


def test_db_shares_across_declarations(monkeypatch: pytest.MonkeyPatch) -> None:
    db = mk_db(monkeypatch, mk_fun("f", X_LT_X), mk_fun("g", X_LT_X))
    f, g = db.decls[Uid(mk_uid("f"))], db.decls[Uid(mk_uid("g"))]
    assert isinstance(f, FunctionDeclaration)
    assert isinstance(g, FunctionDeclaration)
    assert f.function.body is g.function.body
    assert isinstance(g_type := g.function.type, ArrowType)
    assert f.function.arguments[0].type is g_type.domain


def test_db_shares_across_lookups(monkeypatch: pytest.MonkeyPatch) -> None:
    """`decls` and `find_function` convert lazily, at different times, with the DB's one memo"""
    db = mk_db(monkeypatch, mk_fun("f", X_LT_X))
    uid = Uid(mk_uid("f"))
    fun = db.find_function(uid)
    assert lib_memo.get() is None
    decl = db.decls[uid]
    assert isinstance(decl, FunctionDeclaration)
    assert fun is not None
    assert fun.body is decl.function.body


# Memo lifetime
# ====================


def test_memo_is_released_after_conversion() -> None:
    """The memo lives only while a conversion runs, so it keeps no lib object alive"""
    assert lib_memo.get() is None
    term_of_lib(X_LT_X)
    assert lib_memo.get() is None
    Decomposition.of_lib(
        lib.Common_Fun_decomp_t_poly(f_id=mk_uid("f"), f_args=[], regions=[mk_region()])
    )
    assert lib_memo.get() is None
