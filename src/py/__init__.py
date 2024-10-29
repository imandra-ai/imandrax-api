import requests
import requests.cookies
from typing import Optional
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

class Client:
    def __init__(
        self,
        url: str,
        server_path_prefix="/api/v1",
        auth_token: str | None = None,
        timeout: float = 30.0,
        session_id: str | None = None,
    ) -> None:
        # use a session to help with cookies. See https://requests.readthedocs.io/en/latest/user/advanced/#session-objects
        self._session = requests.Session()
        self._auth_token = auth_token
        if auth_token:
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
            self._sesh = self._client.create_session(
                ctx=Context(),
                request=simple_api_pb2.SessionCreateReq(
                    api_version=api_types_version.api_types_version
                ),
                timeout=timeout,
            )
        else:
            # TODO: actually re-open session via RPC
            self._sesh = session_pb2.Session(
                session_id=session_id,
            )

    def status(self) -> str:
        return self._client.status(
            ctx=Context(),
            request=utils_pb2.Empty(),
        )

    def decompose(
        self,
        name: str,
        assuming: Optional[str] = None,
        basis: Optional[list[str]] = [],
        rule_specs: Optional[list[str]] = [],
        prune: Optional[bool] = True,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.DecomposeRes:
        timeout = timeout or self._timeout
        return self._client.decompose(
            ctx=Context(),
            request=simple_api_pb2.DecomposeReq(name=name,
                                                assuming=assuming,
                                                basis=basis,
                                                rule_specs=rule_specs,
                                                prune=prune,
                                                session=self._sesh),
            timeout=timeout,
        )

    def eval_src(
        self,
        src: str,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.EvalRes:
        timeout = timeout or self._timeout
        return self._client.eval_src(
            ctx=Context(),
            request=simple_api_pb2.EvalSrcReq(src=src, session=self._sesh),
            timeout=timeout,
        )

    def verify_src(
        self,
        src: str,
        hints: Optional[simple_api_pb2.Hints] = None,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.VerifyRes:
        timeout = timeout or self._timeout
        return self._client.verify_src(
            ctx=Context(),
            request=simple_api_pb2.VerifySrcReq(
                src=src, session=self._sesh, hints=hints
            ),
            timeout=timeout,
        )

    def instance_src(
        self,
        src: str,
        hints: Optional[simple_api_pb2.Hints] = None,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.InstanceRes:
        timeout = timeout or self._timeout
        return self._client.instance_src(
            ctx=Context(),
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
            ctx=Context(),
            request=api_pb2.ArtifactListQuery(task_id=task.id),
            timeout=timeout,
        )

    def get_artifact_zip(
        self, task: task_pb2.Task, kind: str, timeout: Optional[float] = None
    ) -> api_pb2.ArtifactZip:
        timeout = timeout or self._timeout
        return self._api_client.get_artifact_zip(
            ctx=Context(),
            request=api_pb2.ArtifactGetQuery(task_id=task.id, kind=kind),
            timeout=timeout,
        )
