(** Operations that modify {!Db.t}. These can be sent on the network. *)
type ('term, 'ty) t_poly =
  | Op_enable of Imandrax_api.Uid.t list
  | Op_disable of Imandrax_api.Uid.t list
  | Op_add_decls of ('term, 'ty) Decl.t_poly list
  | Op_add_rw of 'ty Pattern_head.t_poly * ('term, 'ty) Rewrite_rule.t_poly
  | Op_add_fc_trigger of 'ty Pattern_head.t_poly * 'ty Trigger.t_poly
  | Op_add_elim of
      'ty Pattern_head.t_poly * ('term, 'ty) Elimination_rule.t_poly
  | Op_add_gen_trigger of 'ty Pattern_head.t_poly * 'ty Trigger.t_poly
  | Op_add_count_fun of Imandrax_api.Uid.t * ('term, 'ty) Fun_def.t_poly
  | Op_set_admission of Imandrax_api.Uid.t * Admission.t
  | Op_set_thm_as_rw of
      Imandrax_api.Uid.t * ('term, 'ty) Rewrite_rule.t_poly list
  | Op_set_thm_as_fc of
      Imandrax_api.Uid.t * ('term, 'ty) Instantiation_rule.t_poly list
  | Op_set_thm_as_elim of
      Imandrax_api.Uid.t * ('term, 'ty) Elimination_rule.t_poly list
  | Op_set_thm_as_gen of
      Imandrax_api.Uid.t * ('term, 'ty) Instantiation_rule.t_poly
  | Op_add_instantiation_rule of ('term, 'ty) Instantiation_rule.t_poly
  | Op_add_rule_spec_fc_triggers of Imandrax_api.Uid.t * 'ty Trigger.t_poly list
  | Op_add_rule_spec_rw of
      Imandrax_api.Uid.t * ('term, 'ty) Rewrite_rule.t_poly list
[@@deriving show { with_path = false }, twine, map, iter]
