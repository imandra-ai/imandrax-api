"""the HTTP transport must never outlive a failed session.

`Client` / `AsyncClient` build their `requests` / `aiohttp` session up front and
only then issue the `create_session` / `open_session` RPC. When that RPC fails,
nothing else closes the transport, which used to leak it (aiohttp reports it as
an "Unclosed client session" warning).

By default a failed `end_session` on exit raises. With `best_effort_close` it is
only logged (the gateway often answers 503), so the `with` body's reply or
exception is what the caller sees, and the exit waits at most
`END_SESSION_TIMEOUT`.
"""
# ai-disclosure: ai-generated
# pyright: reportPrivateUsage=false

import asyncio
from typing import Any

import pytest
from structlog.testing import capture_logs

import imandrax_api.v1 as sync_client_mod
from imandrax_api.bindings import utils_pb2
from imandrax_api.twirp.errors import Errors
from imandrax_api.twirp.exceptions import TwirpServerException
from imandrax_api.v1 import Client, ClientClosedError
from imandrax_api.v1._async import AsyncClient
from imandrax_api.v1._common import END_SESSION_TIMEOUT

URL = "http://127.0.0.1:1"


class _Raised(Exception):
    pass


class _Sesh:
    id = "session-id"


def _raise_boom(*_: Any, **__: Any) -> Any:
    raise _Raised()


def _create_sesh(*_: Any, **__: Any) -> _Sesh:
    return _Sesh()


async def _create_ok(**_: Any) -> _Sesh:
    return _Sesh()


async def _create_fail(**_: Any) -> _Sesh:
    raise _Raised()


def _unavailable() -> TwirpServerException:
    return TwirpServerException(code=Errors.Unavailable, message="Service Unavailable")


def test_async_enter_failure_closes_transport() -> None:
    async def go() -> None:
        c = AsyncClient(url=URL)
        c._client.create_session = _create_fail
        try:
            async with c:
                raise AssertionError("__aenter__ should have raised")
        except _Raised:
            pass
        assert c._session.closed
        assert c._closed

    asyncio.run(go())


def _mk_async_client(
    end_timeouts: list[Any], *, best_effort_close: bool
) -> AsyncClient:
    """a client whose `status` answers "ok" and whose `end_session` fails."""

    async def status_ok(**_: Any) -> utils_pb2.StringMsg:
        return utils_pb2.StringMsg(msg="ok")

    async def end_unavailable(**kwargs: Any) -> None:
        end_timeouts.append(kwargs.get("timeout"))
        raise _unavailable()

    c = AsyncClient(url=URL, best_effort_close=best_effort_close)
    c._client.create_session = _create_ok
    c._client.status = status_ok
    c._client.end_session = end_unavailable
    return c


def test_async_end_session_failure_raises() -> None:
    end_timeouts: list[Any] = []

    async def go() -> None:
        c = _mk_async_client(end_timeouts, best_effort_close=False)
        with pytest.raises(Exception, match="Error while ending session") as ei:
            async with c:
                pass
        assert isinstance(ei.value.__cause__, TwirpServerException)
        assert c._session.closed
        assert c._closed

    asyncio.run(go())
    # by default the exit waits for the server for as long as it takes
    assert end_timeouts == [None]


def test_async_best_effort_close_keeps_reply() -> None:
    end_timeouts: list[Any] = []

    async def go() -> None:
        c = _mk_async_client(end_timeouts, best_effort_close=True)
        with capture_logs() as logs:
            async with c:
                reply = await c.status()
        assert reply.msg == "ok"
        assert c._session.closed
        assert c._closed
        assert [(e["log_level"], e["event"]) for e in logs] == [
            ("warning", "failed to end session")
        ]

    asyncio.run(go())
    # a hung `end_session` must not hang the exit
    assert end_timeouts == [END_SESSION_TIMEOUT]


def test_async_best_effort_close_keeps_body_exception() -> None:
    async def go() -> None:
        c = _mk_async_client([], best_effort_close=True)
        with pytest.raises(_Raised):
            async with c:
                raise _Raised()
        assert c._session.closed

    asyncio.run(go())


def test_async_happy_path_ends_session_and_closes_transport() -> None:
    calls: list[str] = []

    async def end_ok(**_: Any) -> None:
        calls.append("end_session")

    async def go() -> None:
        c = AsyncClient(url=URL)
        c._client.create_session = _create_ok
        c._client.end_session = end_ok
        async with c as entered:
            assert entered is c
        assert calls == ["end_session"]
        assert c._session.closed
        # exiting twice is a no-op, not a second `end_session`
        await c.__aexit__(None, None, None)
        assert calls == ["end_session"]

    asyncio.run(go())


def _record_sessions(monkeypatch: Any) -> list[Any]:
    """patch in a `requests.Session` that remembers whether it was closed."""
    created: list[Any] = []
    real_session = sync_client_mod.requests.Session

    class RecordingSession(real_session):
        def __init__(self) -> None:
            super().__init__()
            self.was_closed = False
            created.append(self)

        def close(self) -> None:
            self.was_closed = True
            super().close()

    monkeypatch.setattr(sync_client_mod.requests, "Session", RecordingSession)
    return created


def test_sync_init_failure_closes_transport(
    monkeypatch: Any,
) -> None:
    created = _record_sessions(monkeypatch)
    monkeypatch.setattr(
        sync_client_mod.simple_api_twirp.SimpleClient, "create_session", _raise_boom
    )

    try:
        Client(url=URL)
    except _Raised:
        pass
    else:
        raise AssertionError("constructor should have raised")

    assert created and created[-1].was_closed


def _patch_sync_end_unavailable(monkeypatch: Any) -> list[Any]:
    """make `end_session` fail; returns the timeouts it was called with."""
    end_timeouts: list[Any] = []

    def end_unavailable(*_: Any, **kwargs: Any) -> None:
        end_timeouts.append(kwargs.get("timeout"))
        raise _unavailable()

    monkeypatch.setattr(
        sync_client_mod.simple_api_twirp.SimpleClient,
        "create_session",
        _create_sesh,
    )
    monkeypatch.setattr(
        sync_client_mod.simple_api_twirp.SimpleClient, "end_session", end_unavailable
    )
    return end_timeouts


def test_sync_end_session_failure_closes_transport(monkeypatch: Any) -> None:
    created = _record_sessions(monkeypatch)
    end_timeouts = _patch_sync_end_unavailable(monkeypatch)

    c = Client(url=URL)
    with pytest.raises(Exception, match="Error while ending session"):
        c.__exit__()

    assert c._closed
    assert created and created[-1].was_closed
    assert end_timeouts == [None]


def test_sync_best_effort_close_logs(monkeypatch: Any) -> None:
    created = _record_sessions(monkeypatch)
    end_timeouts = _patch_sync_end_unavailable(monkeypatch)

    # a client timeout shorter than END_SESSION_TIMEOUT wins
    with (
        capture_logs() as logs,
        Client(url=URL, timeout=5, best_effort_close=True) as c,
    ):
        pass

    assert c._closed
    assert created and created[-1].was_closed
    assert end_timeouts == [5]
    assert [e["event"] for e in logs] == ["failed to end session"]


def test_async_closed_client_raises() -> None:
    async def end_ok(**_: Any) -> None:
        pass

    async def go() -> None:
        c = AsyncClient(url=URL)
        c._client.create_session = _create_ok
        c._client.end_session = end_ok
        async with c:
            pass
        try:
            await c.status()
        except ClientClosedError:
            pass
        else:
            raise AssertionError("a closed client should refuse requests")

    asyncio.run(go())


def test_sync_closed_client_raises(monkeypatch: Any) -> None:
    created = _record_sessions(monkeypatch)
    monkeypatch.setattr(
        sync_client_mod.simple_api_twirp.SimpleClient,
        "create_session",
        _create_sesh,
    )
    monkeypatch.setattr(
        sync_client_mod.simple_api_twirp.SimpleClient, "end_session", _create_sesh
    )

    with Client(url=URL) as c:
        pass
    assert created and created[-1].was_closed

    # `requests` would silently reopen a connection; the client must not
    try:
        c.status()
    except ClientClosedError:
        pass
    else:
        raise AssertionError("a closed client should refuse requests")
