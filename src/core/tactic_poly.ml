(** Tactic used to solve a PO *)
type 'term t_poly =
  | Default_termination of { basis: Uid_set.t }
  | Default_thm
  | Term of 'term
[@@deriving show { with_path = false }, map, iter, twine, typereg]
