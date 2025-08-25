(** Decomposition tasks *)

type ('term, 'ty) decomp_poly =
  | Decomp of Imandrax_api_common.Decomp.t_
  | Term of 'term
  | Return of ('term, 'ty) Imandrax_api_common.Fun_decomp.t_poly
      (** Just return this decomp. This is useful as a base case of [Merge] and
          [Combine] *)
  | Prune of ('term, 'ty) decomp_poly
  | Merge of ('term, 'ty) decomp_poly * ('term, 'ty) decomp_poly
  | Compound_merge of ('term, 'ty) decomp_poly * ('term, 'ty) decomp_poly
  | Combine of ('term, 'ty) decomp_poly
  | Get of string
  | Parallel_set of {
      bindings: (string * ('term, 'ty) decomp_poly) list;
      and_then: ('term, 'ty) decomp_poly;
    }
[@@deriving show, twine, typereg, map, iter]

type ('term, 'ty) t_poly = {
  db: ('term, 'ty) Imandrax_api_common.Db_ser.t_poly;
  decomp: ('term, 'ty) decomp_poly;
  anchor: Imandrax_api.Anchor.t;
  timeout: int option;
}
[@@deriving show { with_path = false }, twine, typereg]

module Mir = struct
  type decomp = (Imandrax_api_mir.Term.t, Imandrax_api_mir.Type.t) decomp_poly
  [@@deriving show, twine, typereg] [@@typereg.name "Mir.decomp"]

  type t = (Imandrax_api_mir.Term.t, Imandrax_api_mir.Type.t) t_poly
  [@@deriving show, twine, typereg] [@@typereg.name "Mir.t"]
end
