module Encoder = Encoder
(** Abstraction for output types (some sort of writer) *)

module Slice = Imandrakit_bytes.Byte_slice

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

  let rec to_twine enc (self : t) : Imandrakit_twine.Immediate.t =
    match self with
    | I i ->
      Imandrakit_twine.(
        Encode.write_immediate enc (Immediate.int i) |> Immediate.pointer)
    | S s ->
      Imandrakit_twine.(
        Encode.write_immediate enc (Immediate.string s) |> Immediate.pointer)
    | QI (i, sub) ->
      Imandrakit_twine.Encode.(list enc [ Immediate.int i; to_twine enc sub ])
    | QS (s, sub) ->
      Imandrakit_twine.(
        Encode.list enc [ Immediate.string s; to_twine enc sub ])

  let rec of_twine dec (i : Imandrakit_twine.offset) : t =
    let open Imandrakit_twine in
    match Decode.read ~auto_deref:true dec i with
    | Int i -> I (Int64.to_int i)
    | String s -> S (Slice.contents s)
    | Array a when Decode.Array_cursor.length a = 2 ->
      let kind =
        match Decode.read dec @@ Decode.Array_cursor.current a with
        | Int i -> `Int i
        | String s -> `String (Slice.contents s)
        | _ -> Decode.fail "expected a qualified identifier with string|int"
      in
      Decode.Array_cursor.consume a;
      let sub = of_twine dec (Decode.Array_cursor.current a) in
      (match kind with
      | `Int i -> QI (Int64.to_int i, sub)
      | `String s -> QS (s, sub))
    | _ -> Decode.fail "expected an identifier"

  (** Generate a fresh new integer identifier *)
  let gen =
    let n = Atomic.make 0 in
    fun [@inline] () -> Atomic.fetch_and_add n 1

  let rec to_string = function
    | I i -> string_of_int i
    | S s -> s
    | QI (i, sub) -> Printf.sprintf "%d.%s" i (to_string sub)
    | QS (s, sub) -> Printf.sprintf "%s.%s" s (to_string sub)

  let pp out self = Format.pp_print_string out (to_string self)

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
  type t = private Identifier.t [@@deriving show, twine]

  val make : Identifier.t -> t
  val encode : (_, t) Encoder.enc
  val equal : t -> t -> bool
end = struct
  type t = Identifier.t [@@deriving show, twine]

  let equal = Identifier.equal
  let encode = Identifier.encode
  let make = Fun.id
end

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
