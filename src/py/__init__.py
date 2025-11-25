from __future__ import annotations

from typing import Any, Optional, TYPE_CHECKING

import requests

if TYPE_CHECKING:
    import aiohttp

from .twirp.exceptions import TwirpServerException
from .twirp.errors import Errors
from .twirp.context import Context
from .bindings import (
    task_pb2,
    utils_pb2,
    simple_api_twirp,
    simple_api_pb2,
    session_pb2,
    api_pb2,
    api_twirp,
)
from . import api_types_version

# TODO: https://requests.readthedocs.io/en/latest/user/advanced/#example-automatic-retries (for calls that are idempotent, maybe we pass `idempotent=True` for them

url_dev = "https://api.dev.imandracapital.com/internal/imandrax/"
url_prod = "https://api.imandra.ai/internal/imandrax/"

class BaseClient:
    _client: Any
    _api_client: Any
    _timeout: float
    _sesh: Any

    def mk_context(self) -> Context:
        """Build a request context with the appropriate headers"""
        return Context(headers={"x-api-version": api_types_version.api_types_version})

    def status(self):
        return self._client.status(
            ctx=self.mk_context(),
            request=utils_pb2.Empty(),
        )

    def decompose(
        self,
        name: str,
        assuming: Optional[str] = None,
        basis: Optional[list[str]] = [],
        rule_specs: Optional[list[str]] = [],
        prune: Optional[bool] = True,
        ctx_simp: Optional[bool] = None,
        lift_bool: Optional[simple_api_pb2.LiftBool] = None,
        timeout: Optional[float] = None,
        str: Optional[bool] = True,
    ) -> simple_api_pb2.DecomposeRes:
        timeout = timeout or self._timeout
        return self._client.decompose(
            ctx=self.mk_context(),
            request=simple_api_pb2.DecomposeReq(
                name=name,
                assuming=assuming,
                basis=basis,
                rule_specs=rule_specs,
                prune=prune,
                ctx_simp=ctx_simp,
                lift_bool=lift_bool,
                str=str,
                session=self._sesh,
            ),
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


class Client(BaseClient):
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
            if requests is not None and hasattr(self, '_session'):
                self.__exit__()
        except Exception:
            # Silently ignore errors during cleanup to avoid spurious error messages
            pass

try:
    import aiohttp  # type: ignore[import-not-found]

    _async_available = True
except ModuleNotFoundError:
    _async_available = False

if _async_available:
    import aiohttp  # type: ignore[import-not-found]

    class AsyncClient(BaseClient):
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
            self._session: aiohttp.ClientSession = aiohttp.ClientSession()
            self._session_id = session_id
            self._closed = False
            self._auth_token = api_key if api_key else auth_token
            if self._auth_token:
                self._session.headers["Authorization"] = f"Bearer {auth_token}"
            self._url = url
            self._server_path_prefix = server_path_prefix
            self._client = simple_api_twirp.AsyncSimpleClient(
                url,
                timeout=timeout,
                server_path_prefix=server_path_prefix,
                session=self._session,
            )
            self._api_client = api_twirp.AsyncEvalClient(
                url,
                timeout=timeout,
                server_path_prefix=server_path_prefix,
                session=self._session,
            )
            self._timeout = timeout

        async def __aenter__(self, *_: Any) -> AsyncClient:
            await self._session.__aenter__()
            if self._session_id is None:
                try:
                    session =  await self._client.create_session(
                        ctx=self.mk_context(),
                        request=simple_api_pb2.SessionCreateReq(
                            api_version=api_types_version.api_types_version
                        )
                    )
                    self._sesh = session
                    self._session_id = self._sesh.id
                except TwirpServerException as ex:
                    if ex.code == Errors.InvalidArgument:
                        raise Exception(
                            "API version mismatch. Try upgrading the imandrax-api package."
                        ) from ex
                    else:
                        raise ex
            else:
                # TODO: actually re-open session via RPC
                self._sesh = session_pb2.Session(
                    id=self._session_id,
                )
            return self

        async def __aexit__(self, exc_type: Any, exc_val: Any, exc_tb: Any) -> None:
            if self._closed:
                return
            if not hasattr(self, "_sesh"):
                await self._session.__aexit__(exc_type, exc_val, exc_tb)
                self._closed = True
                return
            try:
                await self._client.end_session(
                    ctx=self.mk_context(), request=self._sesh, timeout=None
                )
                await self._session.__aexit__(exc_type, exc_val, exc_tb)
                self._closed = True
            except TwirpServerException as e:
                raise Exception("Error while ending session") from e
