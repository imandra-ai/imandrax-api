type fname = string [@@deriving eq, show, ord, twine]

let () =
  (* a name in a sub-anchor is going to appear in many sub-anchors, we
    should cache it aggressively *)
  Imandrakit_twine.Decode.add_cache fname_of_twine_ref;
  Imandrakit_twine.Encode.add_cache ~max_string_size:12
    (module CCString)
    fname_to_twine_ref

type t = {
  fname: fname;
      (** name of the symbol containing this sub-anchor in its definition *)
  anchor: int;
}
[@@deriving eq, ord, show { with_path = false }, twine]

let[@inline] hash (self : t) : int =
  CCHash.(combine2 (string self.fname) (int self.anchor))

module As_key = struct
  type nonrec t = t

  let equal = equal
  let hash = hash
  let compare = compare
end

module Map = CCMap.Make (As_key)
module Tbl = CCHashtbl.Make (As_key)

let () =
  Imandrakit_twine.Decode.add_cache of_twine_ref;
  Imandrakit_twine.Encode.add_cache (module As_key) to_twine_ref
