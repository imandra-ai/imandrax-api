type t = { tree: Tree_node.t }
[@@deriving twine, make, typereg, show { with_path = false }]
(** This is the entrypoint into a proof file, from which we explore proof steps,
    the proof tree, etc. *)
