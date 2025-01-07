(** Tactic used to solve a PO *)
type ('ty, 'term) t_poly =
  | Default_termination of { basis: Imandrax_api.Uid_set.t }
  | Default_thm
  | Term of 'ty Var.t_poly list * 'term
[@@deriving show { with_path = false }, map, iter, twine, typereg]
