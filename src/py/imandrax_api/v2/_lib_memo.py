"""A memo for converting lib objects to API objects, so shared lib objects convert once"""

# Note [Lib memo]
# ~~~~~~~~~~~~~~~
# The twine decoder returns one lib object for every reference to a shared term or type, so lib
# data is a graph.
#
# Without a memo, `term_of_lib` and `type_of_lib` would convert a shared node once per
# path to it, expanding the graph into a tree: the work and the memory grow with the
# number of paths rather than the number of nodes.
#
# The memo maps `id(lib_obj)` to the converted object. It lives in a context variable for the
# duration of the outermost conversion that uses it:
# - `term_of_lib` and `type_of_lib` open a memo when none is active, so one call shares within
#   its own term;
# - conversions of data holding many terms (e.g. `Decomposition.of_lib`) use `with_lib_memo`,
#   so terms shared between their parts convert once too.
#
# Each entry also holds the lib object. That keeps it alive while the memo is, so its `id` can't
# be reused by another object, e.g. a temporary lib object built during conversion.
#
# A memo is per conversion, not global: a global one would keep lib and client objects alive
# after the result is dropped, and would share client objects between artifacts.

from __future__ import annotations

from collections.abc import Callable
from contextvars import ContextVar
from dataclasses import dataclass, field
from functools import wraps
from typing import TYPE_CHECKING

from imandrax_api import lib

if TYPE_CHECKING:
    from .mir import Term, Type


@dataclass(slots=True, eq=False)
class LibMemo:
    """The API objects converted so far in one conversion."""

    terms: dict[int, tuple[lib.Mir_Term, Term]] = field(default_factory=lambda: {})  # noqa: PIE807
    """Converted terms, keyed by lib term's memory address `id()`"""
    types: dict[int, tuple[lib.Mir_Type, Type]] = field(default_factory=lambda: {})  # noqa: PIE807
    """Converted types, keyed by lib type's memory address `id()`"""


lib_memo: ContextVar[LibMemo | None] = ContextVar("lib_memo", default=None)
"""The memo of the conversion in progress, `None` outside of one"""


def with_lib_memo[**P, R](f: Callable[P, R]) -> Callable[P, R]:
    """Run `f` with a lib memo, unless one is already active."""

    @wraps(f)
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        if lib_memo.get() is not None:
            return f(*args, **kwargs)
        token = lib_memo.set(LibMemo())
        try:
            return f(*args, **kwargs)
        finally:
            lib_memo.reset(token)

    return wrapper
