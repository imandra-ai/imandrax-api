---
- written_by_ai: true
---

# Artifact Loading

## Overview

Artifact loading is the process of deserializing IML model artifacts from their binary Twine format into OCaml `Mir.Model.t` values that can be analyzed and transformed.

## Artifact Format

### JSON Structure
```json
{
  "kind": "mir.model",
  "data": "<base64-encoded-twine-binary>",
  "api_version": "v17",
  "storage": []
}
```

**Fields**:
- `kind`: Type identifier string (e.g., "mir.model", "mir.term")
- `data`: Base64-encoded Twine binary serialization
- `api_version`: Compatibility version for decoder selection
- `storage`: Additional metadata (currently unused)

### Twine Binary Format

Twine is a compact binary serialization format that:
- Supports recursive types and sharing
- Enables incremental deserialization
- Provides type safety through type registry
- Handles cyclic references efficiently

The format uses variable-length encoding and reference tables to minimize size while maintaining fast deserialization.

## Loading Process

### Step 1: JSON Parsing
```ocaml
let json_str = CCIO.File.read_exn "examples/art/movement.json" in
let json = Yojson.Safe.from_string json_str in
```

Extract fields using `Yojson.Safe.Util`:
```ocaml
let kind_str = json |> member "kind" |> to_string in
let data_b64 = json |> member "data" |> to_string in
let api_version = json |> member "api_version" |> to_string in
```

### Step 2: Kind Parsing
```ocaml
match Artifact.kind_of_string kind_str with
| Error err -> (* handle error *)
| Ok (Artifact.Any_kind kind) -> (* proceed *)
```

The `kind` value is existentially typed, carrying:
- Type information for decoding
- Decoder function from Twine format
- Pretty-printer for debugging

### Step 3: Base64 Decoding
```ocaml
let data_bytes = Base64.decode_exn data_b64 in
```

Converts ASCII base64 string to binary bytes for Twine decoder.

### Step 4: Twine Decoder Setup
```ocaml
let decoder = Artifact.of_twine kind in
let twine_decoder = Imandrakit_twine.Decode.of_string data_bytes in
```

Create decoder function specialized for the artifact kind and initialize Twine decoder state.

### Step 5: MIR State Initialization
```ocaml
let term_state = Imandrax_api_mir.Term.State.create () in
let type_state = Imandrax_api_mir.Type.State.create () in
Imandrax_api_mir.Term.State.add_to_dec twine_decoder term_state;
Imandrax_api_mir.Type.State.add_to_dec twine_decoder type_state;
```

MIR types and terms use state for:
- Sharing common substructures
- Resolving type variables
- Maintaining symbol tables
- Handling recursive definitions

### Step 6: Deserialization
```ocaml
let entrypoint = Imandrakit_twine.Decode.get_entrypoint twine_decoder in
let decoded_data = decoder twine_decoder entrypoint in
```

Decode from the entrypoint reference, which triggers recursive deserialization of the entire structure.

### Step 7: Artifact Construction
```ocaml
let artifact = Artifact.make ~storage:[] ~kind decoded_data in
```

Wrap decoded data in `Artifact.t` container with metadata.

### Step 8: Model Extraction
```ocaml
match Artifact.as_model art with
| Some model -> (* Use Mir.Model.t value *)
| None -> (* Not a model artifact *)
```

Extract typed `Mir.Model.t` value, returning `None` if the artifact is not a model (e.g., it's a term or proof).
