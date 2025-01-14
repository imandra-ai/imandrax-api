type ('term, 'ty) t_poly = {
  rw_name: Imandrax_api.Uid.t;
      (** name of theorem that gives this rewrite rule *)
  rw_head: 'ty Pattern_head.t_poly;  (** head symbol of LHS *)
  rw_lhs: 'ty Fo_pattern.t_poly;
  rw_rhs: 'term;
  rw_guard: 'term list;
  rw_vars: 'ty Var.t_poly list;
      (** all variables of the rule (LHS + triggers) *)
  rw_triggers: 'ty Fo_pattern.t_poly list;  (** additional triggers *)
  rw_perm_restrict: bool;
      (** should we apply `permutative rule` restrictions? *)
  rw_loop_break: 'ty Fo_pattern.t_poly option;
      (** if this matches scrutinee term, rewrite aborts *)
}
[@@deriving twine, typereg, map, iter, show { with_path = false }]
(** A rewrite rule *)
