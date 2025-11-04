# py-gen

ImandraX artifact to Python code generator

## Usage

Take a artifact in YAML/JSON format and prints out the Python code to stdout. The input file should have keys `data` (twine data), `api_version`, and `kind` (currently only `mir.model` is supported).
```bash
dune exec bin/parse.exe artifact.yaml - 2>/dev/null | uv run py-gen -
```
