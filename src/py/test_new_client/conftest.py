"""Clients shared by the tests

client sharing is scoped by module so that IML loading won't shadow each other
"""

import os
from collections.abc import Callable, Iterator

import pytest

import imandrax_api
from imandrax_api.demo.interface import AsyncClient, Client


@pytest.fixture(scope="session")
def api_key() -> str | None:
    return os.environ.get("IMANDRAX_API_KEY") or os.environ.get("IMANDRA_UNI_KEY")


@pytest.fixture(scope="session")
def mk_client(api_key: str | None) -> Callable[[], Client]:
    return lambda: Client(url=imandrax_api.url_prod, api_key=api_key)


@pytest.fixture(scope="session")
def mk_async_client(api_key: str | None) -> Callable[[], AsyncClient]:
    return lambda: AsyncClient(url=imandrax_api.url_prod, api_key=api_key)


@pytest.fixture(scope="module")
def c(mk_client: Callable[[], Client]) -> Iterator[Client]:
    with mk_client() as c:
        yield c
