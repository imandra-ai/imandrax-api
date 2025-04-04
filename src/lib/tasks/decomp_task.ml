(** Decomposition tasks *)

type 'term decomp_poly =
  | Decomp of Imandrax_api_common.Decomp.t_
  | Term of 'term
[@@deriving show, twine, typereg, map, iter]

type ('term, 'ty) t_poly = {
  db: ('term, 'ty) Imandrax_api_common.Db_ser.t_poly;
  decomp: 'term decomp_poly;
  anchor: Imandrax_api.Anchor.t;
}
[@@deriving show { with_path = false }, twine, typereg]

module Mir = struct
  type decomp = Imandrax_api_mir.Term.t decomp_poly
  [@@deriving show, twine, typereg] [@@typereg.name "Mir.decomp"]

  type t = (Imandrax_api_mir.Term.t, Imandrax_api_mir.Type.t) t_poly
  [@@deriving show, twine, typereg] [@@typereg.name "Mir.t"]
end
