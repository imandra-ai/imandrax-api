"""Simple recursive deserializer for OCaml yojson AST format.

OCaml format: ["Tag", {...}] for variants with fields, ["Tag"] for empty
variants.
Location info is NOT deserialized - use ast.fix to add it later.
"""

from __future__ import annotations

from typing import Any, cast

from . import ast_types as ast


def deserialize_constant_value(value: Any) -> Any:
    """Deserialize constant value from OCaml tagged format."""
    if not isinstance(value, list):
        return value

    value_list = cast(list[Any], value)
    if len(value_list) < 1 or not isinstance(value_list[0], str):
        return cast(Any, value)

    tag: str = value_list[0]
    if tag == 'Unit':
        return None
    elif tag in ('String', 'Bytes', 'Bool', 'Int', 'Float'):
        return value_list[1]
    return cast(Any, value)


def deserialize(value: Any) -> Any:
    """Recursively deserialize OCaml yojson to Python AST objects."""
    if value is None:
        return None

    if isinstance(value, (str, int, float, bool, bytes)):
        return value

    if isinstance(value, dict):
        # Recursively deserialize dict values
        value_dict = cast(dict[str, Any], value)
        result: dict[str, Any] = {}
        for k, v in value_dict.items():
            result[k] = deserialize(v)
        return result

    if isinstance(value, list):
        value_list = cast(list[Any], value)
        # Check if it's a tagged tuple ["Tag", ...] or just a list
        if len(value_list) >= 1 and isinstance(value_list[0], str):
            tag: str = value_list[0]

            # Empty variant: ["Tag"]
            if len(value_list) == 1:
                return getattr(ast, tag)()

            # Variant with data: ["Tag", {...}]
            if len(value_list) == 2 and isinstance(value_list[1], dict):
                data: dict[str, Any] = cast(dict[str, Any], value_list[1])

                # Special handling: OCaml's ExprStmt maps to Python's Expr
                if tag == 'ExprStmt':
                    tag = 'Expr'

                cls = getattr(ast, tag)

                # Special handling for Constant.value field
                if tag == 'Constant' and 'value' in data:
                    kwargs: dict[str, Any] = {}
                    for k, v in data.items():
                        kwargs[k] = deserialize(v)
                    kwargs['value'] = deserialize_constant_value(data['value'])
                    return cls(**kwargs)

                # Recursively deserialize all fields
                kwargs2: dict[str, Any] = {}
                for k, v in data.items():
                    kwargs2[k] = deserialize(v)
                return cls(**kwargs2)

        # Plain list - recursively deserialize elements
        result_list: list[Any] = []
        for item in value_list:
            result_list.append(deserialize(item))
        return result_list

    return value


def load_stmt_list(json_data: list[Any]) -> list[ast.stmt]:
    """Load a list of statements from OCaml JSON."""
    return deserialize(json_data)


def load_from_json_string(json_string: str) -> list[ast.stmt]:
    """Load statements from a JSON string."""
    import json

    data = json.loads(json_string)
    return load_stmt_list(data)
