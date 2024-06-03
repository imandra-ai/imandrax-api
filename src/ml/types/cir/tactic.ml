(** Tactic used to solve a PO *)
type t =
  | Default_termination of { basis: Uid_set.t }
  | Default_thm
  | Term of Term.t
[@@deriving show { with_path = false }, twine, typereg]
