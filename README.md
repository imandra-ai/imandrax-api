# ImandraX API [![build (OCaml 4)](https://github.com/imandra-ai/imandrax-api/actions/workflows/main.yml/badge.svg)](https://github.com/imandra-ai/imandrax-api/actions/workflows/main.yml) [![build (OCaml 5)](https://github.com/imandra-ai/imandrax-api/actions/workflows/main5.yml/badge.svg)](https://github.com/imandra-ai/imandrax-api/actions/workflows/main5.yml)

This is the public facing repository for ImandraX.

This contains:
- a (very early) programmatic API for ImandraX, based on protobuf
    and OCaml type definitions
- an install script

## Getting started

ImandraX currently supports Linux on x86_64, and macOS on aarch64 (ie ARM machines).

To install the `imandrax-cli` locally, use:

```sh
$ ./scripts/install-internal.sh
```

This requires `gcloud` to be in the path, and to be
authenticated (`gcloud auth login`) so as to be able to download
the installer.

To install the development version, export `VERSION=latest-main`:

```sh
$ VERSION=latest-main ./scripts/install-internal.sh
```

Once the CLI is installed (and, in the case of linux, in path),
you can login using:

```sh
$ imandrax-cli login
```

(or, for the development version of the server:
```sh
$ imandrax-cli login --dev
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


## API

WIP

### Curl

Example if the server is listening on port 8083:

```sh
$ curl -X POST http://localhost:8083/api/v1/System/gc_stats -H 'content-type: application/json' -d {}
{"minorCollections":"4","majorCollections":"2","heapSizeB":"3081624"}
```

### OCaml client library

See library `imandrax-api-client`.

### JS/TS

(TODO)
<details>
<summary> todos </summary>
- [ ] use https://github.com/stephenh/ts-proto
- [ ] write a RPC client implementation on top (websocket+JSON? or directly use the binary version)
</details>
