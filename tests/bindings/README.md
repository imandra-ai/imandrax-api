# Bindings tests

These tests check that the Python client decodes artifacts correctly. The test inputs are **golden
cases**: OCaml values built with the type definitions in this repository (`src/lib`, `src/core`),
and encoded with its encoding functions. The Python bindings are generated from those same
definitions. That the server uses them unchanged is an assumption these tests do not check. The
Python side decodes each case into the client's wrapper classes and checks the result.

```
cases_*.ml ──gen.exe──► golden/<kind>/<name>.pb ──test_golden.py──► golden/<kind>/<name>.json
 (OCaml values)          (artifacts, checked in)    (decode, dump)     (expected, checked in, reviewed)
```

Python tests run without OCaml, because the `.pb` and `.json` files are checked in. Only
regenerating the cases needs the OCaml toolchain.

## Files

| File | Contents |
|---|---|
| `builders.ml` | Builders for the values: uids, types, terms, errors, storage pointers (`store`), and `case` |
| `cases_<topic>.ml` | The cases, one module per topic: `term`, `decl`, `model`, `report`, `po_res`, `eval_res`, `decomp`, `task` |
| `gen.ml` | Writes every case to `golden/` |
| `golden/<kind>/<name>.pb` | A case: an `Artifact` protobuf message, see below |
| `golden/<kind>/<name>.json` | The case's expected decoding |
| `test_golden.py` | Decodes the cases and checks the decodings |
| `shapes.py` | What data an artifact can hold, and what a case holds |
| `test_coverage.py` | The coverage gate |

## Case format

Each `.pb` file is an artifact in the form the API uses: a protobuf `Artifact` message
(`artmsg.proto`), written with `Proto.to_msg_str` from `src/lib/artifact`. The Python side reads it
the way the client reads an artifact from a response, with `Artifact.of_raw`.

```
Artifact {
  kind        = "po_task"
  data        = <the OCaml value, encoded with twine>
  storage     = [ {key, value = <twine bytes>}, ... ]
  api_version = ...
}
```

The storage holds values that `data` refers to through a content-addressed pointer (`Ca_ptr`), e.g.
the operations of a task's database. A pointer is a key; the client looks it up in `storage` and
decodes the bytes. Build a pointer and its storage entry with `Builders.store`, and pass the entries
to `case ~storage`.

The keys `store` builds follow `Ca_ptr.store` in `src/lib/ca_store`, with made-up type names. The
client only uses a key to look it up, so it does not matter whether they match the keys the server
would build.

## The tests

### `test_golden.py`

Each case is decoded with `DECODERS`, the same way the client decodes that kind of artifact (tasks
are built with no client, with the case as their data). The resulting wrapper is dumped to plain
data:

- dataclasses become their public fields, tagged with their class
- other wrapper classes, e.g. tasks and task results, become their public properties; a property
  that raises is dumped as `{"raises": ...}`
- below the top level, types, uids (except builtin ones) and artifacts become their `repr`
  (`COMPACT`); the `ty/*` cases check types in full

| Test | Checks |
|---|---|
| `test_golden_case` | The dump equals the expected `.json` |
| `test_decoding_keeps_every_marker` | Every marker in the case appears in the dump |
| `test_wrappers_compare_and_hash_by_content` | Decoding twice gives equal wrappers with equal hashes |
| `test_every_kind_has_a_decoder` | Every `golden/<kind>/` has a decoder |

The `.json` files are snapshots: once reviewed, they catch any change in a decoding. Whether the
first decoding is right depends on that review. The marker check catches part of it automatically.

### Markers

A **marker** is a number of at least 1000, or a string containing 4 digits in a row, e.g. `1016` or
`"descr_7004"`. The cases use markers for their scalar values, so that each one can be found in the
decoding. A marker missing from the decoding means the wrapper dropped that value.

Ordinary values like `x` or `0` would match anywhere, so they are not checked. Fields the wrappers
leave out on purpose, e.g. anchors, are listed in `DROPPED` with the reason.

The check catches dropped values, and a value copied into the wrong field. It does not catch two
fields swapped with each other.

### `test_coverage.py`: the coverage gate

`shapes.py` builds an **inventory** of every shape an artifact can hold from the generated
bindings, `imandrax_api.lib`, which `genbindings` generates from the OCaml type registry. It starts
from each artifact kind's type and follows every field, through generics, unions and storage
pointers. The shapes are:

| Shape | Meaning |
|---|---|
| `class:C` | The class `C` occurs, e.g. a variant constructor |
| `none:C.f`, `some:C.f` | The optional field `f` is absent / present |
| `nonempty:C.f` | The list field `f` has elements |
| `marker:C.f` | The scalar field `f` holds a marker |

Each case is walked the same way, guided by the types, to see which shapes it holds.
`test_every_shape_is_covered` fails if a shape is in no case, and lists those shapes with an
artifact kind that can hold them. Shapes no case can hold, e.g. a constructor whose argument type
has no values, are listed in `UNCOVERED` with the reason. `test_uncovered_is_up_to_date` fails when
an entry is no longer needed.

When the OCaml types change, the inventory changes with the regenerated bindings, and the gate
lists what the cases do not cover yet.

## Workflows

Commands for OCaml run from the repository root, with the opam switch on the `PATH`
(`PATH=$PWD/_opam/bin:$PATH`). Commands for Python run from `src/py`.

### Run the tests

```sh
uv run pytest ../../tests/bindings
```

### Add or change a case

1. Edit a `cases_*.ml` module, or add one and list it in `gen.ml`. Use markers for scalar values.
2. Regenerate the cases:
   ```sh
   dune exec tests/bindings/gen.exe -- tests/bindings/golden
   ```
   The output is deterministic: an unchanged case gives byte-identical files.
3. Write the expected decodings, and review their diff:
   ```sh
   UPDATE_GOLDEN=1 uv run pytest ../../tests/bindings
   ```
4. Run the tests again without `UPDATE_GOLDEN`.

When you remove or rename a case, delete its old `.pb` and `.json` files: `gen.exe` only writes
files.

### When the coverage gate fails

Each line names a shape and an artifact kind that can hold it, e.g.
`none:Mir_Term_view_Case.default  (term)`: no term case is a `Case` without a default. Add a case
holding it. If no case can hold it, add it to `UNCOVERED` with the reason.

### When the marker check fails

It names the field and the marker the decoding is missing. Either the wrapper should keep that
value, or it leaves it out on purpose; then add the field to `DROPPED` with the reason.

### When a wrapper changes

The decodings of the cases that use it change, and `test_golden_case` fails. Rewrite the expected
decodings with `UPDATE_GOLDEN=1` and check that the diff is the change you meant.
