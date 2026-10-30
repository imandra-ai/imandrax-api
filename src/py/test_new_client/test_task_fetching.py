"""Fetching task artifacts with `Client` and `AsyncClient`

- tasks hold only a weak reference to their client: fetching after the client is gone raises,
  but what was fetched before stays accessible, including attributes derived from it
- with an `AsyncClient`, artifacts are fetched with `await task.awaitable.<attribute>` or
  `await task.fetch_all()`; accessing them before raises `NotFetchedError`
"""

import asyncio
import gc
import weakref
from collections.abc import Callable
from typing import Any

import pytest

from imandrax_api.bindings import task_pb2
from imandrax_api.bindings.api_pb2 import ArtifactResult
from imandrax_api.demo.interface import (
    AsyncClient,
    Client,
    ClientGoneError,
    EvalSrcResponse,
    NoClientError,
    NotFetchedError,
    ProofObligation,
    ProofObligationTask,
    ProofObligationTaskResult,
    Task,
    task_of_raw,
)
from imandrax_api.demo.mir import DB

SRC = "theorem succ_gt x = x + 1 > x"


def get_the_task[T: Task](rsp: EvalSrcResponse, cls: type[T]) -> T:
    (t,) = [t for t in rsp.tasks if isinstance(t, cls)]
    return t


def assert_weak_ref_gone(ref: weakref.ref[Any]) -> None:
    """Collect garbage and check the object behind `ref` is gone"""
    gc.collect()
    assert ref() is None


# Tasks, without a server
# =======================


def test_task_without_client_raises_on_fetch():
    pb_task = task_pb2.Task(
        id=task_pb2.TaskID(id="task:test"), kind=task_pb2.TASK_CHECK_PO
    )
    t = task_of_raw(pb_task)
    assert isinstance(t, ProofObligationTask)

    with pytest.raises(NoClientError):
        _ = t.proof_obligation
    with pytest.raises(NoClientError):
        _ = t.result
    with pytest.raises(NoClientError):
        asyncio.run(t.fetch_all())


# Client
# ======


def test_task_equality(mk_client: Callable[[], Client]):
    """Tasks are equal when their ids are."""

    def mk_pb_task(
        id: str, kind: task_pb2.TaskKind = task_pb2.TASK_CHECK_PO
    ) -> task_pb2.Task:
        return task_pb2.Task(id=task_pb2.TaskID(id=id), kind=kind)

    t1 = task_of_raw(mk_pb_task("task:po:a"))
    t2 = task_of_raw(mk_pb_task("task:po:a"))
    assert t1 is not t2
    assert t1 == t2
    assert hash(t1) == hash(t2)
    assert len({t1, t2}) == 1

    assert t1 != task_of_raw(mk_pb_task("task:po:b"))
    assert t1 != "task:po:a"

    # Same IML source in two sessions gives equal tasks and responses
    with mk_client() as c1, mk_client() as c2:
        r1, r2 = c1.eval_src(SRC), c2.eval_src(SRC)
        assert r1.tasks == r2.tasks
        assert r1 == r2

        other = c1.eval_src("theorem other x = x + 2 > x")
        assert set(other.tasks).isdisjoint(r1.tasks)


def test_kill_then_access_raises(mk_client: Callable[[], Client]):
    client = mk_client()
    po = get_the_task(client.eval_src(SRC), ProofObligationTask)

    ref = weakref.ref(client)
    del client
    assert_weak_ref_gone(ref)

    with pytest.raises(ClientGoneError):
        _ = po.proof_obligation
    with pytest.raises(ClientGoneError):
        _ = po.result


def test_access_kill_access_again(mk_client: Callable[[], Client]):
    client = mk_client()
    po = get_the_task(client.eval_src(SRC), ProofObligationTask)
    po_ = po.proof_obligation
    res = po.result

    ref = weakref.ref(client)
    del client
    assert_weak_ref_gone(ref)

    assert po.proof_obligation is po_
    assert po.result is res


def test_access_kill_access_derived_from_same_artifact(mk_client: Callable[[], Client]):
    client = mk_client()
    po = get_the_task(client.eval_src(SRC), ProofObligationTask)
    # Fetches the `po_task` artifact, which `from_sym` and `db` are also decoded from
    _ = po.proof_obligation
    ref = weakref.ref(client)
    del client
    assert_weak_ref_gone(ref)
    assert po.from_sym == "succ_gt"
    assert isinstance(po.db, DB)

    # The result is in the `po_res` artifact, never fetched
    with pytest.raises(ClientGoneError):
        _ = po.result


def test_kill_set_client_access(mk_client: Callable[[], Client]):
    """A task whose client is gone fetches with another client"""

    with mk_client() as client:
        po_task: ProofObligationTask = get_the_task(
            client.eval_src(SRC), ProofObligationTask
        )
        po: ProofObligation = po_task.proof_obligation

    ref = weakref.ref(client)
    del client
    assert_weak_ref_gone(ref)

    with pytest.raises(ClientGoneError):
        _ = po_task.result

    assert po_task.proof_obligation is po, (
        "Accessing cached property after client is gone should be fine"
    )

    with mk_client() as c2:
        po_task.set_client(c2)
        assert po_task.proof_obligation is po
        assert isinstance(po_task.result, ProofObligationTaskResult)


# AsyncClient
# ===========


def test_async_access_before_fetch_raises(mk_async_client: Callable[[], AsyncClient]):
    async def main() -> None:
        async with mk_async_client() as client:
            po = get_the_task(await client.eval_src(SRC), ProofObligationTask)

            with pytest.raises(NotFetchedError) as e:
                _ = po.proof_obligation
            assert e.value.kind == "po_task"
            with pytest.raises(NotFetchedError) as e:
                _ = po.result
            assert e.value.kind == "po_res"

    asyncio.run(main())


def test_async_awaitable_fetches_then_plain_access(
    mk_async_client: Callable[[], AsyncClient],
):
    async def main() -> None:
        async with mk_async_client() as client:
            po = get_the_task(await client.eval_src(SRC), ProofObligationTask)
            po_ = await po.awaitable.proof_obligation
            assert po.proof_obligation is po_
            # Derived from the same artifact
            assert po.from_sym == "succ_gt"
            # The result is another artifact
            with pytest.raises(NotFetchedError):
                _ = po.result
            res = await po.awaitable.result
            assert po.result is res

    asyncio.run(main())


def test_async_fetch_all(mk_async_client: Callable[[], AsyncClient]):
    async def main() -> None:
        async with mk_async_client() as client:
            po = get_the_task(await client.eval_src(SRC), ProofObligationTask)
            await po.fetch_all()

            # Every artifact is fetched, so plain access does not raise `NotFetchedError`
            _ = po.proof_obligation
            assert isinstance(po.result, ProofObligationTaskResult)

    asyncio.run(main())


def test_async_access_kill_access_again(mk_async_client: Callable[[], AsyncClient]):
    async def main() -> None:
        client = mk_async_client()
        async with client:
            po = get_the_task(await client.eval_src(SRC), ProofObligationTask)
            po_ = await po.awaitable.proof_obligation
        ref = weakref.ref(client)
        del client
        assert_weak_ref_gone(ref)

        # Fetched before, through `awaitable` or not
        assert po.proof_obligation is po_
        assert await po.awaitable.proof_obligation is po_

        # Derived from the same artifact
        assert po.from_sym == "succ_gt"
        assert await po.awaitable.from_sym == "succ_gt"

        with pytest.raises(ClientGoneError):
            await po.awaitable.result

    asyncio.run(main())


def test_async_concurrent_accesses_share_one_fetch(
    mk_async_client: Callable[[], AsyncClient],
):
    async def main() -> None:
        async with mk_async_client() as client:
            po = get_the_task(await client.eval_src(SRC), ProofObligationTask)
            fetched: list[str] = []
            get_artifact = client._client.get_artifact  # pyright: ignore[reportPrivateUsage]

            async def recording_get_artifact(
                task: task_pb2.Task, kind: str, timeout: float | None = None
            ) -> ArtifactResult:
                fetched.append(kind)
                return await get_artifact(task, kind, timeout)

            client._client.get_artifact = recording_get_artifact  # pyright: ignore[reportPrivateUsage]
            r1, r2 = await asyncio.gather(po.awaitable.result, po.awaitable.result)
            assert r1 is r2
            assert fetched == ["po_res"]

    asyncio.run(main())
