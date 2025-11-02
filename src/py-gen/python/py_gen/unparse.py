"""Convert custom AST to Python stdlib AST and unparse to source code."""

from __future__ import annotations

import ast as stdlib_ast
from typing import Any, cast

from . import ast_types as custom_ast


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


def unparse(nodes: list[custom_ast.stmt]) -> str:
    """Convert custom AST to Python source code using stdlib ast.unparse."""
    stdlib_stmts: list[stdlib_ast.stmt] = to_stdlib(nodes)
    module = stdlib_ast.Module(body=stdlib_stmts, type_ignores=[])
    stdlib_ast.fix_missing_locations(module)
    return stdlib_ast.unparse(module)
