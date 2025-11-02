"""Convert custom AST to Python stdlib AST and unparse to source code."""

import ast as stdlib_ast
import subprocess
from typing import Any, cast

from ruff.__main__ import find_ruff_bin

from . import ast_types as custom_ast

ruff_bin = find_ruff_bin()


def format_code(code: str) -> str:
    """Format Python code using ruff."""

    try:
        result = subprocess.run(
            [ruff_bin, 'format', '-'],
            input=code,
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout
    except (subprocess.CalledProcessError, FileNotFoundError):
        # If ruff fails or is not found, return original code
        return code


def remove_unused_import(code: str) -> str:
    """Lint and fix code with ruff, focusing on F401 (unused imports)."""

    ruff_bin = find_ruff_bin()

    try:
        result = subprocess.run(
            [ruff_bin, 'check', '--select', 'F401', '--fix', '-'],
            input=code,
            capture_output=True,
            text=True,
        )
        # ruff check outputs fixed code to stdout
        return result.stdout if result.stdout else code
    except (subprocess.CalledProcessError, FileNotFoundError):
        # If ruff fails or is not found, return original code
        return code


def to_stdlib(node: Any) -> Any:
    """Recursively convert custom AST node to stdlib AST node."""
    if node is None:
        return None

    # Handle primitive types
    if isinstance(node, (str, int, float, bool, bytes)):
        return node

    # Handle lists
    if isinstance(node, list):
        node_list = cast(list[Any], node)
        result: list[Any] = []
        for item in node_list:
            result.append(to_stdlib(item))
        return result

    # Handle custom AST nodes - get the corresponding stdlib class by name
    class_name = node.__class__.__name__
    stdlib_class = getattr(stdlib_ast, class_name, None)

    if stdlib_class is None:
        raise ValueError(f'No stdlib AST class found for: {class_name}')

    # Get all fields from the custom node and recursively convert them
    kwargs: dict[str, Any] = {}
    for field_name, field_value in node.__dict__.items():
        kwargs[field_name] = to_stdlib(field_value)

    return stdlib_class(**kwargs)


def unparse(
    nodes: list[custom_ast.stmt],
) -> str:
    """Convert custom AST to Python source code using stdlib ast.unparse."""
    stdlib_stmts: list[stdlib_ast.stmt] = to_stdlib(nodes)

    dataclass_import = stdlib_ast.ImportFrom(
        module='dataclasses',
        names=[stdlib_ast.alias(name='dataclass', asname=None)],
        level=0,
    )
    body = [dataclass_import, *stdlib_stmts]

    module = stdlib_ast.Module(body=body, type_ignores=[])
    stdlib_ast.fix_missing_locations(module)

    gen_code = stdlib_ast.unparse(module)

    gen_code = format_code(remove_unused_import(gen_code))

    return gen_code
