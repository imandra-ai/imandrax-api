include Imandrax_api_common.Type_schema

type t = Type.t t_poly [@@deriving twine, typereg, eq, ord, show]

let pp_ = ref pp
let pp out d = !pp_ out d
let show = Fmt.to_string pp
