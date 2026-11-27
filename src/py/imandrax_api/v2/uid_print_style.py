"""Whether uids print by short name or by full name (the default)"""

from collections.abc import Generator
from contextlib import contextmanager
from contextvars import ContextVar
from typing import Literal

type UidStyle = Literal["short", "full"]

_UID_STYLES: tuple[UidStyle, ...] = ("short", "full")

# The global choice is a plain variable so that every thread sees it; a scoped choice is held in a
# context variable so that it stays within its thread or asyncio task.
_global_uid_style: UidStyle = "full"
_scoped_uid_style: ContextVar[UidStyle | None] = ContextVar(
    "imandrax_api_uid_style", default=None
)


def _check_uid_style(style: UidStyle) -> None:
    if style not in _UID_STYLES:
        raise ValueError(f"uid style must be one of {_UID_STYLES}, not {style!r}")


def get_uid_style() -> UidStyle:
    """The style set by an enclosing `uid_style` block, else the global one"""
    return _scoped_uid_style.get() or _global_uid_style


def set_uid_style(style: UidStyle) -> None:
    """Set the style for every thread; a `uid_style` block overrides it"""
    global _global_uid_style
    _check_uid_style(style)
    _global_uid_style = style


@contextmanager
def uid_style(style: UidStyle) -> Generator[None]:
    """Override the style within the block, in the current thread or asyncio task only"""
    _check_uid_style(style)
    token = _scoped_uid_style.set(style)
    try:
        yield
    finally:
        _scoped_uid_style.reset(token)
