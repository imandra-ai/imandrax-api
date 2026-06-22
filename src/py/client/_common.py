from .. import api_types_version
from ..twirp.context import Context
from ..twirp.exceptions import TwirpServerException

url_dev = "https://api.dev.imandracapital.com/internal/imandrax/"
url_prod = "https://api.imandra.ai/internal/imandrax/"


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
