# from-twine-derive

> [!WARNING] 
> Implemented by LLM

Procedural derive macro for the `FromTwine<'a>` trait, which deserializes Rust types from the [twine-data](https://twine-data.dev/) binary format.

## Usage

```rust
use from_twine_derive::FromTwine;

#[derive(FromTwine)]
pub struct MyRecord<'a> {
    pub name: &'a str,
    pub value: i64,
}

#[derive(FromTwine)]
pub enum MyEnum<'a> {
    Foo(&'a str),
    Bar { x: i64, y: f64 },
    Baz,
}
```

## How it works

### Structs

- Multi-field structs are decoded from a twine array. Each field is read in definition order from the corresponding array slot. Tags are automatically unwrapped via `deref_tag`.

- Single-field structs are treated as transparent/newtype wrappers: the single field is read directly from the offset without an array layer.

- Unit structs expect a twine `null` value.

- `PhantomData` fields are skipped during deserialization (they don't consume an array slot) and initialized as `std::marker::PhantomData`.

### Enums

Enums are decoded from a twine variant (constructor). The variant index is matched to the enum variant in definition order (0-indexed). Tags are automatically unwrapped.

- Unit variants expect 0 arguments.
- Tuple variants read each positional field from the variant's arguments.
- Struct variants read named fields from arguments in definition order. `PhantomData` fields are skipped.

### Lifetime handling

- If the type already has a `'a` lifetime, it is used directly. Any type parameters get `FromTwine<'a>` bounds added automatically.
- If the type has no `'a` lifetime (an "immediate" type like `struct Stat_time { time_s: f64 }`), a `'a` lifetime is introduced just for the impl.

### Tag handling

Generated code calls `crate::deser::deref_tag(d, off)` before reading arrays or variants. This transparently skips twine tag wrappers (used for hash-consing annotations in artifacts).

## Limitations

### `crate::` path restriction

The macro generates code that references `crate::deser::FromTwine` and `crate::deser::deref_tag`. This means `#[derive(FromTwine)]` only works inside the crate that defines the `deser` module (i.e. `imandrax-api`). It will not compile in external crates or integration tests (`tests/*.rs`), because `crate::` resolves to the wrong crate in those contexts.

To add a `#[from_twine(crate = "...")]` attribute (like serde's `#[serde(crate = "...")]`) that overrides the path, the proc macro would need to parse a custom attribute and substitute the path prefix in the generated code. This is not implemented yet.

For now, tests that use `#[derive(FromTwine)]` on test-local types must live inside the crate as `#[cfg(test)]` modules (see `src/deser.rs`).

## TODO

- [ ] explore potential usage of `twine_data::value`
