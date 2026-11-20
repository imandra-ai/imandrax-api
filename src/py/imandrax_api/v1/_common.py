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

    The server answers a session request with an API version it doesn't support with
    `invalid_argument`.
    """
    if ex.code == Errors.InvalidArgument and not is_session_not_found(ex):
        return ApiVersionMismatchError(
            "API version mismatch. Try upgrading the imandrax-api package."
        )
    return None


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
    body = (getattr(ex, "meta", None) or {}).get("body") or {}  # type: ignore
    msg = body.get("msg") or ""  # type: ignore
    return (
        "Session not found" in msg
        or "Unknown session" in msg
        or "InvalidSession" in msg
    )
