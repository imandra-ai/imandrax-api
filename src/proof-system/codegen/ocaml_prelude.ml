(* prelude *)

module Encoder = Encoder

module Identifier = struct
  type t =
    | I of int
    | S of string
    | QI of t * int
    | QS of t * string

  let equal : t -> t -> bool = ( = )

  (** Generate a fresh new integer identifier *)
  let gen =
    let n = Atomic.make 0 in
    fun [@inline] () -> Atomic.fetch_and_add n 1

  let rec encode (enc : Encoder.t) (self : t) =
    match self with
    | I i -> Encoder.int enc i
    | S s -> Encoder.text enc s
    | QI (id, x) ->
      Encoder.array_begin enc ~len:2;
      encode enc id;
      Encoder.int enc x
    | QS (id, x) ->
      Encoder.array_begin enc ~len:2;
      encode enc id;
      Encoder.text enc x
end

module Make_id () : sig
  type t = private Identifier.t

  val make : Identifier.t -> t
  val encode : t Encoder.enc
  val equal : t -> t -> bool
end = struct
  type t = Identifier.t

  let equal = Identifier.equal
  let encode = Identifier.encode
  let make = Fun.id
end

type fn = string

(** An output for streaming proofs *)
module Output = struct
  type t =
    | Out : {
        st: 'st;
        buf: Buffer.t;
        enc: Encoder.t;  (** Encoder that writes into [buf] *)
        output_entry: 'st -> Buffer.t -> unit;
      }
        -> t
end

(* end prelude *)
