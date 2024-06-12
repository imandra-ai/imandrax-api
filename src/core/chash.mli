(** Cryptographic hash *)

type t = private string [@@deriving twine, eq, ord, show]
(** A cryptographic hash *)

val n_bytes : int
(** Number of bytes in a hash *)

val dummy : t

type builder
type 'a hasher = builder -> 'a -> unit

val to_string : t -> string
val equal : t -> t -> bool
val hash : t -> int
val compare : t -> t -> int
val make : 'a hasher -> 'a -> t
val init : unit -> builder
val finalize : builder -> t
val int : int hasher
val bool : bool hasher
val string : string hasher
val char : char hasher
val float : float hasher
val int32 : int32 hasher
val int64 : int64 hasher
val nativeint : nativeint hasher
val z : Z.t hasher
val q : Q.t hasher
val list : 'a hasher -> 'a list hasher
val iter : 'a hasher -> (('a -> unit) -> unit) hasher
val seq : 'a hasher -> 'a Seq.t hasher
val array : 'a hasher -> 'a array hasher
val option : 'a hasher -> 'a option hasher
val result : 'a hasher -> 'e hasher -> ('a, 'e) result hasher
val pair : 'a hasher -> 'b hasher -> ('a * 'b) hasher
val triple : 'a hasher -> 'b hasher -> 'c hasher -> ('a * 'b * 'c) hasher

val quad :
  'a hasher -> 'b hasher -> 'c hasher -> 'd hasher -> ('a * 'b * 'c * 'd) hasher

val sub_hash : t hasher

val list_sorted : 'a hasher -> 'a list hasher
(** hash then sort then hash *)

val map : ('a -> 'b) -> 'b hasher -> 'a hasher
val hash_as_int : t -> int

val hash_file : string -> t
(** Hash content of the file (blocking) *)

val pp_abbrev : t Fmt.printer
(** Print a prefix *)

val show_abbrev : t -> string

val _of_string : string -> t
(** Decode a hash.
    @raise Invalid_argument if the string is not base64 encoded. *)

val slugify : t -> string

val unslugify : string -> t
(** Decode a hash.
    @raise Invalid_argument if the string is not base64 encoded. *)

module Tbl : CCHashtbl.S with type key = t
