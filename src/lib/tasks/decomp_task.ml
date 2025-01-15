(** Decomposition tasks *)

type ('term, 'ty) t_poly = {
  db: ('term, 'ty) Imandrax_api_common.Db_ser.t_poly;
  decomp: Imandrax_api_common.Decomp.t_;
  anchor: Imandrax_api.Anchor.t;
}
[@@deriving show { with_path = false }, twine, typereg]

module Mir = struct
  type t = (Imandrax_api_mir.Term.t, Imandrax_api_mir.Type.t) t_poly
  [@@deriving show, twine, typereg] [@@typereg.name "Imandrax_api_mir.t"]
end
