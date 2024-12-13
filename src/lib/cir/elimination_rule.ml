include Imandrax_api_common.Elimination_rule

type t = (Term.t, Type.t) t_poly [@@deriving show, twine, typereg]

let[@inline] equal (r1 : t) (r2 : t) : bool =
  Imandrax_api.Uid.equal r1.er_name r2.er_name
