type 'ty view =
  | PH_id of Uid.t  (** starts with function symbol *)
  | PH_ty of 'ty  (** is just a variable *)
  | PH_datatype_op  (** starts with destruct/is-a *)
[@@deriving show, eq, ord, map, iter, twine, typereg]

let hash_view hty = function
  | PH_id id -> CCHash.combine2 10 (Uid.hash id)
  | PH_datatype_op -> CCHash.int 20
  | PH_ty ty -> CCHash.combine2 20 (hty ty)
