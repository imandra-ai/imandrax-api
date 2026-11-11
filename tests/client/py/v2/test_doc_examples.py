"""Run the Python code blocks in the docs (src/py/docs), and check their printed output

Each `print` in a code block is followed by its output as `#>` comments. Run with
`--update-examples` to rewrite those comments (and reformat the blocks) from the
actual output.

A block whose fence has `test="skip"` is linted but not run.
"""
# ai-disclosure: ai-generated

from pathlib import Path

import pytest
from inline_snapshot import snapshot
from pytest_examples import CodeExample, EvalExample, find_examples

DOCS_DIR = Path(__file__).parents[4] / "src" / "py" / "docs"
EXAMPLES = list(find_examples(DOCS_DIR))


def test_examples_count():
    assert len(EXAMPLES) == snapshot(5)


@pytest.mark.network
@pytest.mark.parametrize("example", EXAMPLES, ids=str)
def test_doc_example_lint_and_run(
    example: CodeExample,
    eval_example: EvalExample,
    api_key: str | None,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Lint code block, then run it as is and check its `#>` output

    Each block creates its own client, so it can be copied and run on its own.

    If `--update-examples` presents in `pytest` args, expected output are updated by snapshotting
    """
    eval_example.set_config(target_version="py310", line_length=120)
    if eval_example.update_examples:
        eval_example.format(example)
    else:
        eval_example.lint(example)

    if example.prefix_settings().get("test") == "skip":
        pytest.skip("not run, per the code block's `test` setting")

    # Blocks read the key from the environment
    if api_key is not None:
        monkeypatch.setenv("IMANDRAX_API_KEY", api_key)
    if eval_example.update_examples:
        eval_example.run_print_update(example)
    else:
        eval_example.run_print_check(example)
