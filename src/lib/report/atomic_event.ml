open struct
  let pp_msg out s = Fmt.fprintf out {|"@[%a@]"|} Util.pp_text_newlines s
end

type ('term, 'ty) model = ('term, 'ty) Imandrax_api_common.Model.t_poly
[@@deriving show, typereg, map, twine]

(** An atomic event, happening at a given point in time *)
type ('term, 'ty, 'term2, 'ty2) poly =
  | E_message of 'term Rtext.t  (** Regular message *)
  | E_title of string [@printer pp_msg]  (** More heavy message *)
  | E_enter_waterfall of {
      vars: 'ty Imandrax_api_common.Var.t_poly list;
      goal: 'term;
    }
  | E_enter_tactic of string  (** Running the given tactic *)
  | E_rw_success of
      ('term2, 'ty2) Imandrax_api_common.Rewrite_rule.t_poly * 'term * 'term
  | E_rw_fail of
      ('term2, 'ty2) Imandrax_api_common.Rewrite_rule.t_poly * 'term * string
  | E_inst_success of
      ('term2, 'ty2) Imandrax_api_common.Instantiation_rule.t_poly * 'term
  | E_waterfall_checkpoint of 'term Imandrax_api_common.Sequent.t_poly list
  | E_induction_scheme of 'term
  | E_attack_subgoal of {
      name: string;
      goal: 'term Imandrax_api_common.Sequent.t_poly;
      depth: int;
    }
  | E_simplify_t of 'term * 'term
  | E_simplify_clause of 'term * 'term list
  | E_proved_by_smt of 'term * 'term Smt_proof.t
  | E_refuted_by_smt of
      'term * ('term, 'ty) Imandrax_api_common.Model.t_poly option
  | E_fun_expansion of 'term * 'term (* TODO: generalize, elim, etc. *)
[@@deriving show { with_path = false }, twine, typereg, map]

module Cir = struct
  type t =
    ( Imandrax_api_cir.Term.t,
      Imandrax_api_cir.Type.t,
      Imandrax_api_cir.Term.t,
      Imandrax_api_cir.Type.t )
    poly
  [@@typereg.name "Cir.t"]
  [@@deriving show { with_path = false }, twine, typereg]
  (** An atomic event, happening at a given point in time *)
end

module Mir = struct
  type t =
    ( Imandrax_api_mir.Term.t,
      Imandrax_api_mir.Type.t,
      Imandrax_api_mir.Term.t,
      Imandrax_api_mir.Type.t )
    poly
  [@@typereg.name "Mir.t"]
  [@@deriving show { with_path = false }, twine, typereg]
  (** An atomic event, happening at a given point in time *)
end
