# ImandraX API [![build (OCaml 4)](https://github.com/imandra-ai/imandrax-api/actions/workflows/main.yml/badge.svg)](https://github.com/imandra-ai/imandrax-api/actions/workflows/main.yml) [![build (OCaml 5)](https://github.com/imandra-ai/imandrax-api/actions/workflows/main5.yml/badge.svg)](https://github.com/imandra-ai/imandrax-api/actions/workflows/main5.yml)

This is the public facing repository for ImandraX.

This contains:
- a programmatic API for ImandraX, based on protobuf
    and OCaml type definitions
- an ImandraX installation script

## Getting started

ImandraX currently supports Linux on x86_64, and macOS on aarch64 (ie ARM machines).

Most users should simply run `scripts/install` to install the latest stable production release of `imandrax-cli`:

```sh
./scripts/install
```

For those wanting bleeding edge updates (and okay with occasional breaking changes!), the development version can be installed by exporting `VERSION=latest-main`:

```sh
VERSION=latest-main ./scripts/install
```

## Getting an Imandra Universe API key

To use ImandraX, you'll need an Imandra Universe API Key, available from https://universe.imandra.ai/ under your `User Settings` panel.
Once you have that API key, copy it into this file:

```
~/.config/imandrax/api_key
```

## VS Code Plugin / LSP

Next, install the ImandraX VS Code plugin from the VS Code Marketplace ([link](https://marketplace.visualstudio.com/items?itemName=imandra.imandrax)). 

Depending on the location of your `imandrax` installation, you may need to modify the `settings.json` for the ImandraX VS Code plugin to point to your `imandrax-cli` binary.

### Curl

Example if the server is listening on port 8083:

```sh
curl -X POST http://localhost:8083/api/v1/System/gc_stats -H 'content-type: application/json' -d {}
{"minorCollections":"4","majorCollections":"2","heapSizeB":"3081624"}
```

### OCaml client library

See library `imandrax-api-client`.

### Python API

Requires: python >= 3.12

Install dependencies to be able to fetch the package, and login to google cloud:

```sh
pip install keyring keyrings-google-artifactregistry-auth twirp google-cloud-storage
gcloud auth application-default login
```

then install via:

```sh
pip install --index-url https://europe-west1-python.pkg.dev/imandra-dev/imandrax-api/simple/ imandrax-api
```

#### Building Python API package locally

```
$ python --version
3.12.X

$ python -m venv venv
$ . venv/bin/activate
$ pip install build
$ make build-python
$ pip install src/py/dist/imandrax_api-0.7-py3-none-any.whl
```

### JS/TS

(TODO)
<details>
<summary> todos </summary>
- [ ] use https://github.com/stephenh/ts-proto
- [ ] write a RPC client implementation on top (websocket+JSON? or directly use the binary version)
</details>

