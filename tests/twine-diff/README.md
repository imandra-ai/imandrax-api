# Twine differential test

Checks that a twine decoder decodes exactly what imandrakit's `Twine.Encode`
writes. OCaml generates random values with QCheck, encodes them with imandrakit
(the reference), sends the bytes to the decoder under test, and compares the
decoder's reply with the original value. A failure shrinks to a minimal value.

The decoder under test runs as a separate program and speaks the protocol
below, so any language can be tested. The first one is the Python decoder
(`py_decoder.py`, for `src/py/imandrax_api/lib/twine.py`).

```
OCaml                                          decoder program
-----                                          ---------------
QCheck generates v
        │
        ▼
imandrakit Twine.Encode
        │
        ▼
bytes ──── stdin: mode + length + bytes ─────▶ decoder under test reads the bytes
                                                        │
                                                        ▼
                                               prints the decoded value as one
                                               S-expression line
                                                        │
v' ◀──── parse S-expression ◀──── stdout ───────────────┘
        │
        ▼
compare v' with v
```

## Running

From the repository root:

```sh
TWINE_DIFF_DECODER="uv run --project $PWD/src/py python $PWD/tests/twine-diff/py_decoder.py" \
  dune build @tests/twine-diff/twine-diff --force
```

`uv run` creates or updates the Python environment in `src/py` before starting
the decoder. `--force` reruns the test even when nothing changed. The test is
not part of `dune test`, so the default test run never needs uv.

Environment variables:

| Variable              | Meaning                                                         |
|-----------------------|-----------------------------------------------------------------|
| `TWINE_DIFF_DECODER`  | Shell command that starts the decoder program (required).      |
| `TWINE_DIFF_COUNT`    | Cases per property, default 1000.                               |
| `QCHECK_SEED`         | Random seed. Printed at the start of every run.                 |
| `TWINE_DIFF_CORRUPT=1`| Also run the corrupted-input report (see below).                |

To run it by hand against another decoder:

```sh
TWINE_DIFF_DECODER='path/to/my_decoder' dune build @tests/twine-diff/twine-diff --force
```

## Properties

1. **Reference self-check.** imandrakit's own decoder (`ocaml_decoder.ml`)
   decodes every value back to itself, through the same printer and parser.
2. **Agreement.** The decoder's reply to the encoding of `v` is `v`.
3. **Big integers.** Mode `i` reads integers encoded as ImandraX encodes them
   (`Util_twine.Z`, including values beyond 64 bits).
4. **Sharing.** An encoding where every repeated subtree is written once and
   referred to by pointers decodes to the same value.

**Corrupted input (report only).** With `TWINE_DIFF_CORRUPT=1`, valid encodings
are truncated or have a byte overwritten. The report counts, for each case, what
the decoder replied (value, decode error, crash, or the process died) next to
what the reference decoder replied, and lists the decoder's crashes. A decoder
should never crash: it should reply with a value or a decode error. This does
not fail the run. Both decoders run as child processes here, because
imandrakit's decoder does not bounds-check every read and can segfault on
corrupted input.

## Protocol

A decoder program reads requests from stdin until it is closed, and writes one
reply line to stdout for each request, flushed.

Request:

| Bytes | Content                                   |
|-------|-------------------------------------------|
| 1     | mode: `v` or `i`                          |
| 4     | length `n` of the twine bytes, big-endian |
| `n`   | the twine bytes                           |

- Mode `v`: decode the entry point and reply with its text form.
- Mode `i`: read the entry point as an integer, accepting the bigint form (a
  blob), and reply with `(int "...")`.

Anything the program writes to stderr is shown only if it dies.

## Text form

One S-expression per reply. Every node has a label:

| Value                   | Text form                                            |
|-------------------------|------------------------------------------------------|
| null                    | `null`                                               |
| bool                    | `(bool true)`, `(bool false)`                        |
| integer                 | `(int "-3")`: decimal, any size                      |
| float (f32 or f64)      | `(f64 "<16 hex digits of the f64 bit pattern>")`     |
| string                  | `(str "<hex of the UTF-8 bytes>")`                   |
| blob                    | `(blob "<hex>")`                                     |
| array                   | `(array <item> ...)`                                 |
| dict                    | `(dict (<key> <value>) ...)`, in encoding order      |
| tag                     | `(tag <n> <value>)`                                  |
| constructor             | `(cstor <index> <arg> ...)`                          |
| explicit reference      | `(ref <value it points to>)`                         |
| the input is rejected   | `(error decode "<message>")`                         |
| anything else failed    | `(error crash "<message>")`                          |

- Hex digits are lowercase. Atoms in quotes may also be written without quotes
  when they contain no spaces or parentheses.
- Pointers are followed, so they never appear. Sharing is invisible.
- f32 values are widened to f64 before printing, as decoders return them.
- Dict entries are printed in encoding order, straight from the encoding. Do not
  go through a native map: keys can be any value, including dicts, NaN, and
  keys a language considers equal (`1`, `1.0` and `true` in Python).
- Messages are printable ASCII without `"` or `\`.
- `(error decode ...)` is the decoder's own error for malformed input.
  `(error crash ...)` is anything else, such as an unexpected exception.

OCaml compares the parsed reply with the expected value structurally. Floats
compare by bit pattern, except that any NaN equals any NaN.

## Adding a decoder

Write a program that speaks the protocol and prints the text form, using the
decoder's structural API (its array and dict cursors, scalar getters) rather
than a convenience function that builds native values. Put a single-file
program in this directory as `<lang>_decoder.<ext>`. A decoder that needs its
own build gets a subdirectory, such as `rust_decoder/`. Then run the test with
`TWINE_DIFF_DECODER` set to the command that starts it.

## Files

| File                 | Content                                                        |
|----------------------|----------------------------------------------------------------|
| `value.ml`           | value type, QCheck generator and shrinker                      |
| `encode_v.ml`        | encoding with imandrakit, plain and shared                     |
| `sexp.ml`            | the text form: printer and parser                              |
| `decoder_process.ml` | runs a decoder program as a child process                      |
| `ocaml_decoder.ml`   | the reference decoder on imandrakit's `Decode`                 |
| `py_decoder.py`      | the Python decoder program                                     |
| `twine_diff.ml`      | properties, corrupted-input report, entry point                |
