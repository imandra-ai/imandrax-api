# pyright: strict
"""Deprecated alias of `imandrax_api.v1`."""

from __future__ import annotations

import warnings
from typing import TYPE_CHECKING, Any

from .. import v1
from ..v1 import Client, decomp, url_dev, url_prod

if TYPE_CHECKING:
    from ..v1 import AsyncClient

__all__ = ["AsyncClient", "Client", "decomp", "url_dev", "url_prod"]

warnings.warn(
    "`imandrax_api.client` is deprecated; use the new client in `imandrax_api.v2`, "
    "or `imandrax_api.v1` to keep the current one",
    DeprecationWarning,
    stacklevel=2,
)


def __getattr__(name: str) -> Any:
    if name == "AsyncClient":
        return v1.AsyncClient
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
