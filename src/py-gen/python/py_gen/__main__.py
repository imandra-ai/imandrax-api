#!/usr/bin/env python
"""CLI tool to convert OCaml AST JSON to Python source code."""

import argparse
import sys
from pathlib import Path

from py_gen.ast_deserialize import load_from_json_string
from py_gen.unparse import unparse


def main() -> None:
    parser = argparse.ArgumentParser(
        description='Convert OCaml AST JSON to Python source code'
    )
    parser.add_argument(
        'input',
        help="Input JSON file (from OCaml yojson), or '-' for stdin",
    )
    parser.add_argument(
        '-o',
        '--output',
        help='Output Python file (writes to stdout if not provided)',
        default=None,
    )

    args = parser.parse_args()

    # Read and deserialize
    if args.input == '-':
        json_str = sys.stdin.read()
    else:
        with Path(args.input).open() as f:
            json_str = f.read()

    if not json_str:
        print('Error: Input is empty')
        sys.exit(1)

    stmts = load_from_json_string(json_str)

    # Generate Python code
    python_code = unparse(stmts)

    # Write output
    if args.output:
        with Path(args.output).open('w') as f:
            f.write(python_code)
            f.write('\n')
    else:
        print(python_code)


if __name__ == '__main__':
    main()
