include Imandrax_api_common.Pattern_head

type t = Type.t t_poly [@@deriving show, eq, ord, twine, typereg]

let hash = hash_t_poly Type.hash

let () =
  Imandrakit_twine.Encode.add_cache_with ~eq:equal ~hash to_twine_ref;
  Imandrakit_twine.Decode.add_cache of_twine_ref

module As_key = struct
  type nonrec t = t

  let compare = compare
end

module Map = CCMap.Make (As_key)
module Set = CCSet.Make (As_key)
