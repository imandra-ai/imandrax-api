type ('term, 'ty) t_poly = {
  er_name: Imandrax_api.Uid.t;
      (** name of theorem giving rise to this elim rule *)
  er_guard: 'term list;  (** elimination hypotheses *)
  er_lhs: 'term;  (** the `body' of the rule, at the theorem level *)
  er_rhs: 'ty Var.t_poly;  (** the RHS / elimination variable *)
  er_dests: 'ty Fo_pattern.t_poly list;
      (** destructor terms of the rule, as patterns *)
  er_dest_tms: 'term list;  (** destructor terms of the rule, as terms *)
}
[@@deriving show { with_path = false }, map, iter, twine, typereg]

let[@inline] equal (r1 : _ t_poly) (r2 : _ t_poly) : bool =
  Imandrax_api.Uid.equal r1.er_name r2.er_name
