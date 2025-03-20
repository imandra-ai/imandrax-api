include Imandrax_api_common.Typed_symbol

type t = Type.t Imandrax_api_common.Typed_symbol.t_poly
[@@deriving twine, typereg, eq, ord, show]
(** A value with its type schema *)

let pp_ = ref pp
let pp out d = !pp_ out d
let show = Fmt.to_string pp
