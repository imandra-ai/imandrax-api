type t = {
  last_steps: Types.proof_step list;
  last_deep_steps: Types.deep_proof_step list;
  tree_leaves: Types.deep_proof_tree list;
}
[@@deriving eq, twine, make, typereg, show { with_path = false }]
(** This is the entrypoint into a proof file, from which we explore proof steps,
    the proof tree, etc. *)
