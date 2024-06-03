type t = {
  rw_name: Uid.t;  (** name of theorem that gives this rewrite rule *)
  rw_head: Pattern_head.t;  (** head symbol of LHS *)
  rw_lhs: Fo_pattern.t;
  rw_rhs: Term.t;
  rw_guard: Term.t list;
  rw_vars: Var_set.t;  (** all variables of the rule (LHS + triggers) *)
  rw_triggers: Fo_pattern.t list;  (** additional triggers *)
  rw_perm_restrict: bool;
      (** should we apply `permutative rule` restrictions? *)
  rw_loop_break: Fo_pattern.t option;
      (** if this matches scrutinee term, rewrite aborts *)
}
[@@deriving twine, typereg, show { with_path = false }]
(** A rewrite rule *)
