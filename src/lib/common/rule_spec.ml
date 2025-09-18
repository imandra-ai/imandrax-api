type ('term, 'ty) t_poly = {
  rule_spec_fc: bool;  (** forward chaining rule? *)
  rule_spec_rewriting: bool;  (** rewrite rule? *)
  rule_spec_perm_restrict: bool;
      (** apply permutative rewrite rule restrictions? *)
  rule_spec_link: ('term, 'ty) Fun_def.t_poly;
      (** corresponding (boolean) function *)
  rule_spec_triggers: 'term Pre_trigger.t_poly list;
      (** explicit rule triggers *)
}
[@@deriving twine, map, iter, show { with_path = false }]
(** A rule_spec_spec, entered with
    [rule_spec_spec foo x y = <formula using x,y>] *)

let name self = self.rule_spec_link.f_name
