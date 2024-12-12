open struct
  let pp_msg out s = Fmt.fprintf out {|"@[%a@]"|} Util.pp_text_newlines s
end

(** An atomic event, happening at a given point in time *)
type ('term, 'ty) poly =
  | E_message of 'term Rtext.t  (** Regular message *)
  | E_title of string [@printer pp_msg]  (** More heavy message *)
  | E_enter_waterfall of {
      vars: 'ty Var_poly.t_poly list;
      goal: 'term;
    }
  | E_enter_tactic of string  (** Running the given tactic *)
  | E_rw_success of Imandrax_api_cir.Rewrite_rule.t * 'term * 'term
  | E_rw_fail of Imandrax_api_cir.Rewrite_rule.t * 'term * string
  | E_inst_success of Imandrax_api_cir.Instantiation_rule.t * 'term
  | E_waterfall_checkpoint of 'term Imandrax_api.Sequent_poly.t list
  | E_induction_scheme of 'term
  | E_attack_subgoal of {
      name: string;
      goal: 'term Imandrax_api.Sequent_poly.t;
      depth: int;
    }
  | E_simplify_t of 'term * 'term
  | E_simplify_clause of 'term * 'term list
  | E_proved_by_smt of 'term * 'term Smt_proof.t
  | E_refuted_by_smt of
      'term
      * ( 'term,
          'ty Applied_symbol_poly.t_poly,
          'ty Var_poly.t_poly,
          'ty )
        Imandrax_api.Model.t
        option
  | E_fun_expansion of 'term * 'term (* TODO: generalize, elim, etc. *)
[@@deriving show { with_path = false }, twine, typereg, map]

module Cir = struct
  type t = (Imandrax_api_cir.Term.t, Imandrax_api_cir.Type.t) poly
  [@@deriving show { with_path = false }, twine, typereg]
  (** An atomic event, happening at a given point in time *)
end

module Mir = struct
  type t = (Imandrax_api_mir.Term.t, Imandrax_api_mir.Type.t) poly
  [@@deriving show { with_path = false }, twine, typereg]
  (** An atomic event, happening at a given point in time *)
end
