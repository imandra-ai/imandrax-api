# Internal

Low-level modules that ImandraX API is built on. They are not part of the public
API and are not recommended to be used by non-experts.

- **Protobuf client** (`imandrax_api.v1`): the raw client, which returns protobuf
  messages. Use the [`imandrax_api.v2`](../../index.md) client instead
- **Protobuf messages and services** (`imandrax_api.bindings`): the protobuf
  messages and twirp services, generated from the `.proto` files
- **Artifact decoders** (`imandrax_api.lib`): the generated decoders for artifact
  data, and the `twine` format they are encoded in
- **Twirp RPC runtime** (`imandrax_api.twirp`): the vendored
  [twirpy](https://github.com/verloop/twirpy) RPC runtime
