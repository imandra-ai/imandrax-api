module Identifier = struct
  type t =
    | I of int
    | S of string
    | L of int list

  let equal : t -> t -> bool = ( = )

  let gen =
    let n = Atomic.make 0 in
    fun [@inline] () -> Atomic.fetch_and_add n 1
end

module Make_id () : sig
  type t = private Identifier.t

  val make : Identifier.t -> t
  val equal : t -> t -> bool
end = struct
  type t = Identifier.t

  let equal = Identifier.equal
  let make = Fun.id
end

type fn = string
