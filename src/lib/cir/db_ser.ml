(** A serializable logic database. It contains all relevant context for
    proof obligations. *)

module PH = Pattern_head

type 'a uid_map = (Uid.t * 'a) list [@@deriving show, twine, typereg]
type 'a ph_map = (PH.t * 'a) list [@@deriving show, twine, typereg]
type 'a ca_ptr = 'a Ca_ptr.t [@@deriving twine, typereg]

open struct
  let pp_ca_ptr _ out c = Ca_ptr.pp out c
end

type t = {
  decls: Uid_set.t;
  rw_rules: Rewrite_rule.t ca_ptr list ph_map;
  inst_rules: Instantiation_rule.t ca_ptr uid_map;
  rule_spec_fc: Trigger.t ca_ptr list uid_map;
  rule_spec_rw_rules: Rewrite_rule.t ca_ptr list uid_map;
  fc: Trigger.t ca_ptr list ph_map;
  elim: Elimination_rule.t ca_ptr list ph_map;
  gen: Trigger.t ca_ptr list ph_map;
  thm_as_rw: Rewrite_rule.t ca_ptr list uid_map;
  thm_as_fc: Instantiation_rule.t ca_ptr list uid_map;
  thm_as_elim: Elimination_rule.t ca_ptr list uid_map;
  thm_as_gen: Instantiation_rule.t ca_ptr list uid_map;
  admission: Admission.t ca_ptr uid_map;
  count_funs_of_ty: Uid.t uid_map;  (** Type -> count function for it *)
  config: Logic_config.t ca_ptr;
  disabled: Uid_set.t;
}
[@@deriving show { with_path = false }, twine, typereg]
(** A serializable logic database. *)
