#!/usr/bin/env python3
"""
CLI tool to convert JSON AST to Python source code.

Usage:
    python main.py <input.json> [output.py]

If output.py is not specified, prints to stdout.
"""

import ast as py_ast
import sys
from pathlib import Path


def main():
    if len(sys.argv) < 2:
        print('Usage: python main.py <input.json> [output.py]', file=sys.stderr)
        print('  Converts JSON AST to Python source code', file=sys.stderr)
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None

    # Load JSON and parse to our AST
    print(f'Loading JSON from: {input_file}', file=sys.stderr)
    try:
        stmts = load_from_json(input_file)
        print(f'Loaded {len(stmts)} statements', file=sys.stderr)
    except Exception as e:
        print(f'Error loading JSON: {e}', file=sys.stderr)
        sys.exit(1)

    # Convert to Python AST
    print('Converting to Python AST...', file=sys.stderr)
    try:
        module = convert_to_module(stmts)
    except Exception as e:
        print(f'Error converting to Python AST: {e}', file=sys.stderr)
        sys.exit(1)

    # Unparse to Python source code
    print('Unparsing to Python source...', file=sys.stderr)
    try:
        python_code = py_ast.unparse(module)
    except Exception as e:
        print(f'Error unparsing: {e}', file=sys.stderr)
        sys.exit(1)

    # Output
    if output_file:
        print(f'Writing to: {output_file}', file=sys.stderr)
        Path(output_file).write_text(python_code)
        print(f'Done! Python code written to {output_file}', file=sys.stderr)
    else:
        print('\n' + '=' * 50, file=sys.stderr)
        print('Generated Python code:', file=sys.stderr)
        print('=' * 50 + '\n', file=sys.stderr)
        print(python_code)


if __name__ == '__main__':
    main()
