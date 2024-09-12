(* prelude *)

module Identifier = struct
  type t =
    | I of int
    | S of string
    | QI of int * t
    | QS of string * t

  let equal : t -> t -> bool = ( = )

  let gen =
    let n = Atomic.make 0 in
    fun [@inline] () -> Atomic.fetch_and_add n 1

  let encode (enc : Cbor_enc.t) (self : t) =
    match self with
    | I i -> Cbor_enc.int enc i
    | S s -> Cbor_enc.text enc s
    | L l ->
      Cbor_enc.array_begin enc ~len:(List.length l);
      List.iter (Cbor_enc.int enc) l
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

(* end prelude *)
