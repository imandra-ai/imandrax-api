# py-gen

IML to Python Code Generator

## Documentation

- Refer to `docs/` directory for detailed documentation on everything.
- For writing documentation, see `docs/README.md`.

## Background

This project implements a code generation tool that transforms IML (Imandra Modeling Language) models into executable Python code. IML is a pure functional subset of OCaml designed for automated reasoning, with mechanized formal semantics. This generator enables the use of formally verified IML models in Python-based systems.

## Overview

The code generation pipeline consists of two main phases:

### Phase 1: Artifact Loading (Implemented)
- Load IML model artifacts (stored in Twine binary format)
- Decode to OCaml `Mir.Model.t` representation (see `decode_art.ml`)

### Phase 2: Python AST Construction (Planned)
- Traverse the `Mir.Model.t` structure
- Map IML types to Python types
- Generate Python AST nodes

## Key Concepts

### IML Models
An IML model is a value that represents:
- Type interpretations (including finite domains and aliases)
- Constant function interpretations
- Function interpretations with case-based definitions
- Type substitutions applied during model extraction

Models are the output of Imandra's verification process and contain concrete interpretations of types and functions.

### Artifacts
Artifacts are IML values serialized in Twine binary format with:
- `kind`: Type identifier (e.g., "mir.model")
- `data`: Base64-encoded Twine binary data
- `api_version`: Compatibility version
- `storage`: Additional metadata

See `examples/art/movement` for a concrete example.
