"""Run the Python code blocks in the docs (src/py/docs), and check their printed output

Each `print` in a code block is followed by its output as `#>` comments. Run with
`--update-examples` to rewrite those comments (and reformat the blocks) from the
actual output.

A block whose fence has `test="skip"` is linted but not run.
"""
# ai-disclosure: ai-generated

from collections.abc import Callable
from pathlib import Path

import pytest
from inline_snapshot import snapshot
from pytest_examples import CodeExample, EvalExample, find_examples

from imandrax_api.v2.interface import Client

DOCS_DIR = Path(__file__).parents[4] / "src" / "py" / "docs"
EXAMPLES = list(find_examples(DOCS_DIR))


def test_examples_found():
    assert len(EXAMPLES) == snapshot(5)


@pytest.mark.parametrize("example", EXAMPLES, ids=str)
def test_doc_example(
    example: CodeExample,
    eval_example: EvalExample,
    mk_client: Callable[[], Client],
    api_key: str | None,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    # Blocks after the quick start use `client` without creating it
    eval_example.set_config(target_version="py310", ruff_ignore=["F821"], line_length=120)
    if eval_example.update_examples:
        eval_example.format(example)
    else:
        eval_example.lint(example)

    if example.prefix_settings().get("test") == "skip":
        pytest.skip("not run, per the code block's `test` setting")

    if api_key is not None:
        monkeypatch.setenv("IMANDRAX_API_KEY", api_key)
    # A fresh session per block, so blocks don't see each other's definitions
    with mk_client() as client:
        if eval_example.update_examples:
            eval_example.run_print_update(example, module_globals={"client": client})
        else:
            eval_example.run_print_check(example, module_globals={"client": client})
