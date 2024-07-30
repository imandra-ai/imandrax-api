type t = {
  id: Imandrax_api.Uid.t;
  ty: Type_schema.t;
}
[@@deriving twine, typereg, eq, ord, show { with_path = false }]
(** A value with its type schema *)

let pp_ = ref pp
let pp out d = !pp_ out d
let show = Fmt.to_string pp
