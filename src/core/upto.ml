(** Limit on unrolling *)
type t = N_steps of int
[@@deriving show { with_path = false }, eq, ord, twine]
