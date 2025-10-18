---
- written_by_ai: true
---
# Architecture

## System Overview

The py-gen system transforms formally verified IML models into executable Python code through a two-phase pipeline: artifact deserialization and Python code generation.

```
┌─────────────┐     ┌──────────────┐     ┌───────────────┐
│  IML Model  │────▶│   Artifact   │────▶│  Mir.Model.t  │
│             │     │   (Twine)    │     │   (OCaml)     │
└─────────────┘     └──────────────┘     └───────────────┘
                                                  │
                                                  ▼
                                          ┌───────────────┐
                                          │  Python AST   │
                                          └───────────────┘
                                                  │
                                                  ▼
                                          ┌───────────────┐
                                          │  Python Code  │
                                          └───────────────┘
```

## Core Components

### 1. Artifact Loader (Implemented)

**Location**: `decode_art.ml`

**Responsibilities**:
- Parse JSON artifact format
- Decode base64-encoded Twine binary data
- Initialize MIR type and term states
- Deserialize into `Mir.Model.t` structure

**Key Dependencies**:
- `Imandrax_api_artifact.Artifact`: Artifact format handling
- `Imandrax_api_mir`: MIR type system
- `Imandrakit_twine`: Binary serialization format
- `Base64`: Data encoding/decoding

**Process**:
1. Read JSON artifact file
2. Extract `kind`, `data`, and `api_version` fields
3. Parse kind string to typed `Artifact.kind` value
4. Decode base64 data to binary
5. Create Twine decoder with MIR state
6. Deserialize using kind-specific decoder
7. Wrap in `Artifact.t` structure
8. Extract `Mir.Model.t` using `Artifact.as_model`

### 2. Model Representation (MIR)

**Type**: `Mir.Model.t` (instantiation of `Common.Model.t_poly`)

**Structure**:
```ocaml
type ('term, 'ty) t_poly = {
  tys: ('ty * ('term, 'ty) ty_def) list;
  consts: ('ty Applied_symbol.t_poly * 'term) list;
  funs: ('ty Applied_symbol.t_poly * ('term, 'ty) fi) list;
  representable: bool;
  completed: bool;
  ty_subst: (Uid.t * 'ty) list;
}
```

**Components**:
- **tys**: Type interpretations (finite domains, aliases)
- **consts**: Constant function values
- **funs**: Function interpretations with case-based definitions
- **ty_subst**: Type substitutions from model extraction

### 3. Python Code Generator (Planned)

**Responsibilities**:
- Traverse `Mir.Model.t` structure
- Map IML types to Python types
- Generate Python AST nodes
- Handle type annotations and dataclasses
- Emit formatted Python code

**Planned Architecture**:
```
Mir.Model.t
    │
    ├─▶ Type Generator ──▶ Python type definitions
    │                      (dataclasses, enums, type aliases)
    │
    ├─▶ Const Generator ──▶ Module-level constants
    │
    └─▶ Function Generator ──▶ Function definitions
                              (with pattern matching logic)
```

## Design Decisions

### Type Mapping Strategy

**IML → Python Type Mapping** (Proposed):
- IML `int` → Python `int`
- IML `real` → Python `float`
- IML `string` → Python `str`
- IML `bool` → Python `bool`
- IML `'a list` → Python `list[A]`
- IML `'a option` → Python `Optional[A]`
- IML records → Python `@dataclass`
- IML variants → Python `Enum` or tagged unions

### Function Generation Strategy

IML functions with case-based definitions need transformation:
```iml
(* IML function interpretation *)
fi_cases: [
  ([guard1_1, guard1_2], rhs1),
  ([guard2_1], rhs2),
  ...
]
fi_else: default_rhs
```

Maps to Python:
```python
def function_name(arg1: Type1, arg2: Type2) -> RetType:
    if guard1_1 and guard1_2:
        return rhs1
    elif guard2_1:
        return rhs2
    else:
        return default_rhs
```

### Error Handling

**Artifact Loading**:
- Invalid JSON: Parse error with context
- Unknown kind: Error with valid kind list
- Decode failure: Twine decoding error
- Type mismatch: MIR type error

**Code Generation** (Planned):
- Unsupported types: Warning + skip or error
- Name collisions: Prefix with module name
- Invalid Python identifiers: Sanitization rules

## Extension Points

### Custom Type Mappings
Allow user-defined mappings for specific IML types:
```ocaml
type type_mapper = Mir.Type.t -> Python.Type.t option
```

### Code Templates
Configurable templates for generated code structure:
- Module headers
- Import statements
- Type definition format
- Function signature style

### Optimization Passes
Post-generation optimizations:
- Constant folding
- Dead code elimination
- Pattern matching optimization
- Type inference for cleaner code

## Performance Considerations

### Artifact Loading
- Twine decoding is lazy where possible
- MIR state caching for repeated type lookups
- Streaming for large artifacts (future)

### Code Generation
- Single-pass traversal of model structure
- Incremental code emission
- Parallel generation for independent definitions (future)

## Testing Strategy

### Unit Tests
- Artifact loading for various model types
- Type mapping correctness
- Function generation patterns

### Integration Tests
- End-to-end: IML model → Python code → execution
- Property tests: generated code preserves semantics
- Performance benchmarks

### Validation
- Compare IML and Python execution results
- Type checking generated Python code
- Runtime behavior verification
