from .. import api_types_version
from .._errors import ImandraXError
from ..twirp.context import Context
from ..twirp.errors import Errors
from ..twirp.exceptions import TwirpServerException

url_dev = "https://api.dev.imandracapital.com/internal/imandrax/"
url_prod = "https://api.imandra.ai/internal/imandrax/"


class ClientClosedError(ImandraXError):
    """A request was made on a client that has already been closed"""


class EndSessionError(ImandraXError):
    """`end_session` failed when the client exited"""

    def __init__(self, session_id: str) -> None:
        super().__init__(f"error while ending session {session_id}")
        self.session_id = session_id


class ApiVersionMismatchError(ImandraXError):
    """The server rejected the client's API version"""


def api_version_error(ex: TwirpServerException) -> ApiVersionMismatchError | None:
    """The error to raise for `ex` from `create_session` or `open_session`, if it is a version
    mismatch

    A server answers a session request with an API version it doesn't support with
    `invalid_argument`. In front of the deployed servers, a gateway routes each request by its
    `x-api-version` header, and answers a version it has no server for with a bare 404, which
    maps to `bad_route` (as an error from an intermediary). Only session requests are checked, so
    a 404 elsewhere keeps its own meaning.
    """
    msg = f"API version mismatch: the server rejected API version {api_types_version.api_types_version}. Try upgrading the imandrax-api package."
    if ex.code == Errors.InvalidArgument and not is_session_not_found(ex):
        return ApiVersionMismatchError(msg)
    if (
        ex.code == Errors.BadRoute
        and ex.meta.get("http_error_from_intermediary") == "true"
    ):
        return ApiVersionMismatchError(f"{msg} If it is the latest, check the URL.")
    return None


def check_timeout(timeout: object, default: float) -> float:
    """`timeout`, or `default` when it is `None`; a timeout is a positive number of seconds

    An invalid timeout is the caller's error: it raises before any request is sent.
    """
    if timeout is None:
        return default
    if isinstance(timeout, bool) or not isinstance(timeout, (int, float)):
        raise TypeError(f"timeout must be a number of seconds, got {timeout!r}")
    if not timeout > 0:  # also rejects NaN
        raise ValueError(f"timeout must be positive, got {timeout!r}")
    return timeout


def mk_context() -> Context:
    """Build a request context with the appropriate headers"""
    return Context(headers={"x-api-version": api_types_version.api_types_version})


def is_session_not_found(ex: TwirpServerException) -> bool:
    # TODO:
    # The server currently surfaces an expired/missing session as a generic
    # internal error; the only stable signal is the substring in the body
    # message. The phrasing differs between RPCs:
    #   - SessionManager.open_session  -> "Unknown session"
    #   - other session-bearing RPCs   -> "Session not found"
    # Replace with a typed code check once the server is updated.
    body = (getattr(ex, "meta", None) or {}).get("body")  # type: ignore
    # the body of an error from an intermediary is its text
    msg = (body.get("msg") or "") if isinstance(body, dict) else ""  # type: ignore
    return (
        "Session not found" in msg
        or "Unknown session" in msg
        or "InvalidSession" in msg
    )
