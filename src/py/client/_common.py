from .. import api_types_version
from ..twirp.context import Context

url_dev = "https://api.dev.imandracapital.com/internal/imandrax/"
url_prod = "https://api.imandra.ai/internal/imandrax/"


def mk_context() -> Context:
    """Build a request context with the appropriate headers"""
    return Context(headers={"x-api-version": api_types_version.api_types_version})
