module Induct = struct
  type style =
    | Multiplicative
    | Additive
  [@@deriving show, twine, typereg, enum, eq]

  type method_ =
    | Functional of { f_name: Imandrax_api.Uid.t option }
        (** functional induction *)
    | Structural of {
        style: style;
        vars: string list;
      }  (** structural induction *)
    | Term of {
        t: Term.t;
        vars: Var.t list;
      }
    | Default
  [@@deriving twine, typereg, eq]

  type t = {
    otf: bool;
    timeout: int;
    max_induct: int option;  (** max induction depth *)
    backchain_limit: int;  (** global back-chaining limit, for rewriting *)
    subgoal_depth: int;  (** Max depth of successive subgoals in induction *)
    unroll_enable_all: bool;
    unroll_depth: int;
    method_: method_;
  }
  [@@deriving twine, typereg, eq] [@@typereg.name "Induct.t"]

  let pp_method out = function
    | Default -> Fmt.string out "<default>"
    | Structural { style = Additive; vars } ->
      Format.fprintf out "(@[structural+@ %a@])" Fmt.(list Dump.string) vars
    | Structural { style = Multiplicative; vars } ->
      Format.fprintf out "(@[structural*@ %a@])" Fmt.(list Dump.string) vars
    | Functional { f_name = Some f } ->
      Format.fprintf out "(@[functional %a@])" Imandrax_api.Uid.pp f
    | Functional { f_name = None } -> Format.fprintf out "(@[functional ?@])"
    | Term { t; _ } -> Format.fprintf out "(@[term %a@])" Term.pp t

  let pp out
      {
        otf;
        timeout;
        method_;
        max_induct;
        backchain_limit;
        subgoal_depth;
        unroll_depth;
        unroll_enable_all;
      } =
    Fmt.fprintf out
      "(@[otf:%b, timeout: %i, max_induct:%a, backchain_limit:%i, \
       subgoal_depth:%i, unroll_depth:%i, unroll_enable_all:%b, method:%a@])"
      otf timeout (Fmt.opt Fmt.int) max_induct backchain_limit subgoal_depth
      unroll_depth unroll_enable_all pp_method method_

  let show = Fmt.to_string pp
end

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
