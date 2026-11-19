# imandrax-api (TypeScript)

A TypeScript client for the ImandraX API.

## Install

```sh
npm install imandrax-api
```

Requires Node 22 or later. The package is ESM only; on Node 22.12+ it can also be loaded with `require()`.

## Connecting

`Client.connect` connects to `url`:

- `urlProd` (default): Imandra's hosted production server, `https://api.imandra.ai/internal/imandrax/`
- `urlDev`: Imandra's hosted development server, `https://api.dev.imandracapital.com/internal/imandrax/`
- a self-hosted server, e.g. `{ url: "http://localhost:8089" }`

The hosted servers need an API key, passed as `apiKey`; for a self-hosted server it is optional.

`Client.connect` creates a session, or reopens one with `sessionId`. `close()`, or leaving an `await using` block, ends the session. Every method takes an options object as its last argument, with method-specific options plus `timeoutMs` and `signal`.

## Examples

The examples read the API key from `IMANDRAX_API_KEY` (or `IMANDRA_UNI_KEY`).

### Quick start

<!-- example: quickstart -->

```ts
import { Client } from "imandrax-api";

const apiKey = process.env.IMANDRAX_API_KEY || process.env.IMANDRA_UNI_KEY;

await using client = await Client.connect({ apiKey });

// 1. Load IML definitions into the session
await client.evalSrc("let f x = if x > 0 then x + 1 else 0");

// 2. Prove a property for all inputs
const prop1 = await client.verifySrc("fun x -> f x >= 0");
console.log(prop1.proved); // true

// 3. Try to prove a wrong property, and get a counterexample
const prop2 = await client.verifySrc("fun x -> f x > x");
console.log(prop2.refuted); // true
console.log(prop2.counterExample?.src); // module M = struct let x = 0 end

// 4. Find an input satisfying a goal
const inst = await client.instanceSrc("fun x -> f x = 43");
console.log(inst.instance?.src); // module M = struct let x = 42 end
```

### Region decomposition

Region decomposition splits a function's input space into disjoint regions, each given by constraints on the inputs and an invariant: the function's result in that region. See [Region Decomposition](https://imandrax.dev/docs/region-decomposition) for details.

With `prune: true`, regions proved empty are removed, and each region proved feasible comes with a sample input and the function's output on it.

<!-- example: decompose -->

```ts
import { Client } from "imandrax-api";

const apiKey = process.env.IMANDRAX_API_KEY || process.env.IMANDRA_UNI_KEY;

await using client = await Client.connect({ apiKey });

await client.evalSrc(`
let fee amount =
  if amount < 0 then 0
  else if amount < 100 then 5
  else amount / 20
`);

const res = await client.decompose("fee", { prune: true, stringResults: true });
if (res.decomposition === undefined)
  throw new Error(`decomposition failed: ${res.errors.join("\n")}`);

for (const region of res.decomposition.regions) {
  // The sample input is keyed by each variable's unique ID; key it by name instead
  const input = Object.fromEntries(
    [...(region.sample() ?? [])].map(([uid, v]) => [uid.shortName, v]),
  );
  console.log(
    region.constraintsStr?.join(" && "),
    "|",
    region.invariantStr,
    "|",
    input,
    "|",
    region.sampleOutput(),
  );
}
// amount >= 100 | amount / 20 | { amount: 100n } | 5n
// amount >= 0 && amount <= 99 | 5 | { amount: 0n } | 5n
// amount <= (-1) | 0 | { amount: -1n } | 0n
```

### All at once with `evalSrc`

The steps above can also be written in one IML source and run with a single `evalSrc`. The results of `theorem`, `verify` and `instance` statements are in `poResults`, and those of `[@@decomp ...]` in `decompResults`:

<!-- example: eval_src -->

```ts
import { Client } from "imandrax-api";

const apiKey = process.env.IMANDRAX_API_KEY || process.env.IMANDRA_UNI_KEY;

await using client = await Client.connect({ apiKey });

const res = await client.evalSrc(`
let f x = if x > 0 then x + 1 else 0

theorem f_nonneg x = f x >= 0
theorem f_increasing x = f x > x
instance (fun x -> f x = 43)

let fee amount =
  if amount < 0 then 0
  else if amount < 100 then 5
  else amount / 20
[@@decomp top () |>> prune]
`);

// For a theorem, `instance` means a counterexample was found
for (const po of res.poResults) {
  console.log(po.origin.fromSym, po.outcome);
}
// f_nonneg proof
// f_increasing instance
// _instance_6_1 instance

for (const d of res.decompResults) {
  console.log(d.success, d.decomposition?.regions.length);
}
// true 3

// Task data and results are fetched on first use
const result = await res.poResults[0]!.task.result();
console.log(result.proved); // true
```
