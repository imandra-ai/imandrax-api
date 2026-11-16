(** Values the harness generates, encodes and compares.

    One constructor per kind of twine value. [Int] holds a [Z.t] so that replies
    from decoders with unbounded integers (and the bigint property) parse into
    the same type; generated [Int]s stay within int64. *)

type t =
  | Null
  | Bool of bool
  | Int of Z.t
  | F32 of float  (** a float that is exactly representable as an f32 *)
  | F64 of float
  | Str of string  (** valid UTF-8 *)
  | Blob of string
  | Array of t list
  | Dict of (t * t) list
  | Tag of Z.t * t
  | Cstor of Z.t * t list  (** indices are unbounded, like integers *)
  | Ref of t  (** explicit reference (kind 14) to the value *)

val pp : Format.formatter -> t -> unit
(** Readable form, for failure reports *)

val show : t -> string

val widen : t -> t
(** What a decoder is expected to report for [v]: f32 leaves widened to f64,
    since twine decoders return f32 values as ordinary floats. *)

val equal : t -> t -> bool
(** Structural equality. Floats compare by bit pattern, except that any NaN
    equals any NaN (payloads may not survive widening). *)

val gen : t QCheck2.Gen.t
(** Values of bounded depth, with leaves weighted towards the boundaries of the
    encoding. Some nodes repeat a subtree, so the shared encoding has something
    to share. Shrinks towards a child of a container. *)

val gen_bigint : Z.t QCheck2.Gen.t
(** Integers for the bigint property, mostly beyond 64 bits *)

val encode : ?share:bool -> t -> string
(** The twine encoding of [v], written by imandrakit's encoder (the reference).
    With [share], every repeated subtree is written once and referred to by
    pointers. *)

val encode_bigint : Z.t -> string
(** A [Z.t] encoded the way ImandraX encodes integers (a blob, see
    [Util_twine.Z]) *)
