"""the HTTP transport must never outlive a failed session.

`Client` / `AsyncClient` build their `requests` / `aiohttp` session up front and
only then issue the `create_session` / `open_session` RPC. When that RPC fails,
nothing else closes the transport, which used to leak it (aiohttp reports it as
an "Unclosed client session" warning).

On exit, `end_session` runs with the client's timeout. If it fails after the
body returned, the exit raises `EndSessionError`. If it fails after the body
raised (e.g. the backend went down mid-request and the gateway answers 503 to
everything for a while), the body's own exception reaches the caller instead
of being replaced, with the `end_session` failure attached as a note.
"""
# ai-disclosure: ai-generated
# pyright: reportPrivateUsage=false

import asyncio
from typing import Any

import pytest

import imandrax_api.v1 as sync_client_mod
from imandrax_api.bindings import utils_pb2
from imandrax_api.twirp.errors import Errors
from imandrax_api.twirp.exceptions import TwirpServerException
from imandrax_api.v1 import Client, ClientClosedError, EndSessionError
from imandrax_api.v1._async import AsyncClient

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


def _mk_async_client(end_timeouts: list[Any], **kwargs: Any) -> AsyncClient:
    """a client whose `status` answers "ok" and whose `end_session` fails."""

    async def status_ok(**_: Any) -> utils_pb2.StringMsg:
        return utils_pb2.StringMsg(msg="ok")

    async def end_unavailable(**kwargs: Any) -> None:
        end_timeouts.append(kwargs.get("timeout"))
        raise _unavailable()

    c = AsyncClient(url=URL, **kwargs)
    c._client.create_session = _create_ok
    c._client.status = status_ok
    c._client.end_session = end_unavailable
    return c


def test_async_end_session_failure_raises() -> None:
    end_timeouts: list[Any] = []

    async def go() -> None:
        c = _mk_async_client(end_timeouts)
        with pytest.raises(EndSessionError) as ei:
            async with c:
                await c.status()
        assert ei.value.session_id == "session-id"
        assert isinstance(ei.value.__cause__, TwirpServerException)
        assert c._session.closed
        assert c._closed

    asyncio.run(go())
    # the client's timeout, not `None` (which would wait forever)
    assert end_timeouts == [30]


def test_async_end_session_failure_keeps_body_exception() -> None:
    end_timeouts: list[Any] = []

    async def go() -> None:
        c = _mk_async_client(end_timeouts, timeout=5)
        with pytest.raises(_Raised) as ei:
            async with c:
                raise _Raised()
        assert c._session.closed
        assert c._closed
        assert ei.value.__notes__ == [
            f"also failed to end session session-id: {_unavailable()!r}"
        ]

    asyncio.run(go())
    assert end_timeouts == [5]


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

    with pytest.raises(EndSessionError) as ei, Client(url=URL) as c:
        pass

    assert ei.value.session_id == "session-id"
    assert isinstance(ei.value.__cause__, TwirpServerException)
    assert c._closed
    assert created and created[-1].was_closed
    assert end_timeouts == [30]


def test_sync_end_session_failure_keeps_body_exception(monkeypatch: Any) -> None:
    created = _record_sessions(monkeypatch)
    end_timeouts = _patch_sync_end_unavailable(monkeypatch)

    with pytest.raises(_Raised) as ei, Client(url=URL, timeout=5) as c:
        raise _Raised()

    assert c._closed
    assert created and created[-1].was_closed
    assert end_timeouts == [5]
    assert ei.value.__notes__ == [
        f"also failed to end session session-id: {_unavailable()!r}"
    ]


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
