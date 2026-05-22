# pyright: basic
from __future__ import annotations

from typing import TYPE_CHECKING, Any, Optional

import requests

from . import api_types_version
from ._common import mk_context, url_dev, url_prod
from .bindings import (
    api_pb2,
    api_twirp,
    session_pb2,
    simple_api_pb2,
    simple_api_twirp,
    task_pb2,
    utils_pb2,
)
from .twirp.context import Context
from .twirp.errors import Errors
from .twirp.exceptions import TwirpServerException

if TYPE_CHECKING:
    from ._async import AsyncClient

__all__ = ["Client", "AsyncClient", "url_dev", "url_prod"]

# TODO: https://requests.readthedocs.io/en/latest/user/advanced/#example-automatic-retries (for calls that are idempotent, maybe we pass `idempotent=True` for them


class Client:
    _client: simple_api_twirp.SimpleClient
    _api_client: api_twirp.EvalClient
    _timeout: float
    _sesh: session_pb2.Session

    @staticmethod
    def mk_context() -> Context:
        return mk_context()

    def __init__(
        self,
        url: str = url_prod,
        server_path_prefix: str = "/api/v1",
        auth_token: str | None = None,
        api_key: str | None = None,
        timeout: int = 30,
        session_id: str | None = None,
    ) -> None:
        # use a session to help with cookies. See https://requests.readthedocs.io/en/latest/user/advanced/#session-objects
        self._session = requests.Session()
        self._closed = False
        self._auth_token = api_key if api_key else auth_token
        if self._auth_token:
            self._session.headers["Authorization"] = f"Bearer {auth_token}"
        self._url = url
        self._server_path_prefix = server_path_prefix
        self._client = simple_api_twirp.SimpleClient(
            url,
            timeout=timeout,
            server_path_prefix=server_path_prefix,
            session=self._session,
        )
        self._api_client = api_twirp.EvalClient(
            url,
            timeout=timeout,
            server_path_prefix=server_path_prefix,
            session=self._session,
        )
        self._timeout = timeout

        if session_id is None:
            try:
                self._sesh = self._client.create_session(
                    ctx=self.mk_context(),
                    request=simple_api_pb2.SessionCreateReq(
                        api_version=api_types_version.api_types_version
                    ),
                    timeout=timeout,
                )
            except TwirpServerException as ex:
                status_code: int | None = ex.meta.get("status_code")  # type: ignore[attr-defined]
                if status_code and status_code == Errors.get_status_code(
                    Errors.InvalidArgument
                ):
                    raise Exception(
                        "API version mismatch. Try upgrading the imandrax-api package."
                    ) from ex
                else:
                    raise ex
        else:
            # TODO: actually re-open session via RPC
            self._sesh = session_pb2.Session(
                id=session_id,
            )

    def __enter__(self, *_: Any) -> Client:
        return self

    def __exit__(self, *_: Any) -> None:
        if self._closed:
            return
        if not hasattr(self, "_sesh"):
            return
        try:
            self._client.end_session(
                ctx=self.mk_context(), request=self._sesh, timeout=None
            )
            self._session.close()
            self._closed = True
        except TwirpServerException as e:
            raise Exception("Error while ending session") from e

    def __del__(self):
        # Avoid errors during interpreter shutdown when modules may already be None
        # Only attempt cleanup if we're not in shutdown state
        try:
            # Check if required modules are still available
            if requests is not None and hasattr(self, "_session"):
                self.__exit__()
        except Exception:
            # Silently ignore errors during cleanup to avoid spurious error messages
            pass

    def status(self) -> utils_pb2.StringMsg:
        return self._client.status(
            ctx=self.mk_context(),
            request=utils_pb2.Empty(),
        )

    def decompose(
        self,
        name: str,
        assuming: Optional[str] = None,
        basis: Optional[list[str]] = None,
        rule_specs: Optional[list[str]] = None,
        prune: Optional[bool] = None,
        ctx_simp: Optional[bool] = None,
        lift_bool: Optional[simple_api_pb2.LiftBool] = None,
        timeout: Optional[float] = None,
        string_results: Optional[bool] = None,
    ) -> simple_api_pb2.DecomposeRes:
        timeout = timeout or self._timeout

        req = simple_api_pb2.DecomposeReq(
            name=name,
            assuming=assuming,
            basis=basis,
            rule_specs=rule_specs,
            lift_bool=lift_bool,
            session=self._sesh,
        )
        # If None, keep it as unset
        if prune is not None:
            req.prune = prune
        if ctx_simp is not None:
            req.ctx_simp = ctx_simp
        if string_results is not None:
            req.string_results = string_results

        return self._client.decompose(
            ctx=self.mk_context(),
            request=req,
            timeout=timeout,
        )

    def eval_src(
        self,
        src: str,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.EvalRes:
        timeout = timeout or self._timeout
        return self._client.eval_src(
            ctx=self.mk_context(),
            request=simple_api_pb2.EvalSrcReq(src=src, session=self._sesh),
            timeout=timeout,
        )

    def verify_src(
        self,
        src: str,
        hints: Optional[str] = None,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.VerifyRes:
        timeout = timeout or self._timeout
        return self._client.verify_src(
            ctx=self.mk_context(),
            request=simple_api_pb2.VerifySrcReq(
                src=src, session=self._sesh, hints=hints
            ),
            timeout=timeout,
        )

    def instance_src(
        self,
        src: str,
        hints: Optional[str] = None,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.InstanceRes:
        timeout = timeout or self._timeout
        return self._client.instance_src(
            ctx=self.mk_context(),
            request=simple_api_pb2.InstanceSrcReq(
                src=src, session=self._sesh, hints=hints
            ),
            timeout=timeout,
        )

    def test_src(
        self,
        src: str,
        seed: Optional[int] = None,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.TestRes:
        seed = seed or 0
        timeout = timeout or self._timeout
        return self._client.test_src(
            ctx=self.mk_context(),
            request=simple_api_pb2.TestSrcReq(src=src, session=self._sesh, seed=seed),
            timeout=timeout,
        )

    def qcheck_src(
        self,
        src: str,
        seed: Optional[int] = None,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.TestRes:
        return self.test_src(src, seed, timeout)

    def test_name(
        self,
        name: str,
        seed: Optional[int] = None,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.TestRes:
        seed = seed or 0
        timeout = timeout or self._timeout
        return self._client.test_name(
            ctx=self.mk_context(),
            request=simple_api_pb2.TestNameReq(
                name=name, session=self._sesh, seed=seed
            ),
            timeout=timeout,
        )

    def qcheck_name(
        self,
        name: str,
        seed: Optional[int] = None,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.TestRes:
        return self.test_name(name, seed, timeout)

    def list_artifacts(
        self, task: task_pb2.Task, timeout: Optional[float] = None
    ) -> api_pb2.ArtifactListResult:
        timeout = timeout or self._timeout
        return self._api_client.list_artifacts(
            ctx=self.mk_context(),
            request=api_pb2.ArtifactListQuery(task_id=task.id),
            timeout=timeout,
        )

    def get_artifact_zip(
        self, task: task_pb2.Task, kind: str, timeout: Optional[float] = None
    ) -> api_pb2.ArtifactZip:
        timeout = timeout or self._timeout
        return self._api_client.get_artifact_zip(
            ctx=self.mk_context(),
            request=api_pb2.ArtifactGetQuery(task_id=task.id, kind=kind),
            timeout=timeout,
        )

    def typecheck(
        self, src: str, timeout: Optional[float] = None
    ) -> simple_api_pb2.TypecheckRes:
        timeout = timeout or self._timeout
        return self._client.typecheck(
            ctx=self.mk_context(),
            request=simple_api_pb2.TypecheckReq(src=src, session=self._sesh),
            timeout=timeout,
        )

    def get_decls(
        self, names: list[str], timeout: Optional[float] = None
    ) -> simple_api_pb2.GetDeclsRes:
        timeout = timeout or self._timeout
        return self._client.get_decls(
            ctx=self.mk_context(),
            request=simple_api_pb2.GetDeclsReq(session=self._sesh, name=names),
            timeout=timeout,
        )


def __getattr__(name: str) -> Any:
    # Lazily expose ``AsyncClient`` so importing this package does not require
    # the optional ``aiohttp`` dependency. The import raises ``ImportError``
    # with a clear message if aiohttp is not installed.
    #
    # See PEP 562
    if name == "AsyncClient":
        try:
            from ._async import AsyncClient
        except ImportError as e:
            raise ImportError(
                "AsyncClient requires the optional 'aiohttp' dependency. "
                "Install it with: pip install aiohttp"
            ) from e
        return AsyncClient
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
