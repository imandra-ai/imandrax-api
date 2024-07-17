(** the kind of function. *)
type fun_kind =
  | Fun_defined of {
      is_macro: bool;
      from_lambda: bool;
    }
  | Fun_builtin of Imandrax_api.Builtin.Fun.t
  | Fun_opaque
[@@deriving show { with_path = false }, eq, twine, typereg]

(** How to validate a function *)
type validation_strategy =
  | VS_validate of { tactic: Term.t option }
      (** Validate using this tactic for POs *)
  | VS_no_validate  (** Admitted, or builtin. *)
[@@deriving show { with_path = false }, eq, twine, typereg]

type t = {
  f_name: Imandrax_api.Uid.t; [@printer Util.pp_backquote Imandrax_api.Uid.pp]
  f_ty: Type_schema.t;
  f_args: Var.t list;
  f_body: Term.t;
  f_clique: Clique.t option;
      (** If the function is recursive, this is the set of functions in the
          same block of mutual defs, this one included. It's [None]
          for non-recursive functions. *)
  f_kind: fun_kind;
  f_admission: Imandrax_api.Admission.t option;
  f_admission_measure: Imandrax_api.Uid.t option;
      (** custom measure function *)
  f_validate_strat: validation_strategy;
  f_hints: apply_hint Hints.Top.t option;  (** how to verify the function? *)
  f_enable: Imandrax_api.Uid.t list;  (** local enables *)
  f_disable: Imandrax_api.Uid.t list;  (** local disables *)
  f_timeout: int option;  (** timeout for POs *)
}
(** A function definition. *)

and apply_hint = { apply_fun: t }
[@@unboxed] [@@deriving twine, typereg, eq, show { with_path = false }]
(** A local function that has the same signature as the theorem *)

open Imandrax_api

let () =
  Imandrakit_twine.Encode.add_cache_with
    ~eq:(fun a b -> Uid.equal a.f_name b.f_name)
    ~hash:(fun a -> Uid.hash a.f_name)
    to_twine_ref;
  Imandrakit_twine.Decode.add_cache of_twine_ref
