# pyright: strict, reportUnknownMemberType=false, reportUnknownVariableType=false
from __future__ import annotations

from typing import Any, Optional

import aiohttp  # type: ignore[import-not-found]

from .. import api_types_version
from ..bindings import (
    api_pb2,
    api_twirp_async,
    session_pb2,
    session_twirp_async,
    simple_api_pb2,
    simple_api_twirp_async,
    task_pb2,
    utils_pb2,
)
from ..twirp.context import Context
from ..twirp.errors import Errors
from ..twirp.exceptions import TwirpServerException
from ._common import is_session_not_found, mk_context, url_prod


class AsyncClient:
    _client: simple_api_twirp_async.AsyncSimpleClient
    _api_client: api_twirp_async.AsyncEvalClient
    _session_mgr: session_twirp_async.AsyncSessionManagerClient
    _timeout: float
    _sesh: session_pb2.Session
    _session_id: str | None
    _create_if_not_found: bool

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
        create_if_not_found: bool = False,
    ) -> None:
        # use a session to help with cookies. See https://requests.readthedocs.io/en/latest/user/advanced/#session-objects
        self._session: aiohttp.ClientSession = aiohttp.ClientSession()
        self._session_id = session_id
        self._create_if_not_found = create_if_not_found
        self._closed = False
        self._auth_token = api_key if api_key else auth_token
        if self._auth_token:
            self._session.headers["Authorization"] = f"Bearer {auth_token}"
        self._url = url
        self._server_path_prefix = server_path_prefix
        self._client = simple_api_twirp_async.AsyncSimpleClient(
            url,
            timeout=timeout,
            server_path_prefix=server_path_prefix,
            session=self._session,
        )
        self._api_client = api_twirp_async.AsyncEvalClient(
            url,
            timeout=timeout,
            server_path_prefix=server_path_prefix,
            session=self._session,
        )
        self._session_mgr = session_twirp_async.AsyncSessionManagerClient(
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
                session = await self._client.create_session(
                    ctx=self.mk_context(),
                    request=simple_api_pb2.SessionCreateReq(
                        api_version=api_types_version.api_types_version
                    ),
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
            self._sesh = session_pb2.Session(id=self._session_id)
            try:
                await self._session_mgr.open_session(
                    ctx=self.mk_context(),
                    request=session_pb2.SessionOpen(
                        id=self._sesh,
                        api_version=api_types_version.api_types_version,
                    ),
                )
            except TwirpServerException as ex:
                if is_session_not_found(ex) and self._create_if_not_found:
                    self._sesh = await self._client.create_session(
                        ctx=self.mk_context(),
                        request=simple_api_pb2.SessionCreateReq(
                            api_version=api_types_version.api_types_version
                        ),
                    )
                    self._session_id = self._sesh.id
                else:
                    raise
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

    async def status(self) -> utils_pb2.StringMsg:
        return await self._client.status(
            ctx=self.mk_context(),
            request=utils_pb2.Empty(),
        )

    async def decompose(
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

        return await self._client.decompose(
            ctx=self.mk_context(),
            request=req,
            timeout=timeout,
        )

    async def eval_src(
        self,
        src: str,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.EvalRes:
        timeout = timeout or self._timeout
        return await self._client.eval_src(
            ctx=self.mk_context(),
            request=simple_api_pb2.EvalSrcReq(src=src, session=self._sesh),
            timeout=timeout,
        )

    async def verify_src(
        self,
        src: str,
        hints: Optional[str] = None,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.VerifyRes:
        timeout = timeout or self._timeout
        return await self._client.verify_src(
            ctx=self.mk_context(),
            request=simple_api_pb2.VerifySrcReq(
                src=src, session=self._sesh, hints=hints
            ),
            timeout=timeout,
        )

    async def instance_src(
        self,
        src: str,
        hints: Optional[str] = None,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.InstanceRes:
        timeout = timeout or self._timeout
        return await self._client.instance_src(
            ctx=self.mk_context(),
            request=simple_api_pb2.InstanceSrcReq(
                src=src, session=self._sesh, hints=hints
            ),
            timeout=timeout,
        )

    async def qcheck_src(
        self,
        src: str,
        seed: Optional[int] = None,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.TestRes:
        seed = seed or 0
        timeout = timeout or self._timeout
        return await self._client.qcheck_src(
            ctx=self.mk_context(),
            request=simple_api_pb2.QCheckSrcReq(src=src, session=self._sesh, seed=seed),
            timeout=timeout,
        )

    async def qcheck_name(
        self,
        name: str,
        seed: Optional[int] = None,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.TestRes:
        seed = seed or 0
        timeout = timeout or self._timeout
        return await self._client.qcheck_name(
            ctx=self.mk_context(),
            request=simple_api_pb2.QCheckNameReq(
                name=name, session=self._sesh, seed=seed
            ),
            timeout=timeout,
        )

    async def list_artifacts(
        self, task: task_pb2.Task, timeout: Optional[float] = None
    ) -> api_pb2.ArtifactListResult:
        timeout = timeout or self._timeout
        return await self._api_client.list_artifacts(
            ctx=self.mk_context(),
            request=api_pb2.ArtifactListQuery(task_id=task.id),
            timeout=timeout,
        )

    async def get_artifact_zip(
        self, task: task_pb2.Task, kind: str, timeout: Optional[float] = None
    ) -> api_pb2.ArtifactZip:
        timeout = timeout or self._timeout
        return await self._api_client.get_artifact_zip(
            ctx=self.mk_context(),
            request=api_pb2.ArtifactGetQuery(task_id=task.id, kind=kind),
            timeout=timeout,
        )

    async def typecheck(
        self, src: str, timeout: Optional[float] = None
    ) -> simple_api_pb2.TypecheckRes:
        timeout = timeout or self._timeout
        return await self._client.typecheck(
            ctx=self.mk_context(),
            request=simple_api_pb2.TypecheckReq(src=src, session=self._sesh),
            timeout=timeout,
        )

    async def get_decls(
        self, names: list[str], timeout: Optional[float] = None
    ) -> simple_api_pb2.GetDeclsRes:
        timeout = timeout or self._timeout
        return await self._client.get_decls(
            ctx=self.mk_context(),
            request=simple_api_pb2.GetDeclsReq(session=self._sesh, name=names),
            timeout=timeout,
        )
