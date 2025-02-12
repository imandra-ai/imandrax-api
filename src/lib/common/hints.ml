(** How to validate a function *)
type ('term, 'ty) validation_strategy =
  | VS_validate of { tactic: ('ty Var.t_poly list * 'term) option }
      (** Validate using this tactic for POs *)
  | VS_no_validate  (** Admitted, or builtin. *)
[@@deriving show { with_path = false }, map, iter, eq, twine, typereg]

type ('term, 'ty) t_poly = {
  f_validate_strat: ('term, 'ty) validation_strategy;
  f_unroll_def: int option;
  f_enable: Imandrax_api.Uid.t list;  (** local enables *)
  f_disable: Imandrax_api.Uid.t list;  (** local disables *)
  f_timeout: int option;  (** timeout for POs *)
  f_admission: Admission.t option;
  f_decomp : 'term option;
}
[@@deriving show { with_path = false }, map, iter, eq, twine, typereg]
