import requests

from . import exceptions
from . import errors


class TwirpClient(object):
    def __init__(
        self, address, server_path_prefix: str, session=requests.Session(), timeout=5
    ):
        self._address = address
        self._timeout = timeout
        # prefix used for RPCs
        self._server_path_prefix = server_path_prefix
        # use a session for cookie persistence and such
        self._session = session

    def _make_request(self, *, url, ctx, request, response_obj, **kwargs):
        if "timeout" not in kwargs:
            kwargs["timeout"] = self._timeout
        headers = ctx.get_headers()
        if "headers" in kwargs:
            headers.update(kwargs["headers"])
        kwargs["headers"] = headers
        kwargs["headers"]["Content-Type"] = "application/protobuf"
        # twirp uses POST, which should not redirect: report a redirect, don't follow it
        kwargs["allow_redirects"] = False
        try:
            resp = self._session.post(
                url=self._address + url, data=request.SerializeToString(), **kwargs
            )
        except requests.exceptions.Timeout as e:
            raise exceptions.TwirpServerException(
                code=errors.Errors.DeadlineExceeded,
                message=str(e),
                meta={"original_exception": e},
            )
        except requests.exceptions.RequestException as e:
            # a network failure: failing to connect, a dropped connection, a broken body, ...
            raise exceptions.TwirpServerException(
                code=errors.Errors.Unavailable,
                message=str(e),
                meta={"original_exception": e},
            )
        if resp.status_code == 200:
            return exceptions.decode_response(response_obj, resp.content)
        raise exceptions.twirp_error_of_response(
            resp.status_code, resp.reason, resp.headers, resp.content
        )
