import asyncio
import json

from . import exceptions
from . import errors

try:
	import aiohttp
	_async_available = True
except ModuleNotFoundError:
	_async_available = False

if _async_available:
    class AsyncTwirpClient:
        def __init__(
            self, 
            address: str, 
            server_path_prefix: str, 
            session: aiohttp.ClientSession,
            timeout=5
        ) -> None:
            self._address = address
            self._session = session
            # prefix used for RPCs
            self._server_path_prefix = server_path_prefix
            self._timeout : aiohttp.ClientTimeout = aiohttp.ClientTimeout(total=timeout)

        async def _make_request(
            self, *, url, ctx, request, response_obj, **kwargs
        ):
            headers = ctx.get_headers()
            if "timeout" not in kwargs:
                kwargs["timeout"] = self._timeout
            if "headers" in kwargs:
                headers.update(kwargs["headers"])
            kwargs["headers"] = headers
            kwargs["headers"]["Content-Type"] = "application/protobuf"

            try:
                async with await self._session.post(
                    url=self._address + url, data=request.SerializeToString(), **kwargs
                ) as resp:
                    if resp.status == 200:
                        response = response_obj()
                        response.ParseFromString(await resp.read())
                        return response
                    try:
                        raise exceptions.TwirpServerException(
                            code=resp.status, 
                            message=resp.reason,
                            meta={"body": await resp.json()}
                        )
                    except (aiohttp.ContentTypeError, json.JSONDecodeError):
                        raise exceptions.twirp_error_from_intermediary(
                            resp.status, resp.reason, resp.headers, await resp.text()
                        ) from None
            except asyncio.TimeoutError as e:
                raise exceptions.TwirpServerException(
                    code=errors.Errors.DeadlineExceeded,
                    message=str(e) or "request timeout",
                    meta={"original_exception": e},
                )
            except aiohttp.ServerConnectionError as e:
                raise exceptions.TwirpServerException(
                    code=errors.Errors.Unavailable,
                    message=str(e),
                    meta={"original_exception": e},
                )