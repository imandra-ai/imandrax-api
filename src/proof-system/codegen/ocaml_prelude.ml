(* prelude *)

module Encoder = Encoder

(** Identifiers used for DAG nodes *)
module Identifier = struct
  type t =
    | I of int
    | S of string
    | QI of int * t
    | QS of string * t

  let equal : t -> t -> bool = ( = )

  let rec append a b =
    match a with
    | I i -> QI (i, b)
    | S s -> QS (s, b)
    | QI (i, a2) -> QI (i, append a2 b)
    | QS (s, a2) -> QS (s, append a2 b)

  (** Generate a fresh new integer identifier *)
  let gen =
    let n = Atomic.make 0 in
    fun [@inline] () -> Atomic.fetch_and_add n 1

  (** Encode an identifier *)
  let rec encode (enc : Encoder.t) (self : t) =
    match self with
    | I i -> Encoder.int enc i
    | S s -> Encoder.text enc s
    | QI (x, id) ->
      Encoder.array_begin enc ~len:2;
      Encoder.int enc x;
      encode enc id
    | QS (x, id) ->
      Encoder.array_begin enc ~len:2;
      Encoder.text enc x;
      encode enc id
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
