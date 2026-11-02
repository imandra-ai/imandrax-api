"""the pre-v1/v2 import paths keep working, but warn.

`imandrax_api.Client`, `imandrax_api.AsyncClient` and `imandrax_api.client` are
deprecated aliases of `imandrax_api.v1`; `imandrax_api.v1` itself and the shared
`imandrax_api.url_dev` / `url_prod` must not warn.
"""
# ai-disclosure: ai-generated

import importlib
import subprocess
import sys

import imandrax_api
import pytest
from imandrax_api import v1


def _forget_client_modules(monkeypatch: pytest.MonkeyPatch) -> None:
    """Make the next import of `imandrax_api.client` run its module body again."""
    for name in ("imandrax_api.client", "imandrax_api.client.decomp"):
        monkeypatch.delitem(sys.modules, name, raising=False)
    # Not `delattr(..., raising=False)`: its `hasattr` check would go through the
    # package `__getattr__`, which imports `imandrax_api.client`
    if "client" in vars(imandrax_api):
        monkeypatch.delattr(imandrax_api, "client")


@pytest.mark.parametrize("name", ["Client", "AsyncClient"])
def test_top_level_names_warn_and_alias_v1(name: str):
    with pytest.warns(DeprecationWarning, match=f"imandrax_api.v1.{name}"):
        value = getattr(imandrax_api, name)
    assert value is getattr(v1, name)


def test_from_import_warns():
    with pytest.warns(DeprecationWarning):
        from imandrax_api import Client
    assert Client is v1.Client


def test_client_module_warns_and_aliases_v1(monkeypatch: pytest.MonkeyPatch):
    _forget_client_modules(monkeypatch)
    with pytest.warns(DeprecationWarning, match="imandrax_api.client"):
        client = importlib.import_module("imandrax_api.client")
    assert client.Client is v1.Client
    assert client.AsyncClient is v1.AsyncClient
    assert client.decomp is v1.decomp
    assert client.url_prod == v1.url_prod


def test_client_attribute_on_package_warns(monkeypatch: pytest.MonkeyPatch):
    _forget_client_modules(monkeypatch)
    with pytest.warns(DeprecationWarning, match="imandrax_api.client"):
        client = imandrax_api.client
    assert client.Client is v1.Client


def test_client_module_forwards_other_v1_names(monkeypatch: pytest.MonkeyPatch):
    _forget_client_modules(monkeypatch)
    with pytest.warns(DeprecationWarning):
        client = importlib.import_module("imandrax_api.client")
    assert client.is_session_not_found is v1.is_session_not_found
    with pytest.raises(AttributeError):
        _ = client.no_such_name


def _run_script(code: str, *python_opts: str) -> str:
    """Run `code` as `__main__` in a fresh interpreter; return its stderr."""
    proc = subprocess.run(
        [sys.executable, *python_opts, "-c", code],
        capture_output=True,
        text=True,
        check=True,
    )
    return proc.stderr


def test_client_attribute_warning_points_at_caller():
    # Default filters only show `DeprecationWarning`s attributed to `__main__`
    stderr = _run_script("import imandrax_api\nimandrax_api.client")
    assert stderr.count("`imandrax_api.client` is deprecated") == 1
    assert stderr.startswith("<string>:2: DeprecationWarning")


def test_star_import_does_not_warn():
    _run_script("from imandrax_api import *", "-W", "error::DeprecationWarning")


def test_client_decomp_module_aliases_v1(monkeypatch: pytest.MonkeyPatch):
    _forget_client_modules(monkeypatch)
    with pytest.warns(DeprecationWarning):
        from imandrax_api.client.decomp import by_name
    assert by_name is v1.decomp.by_name


def test_v1_v2_and_urls_do_not_warn():
    # Fresh interpreter: in this one the modules are already imported
    _run_script(
        "import imandrax_api, imandrax_api.v1, imandrax_api.v2; "
        + "from imandrax_api import url_dev, url_prod",
        "-W",
        "error::DeprecationWarning",
    )
