(* prelude *)

module Identifier = struct
  type t =
    | I of int
    | S of string
    | QI of int * t
    | QS of string * t

  let equal : t -> t -> bool = ( = )

  (** Generate a fresh new integer identifier *)
  let gen =
    let n = Atomic.make 0 in
    fun [@inline] () -> Atomic.fetch_and_add n 1

  let rec encode (enc : Cbor_enc.t) (self : t) =
    match self with
    | I i -> Cbor_enc.int enc i
    | S s -> Cbor_enc.text enc s
    | QI (pre, id) ->
      Cbor_enc.array_begin enc ~len:2;
      Cbor_enc.int enc pre;
      encode enc id
    | QS (pre, id) ->
      Cbor_enc.array_begin enc ~len:2;
      Cbor_enc.text enc pre;
      encode enc id
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

(** An output for streaming proofs *)
module Output = struct
  type t =
    | Out : {
        st: 'st;
        new_id: 'st -> Identifier.t;
        buf: Buffer.t;
        output_entry: 'st -> Buffer.t -> unit;
      }
        -> t
end

(* end prelude *)
