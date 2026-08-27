#!/usr/bin/env python3
# pyright: basic
"""Test imandrax_api Python client: eval, artifacts, parsing."""

import asyncio
import io
import os
import sys
import zipfile

import imandrax_api
import imandrax_api.lib as xtypes
from imandrax_api.client import decomp
from imandrax_api.twirp.exceptions import TwirpServerException


async def main():
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

    async with imandrax_api.AsyncClient(url, auth_token=auth_token) as c:
        print("1. status")
        status = await c.status()
        assert status.msg, "status should return message"

        print("2. eval_src")
        x1 = await c.eval_src(src="let f x=x+1 ;;")
        assert x1.success, f"eval_src failed: {x1.errors}"

        print("3. theorem")
        x2 = await c.eval_src(src="theorem yolo1 x = f x > x ;;")
        assert x2.success, f"theorem failed: {x2.errors}"
        assert len(x2.tasks) > 0, "no tasks returned"

        task = x2.tasks[0]

        print("4. get artifacts")
        art_po_task = await c.get_artifact_zip(task, kind="po_task")
        art_po_res = await c.get_artifact_zip(task, kind="po_res")

        assert len(art_po_task.art_zip) > 0, "po_task artifact is empty"
        assert len(art_po_res.art_zip) > 0, "po_res artifact is empty"

        print("5. parse artifacts")
        # Extract from zip
        with zipfile.ZipFile(io.BytesIO(art_po_task.art_zip)) as zf:
            art_task_data = zf.read(zf.namelist()[0])
        with zipfile.ZipFile(io.BytesIO(art_po_res.art_zip)) as zf:
            art_res_data = zf.read(zf.namelist()[0])

        art_task = xtypes.read_artifact_data(data=art_task_data, kind="po_task")
        art_res = xtypes.read_artifact_data(data=art_res_data, kind="po_res")
        assert art_task is not None, "failed to parse po_task"
        assert art_res is not None, "failed to parse po_res"

        print("6. decomp")
        x4 = await c.decompose(name="f", basis=None, ctx_simp=True, prune=False)
        assert x4.err == imandrax_api.bindings.utils_pb2.Empty()
        assert x4.errors == []

        print("7. decompose_full")
        d1 = await c.decompose_full(decomp.by_name("f"))
        assert d1.WhichOneof("res") == "artifact", f"decompose_full failed: {d1.errors}"
        assert d1.artifact.kind == "mir.fun_decomp"
        assert d1.task.id.id, "no task id returned"

        # a compound decomposition exercising the local-variable environment:
        # two simultaneous bindings, both referenced from the body
        x_g = await c.eval_src(src="let g x = if x > 10 then x * 2 else x ;;")
        assert x_g.success, f"eval_src failed: {x_g.errors}"

        d2 = await c.decompose_full(
            decomp.let(
                [("a", decomp.by_name("f")), ("b", decomp.by_name("g"))],
                decomp.merge(decomp.get("a"), decomp.get("b")),
            ),
            string_results=True,
            compute_timeout=10,
        )
        assert d2.WhichOneof("res") == "artifact", (
            f"compound decompose failed: {d2.errors}"
        )
        assert d2.errors == []

        # an unbound variable must be reported, which is what shows the bindings
        # above are actually being resolved rather than ignored
        d3 = await c.decompose_full(
            decomp.let([("a", decomp.by_name("f"))], decomp.get("no_such_var"))
        )
        assert d3.WhichOneof("res") == "err", f"expected err, got {d3}"
        assert "no_such_var" in d3.errors[0].msg.msg, f"unexpected error: {d3.errors}"

        print("8. verify_name / instance_name")
        x5 = await c.eval_src(src="let good x = f x > x ;; let bad x = f x > x + 5 ;;")
        assert x5.success, f"eval_src failed: {x5.errors}"

        v_ok = await c.verify_name(name="good")
        assert v_ok.WhichOneof("res") == "proved", f"expected proved, got {v_ok}"

        v_bad = await c.verify_name(name="bad")
        assert v_bad.WhichOneof("res") == "refuted", f"expected refuted, got {v_bad}"
        assert len(v_bad.refuted.model.src) > 0, "expected a non-empty counter-example"

        i_ok = await c.instance_name(name="good")
        assert i_ok.WhichOneof("res") == "sat", f"expected sat, got {i_ok}"
        assert len(i_ok.sat.model.src) > 0, "expected a non-empty instance"

        print("9. get_decls")
        decls = await c.get_decls(["f"])
        assert len(decls.decls) == 1, "expected one decl"
        assert decls.decls[0].name == "f"
        assert not decls.decls[0].HasField("str"), "str should be unset by default"

        decls_str = await c.get_decls(["f"], include_str=True)
        assert decls_str.decls[0].str, "expected a string representation"

        missing = await c.get_decls(["no_such_decl"])
        assert list(missing.not_found) == ["no_such_decl"]

        print("10. eval_src async_only + get_artifact")
        x6 = await c.eval_src(src="theorem async_thm x = f x > x ;;", async_only=True)
        assert x6.success, f"async eval_src failed: {x6.errors}"
        assert len(x6.tasks) == 1, "expected exactly one task"
        # the point of async_only: tasks are started but not awaited
        assert len(x6.po_results) == 0, "async_only should not return PO results"

        async_task = x6.tasks[0]
        for _ in range(20):
            kinds = (await c.list_artifacts(async_task)).kinds
            if "po_res" in kinds:
                break
            await asyncio.sleep(0.5)
        else:
            raise AssertionError("po_res artifact never became available")

        art = await c.get_artifact(async_task, kind="po_res")
        assert art.art.kind == "po_res", f"unexpected kind {art.art.kind}"
        assert len(art.art.data) > 0, "po_res artifact is empty"
        async_res = xtypes.read_artifact_data(data=art.art.data, kind="po_res")
        assert async_res is not None, "failed to parse async po_res"

        print("11. eval_src task_filter")
        x7 = await c.eval_src(
            src="theorem keepme_a x = f x > x ;; theorem other_b x = f x > x ;;",
            task_filter=["*keepme*"],
        )
        assert x7.success, f"filtered eval_src failed: {x7.errors}"
        assert len(x7.tasks) == 1, (
            f"task_filter should start one task, got {len(x7.tasks)}"
        )

        x8 = await c.eval_src(
            src="theorem both_c x = f x > x ;; theorem both_d x = f x > x ;;"
        )
        assert len(x8.tasks) == 2, f"expected both tasks, got {len(x8.tasks)}"

        print("12. oneshot")
        # self-contained: does not touch the session
        x9 = await c.oneshot(input="let g x = x + 1 ;; theorem t x = g x > x ;;")
        assert list(x9.errors) == [], f"oneshot failed: {x9.errors}"
        assert len(x9.results) == 2, f"expected two results, got {list(x9.results)}"
        assert all("ok" in r for r in x9.results), (
            f"expected all ok: {list(x9.results)}"
        )
        assert x9.stats.time >= 0

        x10 = await c.oneshot(input="1 + 1 ;;", compute_timeout=5.0)
        assert list(x10.errors) == [], f"oneshot failed: {x10.errors}"

        print("13. code snippets")
        snip = await c.eval_code_snippet(code="theorem snip_thm x = f x > x ;;")
        assert len(snip.tasks) == 1, "expected one task from snippet"
        assert list(snip.errors) == [], f"snippet eval failed: {snip.errors}"

        term = await c.parse_term(code="1 + 1")
        assert term.art.kind == "term", f"unexpected kind {term.art.kind}"
        assert len(term.art.data) > 0, "term artifact is empty"

        ty = await c.parse_type(code="int list")
        assert ty.art.kind == "ty", f"unexpected kind {ty.art.kind}"
        assert len(ty.art.data) > 0, "type artifact is empty"

        print("14. session lifecycle")
        assert c.session_id, "expected a session id"
        await c.keep_session_alive()
        # still usable afterwards
        assert (await c.eval_src(src="let after_keepalive x = x ;;")).success

        print("15. system")
        ver = await c.version()
        assert ver.version, "expected a version string"

        gc = await c.gc_stats()
        assert gc.heap_size_B > 0, "expected a non-empty heap"

        # release_memory is privileged, and the cloud currently rejects it with a
        # generic internal error. Accept either outcome rather than pinning down
        # server-side policy -- what we check here is that the RPC is *routed*:
        # a wrong path comes back as a 404 from the intermediary, whose body is a
        # bare string rather than a twirp error dict.
        try:
            rm = await c.release_memory()
            assert rm.heap_size_B > 0, "expected a non-empty heap"
            print("    release_memory: authorized")
        except TwirpServerException as ex:
            body = (getattr(ex, "meta", None) or {}).get("body")
            assert isinstance(body, dict), f"release_memory was not routed: {ex.meta}"
            assert "not authorized" in (body.get("msg") or ""), (
                f"unexpected release_memory error: {body}"
            )
            print("    release_memory: not authorized (expected on cloud)")

    print("PASSED")


if __name__ == "__main__":
    asyncio.run(main())
