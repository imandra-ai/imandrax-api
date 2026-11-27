---
created-date: 2026-11-19
modified-date: 2026-11-27
---

# Language clients: adding a language and keeping parity

This document explains how an ImandraX client for a programming language is built, specifies
what every client must provide, and is the reference for auditing feature parity between the
clients we support.

## 0. About this document

### 0.1 Audience

- **Adding a language**: read chapters 1 to 9 in order; chapter 10.1 is the walkthrough.
- **Adding a feature**: chapter 10.2, then the chapter of the layer the feature lives in.
- **Reviewing a PR**: the checklist at the end of each chapter, and Appendix A.

### 0.2 How to read it

Each chapter has three parts:

1. **How it works**: a short tutorial, with pointers into the repo.
2. **Specification**: what a client provides. The key words MUST, MUST NOT, SHOULD, SHOULD NOT and
   MAY are used as in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119).
3. **Checklist**: what to verify, for a new language or a review.

The specification is normative; the tutorial parts and the examples are not.

### 0.3 This document defines parity

This document is the reference for every client. A client is written in its own language's terms,
and is at parity when it meets this specification and passes the shared tests (chapter 7).

When a client differs from this specification on purpose, the difference is recorded in
[Appendix B](#appendix-b-deliberate-differences) with its reason. A difference that is not
recorded there is a bug in the client or in this document.

### 0.4 Supported languages

| Language   | Raw bindings | Wrapper types | Client | Where                               |
| ---------- | ------------ | ------------- | ------ | ----------------------------------- |
| OCaml      | native       | native        | yes    | `src/core`, `src/lib`, `src/client` |
| Python     | yes          | yes (`v2`)    | yes    | `src/py/imandrax_api`               |
| TypeScript | yes          | yes           | yes    | `src/ts`                            |
| Rust       | yes          | no            | no     | `src/rust/lib`                      |

OCaml is the language the API types are defined in, so its "bindings" are the types themselves.
Rust has raw bindings only; it appears in chapter 2 and in the parity matrix.

## 1. Architecture

### 1.1 How it works

A client talks to the ImandraX server over HTTP. Two formats are involved:

- **Protobuf, for RPC.** Requests and responses are protobuf messages, defined in
  `src/proto/*.proto`, sent with [Twirp](https://twitchtv.github.io/twirp/docs/spec_v7.html):
  `POST <url><prefix>/<package.Service>/<method>` with an `application/protobuf` body.
- **Twine, for artifacts.** Results that carry logic data (terms, types, proof obligations,
  models, decompositions, reports, ...) come as _artifacts_: an `Artifact` message
  (`src/proto/artmsg.proto`) holding a `kind` and `data`, the value encoded in
  [twine](#24-twine-decoder), a compact binary format with sharing. They can also be downloaded as
  a zip archive holding `manifest.json` (with the kind) and `data.twine`.

The types encoded in twine are OCaml types of the API libraries (`src/lib/mir`, `src/lib/tasks`,
`src/lib/proof`, `src/lib/report`, ...). Other languages get them as generated code (chapter 2).

```
                 ┌──────────────────────── client ─────────────────────────┐
  ImandraX       │                                                         │
  server  ◀──────┼── Twirp + protobuf ──▶ RPC layer ──▶ client methods ────┼──▶ user
                 │                          │                ▲             │
                 │                          ▼                │             │
                 │                  Artifact { kind,  ──▶ twine decoder    │
                 │                    data (twine) }        + raw lib types│
                 │                                           │             │
                 │                                           ▼             │
                 │                                      wrapper types ─────┘
                 └─────────────────────────────────────────────────────────┘
```

### 1.2 Layers

Every client is built in three layers:

1. **Raw** (chapter 2): generated code.
   - protobuf messages and RPC stubs, from `src/proto/*.proto`;
   - a twine decoder;
   - the _lib types_: one type and one decoder function per OCaml API type, from `genbindings`.
2. **Wrappers** (chapter 3): types written by hand over the lib types, idiomatic in the language:
   readable names, value equality, lazy conversion, printers, convenience methods.
3. **Client** (chapter 4): connection, sessions, one method per RPC, tasks whose artifacts are
   fetched on demand and converted to wrapper types.

Users program against layers 2 and 3, which hide most of twine and of artifact fetching: a user asks
a task for its result and gets wrapper objects. Layer 1 stays importable for what the wrappers do
not cover.

### 1.3 Where each layer lives

Each language has its own directory: `src/py`, `src/ts` and `src/rust/lib`. Within it, the
generated code SHOULD be kept apart from the code written by hand, so regenerating never touches
the wrappers or the client, and the language's developer guide SHOULD say where each layer is.

## 2. Raw bindings

This is where a new language starts, and the only part Rust has. If the language has no raw
bindings yet, it first needs a `genbindings` backend (2.3) and a twine decoder (2.4); the protobuf
part (2.1) usually comes from an existing protobuf code generator.

### 2.1 Protobuf messages and RPC stubs

#### How it works

The `.proto` files in `src/proto` define the RPC services and their messages. Each language
generates the message types with a protobuf code generator for that language, run by a make
target.

The RPC stubs can be generated too, by a Twirp plugin for the generator, or written by hand: Twirp
is a thin protocol, and any HTTP client that can POST bytes and read the status and body is enough.
Python generates them; TypeScript has a small hand-written Twirp client.

#### Specification

- The generated messages MUST come from the `.proto` files in `src/proto`, by a make target, and
  MUST NOT be edited by hand.
- The RPC layer MUST implement the Twirp protocol: `POST <url><prefix>/<package.Service>/<method>`,
  body and reply in binary protobuf, errors as Twirp JSON error bodies.
- Every request MUST send the `x-api-version` header (2.5), and the `Authorization: Bearer <key>`
  header when the client has an API key.
- The RPC layer MUST map transport failures to Twirp error codes, so callers see one error type for
  them: a timeout is `deadline_exceeded`, a network failure `unavailable`, an undecodable reply
  `internal`, and an error status from an intermediary (a proxy) is mapped as in the
  [Twirp spec](https://twitchtv.github.io/twirp/docs/errors.html#http-errors-from-intermediary-proxies).
- The RPC layer MUST keep cookies the server sets and send them back with later requests, as a
  browser or a `requests.Session` does. Deployments behind a load balancer use them to route a
  session's requests to the same server, which holds the session's state.
- It MUST NOT follow redirects: Twirp uses POST, and a redirect is reported as an error.

### 2.2 Lib types from `genbindings`

#### How it works

The API types are OCaml types, registered in imandrakit's type registry. `src/lib/genbindings`
generates bindings for them in three stages:

1. Read the registered type definitions and the list of artifact kinds, each with its type.
2. Run passes shared by all languages, which normalize the definitions: expand type aliases, drop
   fields that are not serialized, and so on.
3. Hand them to the backend for the language (`gen_<lang>.ml`), which writes one file with a type
   and a decoder function per OCaml type, and a table from artifact kind to decoder.

The per-language make targets (`make genpython`, `make gents`, `make genrust` at the repo root) run
it. The lib types mirror OCaml closely, names included; making them convenient is the job of the
wrappers.

#### Specification

- The lib types MUST be generated by `genbindings` and MUST NOT be edited by hand. A fix to them is
  a fix to the backend.
- The generated file SHOULD be committed, so the client builds without an OCaml toolchain, and
  MUST be regenerated in the same change as the OCaml types it comes from.
- Every artifact kind MUST have a decoder in the table from kind to decoder.
- Decoding MUST NOT lose information: integers are arbitrary precision (`Z.t`), rationals are a
  numerator and a denominator of arbitrary precision (`Q.t`), floats are 64-bit, strings are UTF-8
  and bytes stay bytes.
- Decoding MUST preserve sharing where the language can: a value referred to twice in the twine
  data is decoded once, and both references get the same object. The wrapper layer relies on it
  (3.4). Proof terms are the exception, for now: they are decoded once per reference.
- Malformed data MUST raise the decoder's error type, with the offset where decoding failed. It
  MUST NOT crash the process, loop forever or return a partial value.

### 2.3 Adding a `genbindings` backend

For a language with no raw bindings yet:

1. Write a backend, `src/lib/genbindings/gen_<lang>.ml`, starting from the backend of the closest
   language, and register it in `genbindings.ml`.
2. Add a make target that runs it, in the language's directory and at the repo root.
3. Check that the generated file compiles, and that every artifact kind decodes a real artifact
   fetched from the server. There are no committed artifact fixtures yet; the twine fixtures in
   `src/py/tests/twine/test_data` test the twine decoder only.

### 2.4 Twine decoder

#### How it works

Twine is imandrakit's binary encoding. A value is a tree of nodes (null, bool, integer, float,
string, blob, array, dict, tag, constructor) written from the leaves up, with _pointers_ to
repeated subtrees, so shared values are written once. The entry point, the root value, is found
from the last byte of the buffer.

The reference implementation is imandrakit's `Twine.Decode`. The conformance test in
`tests/twine-conformance` checks any decoder against it: OCaml generates random values, encodes them
with imandrakit, sends the bytes to an _adapter_ for the decoder under test, and compares the
reply with the original value. Its README specifies the adapter protocol and the properties
checked: round trip, integers, rationals, sharing, no crash on corrupted input, and the same
accept or reject verdict as the reference.

#### Specification

- The decoder MUST pass the twine conformance test: implement an adapter
  (`tests/twine-conformance/<lang>_adapter.<ext>`) supporting the types `any`, `int` and `q`.
- It MUST bounds-check every read, and report malformed input as its own error type, never as
  a crash or an out-of-bounds read.
- It SHOULD cache decoded values by offset, so a shared subtree is decoded once (2.2).

### 2.5 Versioning

- A client MUST send the version of the API types it was generated for
  (`src/core/API_TYPES_VERSION`) in the `x-api-version` header of every request.
- The version MUST come from the same `API_TYPES_VERSION` as the lib types.

### Checklist

- [ ] The protobuf messages are generated by a make target, and regenerating gives no diff.
- [ ] The lib types are generated by `genbindings`, and regenerating gives no diff.
- [ ] Every artifact kind has a decoder, and decodes a real artifact of that kind.
- [ ] The twine adapter exists and the conformance test passes (except the known reference bug
      documented in its README).
- [ ] Requests send `x-api-version` and, with a key, `Authorization`, and send back the cookies
      the server set.
- [ ] Transport failures surface as Twirp errors with the codes above.

## 3. Wrapper types

The lib types are faithful to OCaml: `Mir_Term_view_Apply`, fields named `f` and `l`, polymorphic
records instantiated by hand, integers that are really booleans. The wrappers turn them into types
a user of the language would have designed: this is most of the work in a client, and where parity
matters most.

### 3.1 Principles

#### How it works

The same rules apply in every language; only the spelling changes.

| OCaml                                         | Wrapper                                                                            | Python                  | TypeScript                          |
| --------------------------------------------- | ---------------------------------------------------------------------------------- | ----------------------- | ----------------------------------- |
| variant without arguments                     | the language's enumeration                                                         | `StrEnum`               | string-literal union                |
| variant with arguments                        | one class per constructor, plus their union                                        | dataclasses + union     | classes with a `kind` field + union |
| record                                        | one class                                                                          | dataclass               | class                               |
| record wrapping a variant (`{view; ty; ...}`) | a base class for the record's fields, one subclass per constructor, plus the union | base class + subclasses | abstract base class + subclasses    |
| `'term` / `'ty` type parameters               | specialized with the wrapper term and type                                         |                         |                                     |
| `Z.t`                                         | arbitrary-precision integer                                                        | `int`                   | `bigint`                            |
| `Q.t`                                         | exact rational                                                                     | `Fraction`              | `Rational`                          |
| `'a option`                                   | the language's optional                                                            | `X \| None`             | `X \| undefined`                    |
| `'a list`, tuples                             | immutable sequences                                                                | `tuple`                 | `readonly` arrays                   |

Users discriminate variants the way the language does it: `match` or `isinstance` in Python, a
`switch` on `kind` in TypeScript, which narrows the type and checks that every case is handled.

Some OCaml types are internal and have no wrapper (e.g. `Anchor`, `Sub_anchor`).

#### Specification

- Names MUST be readable words, spelled as the language spells them (`snake_case` in Python,
  `camelCase` in TypeScript), e.g. `Apply.function` and `Apply.arguments` for OCaml's `f` and `l`.
- A concept MUST have the same name in every client, up to spelling (3.6).
- Variants MUST be represented so the language can tell the cases apart and, where it can, check
  that a `match` or `switch` covers them all.
- Wrapper values MUST be immutable.
- Wrapper types MUST present OCaml-only encodings as what they mean: an integer used as a boolean
  is a boolean, a bit field is a set of names, a `Z.t` is an integer.
- Source positions MUST be given as the server sends them: lines and columns from 1, columns
  counted in bytes of the line's UTF-8 encoding, and a location's end included. A client MUST
  document this on its position or location type.
- Wrappers SHOULD hide twine and artifact fetching from users: a user asks for a result and gets
  wrapper objects, decoded and converted on the way. Exposing them is for what the wrappers do not
  cover yet.

### 3.2 Access to the raw object

Not decided yet. The current clients keep the lib object a wrapper was converted from, as `raw`
(`_raw` in Python), which gives access to what the wrappers leave out; whether every client must
keep it is open.

### 3.3 Value equality

#### How it works

Several wrapper types are values: two objects for the same uid, type, applied symbol or pattern
head are equal, and are used as map keys and set elements (`DB.decls` is keyed by uid). Two such
objects are often distinct: the uid of a symbol in a term and the uid keying its declaration come
from different parts of the twine data.

- Python gives these classes `__eq__` and `__hash__`, and uses `dict` and `frozenset`.
- TypeScript has no hashing protocol, and `Map` and `Set` compare keys by identity. The classes have
  an `equals` method, and maps and sets keyed by them are `ValueMap` and `ValueSet`, keyed by a
  structural string computed once per object (Note [Value equality] in `lib/mir.ts`).

#### Specification

- `Uid`, `Type`, `AppliedSymbol`, `PatternHead`, `Variable` and `Rational` MUST compare by value.
- Maps and sets keyed by them MUST find an entry from any equal key, and MUST present the
  language's map and set interface (`dict` and `set` in Python, `ReadonlyMap` and `ReadonlySet` in
  TypeScript).
- In a language without user-defined hashing, the client MUST provide such maps and sets itself
  (as TypeScript's `ValueMap` and `ValueSet` do).

### 3.4 Shared nodes

Twine shares repeated subtrees, and the decoder preserves the sharing (2.2), so lib data is a
graph. Converting it to wrappers by walking every path to a node can take time exponential in the
size of the data. Decompositions are where this happens: their regions share most of their terms.
Both clients memoize conversion by lib object.

Proof terms share sub-proofs too, and converting them can be exponential. This is accepted for now (issue #203).

- Converting a decomposition MUST NOT take time exponential in the size of its twine data.

### 3.5 Lazy and eager conversion

Wrappers MAY convert their fields lazily, on first access, and cache the result: a DB holds every
declaration of the prelude, and most are never read. A wrapper that converts lazily MUST give the
same object on every access, and MUST surface a conversion error as the client's
unexpected-response error.

### 3.6 Names

A concept has one name across clients. When a language cannot use it, the difference goes in
[Appendix B](#appendix-b-deliberate-differences). Known cases:

- A field named `constructor` is `constructor_` in TypeScript: `constructor` names a class's
  constructor.
- `let` (decomposition binding) is `let_` in TypeScript, a reserved word.
- Server errors are `ErrorInfo` in TypeScript, to not shadow the global `Error`.

Each client SHOULD say in a comment, at the definition, why a name differs, in terms of its own
language.

### 3.7 Coverage

A client MUST wrap:

| Area               | What                                                                                                         |
| ------------------ | ------------------------------------------------------------------------------------------------------------ |
| MIR                | uids, types, terms, patterns, function and type definitions, declarations, rules, models, the DB (chapter 5) |
| Tasks              | proof obligation, evaluation and decomposition tasks, and their results                                      |
| Decomposition      | decompositions, regions, region status and models                                                            |
| Evaluation values  | the values `eval` returns                                                                                    |
| Proofs and reports | proof trees and reports                                                                                      |
| Errors             | server-reported errors: kind, message, the stack of context messages, and process                            |

### Checklist

- [ ] Every user-facing type is a wrapper; users get results without handling twine or artifacts.
- [ ] Variants can be matched exhaustively in the language.
- [ ] Uids, types, applied symbols, pattern heads, variables and rationals compare by value, and
      maps and sets keyed by them find entries from equal keys.
- [ ] Converting a large decomposition is not exponential.
- [ ] Every renamed concept is in Appendix B.

## 4. Client

### 4.1 How it works

A client holds a connection to one server and one session on it. Its methods map one to one to
RPCs: each builds the request, calls the RPC layer, and turns the response into wrapper types.

Responses that produce logic data create _tasks_. A task is a handle: its id and kind come with the
response, and its data (the proof obligation, the result, the DB, ...) is in artifacts fetched from
the server on first use. Users read `task.result()` (or the language's equivalent) and get wrapper
objects; listing and downloading artifacts by hand is there for what the wrappers do not cover.

### 4.2 Connecting and sessions

- A client MUST take the server URL (defaulting to the production URL), the server path prefix, and
  an API key and/or an auth token, the API key taking precedence when both are given.
- Connecting MUST create a session, or reopen a given session id, optionally creating a new one if
  it is not found.
- A server rejecting the client's API version (2.5) MUST surface as an error telling the user to
  upgrade the client.
- Closing MUST end the session, once, even when called concurrently or repeatedly. The client MUST
  support the language's scoped-resource construct (a context manager, `await using`, ...).
- The clients take the API key as an argument. Examples and tests read it from
  `IMANDRA_UNI_KEY` or `IMANDRAX_API_KEY`.

### 4.3 RPC coverage

The services are defined in `src/proto`; the method names below are their RPC names, spelled per
language.

| Group               | Methods                                                                               |
| ------------------- | ------------------------------------------------------------------------------------- |
| Server              | `status`, `version`                                                                   |
| Session             | `keep_session_alive` (create, open and end are part of connecting and closing)        |
| Evaluation          | `eval_src`, `eval_code_snippet`, `oneshot`, `typecheck`                               |
| Verify and instance | `verify_src`, `verify_name`, `instance_src`, `instance_name`, `test_src`, `test_name` |
| Decomposition       | `decompose`, `decompose_full`                                                         |
| Parsing             | `parse_term`, `parse_type`                                                            |
| Artifacts           | `list_artifacts`, `get_artifact`, `get_artifact_zip`                                  |

- A client MUST provide every method in the table, with the request's options as optional
  arguments.
- A client MUST NOT provide the deprecated `qcheck_src` and `qcheck_name` (use `test_src` and
  `test_name`), nor `get_decls`, which is being deprecated.
- A client MUST NOT provide the administration RPCs of the `System` service (`gc_stats`,
  `release_memory`, `shutdown`).
- Each response MUST be returned as a wrapper: outcomes as the language's enumeration, errors as
  error wrappers, artifacts and tasks as described in 4.5.

### 4.4 Calls

- Every method of 4.3 MUST accept a timeout, defaulting to the client's, in the language's usual
  unit. Other methods need not: reading task data (4.5) fetches with the client's timeout, and
  printers, conversions and DB lookups make no request.
- Where the language has a cancellation mechanism (an `AbortSignal`, task cancellation), methods
  SHOULD support it.
- A client MAY be synchronous, asynchronous or both, following the language's usual practice for
  network I/O. Both styles MUST offer the same methods.

### 4.5 Tasks and artifacts

- A task's data MUST be fetched on first use, and concurrent first reads MUST share one fetch.
- Later reads SHOULD return the same objects without fetching again. A client MAY drop fetched data
  that is costly to keep, such as a large decomposition's artifact once it is decoded, and fetch it
  again when it is read again.
- What was fetched and kept MUST stay readable after the client is closed, including data decoded
  from it later (a DB from a fetched task). Fetching after the client is closed, something new or
  something dropped, MUST raise the client's closed-client error.
- A task MUST be able to fetch with another client (`set_client`), e.g. a task restored from its
  id.
- A task SHOULD offer a way to fetch all of its artifacts at once.
- Task ids MUST compare by value. They are content-addressed: the same source in two sessions
  gives tasks with equal ids.

### 4.6 Errors

Apart from invalid arguments (below), all errors the client raises MUST derive from one base
class, `ImandraXError`, with subclasses for:

| Error                | When                                                                        |
| -------------------- | --------------------------------------------------------------------------- |
| transport (Twirp)    | the RPC failed: Twirp error code, message, HTTP status (2.1)                |
| server               | the server reported an error in a response; carries the error wrapper (3.7) |
| unexpected response  | the response or an artifact did not have the expected shape                 |
| closed client        | a call, or a fetch, on a closed client                                      |
| no client            | a fetch on a task created without a client                                  |
| API version mismatch | the server rejected the client's API version                                |

Malformed twine data MAY raise the twine decoder's own error (2.4) instead.

An invalid argument, such as a timeout that is not positive or a number a request field cannot
hold, is the caller's error: it MUST raise the language's error for invalid arguments (`TypeError`
or `ValueError` in Python, `RangeError` or `TypeError` in TypeScript) before any request is sent,
and MUST NOT be reported as a transport error. The error SHOULD name the argument.

Methods SHOULD return failures reported in a response (a refuted goal, a type error in the source)
as data in the result, and raise only when there is no result to return.

### Checklist

- [ ] Every method of 4.3 exists, with every request option; no excluded RPC is exposed.
- [ ] Closing is idempotent and works with the language's scoped-resource construct.
- [ ] Task data is fetched on first use, shared by concurrent reads, readable after close.
- [ ] Errors derive from `ImandraXError`, one subclass per case of 4.6.

## 5. MIR DB

### 5.1 How it works

A task's DB is the symbol database its data refers to: every declaration in scope (the prelude's
included), keyed by uid, with the rules derived from theorems. Users look up what a uid in a term
refers to, search declarations by name, and inspect which rules a theorem gives rise to.

### 5.2 Specification

- Declarations MUST be available as a map from uid to declaration.
- Lookups by uid MUST be provided for declarations, function definitions and type definitions
  (`find_declaration`, `find_function`, `find_type`), returning the language's "absent" when there
  is none. A theorem or a verify statement is found by `find_function` through its linked
  function.
- Search by name MUST be provided for the same three (`find_*_re`): a regular expression in the
  language's syntax, matched against the uid's full name from its start.
- The rules MUST be available keyed by pattern head (rewrite rules, forward-chaining and
  generalization triggers, elimination rules) and by theorem (rules each theorem gives,
  instantiation rules, rules from rule specs).
- The disabled symbols MUST be available as a set of uids.
- The DB MUST be converted lazily (3.5): it holds the whole prelude, and most of it is never read.

### 5.3 Known server behaviour

A client documents what the server sends as it is, and leaves it to the server to change. For
example:

- Type aliases are expanded: `type my_int = int` has no declaration, and declarations using it
  refer to `int`.

### Checklist

- [ ] Every lookup and search of 5.2, with search anchored at the start of the full name.
- [ ] Rules by pattern head and by theorem.
- [ ] Converting a DB only converts what is read.

## 6. Convenience features

### 6.1 Printers

There is no MIR text format: MIR is exchanged only as twine, and there is no parser from text, as
turning IML into MIR involves steps the client does not replicate (content hashing, lambda lifting,
type inference, ...). Printing a wrapper is for debugging and display.

- Terms, types, uids and the other main wrappers MUST print readably, in a syntax close to IML.
- A float MUST print so it reads as a float (`1.0`).
- Printed output is outside parity: clients MAY print differently, and tests MUST NOT compare one
  client's output with another's.

#### Uid names

A uid has a short name (its name) and a full name (its name with its suffix: a generative id or a
content hash, see Appendix C). A builtin or persistent uid has no suffix, so both names are the
same. Short names are easier to read but can clash: redefining a type gives a new constructor
`Foo` with the same short name as the old one, and only the hash tells them apart. Printers
therefore take the name from a switch.

- A client MUST provide a way to choose whether printers use short or full uid names, defaulting
  to full names. Where the choice lives (globally, on a client object, ...) is up to the client.
- A client MUST provide a way to apply the switch to a block of code only, restoring the previous
  value when the block exits, including when it exits with an error (for example,
  `with uid_style(...)` in Python, `withUidStyle(..., () => ...)` in TypeScript).
- Where the language has threads or concurrent tasks, a global choice SHOULD hold in all of
  them and the scoped form only in its own, for example by keeping the scoped value in
  context-local storage. Where the language has none, the scoped form can accept synchronous code
  only, so that no other code runs while the switch is flipped.
- Every uid a printer shows MUST follow the switch: uids, symbols, uid constants, type
  constructors, data constructors, record fields and labels, and variables.
- The switch MUST affect printed output only, never the code's logic. For example, converting a
  value to native data or searching by name gives the same result whichever names are printed.

### 6.2 Values as native data

`to_python` / `toJs` turns a term that is a value (built from constants and constructors, e.g. a
counterexample's inputs) into the language's own data, so users can work with results without
walking MIR terms.

- A client SHOULD provide this conversion.
- It MUST NOT lose or invent information: integers and rationals convert exactly, and a term with
  no faithful native form raises an error instead of being approximated.
- A client MAY convert a model's constants to a map from name to value. It MUST NOT present the map
  as the whole model: its documentation says the map holds the constants.

### 6.3 Decomposition combinators

`decompose_full` takes a request built from combinators: start from a function (`by_name`) or an
earlier decomposition (`from_artifact`), then `merge`, `compound_merge`, `prune`, `combine`, and
bind intermediate results with `let` and `get`.

- A client MUST provide every combinator, with the name spelled per language (3.6).
- `from_artifact` MUST accept an artifact, its wrapper, and a decomposition task result.

### 6.4 Regions and results

- A region MUST give its constraints, invariant and status.
- A region has a model only when its status says it is feasible. A status is computed when the
  decomposition is pruned, and that computation can time out, so a region can have no model even
  when pruned. A client MUST give the model as the language's optional.
- From the model, a region SHOULD give as helpers a sample input (the model's constant values, by
  variable uid) and the function's output on it, each as the language's optional: there is neither
  without a model.
- The constraints and the invariant as strings (`constraints_str` and `invariant_str`, requested
  with `string_results`) will be deprecated. To get a string, print the MIR wrappers instead (6.1): `constraints` and
  `invariant` are terms.
- Proof terms and reports MUST be decoded into wrappers (3.7), including a report read from a
  downloaded archive.

### Checklist

- [ ] Printers exist for the main wrappers; no test compares output across clients.
- [ ] The uid name switch defaults to full names, has a scoped form that restores it on error, and
      covers every uid a printer shows; only printed output depends on it.
- [ ] Converting values loses nothing: exact numbers, an error rather than an approximation; the
      model map's documentation says it holds the constants.
- [ ] Every combinator of 6.3, `from_artifact` accepting all three inputs.
- [ ] Region helpers of 6.4.

## 7. Testing and parity

### 7.1 How it works

Parity is checked by behaviour: each client has tests that check what this document specifies, on
the same inputs. The inputs are shared; the tests are written in each language's own terms.

### 7.2 Specification

- **Offline tests** (no server) MUST cover:
  - the twine decoder: the conformance test (2.4) and the shared fixtures in
    `src/py/tests/twine/test_data`;
  - wrapper conversion: converting a decomposition with shared nodes, value equality,
    `to_python` / `toJs` on generated values;
  - the client against a fake server: request shape, headers, error mapping, session lifecycle.
- **Integration tests** run against the server. They
  MUST cover:
  - every method of 4.3;
  - task data and results: valid and consistent with the source (a proved theorem has no model,
    a counterexample assigns exactly the goal's variables, at their types, ...);
  - the DB (chapter 5);
  - MIR invariants over everything a session produces: terms are well-typed, functions only use
    their arguments, rules are well-formed, models are ground;
  - task fetching (4.5).
- Integration tests SHOULD use the same IML sources in every client, so a server change shows up
  everywhere.
- Tests MUST assert in the client's own terms (its values, its equality, its fields), and MUST NOT
  compare against another client's printed output.
- Known server bugs MUST be tests that are expected to fail (strict), so a fix is noticed.

### Checklist

- [ ] Offline and integration suites exist
- [ ] Every area of 7.2 has tests; integration sources match the other clients'.

## 8. Documentation (optional)

A client MAY ship with a README only. When it has more documentation, this chapter applies.

### 8.1 Specification

- The API reference SHOULD be generated from doc comments, with the language's usual tool.
- Doc comments MUST describe the client in its own terms, without reference to other clients.
- The README MUST have a quickstart; a developer guide SHOULD say how to build, test and regenerate
  (1.3).
- The documentation MUST include examples, covering at least:
  - **verify**: a property proved, and a false one refuted, with its counterexample;
  - **decompose**: a function's regions, with their constraints, invariant, and sample input and
    output;
  - **eval_src**: a source with theorems, an instance and a `[@@decomp]`, then its proof obligation
    and decomposition results, and task data fetched from them.
- Every example MUST be tested: extracted from the documentation, checked by the type checker or
  linter, and run against the server by the integration tests. A block that cannot run MUST be
  marked as such explicitly.
- Each example SHOULD be self-contained, creating its own client, so it can be copied and run.

### Checklist

- [ ] The three example scenarios are present.
- [ ] Every code block is tested, or explicitly marked as not run.

## 9. Packaging and release

- A client MUST be published with the language's usual package manager and metadata, and SHOULD
  state its minimum runtime version.
- The published package MUST include the generated code (chapter 2), so installing it needs no
  OCaml toolchain or code generator.
- The package version MUST track the API types version: `0.<API_TYPES_VERSION>.<patch>`, with an
  extra component where the language's versioning allows one. A client for a new
  `API_TYPES_VERSION` is a new minor version.
- The package SHOULD expose the wrappers and the client at the top level, and the raw layer under a
  separate name.

## 10. Process

### 10.1 Adding a language

1. Raw bindings (chapter 2): protobuf messages, then a `genbindings` backend if the language has
   none, then a twine decoder passing the conformance test. A language can stop here, as Rust does.
2. Wrappers (chapter 3), starting with MIR uids, types and terms, then tasks and results.
3. The client (chapter 4), starting with connecting, `eval_src`, `verify_src` and `decompose`.
4. The DB and convenience features (chapters 5 and 6).
5. Tests along the way (chapter 7), documentation (chapter 8), packaging (chapter 9).
6. A column in Appendix A, and the language's entries in Appendix B.

The smallest useful client is steps 1 to 3 for the methods of the quickstart (8.1).

### 10.2 Adding a feature to every client

1. Change the OCaml types or the `.proto` files.
2. Regenerate the raw bindings of every language (2.2), and bump `API_TYPES_VERSION` if the types
   changed.
3. Update the wrappers and the client of every full client, with tests.
4. Update Appendix A, and Appendix B if a client differs, in the same change.

A feature can land in one client first; its row in Appendix A then says which clients lack it.

### 10.3 Reviewing a change for parity

- Does the change follow this document? Is a difference from it recorded in Appendix B?
- Are the generated files regenerated, never edited?
- Is the feature in every full client, or marked missing in Appendix A?
- Do the tests assert in the client's own terms?
- Do docs and comments describe the client without reference to another client?

## Appendix A. Parity matrix

Maintained by hand, updated in the same change as a feature. Nothing checks it automatically, so a
row can lag behind the code. The whole matrix was last checked against the code on 2026-11-24
(#205). 

✓ done, ◐ partial, ✗ missing, n/a not applicable, B different on purpose (Appendix B).
OCaml defines the types and is the server's own language, so it has no column.

| Feature                                   | Python | TypeScript | Rust |
| ----------------------------------------- | ------ | ---------- | ---- |
| Protobuf messages (2.1)                   | ✓      | ✓          | ✗    |
| Twirp RPC layer (2.1)                     | ◐      | ✓          | n/a  |
| Lib types from `genbindings` (2.2)        | ✓      | ✓          | ✓    |
| Twine decoder, conformance adapter (2.4)  | ✓      | ✓          | ◐    |
| `x-api-version` header (2.5)              | ✓      | ✓          | n/a  |
| Wrapper types (3.1, 3.7)                  | ✓      | ✓          | n/a  |
| Value equality, value maps and sets (3.3) | ✓      | B          | n/a  |
| Shared nodes (3.4)                        | ✓      | ✓          | n/a  |
| Connecting, sessions, scoped close (4.2)  | ◐      | ◐          | n/a  |
| RPC methods (4.3)                         | ✓      | ✓          | n/a  |
| Synchronous client (4.4)                  | ◐      | B          | n/a  |
| Asynchronous client (4.4)                 | ◐      | ✓          | n/a  |
| Lazy task fetching, `set_client` (4.5)    | ✓      | ✓          | n/a  |
| Errors (4.6)                              | ◐      | ✓          | n/a  |
| MIR DB lookups and search (5)             | ✓      | ✓          | n/a  |
| Printers (6.1)                            | ✓      | ✓          | n/a  |
| Uid name switch (6.1)                     | ✓      | ✓          | n/a  |
| `to_python` / `toJs` (6.2)                | ✓      | ✓          | n/a  |
| Decomposition combinators (6.3)           | ✓      | B          | n/a  |
| Region helpers, proofs, reports (6.4)     | ✓      | B          | n/a  |
| Offline and integration tests (7)         | ✓      | ✓          | ◐    |
| Tested documentation examples (8)         | ✓      | ✓          | n/a  |

Partial support (◐):

- Twirp RPC layer, Python: the Twirp code of an error reply is not read (it is always `unknown`),
  and redirects are followed instead of reported as errors.
- Connecting, Python: an API version mismatch is not detected. TypeScript: it is detected only from
  an `invalid_argument` reply to `create_session`, but the server answers an unknown version with
  an HTTP 404 (`bad_route` from an intermediary), on every call.
- Synchronous and asynchronous clients, Python: `status` takes no timeout.
- Errors, Python: transport errors and the closed-client errors do not derive from
  `ImandraXError`, and there is no API version mismatch error.

## Appendix B. Deliberate differences

| Language   | Difference                                                                                                                                                                                  | Reason                                                                                                               |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| TypeScript | fields named `constructor` are `constructor_`                                                                                                                                               | `constructor` names a class's constructor                                                                            |
| TypeScript | decomposition `let` is `let_`                                                                                                                                                               | `let` is a reserved word                                                                                             |
| TypeScript | server errors are `ErrorInfo`, not an `Error`                                                                                                                                               | not to shadow the global `Error`; it is response data, not an exception: `ServerError` is the `Error` thrown with it |
| TypeScript | value maps and sets are `ValueMap` and `ValueSet`                                                                                                                                           | JS `Map` and `Set` compare keys by identity, with no hashing protocol                                                |
| TypeScript | decoding a report from an archive is asynchronous                                                                                                                                           | it decompresses with `DecompressionStream`, which has no synchronous API                                             |
| TypeScript | logic fragments are a set of names, without unknown bits                                                                                                                                    | unknown bits have no name; they stay in the raw bit field                                                            |
| TypeScript | async client only                                                                                                                                                                           | network I/O is asynchronous in JS                                                                                    |
| Python     | a task holds its client weakly; fetching after the client is garbage-collected raises `ClientGoneError`                                                                                     | tasks do not keep a client alive                                                                                     |
| Python     | with `AsyncClient`, task data is read synchronously once fetched, and reading it before raises `NotFetchedError`; fetch with `await task.awaitable.<attribute>` or `await task.fetch_all()` | task data stays a plain attribute in both clients                                                                    |

## Appendix C. Glossary

- **Artifact**: a value the server sends in twine, with its kind (`po_task`, `decomp_res`, ...).
- **Clique**: a group of mutually recursive definitions, of types or of functions.
- **Cname, content-addressed uid**: a uid named by the hash of its definition, so the same
  definition has the same uid across sessions.
- **Generative uid**: a uid with a counter, for local variables; it differs between sessions.
- **Lib types**: the generated types mirroring OCaml (chapter 2).
- **MIR**: the intermediate representation ImandraX produces from IML; terms, types, declarations.
- **Pattern head**: what a rule's pattern starts with (a symbol, a type, ...), used to index rules.
- **Proof obligation (PO)**: a goal to prove, from a theorem, a `verify` or an `instance`.
- **Region**: a part of a function's input space, given by constraints, with the function's result
  in it (its invariant).
- **Task**: a unit of work on the server (a PO, an evaluation, a decomposition), whose data and
  result are artifacts.
- **Twine**: imandrakit's binary encoding with sharing (2.4).
- **Uid**: the unique identifier of a symbol, type or variable.
- **Uid full name**: a uid's name with its suffix, `name/<generative id>` or `name/<content hash>`;
  the name alone for builtin and persistent uids.
- **Uid short name**: a uid's name without its suffix.
- **Wrapper**: a hand-written, idiomatic type over a lib type (chapter 3).
