# pyright: strict
from __future__ import annotations

import importlib
import warnings
from typing import TYPE_CHECKING, Any

from . import v1
from .v1 import url_dev, url_prod

if TYPE_CHECKING:
    from .v1 import AsyncClient as AsyncClient
    from .v1 import Client as Client

# The deprecated `Client` / `AsyncClient` are left out so `import *` doesn't warn
__all__ = ["url_dev", "url_prod"]

# Deprecated top-level re-exports of the v1 client, resolved lazily so each
# access can warn
_DEPRECATED_V1_NAMES = frozenset({"AsyncClient", "Client"})

_CLIENT_DEPRECATION = (
    "`imandrax_api.client` is deprecated and will soon point to the new v2 client. "
    "Import from `imandrax_api.v2` to switch to v2 now, or from `imandrax_api.v1` "
    "to stay on v1"
)


def __getattr__(name: str) -> Any:
    if name in _DEPRECATED_V1_NAMES:
        warnings.warn(
            f"`imandrax_api.{name}` is deprecated and will soon point to the new "
            f"v2 client. Use `imandrax_api.v2.{name}` to switch to v2 now, or "
            f"`imandrax_api.v1.{name}` to stay on v1",
            DeprecationWarning,
            stacklevel=2,
        )
        return getattr(v1, name)
    if name == "client":
        # `imandrax_api.client` used to be imported eagerly; importing it here
        # keeps `import imandrax_api; imandrax_api.client.X` working. Warn here so
        # the warning points at the caller, and silence the module's own warning,
        # which would point at this file
        warnings.warn(_CLIENT_DEPRECATION, DeprecationWarning, stacklevel=2)
        with warnings.catch_warnings():
            warnings.simplefilter("ignore", DeprecationWarning)
            return importlib.import_module(".client", __name__)
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
