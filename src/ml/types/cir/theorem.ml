type t = {
  thm_link: Fun_def.t;  (** corresponding (boolean) function *)
  thm_rewriting: bool;  (** rewrite rule? *)
  thm_perm_restrict: bool;  (** apply permutative rewrite rule restrictions? *)
  thm_fc: bool;  (** forward chaining rule? *)
  thm_elim: bool;  (** elimination rule? *)
  thm_gen: bool;  (** generalization rule? *)
  thm_otf: bool;  (** should induction proceed "onward through the fog"? *)
  thm_triggers: Pre_trigger.t list;
  thm_is_axiom: bool;
  thm_by: Term.t;
}
[@@deriving twine, typereg, show { with_path = false }]
(** A theorem, entered with [theorem foo x y = <formula using x,y>] *)
