type unboxed_wrapper = { value: int } [@@unboxed]

type record_with_attrs = {
  visible: string;
  internal: (int[@ocaml_only]);
  binary_data: (bytes[@twine.use_bytes]);
}

type variant_with_attrs =
  | Public of string
  | Internal of (int[@ocaml_only])
  | WithBytes of (bytes[@twine.use_bytes])

type mixed_attrs =
  | Data of {
      id: int;
      secret: (string[@ocaml_only]);
      raw: (bytes[@twine.use_bytes])
    }
  | Empty

type tuple_with_attrs = (int[@ocaml_only]) * string * (bytes[@twine.use_bytes])

type nested_unboxed = { inner: unboxed_wrapper } [@@unboxed]

let make_unboxed_wrapper () : unboxed_wrapper = { value = 42 }

let make_record_with_attrs () : record_with_attrs = {
  visible = "public";
  internal = 123;
  binary_data = Bytes.of_string "data";
}

let make_variant_with_attrs () : variant_with_attrs = Public "test"

let make_mixed_attrs () : mixed_attrs =
  Data { id = 1; secret = "hidden"; raw = Bytes.of_string "raw" }

let make_tuple_with_attrs () : tuple_with_attrs =
  (999, "visible", Bytes.of_string "bytes")

let make_nested_unboxed () : nested_unboxed = { inner = { value = 100 } }
