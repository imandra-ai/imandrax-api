(** How to validate a function *)
type 'term validation_strategy =
  | VS_validate of { tactic: 'term option }
      (** Validate using this tactic for POs *)
  | VS_no_validate  (** Admitted, or builtin. *)
[@@deriving show { with_path = false }, map, iter, eq, twine, typereg]

type 'term t_poly = {
  f_validate_strat: 'term validation_strategy;
  f_unroll_def: int option;
  f_enable: Uid.t list;  (** local enables *)
  f_disable: Uid.t list;  (** local disables *)
  f_timeout: int option;  (** timeout for POs *)
  f_admission: Admission.t option;
}
[@@deriving show { with_path = false }, map, iter, eq, twine, typereg]
