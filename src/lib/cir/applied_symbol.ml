type t = {
  sym: Typed_symbol.t;
  args: Type.t list;
  ty: Type.t;  (** computed *)
}
[@@deriving twine, typereg, ord, eq, show { with_path = false }]
(** A value with its type schema *)

let pp_ = ref pp
let pp out d = !pp_ out d
let show = Fmt.to_string pp
