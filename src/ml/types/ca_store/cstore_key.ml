type t = string [@@deriving eq, ord]

let show self = spf "(cstore.key %s)" self

let pp = Fmt.of_to_string show

let slugify : t -> string = Fun.id

let unslugify_exn : string -> t = Fun.id

let hash = CCHash.string

module Tbl = Str_tbl
module Map = Str_map

open struct
  (* serialization: we encode as string, but we wrap in tag(7,...)
      so we can statically find keys in stored blobs, potentially
      enabling things like GC in the future *)
  let to_twine_basic_ enc (self : t) =
    Imandrakit_twine.Encode.(tag enc ~tag:7 ~v:(Immediate.string self))

  let to_twine_ref = ref to_twine_basic_

  let of_twine_basic_ dec off : t =
    Imandrakit_twine.Decode.(
      let n, v = tag dec off in
      if n <> 7 then fail "expected a Cstore key as `tag(7, <string>)`";
      let s = string dec v in
      s)

  let of_twine_ref = ref of_twine_basic_

  (* caching *)
  let () =
    Imandrakit_twine.Encode.add_cache_with ~eq:equal ~hash to_twine_ref;
    Imandrakit_twine.Decode.add_cache of_twine_ref
end

let[@inline] to_twine enc x = !to_twine_ref enc x

let[@inline] of_twine dec x = !of_twine_ref dec x

module Private_ = struct
  let to_string = Fun.id

  let of_string = Fun.id
end
