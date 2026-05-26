# pyright: strict
from __future__ import annotations

from typing import TYPE_CHECKING, Any

from .client import Client, url_dev, url_prod

if TYPE_CHECKING:
    from .client import AsyncClient

__all__ = ["Client", "AsyncClient", "url_dev", "url_prod"]


def __getattr__(name: str) -> Any:
    if name == "AsyncClient":
        from . import client

        return client.AsyncClient
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
