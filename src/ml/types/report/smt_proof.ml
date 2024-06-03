(** Proof term for SMT *)

type !'term t = {
  logic: Logic_fragment.t;  (** The logic used  *)
  unsat_core: 'term list;  (** Subset of assumptions used in the proof *)
  expansions: 'term Expansion.t list;
      (** Set of function expansions used in the proof *)
  instantiations: 'term Instantiation.t list;
      (** Set of rule instantiations used in the proof *)
}
[@@deriving twine, typereg, map, show { with_path = false }]
(** A proof of [clauses /\ bool_terms /\ assumptions |- false], by deduction. *)
