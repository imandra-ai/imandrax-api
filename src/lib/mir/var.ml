(** Variables *)

include Imandrax_api.Var_poly

type t = Type.t t_poly [@@deriving twine, typereg, show]

open Imandrax_api

let[@inline] equal (a : t) (b : t) : bool = Uid.equal a.id b.id
let[@inline] compare (a : t) (b : t) = Uid.compare a.id b.id
let[@inline] hash (v : t) = Uid.hash v.id

module As_key = struct
  type nonrec t = t

  let equal = equal
  let hash = hash
  let compare = compare
end

module Tbl = CCHashtbl.Make (As_key)
module Map = CCMap.Make (As_key)
module Set = CCSet.Make (As_key)
