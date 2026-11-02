# pyright: strict
from __future__ import annotations

import importlib
import warnings
from typing import TYPE_CHECKING, Any

from . import v1
from .v1 import url_dev, url_prod

if TYPE_CHECKING:
    from .v1 import AsyncClient, Client

__all__ = ["AsyncClient", "Client", "url_dev", "url_prod"]

# Deprecated top-level re-exports of the v1 client, resolved lazily so each
# access can warn
_DEPRECATED_V1_NAMES = frozenset({"AsyncClient", "Client"})


def __getattr__(name: str) -> Any:
    if name in _DEPRECATED_V1_NAMES:
        warnings.warn(
            f"`imandrax_api.{name}` is deprecated; use the new client in "
            f"`imandrax_api.v2`, or `imandrax_api.v1.{name}` to keep the current one",
            DeprecationWarning,
            stacklevel=2,
        )
        return getattr(v1, name)
    if name == "client":
        # `imandrax_api.client` used to be imported eagerly; importing it here
        # keeps `import imandrax_api; imandrax_api.client.X` working (with a warning)
        return importlib.import_module(".client", __name__)
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
