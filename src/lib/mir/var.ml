(** Variables *)

type t = {
  view: Imandrax_api.Uid.t;
  ty: Type.t;
}
[@@deriving twine, typereg, show]

open Imandrax_api

let[@inline] equal (a : t) (b : t) : bool = Uid.equal a.view b.view
let[@inline] compare (a : t) (b : t) = Uid.compare a.view b.view
let[@inline] hash (v : t) = Uid.hash v.view

module As_key = struct
  type nonrec t = t

  let equal = equal
  let hash = hash
  let compare = compare
end

module Tbl = CCHashtbl.Make (As_key)
module Map = CCMap.Make (As_key)
module Set = CCSet.Make (As_key)
