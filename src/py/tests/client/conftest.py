"""Server and API key shared by the tests that talk to an ImandraX server

The server is, by precedence:
- `IMANDRAX_URL`, if set
- the deployment `IMANDRAX_DEPLOYMENT` names: `dev` or `prod`
- prod
"""

import os

import pytest

import imandrax_api

_DEPLOYMENTS = {"dev": imandrax_api.url_dev, "prod": imandrax_api.url_prod}


def pytest_collection_modifyitems(items: list[pytest.Item]) -> None:
    """mark every test that (transitively) needs the API key as `network`."""
    for item in items:
        if "api_key" in getattr(item, "fixturenames", ()):
            item.add_marker(pytest.mark.network)


@pytest.fixture(scope="session")
def url() -> str:
    if url := os.environ.get("IMANDRAX_URL"):
        return url
    deployment = os.environ.get("IMANDRAX_DEPLOYMENT") or "prod"
    if deployment not in _DEPLOYMENTS:
        raise pytest.UsageError(
            f"IMANDRAX_DEPLOYMENT={deployment!r}, expected one of {sorted(_DEPLOYMENTS)}"
        )
    return _DEPLOYMENTS[deployment]


@pytest.fixture(scope="session")
def api_key() -> str | None:
    return os.environ.get("IMANDRAX_API_KEY") or os.environ.get("IMANDRA_UNI_KEY")
