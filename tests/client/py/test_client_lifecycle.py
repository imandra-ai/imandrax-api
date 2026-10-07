"""the HTTP transport must never outlive a failed session.

`Client` / `AsyncClient` build their `requests` / `aiohttp` session up front and
only then issue the `create_session` / `open_session` RPC. When that RPC fails,
nothing else closes the transport, which used to leak it (aiohttp reports it as
an "Unclosed client session" warning).
"""
# ai-disclosure: ai-generated
# pyright: reportPrivateUsage=false

import asyncio
from typing import Any

import imandrax_api.client as sync_client_mod
from imandrax_api.client import Client
from imandrax_api.client._async import AsyncClient

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


async def _end_fail(**_: Any) -> None:
    raise _Raised()


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


def test_async_end_session_failure_closes_transport() -> None:
    async def go() -> None:
        c = AsyncClient(url=URL)
        c._client.create_session = _create_ok
        c._client.end_session = _end_fail
        try:
            async with c:
                pass
        except Exception:
            pass
        else:
            raise AssertionError("__aexit__ should have raised")
        assert c._session.closed
        assert c._closed

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


def test_sync_end_session_failure_closes_transport(monkeypatch: Any) -> None:
    created = _record_sessions(monkeypatch)
    monkeypatch.setattr(
        sync_client_mod.simple_api_twirp.SimpleClient,
        "create_session",
        _create_sesh,
    )
    monkeypatch.setattr(
        sync_client_mod.simple_api_twirp.SimpleClient, "end_session", _raise_boom
    )

    c = Client(url=URL)
    try:
        c.__exit__()
    except Exception:
        pass
    else:
        raise AssertionError("__exit__ should have raised")

    assert c._closed
    assert created and created[-1].was_closed
