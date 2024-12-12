include Imandrax_api.Pattern_head_view

type t = Type.t view [@@deriving show, eq, ord, twine, typereg]

let hash = hash_view Type.hash

let () =
  Imandrakit_twine.Encode.add_cache_with ~eq:equal ~hash to_twine_ref;
  Imandrakit_twine.Decode.add_cache of_twine_ref

module As_key = struct
  type nonrec t = t

  let compare = compare
end

module Map = CCMap.Make (As_key)
module Set = CCSet.Make (As_key)
