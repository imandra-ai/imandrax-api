include Imandrax_api_common.Applied_symbol

type t = Type.t t_poly [@@deriving twine, typereg, ord, eq, show]
(** A value with its type schema *)

let pp_ = ref pp
let pp out d = !pp_ out d
let show = Fmt.to_string pp

let hash self =
  CCHash.(
    combine2 (Imandrax_api.Uid.hash self.sym.id) (list Type.hash self.args))
