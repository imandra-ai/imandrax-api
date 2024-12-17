type ('term, 'ty) t_poly = {
  thm_link: ('term, 'ty) Fun_def.t_poly;
      (** corresponding (boolean) function *)
  thm_rewriting: bool;  (** rewrite rule? *)
  thm_perm_restrict: bool;  (** apply permutative rewrite rule restrictions? *)
  thm_fc: bool;  (** forward chaining rule? *)
  thm_elim: bool;  (** elimination rule? *)
  thm_gen: bool;  (** generalization rule? *)
  thm_triggers: 'term Pre_trigger.t_poly list;
  thm_is_axiom: bool;
  thm_by: 'term;
}
[@@deriving twine, typereg, map, iter, show { with_path = false }]
(** A theorem, entered with [theorem foo x y = <formula using x,y>] *)

let name (self : _ t_poly) : Imandrax_api.Uid.t = self.thm_link.f_name
