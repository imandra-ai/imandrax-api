(** Entrypoint of a proof file.

    This is the record containing the actual proof. *)
type t = { tree: Tree_node.t Types.offset_for  (** The proof tree *) }
[@@deriving twine, make, typereg, show { with_path = false }]
(** This is the entrypoint into a proof file, from which we explore proof steps,
    the proof tree, etc. *)
