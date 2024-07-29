from typing import Optional
from twirp.context import Context
from bindings import (
    task_pb2,
    utils_pb2,
    simple_api_twirp,
    simple_api_pb2,
    api_pb2,
    api_twirp,
)


class Client(object):
    def __init__(self, url: str, server_path_prefix="/api/v1") -> None:
        self._url = url
        self._server_path_prefix = server_path_prefix
        self._client = simple_api_twirp.SimpleClient(url)
        self._api_client = api_twirp.EvalClient(url)

        self._sesh = self._client.create_session(
            ctx=Context(),
            server_path_prefix=self._server_path_prefix,
            request=utils_pb2.Empty(),
        )

    def status(self) -> str:
        return self._client.status(
            ctx=Context(),
            server_path_prefix=self._server_path_prefix,
            request=utils_pb2.Empty(),
        )

    def eval_src(self, src: str) -> simple_api_pb2.EvalRes:
        return self._client.eval_src(
            ctx=Context(),
            server_path_prefix=self._server_path_prefix,
            request=simple_api_pb2.EvalSrcReq(src=src, session=self._sesh),
        )

    def verify_src(
        self, src: str, hints: Optional[simple_api_pb2.Hints] = None
    ) -> simple_api_pb2.VerifyRes:
        return self._client.verify_src(
            ctx=Context(),
            server_path_prefix=self._server_path_prefix,
            request=simple_api_pb2.VerifySrcReq(
                src=src, session=self._sesh, hints=hints
            ),
        )

    def instance_src(
        self, src: str, hints: Optional[simple_api_pb2.Hints] = None
    ) -> simple_api_pb2.InstanceRes:
        return self._client.instance_src(
            ctx=Context(),
            server_path_prefix=self._server_path_prefix,
            request=simple_api_pb2.InstanceSrcReq(
                src=src, session=self._sesh, hints=hints
            ),
        )

    def list_artifacts(self, task: task.Task) -> api_pb2.ArtifactListResult:
        return self._api_client.list_artifacts(
            ctx=Context(),
            server_path_prefix=self._server_path_prefix,
            request=api_pb2.ArtifactListQuery(session=self._sesh, task=task),
        )

    def get_artifact_zip(self, task: task_pb2.Task, kind: str) -> api_pb2.ArtifactZip:
        return self._api_client.get_artifact_zip(
            ctx=Context(),
            server_path_prefix=self._server_path_prefix,
            request=api_pb2.ArtifactGetQuery(task=Task, kind=kind),
        )
