(** A serializable logic database. It contains all relevant context for
    proof obligations. *)

module PH = Pattern_head

type 'a uid_map = (Uid.t * 'a) list [@@deriving show, twine, typereg]

type 'a ph_map = (PH.t * 'a) list [@@deriving show, twine, typereg]

type 'a cptr = 'a Ca_ptr.t [@@deriving twine, typereg]

let pp_cptr _ out c = Ca_ptr.pp out c

type t = {
  decls: Uid_set.t;
  rw_rules: Rewrite_rule.t cptr list ph_map;
  inst_rules: Instantiation_rule.t cptr uid_map;
  rule_spec_fc: Trigger.t cptr list uid_map;
  rule_spec_rw_rules: Rewrite_rule.t cptr list uid_map;
  fc: Trigger.t cptr list ph_map;
  elim: Elimination_rule.t cptr list ph_map;
  gen: Trigger.t cptr list ph_map;
  thm_as_rw: Rewrite_rule.t cptr list uid_map;
  thm_as_fc: Instantiation_rule.t cptr list uid_map;
  thm_as_elim: Elimination_rule.t cptr list uid_map;
  thm_as_gen: Instantiation_rule.t cptr list uid_map;
  admission: Admission.t cptr uid_map;
  count_funs_of_ty: Uid.t uid_map;  (** Type -> count function for it *)
  config: Logic_config.t cptr;
  disabled: Uid_set.t;
}
[@@deriving show { with_path = false }, twine, typereg]
(** A serializable logic database. *)
