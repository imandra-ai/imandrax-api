# Twine differential test

Checks that a twine decoder decodes exactly what imandrakit's `Twine.Encode`
writes. OCaml generates random values with QCheck, encodes them with imandrakit
(the reference), sends the bytes to the decoder under test, and compares the
decoder's reply with the original value. A failure shrinks to a minimal value.

The decoder under test is wrapped in an adapter: a small program that speaks
the protocol below, so a decoder in any language can be tested. The first one
is the Python adapter (`py_adapter.py`, for
`src/py/imandrax_api/lib/twine.py`).

```
OCaml                                          adapter
-----                                          -------
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
TWINE_DIFF_DECODER="uv run --project $PWD/src/py python $PWD/tests/twine-diff/py_adapter.py" \
  dune build @tests/twine-diff/twine-diff --force
```

`--force` reruns the test even when nothing changed. The test is not part of
`dune test`, so the default test run never needs uv.

Environment variables:

| Variable              | Meaning                                                         |
|-----------------------|-----------------------------------------------------------------|
| `TWINE_DIFF_DECODER`  | Shell command that starts the adapter (required).               |
| `TWINE_DIFF_COUNT`    | Cases per property, default 1000.                               |
| `QCHECK_SEED`         | Random seed. Printed at the start of every run.                 |

To run it by hand against another decoder:

```sh
TWINE_DIFF_DECODER='path/to/my_adapter' dune build @tests/twine-diff/twine-diff --force
```

## Properties

1. **Reference self-check.** imandrakit's own decoder (`ocaml_adapter.ml`)
   decodes every value back to itself, through the same printer and parser.
2. **Agreement.** The decoder's reply to the encoding of `v` is `v`.
3. **Big integers.** Mode `i` reads integers encoded as ImandraX encodes them
   (`Util_twine.Z`, including values beyond 64 bits).
4. **Sharing.** An encoding where every repeated subtree is written once and
   referred to by pointers decodes to the same value.

Properties 5 and 6 use corrupted input: valid encodings that are truncated or
have a byte overwritten.

5. **No crash.** The decoder replies with a value or a decode error. An
   unparseable reply, or a decoder process that exits or does not reply within
   10 seconds, fails the test.
6. **Same values as the reference.** When both the decoder and the reference
   decode the bytes to a value, the two values are equal.

Whether the decoder accepts or rejects corrupted bytes is not checked. twine
does not say which inputs must be rejected, and the reference is lenient: it
returns a value for many inputs that the Python decoder rejects. The reference
decoder runs as a child process for these properties, because imandrakit's
decoder does not bounds-check every read and can segfault on corrupted input.
If the reference dies on an input, that case is skipped.

## Protocol

An adapter reads requests from stdin until it is closed, and writes one
reply line to stdout for each request, flushed. An adapter reports a crash
(anything other than rejecting the input) by exiting.

Request:

| Bytes | Content                                   |
|-------|-------------------------------------------|
| 1     | mode: `v` or `i`                          |
| 4     | length `n` of the twine bytes, big-endian |
| `n`   | the twine bytes                           |

- Mode `v`: decode the entry point and reply with its text form.
- Mode `i`: read the entry point as an integer, accepting the bigint form (a
  blob), and reply with `(int "...")`.

Write exactly one line per request: the harness waits for each reply on the
pipe, so a line written ahead of time looks like a missing reply. Anything the
program writes to stderr is shown only if it dies.

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
| the input is rejected   | `(error "<message>")`                                |

- Hex digits are lowercase. Atoms in quotes may also be written without quotes
  when they contain no spaces or parentheses.
- Pointers are followed, so they never appear. Sharing is invisible.
- f32 values are widened to f64 before printing, as decoders return them.
- Dict entries are printed in encoding order, straight from the encoding. Do not
  go through a native map: keys can be any value, including dicts, NaN, and
  keys a language considers equal (`1`, `1.0` and `true` in Python).
- Messages are printable ASCII without `"` or `\`.
- `(error ...)` is only for the decoder's own error on malformed input. Any
  other failure, such as an unexpected exception, ends the program.

OCaml compares the parsed reply with the expected value structurally. Floats
compare by bit pattern, except that any NaN equals any NaN.

## Adding a decoder

Write an adapter: a program that speaks the protocol and prints the text form,
using the decoder's structural API (its array and dict cursors, scalar getters)
rather than a convenience function that builds native values. Put a
single-file adapter in this directory as `<lang>_adapter.<ext>`. An adapter
that needs its own build gets a subdirectory, such as `rust_adapter/`. Then run
the test with `TWINE_DIFF_DECODER` set to the command that starts it.

## Files

| File                 | Content                                                        |
|----------------------|----------------------------------------------------------------|
| `value.ml`           | value type, QCheck generator and shrinker, reference encoding  |
| `sexp.ml`            | the text form: printer and parser                              |
| `decoder_client.ml`  | runs an adapter as a child process, restarted if it dies       |
| `ocaml_adapter.ml`   | the reference adapter, on imandrakit's `Decode`                |
| `twine_diff.ml`      | properties, entry point                                        |
| `py_adapter.py`      | the Python adapter                                             |
