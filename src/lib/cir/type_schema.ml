type t = {
  params: Type.var list;
  ty: Type.t;
}
[@@deriving twine, typereg, eq, ord, show { with_path = false }]

let pp_ = ref pp
let pp out d = !pp_ out d
let show = Fmt.to_string pp
