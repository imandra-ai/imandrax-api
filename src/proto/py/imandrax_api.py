from twirp.context import Context
from bindings import error_pb2, locs_pb2, utils_pb2, simple_api_twirp, simple_api_pb2


class Client(object):
    def __init__(self, url: str, server_path_prefix="/api/v1") -> None:
        self._url = url
        self._server_path_prefix = server_path_prefix
        self._client = simple_api_twirp.SimpleClient(url)

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
