# imandrax-api (TypeScript)

A TypeScript client for the ImandraX API.

Requires Node 22 or later. The package is ESM only; on Node 22.12+ it can also be loaded with `require()`.

## Example

```ts
import { Client } from "imandrax-api";

await using client = await Client.connect({ apiKey: process.env.IMANDRAX_API_KEY });

const res = await client.evalSrc(`
let f x = if x > 0 then x + 1 else 0
theorem f_nonneg x = f x >= 0
`);
for (const po of res.poResults) {
  console.log(po.origin.fromSym, po.outcome); // "f_nonneg" "proof"
}

const v = await client.verifySrc("fun x -> f x > 0");
console.log(v.outcome, v.counterExample?.src); // "refuted" "... x = 0 ..."

const d = await client.decompose("f");
console.log(d.decomposition?.regions.length); // 2

// task data and results are fetched on first use
const result = await res.poResults[0]!.task.result();
console.log(result.proved); // true
```

`Client.connect` creates a session, or reopens one with `sessionId`. `close()`, or leaving an `await using` block, ends the session. Every method takes an options object as its last argument, with method-specific options plus `timeoutMs` and `signal`.

## Conventions

- `Client` is async: every method returns a promise.
- Names are camelCase, e.g. `evalSrc` and `poResults`. Optional values are `undefined`, never `null`.
- Union results are discriminated by `kind`, e.g. `VerifyResponse.res` is `{ kind: "proved", proofPp }`, `{ kind: "refuted", counterExample }`, and so on. Outcome strings and enum values are camelCase (`"verifiedUpto"`, `"counterExample"`, `"nestedEqualities"`).
- Task data and results are async methods (`await task.result()`, `await task.proofObligation()`), cached after the first fetch. Concurrent calls share one request.
- A task keeps its client alive. Fetching after the client is closed rejects with `ClientClosedError`; `task.setClient(other)` switches clients.
- The server's error type is `ErrorInfo`, so it does not shadow the global `Error`.
- `report()` on task results is async, since decompressing the report is.
- `decomp.let_` has a trailing underscore because `let` is reserved in JS.

The generated layers are exported as `raw`: `raw.proto` (protobuf messages), `raw.types` (artifact types and decoders) and `raw.twine` (the decoder).

## Development

```sh
make -C src/ts check              # typecheck
make -C src/ts test               # unit tests, offline
make -C src/ts test-integration   # against the server; needs IMANDRAX_API_KEY
make -C src/ts build              # build dist/
make gents                        # from the repo root: regenerate lib/raw
```

The integration tests are in `test/integration`. The twine tests read their fixtures from `src/py/imandrax_api/lib/test_data`.
