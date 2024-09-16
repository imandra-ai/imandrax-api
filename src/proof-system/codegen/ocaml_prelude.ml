(* prelude *)

module Encoder = Encoder
(** Abstraction for output types (some sort of writer) *)

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
  let rec encode (enc : 'st Encoder.t) st (self : t) =
    match self with
    | I i -> Encoder.int enc st i
    | S s -> Encoder.text enc st s
    | QI (x, id) ->
      Encoder.array_begin enc st ~len:2;
      Encoder.int enc st x;
      encode enc st id
    | QS (x, id) ->
      Encoder.array_begin enc st ~len:2;
      Encoder.text enc st x;
      encode enc st id
end

module Make_id () : sig
  type t = private Identifier.t

  val make : Identifier.t -> t
  val encode : (_, t) Encoder.enc
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
        enc: 'st Encoder.t;  (** Encoder that writes into [st] *)
        gen_id: unit -> Identifier.t;
        output_entry: 'st -> unit;
      }
        -> t

  let make_gen_id () : unit -> Identifier.t =
    let n = Atomic.make 0 in
    fun () -> Identifier.I (Atomic.fetch_and_add n 1)
end

(* end prelude *)
