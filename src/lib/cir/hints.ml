(** All the hints for a function coming from explicit attributes (`[@@..]` annotations)*)

(** How to validate a function *)
type validation_strategy =
  | VS_validate of { tactic: Term.t option }
      (** Validate using this tactic for POs *)
  | VS_no_validate  (** Admitted, or builtin. *)
[@@deriving show { with_path = false }, eq, twine, typereg]

type t = {
  f_validate_strat: validation_strategy;
  f_unroll_def: int option;
  f_enable: Imandrax_api.Uid.t list;  (** local enables *)
  f_disable: Imandrax_api.Uid.t list;  (** local disables *)
  f_timeout: int option;  (** timeout for POs *)
  f_admission: Imandrax_api.Admission.t option;
}
[@@deriving show { with_path = false }, eq, twine, typereg]
