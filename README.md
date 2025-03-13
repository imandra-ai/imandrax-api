# ImandraX API [![build (OCaml 4)](https://github.com/imandra-ai/imandrax-api/actions/workflows/main.yml/badge.svg)](https://github.com/imandra-ai/imandrax-api/actions/workflows/main.yml) [![build (OCaml 5)](https://github.com/imandra-ai/imandrax-api/actions/workflows/main5.yml/badge.svg)](https://github.com/imandra-ai/imandrax-api/actions/workflows/main5.yml)

This is the public facing repository for ImandraX.

This contains:
- a programmatic API for ImandraX, based on protobuf
    and OCaml type definitions
- an ImandraX installation script

## Getting started

ImandraX currently supports Linux on x86_64, and macOS on aarch64 (ie ARM machines).

To install the `imandrax-cli` locally, use:

```sh
$ ./scripts/install.sh
```

To install the development version, export `VERSION=latest-main`:

```sh
$ VERSION=latest-main ./scripts/install.sh
```

Once the CLI is installed (and, in the case of linux, in path),
you can login using:

```sh
$ ./configure-imandrax.auth.sh
```

and configure imandrax to talk to the relevant cloud server:
```sh
$ mkdir -p ~/.config/imandrax
$ cat <<EOF > ~/.config/imandrax/config.toml
[net]
deployment = "prod"
EOF
```

(or for the development version:
```sh
$ mkdir -p ~/.config/imandrax
$ cat <<EOF > ~/.config/imandrax/config.toml
[net]
deployment = "dev"
EOF
```
)

This is necessary for the CLI to be able to communicate with the server.
Once logged in, the CLI can be freely used, e.g. with

```sh
$ cat > foo.iml <<EOF
let f x = x+1
verify (fun x -> f x > x)
EOF

$ imandrax-cli check foo.iml
```

## VS Code Plugin / LSP

The VS Code plugin needs to be obtained separately.
If you have access, you can find the latest release binary (.vsix) file here:
https://github.com/imandra-ai/imandrax-vscode/releases

Soon we will bundle this with the installer and/or make the plugin available through
the VS Code extensions marketplace.

### Curl

Example if the server is listening on port 8083:

```sh
$ curl -X POST http://localhost:8083/api/v1/System/gc_stats -H 'content-type: application/json' -d {}
{"minorCollections":"4","majorCollections":"2","heapSizeB":"3081624"}
```

### OCaml client library

See library `imandrax-api-client`.

### Python API

Requires: python >= 3.12

Install dependencies to be able to fetch the package, and login to google cloud:

```sh
$ pip install keyring keyrings-google-artifactregistry-auth twirp google-cloud-storage
$ gcloud auth application-default login
```

then install via:

```sh
$ pip install --index-url https://europe-west1-python.pkg.dev/imandra-dev/imandrax-api/simple/ imandrax-api
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
