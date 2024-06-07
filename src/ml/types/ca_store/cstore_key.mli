(** Storage keys.

    Content-addressed storage uses these keys to store and
    retrieve values. *)

type t [@@deriving twine, eq, ord, show]
(** Key by which entries are accessed *)

val hash : t -> int

val slugify : t -> string

val unslugify_exn : string -> t
(** Read from a string. *)

(** {2 Containers} *)

module Tbl : CCHashtbl.S with type key = t

module Map : CCMap.S with type key = t

(**/**)

module Private_ : sig
  val to_string : t -> string
  [@@alert expert "Make sure the string is a valid key"]

  val of_string : string -> t
  [@@alert expert "Make sure the string is a valid key"]
end

(**/**)
