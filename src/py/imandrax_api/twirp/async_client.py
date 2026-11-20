import asyncio

import aiohttp  # type: ignore[import-not-found]

from . import exceptions
from . import errors


class AsyncTwirpClient:
    def __init__(
        self,
        address: str,
        server_path_prefix: str,
        session: aiohttp.ClientSession,
        timeout=5,
    ) -> None:
        self._address = address
        self._session = session
        # prefix used for RPCs
        self._server_path_prefix = server_path_prefix
        self._timeout: aiohttp.ClientTimeout = aiohttp.ClientTimeout(total=timeout)

    async def _make_request(self, *, url, ctx, request, response_obj, **kwargs):
        headers = ctx.get_headers()
        if "timeout" not in kwargs:
            kwargs["timeout"] = self._timeout
        if "headers" in kwargs:
            headers.update(kwargs["headers"])
        kwargs["headers"] = headers
        kwargs["headers"]["Content-Type"] = "application/protobuf"

        # twirp uses POST, which should not redirect: report a redirect, don't follow it
        kwargs["allow_redirects"] = False
        try:
            async with await self._session.post(
                url=self._address + url, data=request.SerializeToString(), **kwargs
            ) as resp:
                status, reason, headers = resp.status, resp.reason, resp.headers
                body = await resp.read()
        except asyncio.TimeoutError as e:
            raise exceptions.TwirpServerException(
                code=errors.Errors.DeadlineExceeded,
                message=str(e) or "request timeout",
                meta={"original_exception": e},
            )
        except aiohttp.ClientError as e:
            # a network failure: failing to connect, a dropped connection, a broken body, ...
            raise exceptions.TwirpServerException(
                code=errors.Errors.Unavailable,
                message=str(e),
                meta={"original_exception": e},
            )
        if status == 200:
            return exceptions.decode_response(response_obj, body)
        raise exceptions.twirp_error_of_response(status, reason, headers, body)
