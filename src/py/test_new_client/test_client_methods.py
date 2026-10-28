import asyncio
import inspect
import os
import zipfile
from collections.abc import Iterator
from io import BytesIO

import pytest
from inline_snapshot import snapshot

import imandrax_api
from imandrax_api.client import decomp
from imandrax_api.demo.interface import (
    Artifact,
    AsyncClient,
    Client,
    CodeSnippetResult,
    DecompositionResult,
    DecompositionTask,
    EvalSrcResponse,
    EvalStatus,
    InstanceResult,
    ModelKind,
    ModelOutput,
    OneshotResult,
    ProofObligationResult,
    ProofObligationTask,
    ServerVersion,
    TestResult,
    TypecheckResult,
    VerifyResult,
)
from imandrax_api.demo.mir import ArrowType, Term, Type

SRC = """
let f x = if x > 0 then x + 1 else 0
let nonneg x = f x >= 0
"""


def api_key() -> str | None:
    return os.environ.get("IMANDRAX_API_KEY") or os.environ.get("IMANDRA_UNI_KEY")


def mk_client() -> Client:
    return Client(url=imandrax_api.url_prod, api_key=api_key())


def mk_async_client() -> AsyncClient:
    return AsyncClient(url=imandrax_api.url_prod, api_key=api_key())


@pytest.fixture(scope="module")
def client() -> Iterator[Client]:
    """A client whose session has `SRC` loaded"""
    with mk_client() as c:
        assert c.eval_src(SRC).success
        yield c


# Session and server
# ==================


def test_session_and_sys_client(client: Client):
    _ = client.session_id
    assert client.keep_session_alive() is None

    v = client.version()
    assert isinstance(v, ServerVersion)
    assert v.version


# eval_src
# ========


def test_eval_src_async_only_and_task_filter(client: Client):
    src = "theorem t1 x = x + 1 > x\ntheorem t2 x = x * 1 = x"
    rsp: EvalSrcResponse = client.eval_src(src, async_only=True, task_filter=["t1"])
    assert rsp.success is True
    pos = [t for t in rsp.tasks if isinstance(t, ProofObligationTask)]
    assert len(pos) == 1, "expect: 1 PO task"
    assert [po.from_sym for po in pos] == ["t1"]
    # Not waited for when async_only=True
    assert rsp.po_results == ()


def test_eval_src_po_results(client: Client):
    src = """theorem good x = x + 1 > x
theorem bad x = x > 0"""
    good, bad = client.eval_src(src).po_results

    assert good.origin.from_sym == "good"
    assert isinstance(good.res, ProofObligationResult.Proof)
    assert good.outcome == "proof"
    assert good.errors == ()

    assert bad.origin.from_sym == "bad"
    assert isinstance(bad.res, ProofObligationResult.Instance)
    assert bad.outcome == "instance"
    cx: ModelOutput | None = bad.res.model
    assert cx is not None
    assert cx.kind == ModelKind.COUNTER_EXAMPLE
    assert "x = 0" in cx.src
    (e,) = bad.errors
    assert "counter-satisfiable" in str(e)


# Verify, instance and test
# =========================


def test_verify_name_proved(client: Client):
    r: VerifyResult = client.verify_name("nonneg")
    assert isinstance(r.res, VerifyResult.Proved)
    assert r.outcome == "proved"
    assert r.proved and not r.refuted
    assert r.counter_example is None
    assert r.errors == ()


def test_verify_src_refuted(client: Client):
    r: VerifyResult = client.verify_src("fun x -> f x > 0")
    assert r.outcome == "refuted"
    assert r.refuted and not r.proved
    assert r.proof_pp is None

    assert isinstance(r.res, VerifyResult.Refuted)

    cx: ModelOutput | None = r.counter_example
    assert cx is not None
    assert cx.kind == ModelKind.COUNTER_EXAMPLE
    assert "x = 0" in cx.src

    assert cx.model is not None


def test_instance_src_sat(client: Client):
    r: InstanceResult = client.instance_src("fun x -> f x = 5")
    assert isinstance(r.res, InstanceResult.Sat)
    assert r.outcome == "sat"
    assert r.found
    inst: ModelOutput | None = r.instance
    assert inst is not None
    assert inst.kind == ModelKind.INSTANCE
    assert "x = 4" in inst.src

    assert inst.model is not None


def test_instance_src_unsat(client: Client):
    r: InstanceResult = client.instance_src("fun x -> f x < 0")
    assert isinstance(r.res, InstanceResult.Unsat)
    assert r.outcome == "unsat"
    assert not r.found
    assert r.instance is None


def test_instance_name(client: Client):
    r = client.instance_name("nonneg")
    assert r.found


def test_test_src_counter_example(client: Client):
    r: TestResult = client.test_src("fun x -> f x > 0", seed=1)
    assert isinstance(r.res, TestResult.CounterExample)
    assert r.outcome == "counter_example"
    cx = r.counter_example
    assert cx is not None
    assert "x = 0" in cx.src


def test_test_name_no_counter_example(client: Client):
    r: TestResult = client.test_name("nonneg", seed=1)
    assert r.res == TestResult.Err()
    assert r.outcome == "err"
    assert r.counter_example is None
    (e,) = r.errors
    assert e.kind == "NoCounterExample"


# Decomposition
# =============


def test_decompose(client: Client):
    r: DecompositionResult = client.decompose("f")
    assert r.errors == ()
    assert isinstance(r.task, DecompositionTask)

    # TODO: more checks on regions
    art = r.artifact
    assert art is not None
    assert art.kind == "mir.fun_decomp"


def test_decompose_full(client: Client):
    # TODO: should exists a test for testing decomp combinators
    r = client.decompose_full(decomp.prune(decomp.by_name("f")))
    assert r.errors == ()
    assert r.artifact is not None


# Source and lookups
# ==================


def test_typecheck(client: Client):
    r = client.typecheck("let g y = y + 1")
    assert isinstance(r, TypecheckResult)
    assert r.success
    assert r.types == [{"name": "g", "ty": "int -> int", "line": 1, "column": 1}]


def test_typecheck_error(client: Client):
    r = client.typecheck("let g y = y + true")
    assert not r.success
    assert r.errors


def test_oneshot(client: Client):
    r: OneshotResult = client.oneshot("let h = 1")
    assert r.errors == ()
    assert len(r.results) == 1
    assert r.time_s >= 0


def test_eval_code_snippet(client: Client):
    r: CodeSnippetResult = client.eval_code_snippet("theorem snippet_thm x = f x >= 0")
    assert r.res == EvalStatus.OK
    assert r.errors == ()
    # Its result may not be available yet, similar to async_only=True
    (po,) = [t for t in r.tasks if isinstance(t, ProofObligationTask)]
    assert po.from_sym == "snippet_thm"


@pytest.mark.parametrize(
    ("code", "res", "kind"),
    [
        pytest.param("let = ", EvalStatus.ERRORS, "SyntaxErr", id="syntax-error"),
        # The server reports type errors with status `OK`, but a non-empty error list
        pytest.param("let bad = 1 + true", EvalStatus.OK, "TypeErr", id="type-error"),
    ],
)
def test_eval_code_snippet_error(client: Client, code: str, res: EvalStatus, kind: str):
    r = client.eval_code_snippet(code)
    assert r.res == res
    (e,) = r.errors
    assert kind in str(e)


def test_parse_term(client: Client):
    t: Term = client.parse_term("f 3 + 1")
    assert isinstance(t, Term)


def test_parse_type(client: Client):
    ty: Type = client.parse_type("int -> bool")
    assert isinstance(ty, ArrowType)


def test_parse_term_error_raises(client: Client):
    # TODO: an error should be returned in a result type?
    with pytest.raises(Exception, match="expected argument of type `int`"):
        client.parse_term("1 + true")


# Artifacts
# =========


def test_list_and_get_artifacts(client: Client):
    task = client.verify_name("nonneg").task
    kinds: list[str] = client.list_artifacts(task)
    assert set(kinds) == snapshot({"po_res", "po_task", "report", "show"})

    art = client.get_artifact(task, "po_res")
    assert isinstance(art, Artifact)
    assert art.kind == "po_res"

    zip_bytes = client.get_artifact_zip(task, "po_res")
    with zipfile.ZipFile(BytesIO(zip_bytes)) as z:
        assert "manifest.json" in z.namelist()


# AsyncClient
# ===========


def test_sync_async_client_parity():
    """Parity test: uses introspection to check that the sync and async clients expose the same public methods with matching signatures."""

    def public_members_of_type(cls: type) -> dict[str, object]:
        return {
            n: inspect.getattr_static(cls, n)
            for n in dir(cls)
            if not n.startswith("_") or n == "__init__"
        }

    sync = public_members_of_type(Client)
    async_ = public_members_of_type(AsyncClient)
    assert sorted(sync) == sorted(async_)

    for name, s in sync.items():
        a = async_[name]
        if isinstance(s, property):
            assert isinstance(a, property), name
            assert s.fget is not None and a.fget is not None
            s_ret = inspect.signature(s.fget).return_annotation
            a_ret = inspect.signature(a.fget).return_annotation
            if name == "session_id":
                # The async session is only created on `async with`
                assert a_ret == s_ret | None
            else:
                assert a_ret == s_ret, name
            continue

        assert callable(s) and callable(a), name
        if name != "__init__":
            assert not inspect.iscoroutinefunction(s), name
            assert inspect.iscoroutinefunction(a), name
        assert inspect.signature(a) == inspect.signature(s), name


def test_async_methods():
    async def main() -> None:
        async with mk_async_client() as c:
            assert c.session_id
            assert (await c.eval_src(SRC)).success
            await c.keep_session_alive()
            assert isinstance(await c.version(), ServerVersion)

            v = await c.verify_name("nonneg")
            assert v.proved
            assert (await c.verify_src("fun x -> f x > 0")).refuted
            assert (await c.instance_name("nonneg")).found
            assert (await c.instance_src("fun x -> f x = 5")).found
            assert (
                await c.test_src("fun x -> f x > 0", seed=1)
            ).counter_example is not None
            assert (await c.test_name("nonneg", seed=1)).outcome == "err"

            assert (await c.decompose("f")).artifact is not None
            assert (await c.decompose_full(decomp.by_name("f"))).artifact is not None

            assert (await c.typecheck("let g y = y + 1")).success
            assert (await c.oneshot("let h = 1")).errors == ()
            assert (await c.eval_code_snippet("let k = 2")).res == EvalStatus.OK
            assert isinstance(await c.parse_term("f 3"), Term)
            assert isinstance(await c.parse_type("int"), Type)

            assert "po_res" in await c.list_artifacts(v.task)
            assert (await c.get_artifact(v.task, "po_res")).kind == "po_res"
            assert await c.get_artifact_zip(v.task, "po_res")

    asyncio.run(main())
