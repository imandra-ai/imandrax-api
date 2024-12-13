type 'ty t_poly =
  | PH_id of Imandrax_api.Uid.t  (** starts with function symbol *)
  | PH_ty of 'ty  (** is just a variable *)
  | PH_datatype_op  (** starts with destruct/is-a *)
[@@deriving show, eq, ord, map, iter, twine, typereg]

let hash_t_poly hty = function
  | PH_id id -> CCHash.combine2 10 (Imandrax_api.Uid.hash id)
  | PH_datatype_op -> CCHash.int 20
  | PH_ty ty -> CCHash.combine2 20 (hty ty)
