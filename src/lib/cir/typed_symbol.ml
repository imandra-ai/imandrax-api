type t = {
  id: Imandrax_api.Uid.t;
  ty: Type_schema.t;
}
[@@deriving twine, typereg, eq, ord, show { with_path = false }]
(** A value with its type schema *)
