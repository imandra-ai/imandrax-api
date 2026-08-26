# pyright: strict, reportUnknownMemberType=false, reportUnknownVariableType=false
from __future__ import annotations

from typing import TYPE_CHECKING, Any, Optional, Self

import requests

from .. import api_types_version
from ..bindings import (
    api_pb2,
    api_twirp,
    session_pb2,
    session_twirp,
    simple_api_pb2,
    simple_api_twirp,
    system_pb2,
    system_twirp,
    task_pb2,
    utils_pb2,
)
from ..twirp.context import Context
from ..twirp.errors import Errors
from ..twirp.exceptions import TwirpServerException
from . import decomp
from ._common import is_session_not_found, mk_context, url_dev, url_prod

if TYPE_CHECKING:
    from ._async import AsyncClient

__all__ = ["Client", "AsyncClient", "decomp", "url_dev", "url_prod"]

# TODO: https://requests.readthedocs.io/en/latest/user/advanced/#example-automatic-retries (for calls that are idempotent, maybe we pass `idempotent=True` for them


class Client:
    _client: simple_api_twirp.SimpleClient
    _api_client: api_twirp.EvalClient
    _session_mgr: session_twirp.SessionManagerClient
    _system_client: system_twirp.SystemClient
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
        create_if_not_found: bool = False,
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
        self._session_mgr = session_twirp.SessionManagerClient(
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
        self._system_client = system_twirp.SystemClient(
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
            # Reopen the supplied session via the SessionManager.open_session
            # RPC. If the server reports it as missing/expired, fall back to
            # creating a fresh session.
            self._sesh = session_pb2.Session(id=session_id)
            try:
                self._session_mgr.open_session(
                    ctx=self.mk_context(),
                    request=session_pb2.SessionOpen(
                        id=self._sesh,
                        api_version=api_types_version.api_types_version,
                    ),
                    timeout=timeout,
                )
            except TwirpServerException as ex:
                if is_session_not_found(ex) and create_if_not_found:
                    self._sesh = self._client.create_session(
                        ctx=self.mk_context(),
                        request=simple_api_pb2.SessionCreateReq(
                            api_version=api_types_version.api_types_version
                        ),
                        timeout=timeout,
                    )
                else:
                    raise

    def __enter__(self, *_: Any) -> Self:
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
            if (
                requests is not None  # pyright: ignore[reportUnnecessaryComparison]
                and hasattr(self, "_session")
            ):
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
        compute_timeout: Optional[int] = None,
    ) -> simple_api_pb2.DecomposeRes:
        """
        Args:
            timeout (float | None): HTTP request timeout
            compute_timeout (int | None): computation timeout (in seconds) on the server
        """
        if timeout is None:
            timeout = self._timeout

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
        if compute_timeout is not None:
            req.timeout = compute_timeout

        return self._client.decompose(
            ctx=self.mk_context(),
            request=req,
            timeout=timeout,
        )

    def decompose_full(
        self,
        d: decomp.Decomp,
        timeout: Optional[float] = None,
        string_results: Optional[bool] = None,
        compute_timeout: Optional[int] = None,
    ) -> simple_api_pb2.DecomposeRes:
        """Run a compound decomposition.

        More expressive than `decompose`: `d` describes a tree of
        operations (decompose by name, prune, combine, merge, let-bind) built
        with the helpers in `imandrax_api.client.decomp`.

        Args:
            d: the decomposition to perform
            timeout (float | None): HTTP request timeout
            compute_timeout (int | None): computation timeout (in seconds) on the server
        """
        if timeout is None:
            timeout = self._timeout

        req = simple_api_pb2.DecomposeReqFull(session=self._sesh, decomp=d)
        # If None, keep it as unset
        if string_results is not None:
            req.string_results = string_results
        if compute_timeout is not None:
            req.timeout = compute_timeout

        return self._client.decompose_full(
            ctx=self.mk_context(),
            request=req,
            timeout=timeout,
        )

    def eval_src(
        self,
        src: str,
        timeout: Optional[float] = None,
        async_only: Optional[bool] = None,
        task_filter: Optional[list[str]] = None,
    ) -> simple_api_pb2.EvalRes:
        """Evaluate source code in the session.

        Args:
            timeout (float | None): HTTP request timeout
            async_only (bool | None): if true, return as soon as the tasks are
                started, without waiting for their results. The returned
                `EvalRes.tasks` can then be passed to `get_artifact`
                or `get_artifact_zip` to collect results later.
            task_filter (list[str] | None): glob patterns restricting which
                verification tasks are started, matched against the name of the
                top-level definition, e.g. `["*xyz*"]`. The default is to
                start all tasks.
        """
        timeout = timeout or self._timeout
        req = simple_api_pb2.EvalSrcReq(
            src=src, session=self._sesh, task_filter=task_filter
        )
        # If None, keep it as unset
        if async_only is not None:
            req.async_only = async_only

        return self._client.eval_src(
            ctx=self.mk_context(),
            request=req,
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

    def verify_name(
        self,
        name: str,
        hints: Optional[str] = None,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.VerifyRes:
        """Verify an already-defined predicate, by name."""
        timeout = timeout or self._timeout
        return self._client.verify_name(
            ctx=self.mk_context(),
            request=simple_api_pb2.VerifyNameReq(
                name=name, session=self._sesh, hints=hints
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

    def instance_name(
        self,
        name: str,
        hints: Optional[str] = None,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.InstanceRes:
        """Find an instance of an already-defined predicate, by name."""
        timeout = timeout or self._timeout
        return self._client.instance_name(
            ctx=self.mk_context(),
            request=simple_api_pb2.InstanceNameReq(
                name=name, session=self._sesh, hints=hints
            ),
            timeout=timeout,
        )

    def test_src(
        self,
        src: str,
        seed: Optional[int] = None,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.TestRes:
        req = simple_api_pb2.TestSrcReq(src=src, session=self._sesh)
        if seed is not None:
            req.seed = seed

        timeout = timeout or self._timeout
        return self._client.test_src(
            ctx=self.mk_context(),
            request=req,
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
        req = simple_api_pb2.TestNameReq(name=name, session=self._sesh)
        if seed is not None:
            req.seed = seed

        timeout = timeout or self._timeout
        return self._client.test_name(
            ctx=self.mk_context(),
            request=req,
            timeout=timeout,
        )

    def qcheck_name(
        self,
        name: str,
        seed: Optional[int] = None,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.TestRes:
        return self.test_name(name, seed, timeout)

    # Artifacts
    # ---------

    def list_artifacts(
        self, task: task_pb2.Task, timeout: Optional[float] = None
    ) -> api_pb2.ArtifactListResult:
        timeout = timeout or self._timeout
        return self._api_client.list_artifacts(
            ctx=self.mk_context(),
            request=api_pb2.ArtifactListQuery(task_id=task.id),
            timeout=timeout,
        )

    def get_artifact(
        self, task: task_pb2.Task, kind: str, timeout: Optional[float] = None
    ) -> api_pb2.Artifact:
        """Fetch one artifact produced by `task`."""
        timeout = timeout or self._timeout
        return self._api_client.get_artifact(
            ctx=self.mk_context(),
            request=api_pb2.ArtifactGetQuery(task_id=task.id, kind=kind),
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
        self,
        names: list[str],
        timeout: Optional[float] = None,
        include_str: bool = False,
    ) -> simple_api_pb2.GetDeclsRes:
        """Look up declarations by name.

        Args:
            include_str (bool): also populate `DeclWithName.str` with the
                string representation of each declaration.
        """
        timeout = timeout or self._timeout
        return self._client.get_decls(
            ctx=self.mk_context(),
            request=simple_api_pb2.GetDeclsReq(
                session=self._sesh, name=names, str=include_str
            ),
            timeout=timeout,
        )

    def oneshot(
        self,
        input: str,
        compute_timeout: Optional[float] = None,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.OneshotRes:
        """Evaluate a self-contained snippet without using the session.

        Args:
            input (str): some IML code
            compute_timeout (float | None): computation timeout (in seconds) on the server
            timeout (float | None): HTTP request timeout
        """
        timeout = timeout or self._timeout
        req = simple_api_pb2.OneshotReq(input=input)
        # If None, keep it as unset
        if compute_timeout is not None:
            req.timeout = compute_timeout

        return self._client.oneshot(
            ctx=self.mk_context(),
            request=req,
            timeout=timeout,
        )

    # Code snippets
    # -------------

    def eval_code_snippet(
        self,
        code: str,
        task_filter: Optional[list[str]] = None,
        timeout: Optional[float] = None,
    ) -> api_pb2.CodeSnippetEvalResult:
        """Evaluate a snippet, returning only the tasks it started.

        Always asynchronous: collect the results via `get_artifact`.

        Args:
            task_filter (list[str] | None): glob patterns restricting which
                verification tasks are started, as in `eval_src`.
        """
        timeout = timeout or self._timeout
        return self._api_client.eval_code_snippet(
            ctx=self.mk_context(),
            request=api_pb2.CodeSnippet(
                session=self._sesh, code=code, task_filter=task_filter
            ),
            timeout=timeout,
        )

    def parse_term(
        self, code: str, timeout: Optional[float] = None
    ) -> api_pb2.Artifact:
        """Parse and typecheck `code` as a term, returning it as an artifact."""
        timeout = timeout or self._timeout
        return self._api_client.parse_term(
            ctx=self.mk_context(),
            request=api_pb2.CodeSnippet(session=self._sesh, code=code),
            timeout=timeout,
        )

    def parse_type(
        self, code: str, timeout: Optional[float] = None
    ) -> api_pb2.Artifact:
        """Parse and typecheck `code` as a type, returning it as an artifact."""
        timeout = timeout or self._timeout
        return self._api_client.parse_type(
            ctx=self.mk_context(),
            request=api_pb2.CodeSnippet(session=self._sesh, code=code),
            timeout=timeout,
        )

    # Session lifecycle
    # -----------------

    @property
    def session_id(self) -> str:
        return self._sesh.id

    def keep_session_alive(self, timeout: Optional[float] = None) -> None:
        timeout = timeout or self._timeout
        self._session_mgr.keep_session_alive(
            ctx=self.mk_context(),
            request=self._sesh,
            timeout=timeout,
        )

    # System
    # ------

    def version(self, timeout: Optional[float] = None) -> system_pb2.VersionResponse:
        timeout = timeout or self._timeout
        return self._system_client.version(
            ctx=self.mk_context(),
            request=utils_pb2.Empty(),
            timeout=timeout,
        )

    def gc_stats(self, timeout: Optional[float] = None) -> system_pb2.Gc_stats:
        timeout = timeout or self._timeout
        return self._system_client.gc_stats(
            ctx=self.mk_context(),
            request=utils_pb2.Empty(),
            timeout=timeout,
        )

    def release_memory(self, timeout: Optional[float] = None) -> system_pb2.Gc_stats:
        """Ask the server to free memory, returning the resulting GC statistics."""
        timeout = timeout or self._timeout
        return self._system_client.release_memory(
            ctx=self.mk_context(),
            request=utils_pb2.Empty(),
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
