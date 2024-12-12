type t = {
  er_name: Imandrax_api.Uid.t;
      (** name of theorem giving rise to this elim rule *)
  er_guard: Term.t list;  (** elimination hypotheses *)
  er_lhs: Term.t;  (** the `body' of the rule, at the theorem level *)
  er_rhs: Var.t;  (** the RHS / elimination variable *)
  er_dests: Fo_pattern.t list;  (** destructor terms of the rule, as patterns *)
  er_dest_tms: Term.t list;  (** destructor terms of the rule, as terms *)
}
[@@deriving show { with_path = false }, twine, typereg]

let[@inline] equal (r1 : t) (r2 : t) : bool =
  Imandrax_api.Uid.equal r1.er_name r2.er_name
