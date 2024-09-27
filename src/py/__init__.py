import requests
import requests.cookies
from typing import Optional
from twirp.context import Context
from twirp import exceptions, errors
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

class ClientWithSession:
    def __init__(self, url, session, timeout=5, **kwargs):
        self._address = url
        self._timeout = timeout
        self._session = session

    def _make_request(self, *args, url, ctx, request, response_obj, **kwargs):
        # copy of the original code in twirp, except we use the session.
        if "timeout" not in kwargs:
            kwargs["timeout"] = self._timeout
        headers = ctx.get_headers()
        if "headers" in kwargs:
            headers.update(kwargs["headers"])
        kwargs["headers"] = headers
        kwargs["headers"]["Content-Type"] = "application/protobuf"
        try:
            # change here
            resp = self._session.post(
                url=self._address + url, data=request.SerializeToString(), **kwargs
            )
            if resp.status_code == 200:
                response = response_obj()
                response.ParseFromString(resp.content)
                return response
            try:
                raise exceptions.TwirpServerException.from_json(resp.json())
            except requests.JSONDecodeError:
                raise exceptions.twirp_error_from_intermediary(
                    resp.status_code, resp.reason, resp.headers, resp.text
                ) from None
            # Todo: handle error
        except requests.exceptions.Timeout as e:
            raise exceptions.TwirpServerException(
                code=errors.Errors.DeadlineExceeded,
                message=str(e),
                meta={"original_exception": e},
            )
        except requests.exceptions.ConnectionError as e:
            raise exceptions.TwirpServerException(
                code=errors.Errors.Unavailable,
                message=str(e),
                meta={"original_exception": e},
            )

class SimpleClient(ClientWithSession, simple_api_twirp.SimpleClient):
    pass

class EvalClient(ClientWithSession, api_twirp.EvalClient):
    pass


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
            self._session.headers['Authorization'] = f'Bearer {auth_token}'
        self._url = url
        self._server_path_prefix = server_path_prefix
        self._client = SimpleClient(url, timeout=timeout, session=self._session)
        self._api_client = EvalClient(url, timeout=timeout, session=self._session)
        self._timeout = timeout

        if session_id is None:
            self._sesh = self._client.create_session(
                ctx=Context(),
                server_path_prefix=self._server_path_prefix,
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
            server_path_prefix=self._server_path_prefix,
            request=utils_pb2.Empty(),
        )

    def eval_src(
        self,
        src: str,
        timeout: Optional[float] = None,
    ) -> simple_api_pb2.EvalRes:
        timeout = timeout or self._timeout
        return self._client.eval_src(
            ctx=Context(),
            server_path_prefix=self._server_path_prefix,
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
            server_path_prefix=self._server_path_prefix,
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
            server_path_prefix=self._server_path_prefix,
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
            server_path_prefix=self._server_path_prefix,
            request=api_pb2.ArtifactListQuery(task_id=task.id),
            timeout=timeout,
        )

    def get_artifact_zip(
        self, task: task_pb2.Task, kind: str, timeout: Optional[float] = None
    ) -> api_pb2.ArtifactZip:
        timeout = timeout or self._timeout
        return self._api_client.get_artifact_zip(
            ctx=Context(),
            server_path_prefix=self._server_path_prefix,
            request=api_pb2.ArtifactGetQuery(task_id=task.id, kind=kind),
            timeout=timeout,
        )
