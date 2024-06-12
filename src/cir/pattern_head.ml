type t =
  | PH_id of Uid.t  (** starts with function symbol *)
  | PH_ty of Type.t  (** is just a variable *)
  | PH_datatype_op  (** starts with destruct/is-a *)
[@@deriving show, eq, ord, twine, typereg]

let hash = function
  | PH_id id -> CCHash.combine2 10 (Uid.hash id)
  | PH_datatype_op -> CCHash.int 20
  | PH_ty ty -> CCHash.combine2 20 (Type.hash ty)

let () =
  Imandrakit_twine.Encode.add_cache_with ~eq:equal ~hash to_twine_ref;
  Imandrakit_twine.Decode.add_cache of_twine_ref

module As_key = struct
  type nonrec t = t

  let compare = compare
end

module Map = CCMap.Make (As_key)
module Set = CCSet.Make (As_key)
