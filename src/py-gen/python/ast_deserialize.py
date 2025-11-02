"""Simple recursive deserializer for OCaml yojson AST format.

OCaml format: ["Tag", {...}] for variants with fields, ["Tag"] for empty variants.
Location info is NOT deserialized - use ast.fix to add it later.
"""

from __future__ import annotations

from typing import Any

from . import ast_types as ast


def deserialize_constant_value(value: Any) -> Any:
    """Deserialize constant value from OCaml tagged format."""
    if (
        isinstance(value, list)
        and len(value) >= 1
        and isinstance(value[0], str)
    ):
        tag = value[0]
        if tag == 'Unit':
            return None
        elif tag in ('String', 'Bytes', 'Bool', 'Int', 'Float'):
            return value[1]
    return value


def deserialize(value: Any) -> Any:
    """Recursively deserialize OCaml yojson to Python AST objects."""
    if value is None:
        return None

    if isinstance(value, (str, int, float, bool, bytes)):
        return value

    if isinstance(value, dict):
        # Recursively deserialize dict values
        return {k: deserialize(v) for k, v in value.items()}

    if isinstance(value, list):
        # Check if it's a tagged tuple ["Tag", ...] or just a list
        if len(value) >= 1 and isinstance(value[0], str):
            tag = value[0]

            # Empty variant: ["Tag"]
            if len(value) == 1:
                return getattr(ast, tag)()

            # Variant with data: ["Tag", {...}]
            if len(value) == 2 and isinstance(value[1], dict):
                data = value[1]
                cls = getattr(ast, tag)

                # Special handling for Constant.value field
                if tag == 'Constant' and 'value' in data:
                    kwargs = {k: deserialize(v) for k, v in data.items()}
                    kwargs['value'] = deserialize_constant_value(data['value'])
                    return cls(**kwargs)

                # Recursively deserialize all fields
                kwargs = {k: deserialize(v) for k, v in data.items()}
                return cls(**kwargs)

        # Plain list - recursively deserialize elements
        return [deserialize(item) for item in value]

    return value


def load_stmt_list(json_data: list[Any]) -> list[ast.stmt]:
    """Load a list of statements from OCaml JSON."""
    return deserialize(json_data)


def load_from_json_string(json_string: str) -> list[ast.stmt]:
    """Load statements from a JSON string."""
    import json

    data = json.loads(json_string)
    return load_stmt_list(data)
