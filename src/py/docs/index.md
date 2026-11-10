# imandrax-api

Python client for the [ImandraX](https://www.imandra.ai) API.

```bash
pip install imandrax-api
```

!!! note "v1 and v2 clients"
    `imandrax_api.v2` is the new client, with more features and a more
    ergonomic API. It is the one documented here.

    `imandrax_api.client` (and `imandrax_api.Client` / `imandrax_api.AsyncClient`)
    currently point to the v1 client. They are deprecated and will soon point to
    v2. To keep using v1, import from `imandrax_api.v1`.

::: imandrax_api.v2
    options:
      members: false
      show_root_heading: false

## Endpoints

Set `url` to the server you want to connect to:

- `imandrax_api.v2.url_prod` (default): Imandra's hosted production server,
  `https://api.imandra.ai/internal/imandrax/`
- `imandrax_api.v2.url_dev`: Imandra's hosted development server,
  `https://api.dev.imandracapital.com/internal/imandrax/`
- A self-hosted server, e.g. `Client(url="http://localhost:8089")`

## Authentication

The hosted servers need an API key; for a self-hosted server it is optional.
Pass it to the client with `api_key`. The client doesn't read environment
variables itself; the examples below take the key from `IMANDRAX_API_KEY`:

```{.python test="skip"}
import os

from imandrax_api.v2 import Client, url_prod

with Client(url=url_prod, api_key=os.environ["IMANDRAX_API_KEY"]) as client:
    ...
```

## Examples

### Quick start

```python
import os

from imandrax_api.v2 import Client, url_prod
from imandrax_api.v2.interface import InstanceResponse, VerifyResponse

api_key: str | None = os.environ.get("IMANDRAX_API_KEY") or os.environ.get("IMANDRA_UNI_KEY")

with Client(url=url_prod, api_key=api_key) as client:
    # 1. Load IML definitions into the session
    client.eval_src("let f x = if x > 0 then x + 1 else 0")

    # 2. Prove a property for all inputs
    prop1: VerifyResponse = client.verify_src("fun x -> f x >= 0")
    print(prop1.proved)
    #> True

    # 3. Prove a (wrong) property
    prop2: VerifyResponse = client.verify_src("fun x -> f x > x")
    print(prop2.refuted)
    #> True

    # 3.1 Counterexample from the refuted result
    print(prop2.counter_example)
    """
    module M = struct

      let x = 0

    end
    """

    # 4. Find inputs satisfying a goal
    instance_res: InstanceResponse = client.instance_src("fun x -> f x = 43")
    print(instance_res.instance)
    """
    module M = struct

      let x = 42

    end
    """
```

### Region Decomposition

Given a function, region decomposition exhaustively decomposes its input space
into disjoint regions, each characterized by a set of constraints and an
invariant describing the function's behavior in that region. See
[Region Decomposition](https://imandrax.dev/docs/region-decomposition) for
details.

With `prune=True`, regions proved empty are removed, and each region proved
feasible comes with a sample input and the function's output on it.

```python
from imandrax_api.v2.interface import DecompositionResult
from imandrax_api.v2.mir import PyValue, Uid

client.eval_src("""
let fee amount =
  if amount < 0 then 0
  else if amount < 100 then 5
  else amount / 20
""")

res: DecompositionResult = client.decompose("fee", prune=True, string_results=True)
assert res.decomposition is not None, f"decomposition failed: {res.errors}"

rows: list[tuple[str, str, str, str]] = [("constraints", "invariant", "sample input", "sample output")]
for region in res.decomposition.regions:
    constraints: str = " && ".join(region.constraints_str or ())
    invariant: str | None = region.invariant_str
    # The sample input is keyed by each variable's unique ID; key it by name instead
    sample: dict[Uid, PyValue] = region.sample() or {}
    sample_input: dict[str, PyValue] = {uid.short_name: value for uid, value in sample.items()}
    sample_output: PyValue | None = region.sample_output()
    rows.append((constraints, str(invariant), str(sample_input), str(sample_output)))

for row in rows:
    print(f"{row[0]:<30} | {row[1]:<15} | {row[2]:<15} | {row[3]}")
    #> constraints                    | invariant       | sample input    | sample output
    #> amount >= 100                  | amount / 20     | {'amount': 100} | 5
    #> amount >= 0 && amount <= 99    | 5               | {'amount': 0}   | 5
    #> amount <= (-1)                 | 0               | {'amount': -1}  | 0
```

### All at once with `eval_src`

The steps above can also be written in one IML and run with a single `eval_src`.
The results of `theorem`, `verify` and `instance` statements are in
`po_results`, and those of `[@@decomp ...]` in `decomp_results`:

```python
from imandrax_api.v2.interface import EvalSrcResponse

res: EvalSrcResponse = client.eval_src("""
let f x = if x > 0 then x + 1 else 0

theorem f_nonneg x = f x >= 0
theorem f_increasing x = f x > x
instance (fun x -> f x = 43)

let fee amount =
  if amount < 0 then 0
  else if amount < 100 then 5
  else amount / 20
[@@decomp top () |>> prune]
""")

# For a theorem, `instance` means a counter-example was found
for po in res.po_results:
    print(po.origin.from_sym, po.outcome)
    #> f_nonneg proof
    #> f_increasing instance
    #> _instance_6_1 instance

for d in res.decomp_results:
    print(d.success, d.decomposition and len(d.decomposition.regions))
    #> True 3
```

### Async client

`AsyncClient` has the same methods as `Client`, as coroutines. It needs optional
dependencies and can be installed with `pip install 'imandrax-api[async]'`.

```python
import asyncio
import os

from imandrax_api.v2 import AsyncClient, url_prod
from imandrax_api.v2.interface import VerifyResponse

api_key: str | None = os.environ.get("IMANDRAX_API_KEY") or os.environ.get("IMANDRA_UNI_KEY")


async def main() -> bool:
    async with AsyncClient(url=url_prod, api_key=api_key) as client:
        await client.eval_src("let f x = x + 1")
        res: VerifyResponse = await client.verify_src("fun x -> f x > x")
        return res.proved


print(asyncio.run(main()))
#> True
```
