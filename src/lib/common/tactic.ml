(** Tactic used to solve a PO *)
type ('term, 'ty) t_poly =
  | Default_termination of {
      max_steps: int;
      basis: Imandrax_api.Uid_set.t;
    }
  | Default_thm of {
      max_steps: int;
      upto: Imandrax_api.Upto.t option;
    }
  | Default_quickcheck of {
      num_steps: int option;
      seed: int option;
    }
  | Term of ('ty Var.t_poly list * 'term)
[@@deriving show { with_path = false }, map, iter, twine, typereg]
