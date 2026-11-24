# Twine conformance test

Checks that a twine decoder implementation decodes exactly what `imandrakit`'s `Twine.Encode` writes, thus conforming to the reference implementation.

The test is carry out by:

- gen random value: OCaml generates random values with QCheck,
- encodes them with `imandrakit.Twine.Encode` to twine bytes
- sends the bytes to the decoder under test, and compares the decoder's reply with the original value. A failure shrinks to a minimal value.

The decoder under test is wrapped in an adapter: a small program that speaks
a given protocol, so a decoder in any language can be tested:

- the protocol takes one line `<type> <hex bytes>` on stdin
- returns s-expression of `| Value of Value.t | Rational of Z.t * Z.t | Decode_error of string | Unsupported of string`

```
OCaml                                          adapter
-----                                          -------
QCheck generates v
        │
        ▼
imandrakit Twine.Encode
        │
        ▼
bytes ──── stdin: type + hex bytes ──────────▶ decoder under test reads the bytes
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

## Properties

Every decoder, imandrakit's own included, runs the same properties:

1. **Round trip**: For a random value `v`, encoded by imandrakit, the decoder's reply is `v`: it decodes the bytes to exactly the value that was encoded.
2. **Integers**: Type `int` reads integers encoded as ImandraX encodes them (`Util_twine.Z`, mostly beyond 64 bits). Skipped if the adapter does not support type `int`.
3. **Rationals**: Type `q` reads rationals encoded as ImandraX encodes them (`Util_twine.Q`). Skipped if the adapter does not support type `q`.
4. **Sharing**: An encoding where every repeated subtree is written once and referred to by pointers decodes to the same value.
5. **No crash**: The decoder replies with a value or a decode error. An unparseable reply, or a decoder process that exits or does not reply within 10 seconds, fails the test.
6. **Same verdict as the reference**: The decoder accepts exactly the inputs the reference accepts, and rejects the rest. When both accept, the two values are equal. Error messages are not compared.

Properties 5 and 6 use corrupted input: valid encodings that are truncated or
have a byte overwritten.

The reference is the spec for which inputs are malformed: a corrupted input can
still be valid twine (one changed byte of an int is another int), so it is the
reference that decides. It is the OCaml adapter, run as a child process because
it can crash on corrupted input (see [Known failure](#known-failure)). If the
reference dies on an input, that case is skipped for property 6, since there is
no verdict to compare; the OCaml job reports the crash under property 5.

### Text form (used in comparsion)

One S-expression per reply. Every node has a label:

| Value                 | Text form                                        |
| --------------------- | ------------------------------------------------ |
| null                  | `null`                                           |
| bool                  | `(bool true)`, `(bool false)`                    |
| integer               | `(int "-3")`: decimal, any size                  |
| float (f32 or f64)    | `(f64 "<16 hex digits of the f64 bit pattern>")` |
| string                | `(str "<hex of the UTF-8 bytes>")`               |
| blob                  | `(blob "<hex>")`                                 |
| array                 | `(array <item> ...)`                             |
| dict                  | `(dict (<key> <value>) ...)`, in encoding order  |
| tag                   | `(tag <n> <value>)`                              |
| constructor           | `(cstor <index> <arg> ...)`                      |
| explicit reference    | `(ref <value it points to>)`                     |
| rational (type `q`)   | `(q "<num>" "<den>")`: decimal, any size         |
| the input is rejected | `(error "<message>")`                            |
| the type is unknown   | `(unsupported "<type>")`                         |

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

## Protocol

An adapter reads requests from stdin until it is closed, and writes one
reply line to stdout for each request, flushed. 

An adapter reports a crash (anything other than rejecting the input) by exiting.

Each request is one line:

```
<type> <hex of the twine bytes>
```

The type is a name, followed by one space and the twine bytes in hex (possibly none, so the line can end right after the space).

### Types

The type says what the twine bytes represent, and so how to decode them.
Decoding always starts from the entry point (the root value, located by the
last byte of the buffer).

| Type  | The bytes are             | Decode with                                    | Expected reply        |
| ----- | ------------------------- | ---------------------------------------------- | --------------------- |
| `any` | any twine value (untyped) | the generic decoder, walking every node        | its text form         |
| `int` | an ImandraX integer       | the binding's integer reader (`Util_twine.Z`)  | `(int "<decimal>")`   |
| `q`   | an ImandraX rational      | the binding's rational reader (`Util_twine.Q`) | `(q "<num>" "<den>")` |

`any` is untyped: it reports the twine structure as written. Every other type
is a known ImandraX type, encoded with a convention on top of twine, and checks
the binding's decoder for that type rather than the generic decoder. The same
bytes get a different reply depending on the type:

- `int`: ImandraX writes every integer, small or not, as a blob holding
  `|z| << 1` with the sign in the lowest bit, little-endian (`Z.to_bits`). The
  reference reader accepts only that blob. For z = 2^64:

  ```
  any 5f010000000000000000020000000000000011   →   (blob "00000000000000000200000000000000")
  int 5f010000000000000000020000000000000011   →   (int "18446744073709551616")
  ```

  Type `any` sees a blob, since nothing in the bytes says it is an integer.
  Type `int` is told it is one, and replies with the number.

- `q`: ImandraX writes a rational as a two-item array, numerator then
  denominator, each an integer as above. The denominator is positive and the
  fraction is in lowest terms. For -1/3:

  ```
  any 6258030000000000000058060000000000000012   →   (array (blob "0300000000000000") (blob "0600000000000000"))
  q   6258030000000000000058060000000000000012   →   (q "-1" "3")
  ```

An adapter must implement `any`. For any other type it does not implement, it
replies `(unsupported "<type>")` without looking at the bytes, and the
properties that use that type are skipped. 

Write exactly one line per request: the harness waits for each reply on the
pipe, so a line written ahead of time looks like a missing reply. Anything the
program writes to stderr is shown only if it dies.

## Run test

To run it by hand against another decoder, through dune:

```sh
TWINE_CONFORMANCE_DECODER='path/to/my_adapter' dune build @tests/twine-conformance/twine-conformance --force
```

Environment variables:

| Variable                    | Meaning                                                |
| --------------------------- | ------------------------------------------------------ |
| `TWINE_CONFORMANCE_DECODER` | Shell command that starts the adapter (required).      |
| `TWINE_CONFORMANCE_NAME`    | The decoder's name in the output, default the command. |
| `TWINE_CONFORMANCE_COUNT`   | Cases per property, default 1000.                      |
| `QCHECK_SEED`               | Random seed. Printed at the start of every run.        |

## Adding a decoder

Write an adapter: a program that speaks the protocol and prints the text form,
using the decoder's structural API (its array and dict cursors, scalar getters)
rather than a convenience function that builds native values. Put a
single-file adapter in this directory as `<lang>_adapter.<ext>`. An adapter
that needs its own build gets a subdirectory, such as `rust_adapter/`. Then run
the test with `TWINE_CONFORMANCE_DECODER` set to the command that starts it.

## Files

| File                   | Content                                                         |
| ---------------------- | --------------------------------------------------------------- |
| `value.ml`             | value type, QCheck generator and shrinker, reference encoding   |
| `sexp.ml`              | the text form: printer and parser                               |
| `decoder_client.ml`    | runs an adapter as a child process, restarted if it dies        |
| `ocaml_adapter.ml`     | the OCaml adapter, on imandrakit's `Decode`; also the reference |
| `twine_conformance.ml` | properties, entry point                                         |
| `py_adapter.py`        | the Python adapter                                              |
| `ts_adapter.ts`        | the TypeScript adapter, run by Node on the built `src/ts/dist`  |

## Known failure

imandrakit's decoder does not bounds-check every read, and it is also the
reference. Both jobs fail on corrupted input because of it:

- `ocaml` job, property 5 (no crash): It crashes, for example `Assertion failed` in imandrakit's `src/twine/decode.ml` on empty input, and can segfault.
- Both jobs, property 6 (same verdict as the reference): The reference
  accepts malformed input that it should reject. It reads memory outside the
  buffer, so it returns garbage, which also differs from one run to the next.
  For the single byte `60`, Python rightly rejects the entry point at offset
  -97, and the reference replies `false`:

  ```
  decoder:   decode error: offset -97 out of bounds (buffer size 1)
  reference: false
  ```

  In the `ocaml` job, the decoder and the reference are the same decoder in two
  processes, and they disagree with each other.

A property 6 failure where the reference replies with a value and the decoder
rejects is the reference's bug. The bug is in imandrakit, so both jobs stay red
until it is fixed there.
