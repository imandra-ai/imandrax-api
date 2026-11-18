"""`imandrax_api.v1` clients against a server: eval, artifacts, decompositions, system RPCs

Every test runs with both `Client` and `AsyncClient`, the latter through `Blocking`.
"""

import asyncio
import inspect
import io
import time
import zipfile
from collections.abc import Iterator
from typing import Any, cast

import pytest

import imandrax_api.lib as xtypes
from imandrax_api.bindings import utils_pb2
from imandrax_api.twirp.exceptions import TwirpServerException
from imandrax_api.v1 import AsyncClient, Client, decomp

SRC = "let f x = x + 1 ;;"


class Blocking:
    """`AsyncClient`, with its coroutine methods run to completion on `runner`"""

    def __init__(self, runner: asyncio.Runner, client: AsyncClient) -> None:
        self._runner = runner
        self._client = client

    def __getattr__(self, name: str) -> Any:
        attr = getattr(self._client, name)
        if not inspect.iscoroutinefunction(attr):
            return attr

        def run(*args: Any, **kwargs: Any) -> Any:
            return self._runner.run(attr(*args, **kwargs))

        return run


@pytest.fixture(scope="module", params=["sync", "async"])
def client(
    request: pytest.FixtureRequest, url: str, api_key: str | None
) -> Iterator[Client]:
    """A client whose session has `SRC` loaded"""
    if request.param == "sync":
        with Client(url, auth_token=api_key) as c:
            assert c.eval_src(src=SRC).success
            yield c
    else:
        # the constructor needs a running event loop
        async def open_client() -> AsyncClient:
            return await AsyncClient(url, auth_token=api_key).__aenter__()

        with asyncio.Runner() as runner:
            ac = runner.run(open_client())
            try:
                c = cast(Client, Blocking(runner, ac))
                assert c.eval_src(src=SRC).success
                yield c
            finally:
                runner.run(ac.__aexit__(None, None, None))


def unzip_one(art_zip: bytes) -> bytes:
    with zipfile.ZipFile(io.BytesIO(art_zip)) as zf:
        return zf.read(zf.namelist()[0])


def test_status(client: Client):
    assert client.status().msg


def test_theorem_artifacts(client: Client):
    res = client.eval_src(src="theorem yolo1 x = f x > x ;;")
    assert res.success, res.errors
    assert len(res.tasks) > 0

    task = res.tasks[0]
    art_po_task = client.get_artifact_zip(task, kind="po_task")
    art_po_res = client.get_artifact_zip(task, kind="po_res")
    assert len(art_po_task.ok.art_zip) > 0
    assert len(art_po_res.ok.art_zip) > 0

    assert (
        xtypes.read_artifact_data(
            data=unzip_one(art_po_task.ok.art_zip), kind="po_task"
        )
        is not None
    )
    assert (
        xtypes.read_artifact_data(data=unzip_one(art_po_res.ok.art_zip), kind="po_res")
        is not None
    )


def test_test_src(client: Client):
    found = client.test_src(src="fun x -> x = 42")
    assert len(found.counter_example.model.src) > 0

    not_found = client.test_src(src="fun x -> x = 42 || x <> 42")
    assert not_found.WhichOneof("res") == "err"
    assert not_found.errors[0].msg.msg.startswith("Did not find")


def test_decompose(client: Client):
    res = client.decompose(name="f", basis=None, ctx_simp=True, prune=False)
    assert res.err == utils_pb2.Empty()
    assert res.errors == []


def test_decompose_region_strings(client: Client):
    src = "let add_positive x y = if x > 0 && y > 0 then x + y else 0 ;;"
    assert client.eval_src(src=src).success

    res = client.decompose(
        name="add_positive", prune=True, string_results=True, timeout=30.0
    )
    assert res.HasField("artifact"), res.errors
    assert res.artifact.kind == "mir.fun_decomp"
    assert len(res.artifact.data) > 0

    regions = xtypes.get_region_str_from_decomp_artifact(
        data=res.artifact.data, kind=res.artifact.kind
    )
    assert len(regions) == 3
    for r in regions:
        assert r.invariant_str is not None
        assert r.model_str


def test_decompose_full(client: Client):
    d1 = client.decompose_full(decomp.by_name("f"))
    assert d1.WhichOneof("res") == "artifact", d1.errors
    assert d1.artifact.kind == "mir.fun_decomp"
    assert d1.task.id.id

    # a compound decomposition exercising the local-variable environment:
    # two simultaneous bindings, both referenced from the body
    assert client.eval_src(src="let g x = if x > 10 then x * 2 else x ;;").success
    d2 = client.decompose_full(
        decomp.let(
            [("a", decomp.by_name("f")), ("b", decomp.by_name("g"))],
            decomp.merge(decomp.get("a"), decomp.get("b")),
        ),
        string_results=True,
        compute_timeout=10,
    )
    assert d2.WhichOneof("res") == "artifact", d2.errors
    assert d2.errors == []

    # an unbound variable must be reported, which is what shows the bindings
    # above are actually being resolved rather than ignored
    d3 = client.decompose_full(
        decomp.let([("a", decomp.by_name("f"))], decomp.get("no_such_var"))
    )
    assert d3.WhichOneof("res") == "err", d3
    assert "no_such_var" in d3.errors[0].msg.msg, d3.errors


def test_verify_and_instance_name(client: Client):
    assert client.eval_src(
        src="let good x = f x > x ;; let bad x = f x > x + 5 ;;"
    ).success

    v_ok = client.verify_name(name="good")
    assert v_ok.WhichOneof("res") == "proved", v_ok

    v_bad = client.verify_name(name="bad")
    assert v_bad.WhichOneof("res") == "refuted", v_bad
    assert len(v_bad.refuted.model.src) > 0

    i_ok = client.instance_name(name="good")
    assert i_ok.WhichOneof("res") == "sat", i_ok
    assert len(i_ok.sat.model.src) > 0


def test_get_decls(client: Client):
    decls = client.get_decls(["f"])
    assert [d.name for d in decls.decls] == ["f"]
    assert not decls.decls[0].HasField("str"), "str should be unset by default"

    assert client.get_decls(["f"], include_str=True).decls[0].str

    assert list(client.get_decls(["no_such_decl"]).not_found) == ["no_such_decl"]


def test_eval_src_async_only(client: Client):
    res = client.eval_src(src="theorem async_thm x = f x > x ;;", async_only=True)
    assert res.success, res.errors
    assert len(res.tasks) == 1
    # the point of async_only: tasks are started but not awaited
    assert len(res.po_results) == 0

    task = res.tasks[0]
    for _ in range(20):
        if "po_res" in client.list_artifacts(task).ok.kinds:
            break
        time.sleep(0.5)
    else:
        raise AssertionError("po_res artifact never became available")

    art = client.get_artifact(task, kind="po_res")
    assert art.WhichOneof("result") == "ok", art.error
    assert art.ok.kind == "po_res"
    assert xtypes.read_artifact_data(data=art.ok.data, kind="po_res") is not None


def test_eval_src_task_filter(client: Client):
    filtered = client.eval_src(
        src="theorem keepme_a x = f x > x ;; theorem other_b x = f x > x ;;",
        task_filter=["*keepme*"],
    )
    assert filtered.success, filtered.errors
    assert len(filtered.tasks) == 1

    unfiltered = client.eval_src(
        src="theorem both_c x = f x > x ;; theorem both_d x = f x > x ;;"
    )
    assert len(unfiltered.tasks) == 2


def test_oneshot(client: Client):
    # self-contained: does not touch the session
    res = client.oneshot(input="let g x = x + 1 ;; theorem t x = g x > x ;;")
    assert list(res.errors) == []
    assert len(res.results) == 2
    assert all("ok" in r for r in res.results), list(res.results)
    assert res.stats.time >= 0

    assert list(client.oneshot(input="1 + 1 ;;", compute_timeout=5.0).errors) == []


def test_code_snippets(client: Client):
    snip = client.eval_code_snippet(code="theorem snip_thm x = f x > x ;;")
    assert len(snip.tasks) == 1
    assert list(snip.errors) == []

    term = client.parse_term(code="1 + 1")
    assert term.WhichOneof("result") == "ok", term.error
    assert term.ok.kind == "term"
    assert len(term.ok.data) > 0

    ty = client.parse_type(code="int list")
    assert ty.WhichOneof("result") == "ok", ty.error
    assert ty.ok.kind == "ty"
    assert len(ty.ok.data) > 0


def test_session_lifecycle(client: Client):
    assert client.session_id
    client.keep_session_alive()
    # still usable afterwards
    assert client.eval_src(src="let after_keepalive x = x ;;").success


def test_system(client: Client):
    assert client.version().version
    assert client.gc_stats().heap_size_B > 0

    # release_memory is privileged, and the cloud currently rejects it with a
    # generic internal error. Accept either outcome rather than pinning down
    # server-side policy -- what we check here is that the RPC is *routed*:
    # a wrong path comes back as a 404 from the intermediary, whose body is a
    # bare string rather than a twirp error dict.
    try:
        assert client.release_memory().heap_size_B > 0
    except TwirpServerException as ex:
        meta: dict[str, Any] = getattr(ex, "meta", None) or {}
        body: Any = meta.get("body")
        assert isinstance(body, dict), f"release_memory was not routed: {meta}"
        msg: Any = cast(dict[str, Any], body).get("msg")
        assert "not authorized" in (msg or ""), body
