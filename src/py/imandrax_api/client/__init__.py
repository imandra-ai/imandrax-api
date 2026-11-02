# pyright: strict
"""Deprecated alias of `imandrax_api.v1`."""

from __future__ import annotations

import warnings
from typing import TYPE_CHECKING, Any

from .. import _CLIENT_DEPRECATION, v1  # pyright: ignore[reportPrivateUsage]
from ..v1 import Client, decomp, url_dev, url_prod

if TYPE_CHECKING:
    from ..v1 import AsyncClient

__all__ = ["AsyncClient", "Client", "decomp", "url_dev", "url_prod"]

warnings.warn(_CLIENT_DEPRECATION, DeprecationWarning, stacklevel=2)


def __getattr__(name: str) -> Any:
    # Forward everything else to v1 (`AsyncClient` lazily, and any name v1 gains)
    try:
        return getattr(v1, name)
    except AttributeError:
        raise AttributeError(f"module {__name__!r} has no attribute {name!r}") from None
