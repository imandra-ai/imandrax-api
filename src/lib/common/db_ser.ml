(** A serializable logic database. It contains all relevant context for proof
    obligations. *)

type 'a uid_map = (Imandrax_api.Uid.t * 'a) list
[@@deriving show, twine, typereg]

type ('ty, 'a) ph_map = ('ty Pattern_head.t_poly * 'a) list
[@@deriving show, twine, typereg, map, iter]

type 'a ca_ptr = 'a Imandrax_api_ca_store.Ca_ptr.t [@@deriving twine, typereg]

open struct
  let pp_ca_ptr _ out c = Imandrax_api_ca_store.Ca_ptr.pp out c
end

type ('term, 'ty) t_poly = {
  cname_decls: Imandrax_api.Uid_set.t;  (** declarations by cname/cptr *)
  local_tys: 'ty Imandrax_api.Ty_view.def_poly list;
      (** type declarations included here *)
  local_funs: ('term, 'ty) Fun_def.t_poly list;
      (** function declarations included here *)
  def_depth: (int * int) uid_map;
  rw_rules: ('ty, ('term, 'ty) Rewrite_rule.t_poly ca_ptr list) ph_map;
  inst_rules: ('term, 'ty) Instantiation_rule.t_poly ca_ptr uid_map;
  rule_spec_fc: 'ty Trigger.t_poly ca_ptr list uid_map;
  rule_spec_rw_rules: ('term, 'ty) Rewrite_rule.t_poly ca_ptr list uid_map;
  fc: ('ty, 'ty Trigger.t_poly ca_ptr list) ph_map;
  elim: ('ty, ('term, 'ty) Elimination_rule.t_poly ca_ptr list) ph_map;
  gen: ('ty, 'ty Trigger.t_poly ca_ptr list) ph_map;
  thm_as_rw: ('term, 'ty) Rewrite_rule.t_poly ca_ptr list uid_map;
  thm_as_fc: ('term, 'ty) Instantiation_rule.t_poly ca_ptr list uid_map;
  thm_as_elim: ('term, 'ty) Elimination_rule.t_poly ca_ptr list uid_map;
  thm_as_gen: ('term, 'ty) Instantiation_rule.t_poly ca_ptr list uid_map;
  admission: Admission.t ca_ptr uid_map;
  count_funs_of_ty: Imandrax_api.Uid.t uid_map;
      (** Type -> count function for it *)
  disabled: Imandrax_api.Uid_set.t;
}
[@@deriving show { with_path = false }, twine, typereg]
(** A serializable logic database. *)

(* NOTE: this is not deriving map because we can't map through a ca_ptr. *)
