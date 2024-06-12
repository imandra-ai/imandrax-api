module Cir = Imandrax_api_cir
module Model = Imandrax_api_model

open struct
  let pp_msg out s = Fmt.fprintf out {|"@[%a@]"|} Util.pp_text_newlines s
end

(** An atomic event, happening at a given point in time *)
type ('term, 'fn, 'var, 'ty) poly =
  | E_message of 'term Rtext.t  (** Regular message *)
  | E_title of string [@printer pp_msg]  (** More heavy message *)
  | E_enter_waterfall of {
      vars: 'var list;
      goal: 'term;
      hints: Cir.Hints.Induct.t;
    }
  | E_enter_tactic of string  (** Running the given tactic *)
  | E_rw_success of Cir.Rewrite_rule.t * 'term * 'term
  | E_rw_fail of Cir.Rewrite_rule.t * 'term * string
  | E_inst_success of Cir.Instantiation_rule.t * 'term
  | E_waterfall_checkpoint of 'term Sequent_poly.t list
  | E_induction_scheme of 'term
  | E_attack_subgoal of {
      name: string;
      goal: 'term Sequent_poly.t;
      depth: int;
    }
  | E_simplify_t of 'term * 'term
  | E_simplify_clause of 'term * 'term list
  | E_proved_by_smt of 'term * 'term Smt_proof.t
  | E_refuted_by_smt of 'term * ('term, 'fn, 'var, 'ty) Model.t option
  | E_fun_expansion of 'term * 'term (* TODO: generalize, elim, etc. *)
[@@deriving show { with_path = false }, twine, typereg, map]

type t = (Cir.Term.t, Cir.Applied_symbol.t, Cir.Var.t, Cir.Type.t) poly
[@@deriving show { with_path = false }, twine, typereg]
(** An atomic event, happening at a given point in time *)
