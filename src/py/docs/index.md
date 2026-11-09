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
Pass it to the client with `api_key`:

```{.python test="skip"}
from imandrax_api.v2 import Client, url_prod

with Client(url=url_prod, api_key="your-api-key") as client:
    ...
```
