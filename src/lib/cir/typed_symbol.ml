include Imandrax_api.Typed_symbol_poly

type t = Type.t t_poly [@@deriving twine, typereg, eq, ord, show]
(** A value with its type schema *)

let pp_ = ref pp
let pp out d = !pp_ out d
let show = Fmt.to_string pp
