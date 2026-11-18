"""Clients shared by the tests

client sharing is scoped by module so that IML loading won't shadow each other
"""

from collections.abc import Callable, Iterator

import pytest

from imandrax_api.v2.interface import AsyncClient, Client


@pytest.fixture(scope="session")
def mk_client(url: str, api_key: str | None) -> Callable[[], Client]:
    return lambda: Client(url=url, api_key=api_key)


@pytest.fixture(scope="session")
def mk_async_client(url: str, api_key: str | None) -> Callable[[], AsyncClient]:
    return lambda: AsyncClient(url=url, api_key=api_key)


@pytest.fixture(scope="module")
def c(mk_client: Callable[[], Client]) -> Iterator[Client]:
    with mk_client() as c:
        yield c
