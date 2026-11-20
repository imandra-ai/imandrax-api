"""Errors from the RPC layer and the clients, against a local stand-in server

- The Twirp layer maps every failure to a `TwirpServerException` with the Twirp code: a Twirp
  JSON error by its `code`, a timeout to `deadline_exceeded`, a network failure to `unavailable`,
  an undecodable 200 reply to `internal`, and an intermediary's error status as in the Twirp
  spec. It does not follow redirects.
- A session request rejected with `invalid_argument` raises `ApiVersionMismatchError`.
- All of these derive from `ImandraXError`.
"""
# ai-disclosure: ai-generated
# pyright: reportUnknownMemberType=false, reportUnknownVariableType=false

import asyncio
import json
import threading
import time
from collections.abc import Callable, Iterator
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any, cast

import aiohttp
import pytest
import requests

from imandrax_api import v1, v2
from imandrax_api.bindings import (
    session_pb2,
    simple_api_twirp,
    simple_api_twirp_async,
    utils_pb2,
)
from imandrax_api.twirp.errors import Errors
from imandrax_api.twirp.exceptions import TwirpServerException
from imandrax_api.v1._common import mk_context

Route = Callable[[], tuple[int, dict[str, str], bytes]]


class _Server(ThreadingHTTPServer):
    routes: dict[str, Route]
    """What to answer, by RPC method name"""
    hits: list[str]
    """The paths requested"""

    def handle_error(self, request: Any, client_address: Any) -> None:
        pass  # e.g. writing to a client that timed out


class _Handler(BaseHTTPRequestHandler):
    def do_POST(self) -> None:
        server = cast(_Server, self.server)
        self.rfile.read(int(self.headers.get("Content-Length", 0)))
        server.hits.append(self.path)
        status, headers, body = server.routes[self.path.rsplit("/", 1)[-1]]()
        self.send_response(status)
        for k, v in headers.items():
            self.send_header(k, v)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format: str, *args: Any) -> None:
        pass


@pytest.fixture
def server() -> Iterator[_Server]:
    srv = _Server(("127.0.0.1", 0), _Handler)
    srv.routes = {}
    srv.hits = []
    t = threading.Thread(
        target=srv.serve_forever, kwargs={"poll_interval": 0.01}, daemon=True
    )
    t.start()
    yield srv
    srv.shutdown()
    srv.server_close()


def url_of(srv: _Server) -> str:
    return f"http://127.0.0.1:{srv.server_address[1]}"


def ok(msg: Any, delay: float = 0) -> Route:
    def route() -> tuple[int, dict[str, str], bytes]:
        time.sleep(delay)
        return 200, {"Content-Type": "application/protobuf"}, msg.SerializeToString()

    return route


def twirp_error(status: int, code: str, msg: str) -> Route:
    body = json.dumps({"code": code, "msg": msg}).encode()
    return lambda: (status, {"Content-Type": "application/json"}, body)


def raw(status: int, body: bytes, headers: dict[str, str] | None = None) -> Route:
    return lambda: (status, headers or {}, body)


def status_rpc(url: str, is_async: bool, timeout: Any = 5) -> str:
    """Call the `status` RPC through the generated Twirp stubs"""
    if not is_async:
        client = simple_api_twirp.SimpleClient(
            url,
            timeout=timeout,
            server_path_prefix="/api/v1",
            session=requests.Session(),
        )
        return client.status(ctx=mk_context(), request=utils_pb2.Empty()).msg

    async def go() -> str:
        async with aiohttp.ClientSession() as session:
            client = simple_api_twirp_async.AsyncSimpleClient(
                url, timeout=timeout, server_path_prefix="/api/v1", session=session
            )
            return (
                await client.status(ctx=mk_context(), request=utils_pb2.Empty())
            ).msg

    return asyncio.run(go())


both = pytest.mark.parametrize("is_async", [False, True], ids=["sync", "async"])


# The Twirp layer
# ====================


@both
def test_ok(server: _Server, is_async: bool) -> None:
    server.routes["status"] = ok(utils_pb2.StringMsg(msg="fine"))
    assert status_rpc(url_of(server), is_async) == "fine"


@both
def test_twirp_json_error(server: _Server, is_async: bool) -> None:
    server.routes["status"] = twirp_error(404, "not_found", "no such thing")
    with pytest.raises(TwirpServerException) as e:
        status_rpc(url_of(server), is_async)
    assert e.value.code == Errors.NotFound
    assert e.value.status == 404
    assert e.value.message == "no such thing"
    assert e.value.meta["body"] == {"code": "not_found", "msg": "no such thing"}


@both
def test_dataloss_code(server: _Server, is_async: bool) -> None:
    server.routes["status"] = twirp_error(500, "dataloss", "lost")
    with pytest.raises(TwirpServerException) as e:
        status_rpc(url_of(server), is_async)
    assert e.value.code == Errors.DataLoss


@both
def test_intermediary_error(server: _Server, is_async: bool) -> None:
    server.routes["status"] = raw(503, b"<html>Service Unavailable</html>")
    with pytest.raises(TwirpServerException) as e:
        status_rpc(url_of(server), is_async)
    assert e.value.code == Errors.Unavailable
    assert e.value.status == 503


@both
def test_redirect_is_not_followed(server: _Server, is_async: bool) -> None:
    url = url_of(server)
    server.routes["status"] = raw(307, b"", {"Location": f"{url}/api/v1/x/status"})
    with pytest.raises(TwirpServerException) as e:
        status_rpc(url, is_async)
    assert e.value.code == Errors.Internal
    assert e.value.status == 307
    assert e.value.meta["location"] == f"{url}/api/v1/x/status"
    assert len(server.hits) == 1


@both
def test_undecodable_reply(server: _Server, is_async: bool) -> None:
    server.routes["status"] = raw(200, b"\xff\xff\xff\xff")
    with pytest.raises(TwirpServerException) as e:
        status_rpc(url_of(server), is_async)
    assert e.value.code == Errors.Internal
    assert e.value.status == 200


@both
def test_timeout(server: _Server, is_async: bool) -> None:
    server.routes["status"] = ok(utils_pb2.StringMsg(msg="late"), delay=1)
    with pytest.raises(TwirpServerException) as e:
        status_rpc(url_of(server), is_async, timeout=0.1)
    assert e.value.code == Errors.DeadlineExceeded
    assert e.value.status is None


@both
def test_connection_refused(is_async: bool) -> None:
    with pytest.raises(TwirpServerException) as e:
        status_rpc("http://127.0.0.1:1", is_async)
    assert e.value.code == Errors.Unavailable
    assert e.value.status is None


# Clients
# ====================


def connect(cls: Any, url: str, **kwargs: Any) -> Any:
    """Connect a client of class `cls` and close it, returning what `status` gives"""
    if cls in (v1.Client, v2.Client):
        with cls(url=url, **kwargs) as c:
            return c.status(timeout=0.1)

    async def go() -> Any:
        async with cls(url=url, **kwargs) as c:
            return await c.status(timeout=0.1)

    return asyncio.run(go())


clients = pytest.mark.parametrize(
    "cls",
    [v1.Client, v1.AsyncClient, v2.Client, v2.AsyncClient],
    ids=["v1", "v1-async", "v2", "v2-async"],
)


def serve_session(server: _Server) -> None:
    server.routes["create_session"] = ok(session_pb2.Session(id="s"))
    server.routes["end_session"] = ok(utils_pb2.Empty())


@clients
def test_version_mismatch_on_create(server: _Server, cls: Any) -> None:
    server.routes["create_session"] = twirp_error(
        400, "invalid_argument", "bad version"
    )
    with pytest.raises(v2.ApiVersionMismatchError, match="upgrading") as e:
        connect(cls, url_of(server))
    assert isinstance(e.value, v2.ImandraXError)
    assert isinstance(e.value.__cause__, TwirpServerException)


@clients
def test_version_mismatch_on_open(server: _Server, cls: Any) -> None:
    server.routes["open_session"] = twirp_error(400, "invalid_argument", "bad version")
    with pytest.raises(v2.ApiVersionMismatchError):
        connect(cls, url_of(server), session_id="s")


@clients
@pytest.mark.parametrize(
    "kwargs",
    [{}, {"session_id": "s"}, {"session_id": "s", "create_if_not_found": True}],
    ids=["create", "open", "open-or-create"],
)
def test_version_mismatch_from_gateway(
    server: _Server, cls: Any, kwargs: dict[str, Any]
) -> None:
    """The deployed gateway answers an API version it has no server for with a bare 404"""
    for method in ("create_session", "open_session"):
        server.routes[method] = raw(404, b"fault filter abort")
    with pytest.raises(v2.ApiVersionMismatchError, match="upgrading") as e:
        connect(cls, url_of(server), **kwargs)
    assert isinstance(e.value.__cause__, TwirpServerException)
    assert e.value.__cause__.code == Errors.BadRoute


@clients
def test_gateway_404_elsewhere_is_not_a_mismatch(server: _Server, cls: Any) -> None:
    serve_session(server)
    server.routes["status"] = raw(404, b"fault filter abort")
    with pytest.raises(TwirpServerException) as e:
        connect(cls, url_of(server))
    assert e.value.code == Errors.BadRoute


@clients
def test_status_timeout(server: _Server, cls: Any) -> None:
    """`status` takes a timeout, which overrides the client's"""
    serve_session(server)
    server.routes["status"] = ok(utils_pb2.StringMsg(msg="late"), delay=1)
    with pytest.raises(TwirpServerException) as e:
        connect(cls, url_of(server))
    assert e.value.code == Errors.DeadlineExceeded


@clients
def test_status(server: _Server, cls: Any) -> None:
    serve_session(server)
    server.routes["status"] = ok(utils_pb2.StringMsg(msg="fine"))
    res = connect(cls, url_of(server))
    assert (res if isinstance(res, str) else res.msg) == "fine"


def test_errors_derive_from_imandrax_error() -> None:
    for name in v2.errors.__all__:
        assert issubclass(getattr(v2, name), v2.ImandraXError), name
    assert v2.TwirpServerException is TwirpServerException
    assert v1.ClientClosedError is v2.ClientClosedError
    assert issubclass(v1.EndSessionError, v2.ImandraXError)
