from collections.abc import Iterable, Iterator, Mapping
from typing import override


class FrozenMap[K, V](Mapping[K, V]):
    """A read-only mapping that hashes by content, for the mapping fields of frozen dataclasses

    A minimal stand-in for Python 3.15's builtin `frozendict`"""

    __slots__ = ("_d",)

    _d: dict[K, V]

    def __init__(self, items: Mapping[K, V] | Iterable[tuple[K, V]] = ()):
        self._d = dict(items)

    @override
    def __getitem__(self, key: K) -> V:
        return self._d[key]

    @override
    def __iter__(self) -> Iterator[K]:
        return iter(self._d)

    @override
    def __len__(self) -> int:
        return len(self._d)

    @override
    def __hash__(self) -> int:
        return hash(frozenset(self._d.items()))

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self._d!r})"
