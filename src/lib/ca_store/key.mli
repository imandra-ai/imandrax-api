(** Storage keys.

    Content-addressed storage uses these keys to store and retrieve values. *)

type t [@@deriving twine, eq, ord, show]
(** Key by which entries are accessed *)

val hash : t -> int
val chasher : t Chash.hasher
val slugify : t -> string

val unslugify_exn : string -> t
(** Read from a string. *)

(** {2 Containers} *)

module Tbl : CCHashtbl.S with type key = t
module Map : CCMap.S with type key = t
module Set : CCSet.S with type elt = t

(** {2 Builders} *)

val chash : ty:string -> Chash.t -> t
(** Value represented by the hash of its serialized representation
    @param ty What "type" of data? *)

val cname : ty:string -> Cname.t -> t
(** Key for data that is already content addressed by its cname.
    @param ty What "type" of data? (ie term, type, fundef, etc.) *)

val task : kind:string -> Chash.t -> t
(** Key for tasks that are content addressed by the hash of the task definition.
    @param kind the kind of task. This should be a slugified task kind. *)

val custom : ns:string -> string -> t
(** Custom keys, in their own namespace. Use with caution. *)

val as_chash : t -> (string * Chash.t) option
val as_cname : t -> (string * Cname.t) option
val as_task : t -> (string * Chash.t) option
val is_task : t -> bool

type view = private
  | Chash of {
      ty: string;
      h: Chash.t;
    }
  | Cname of {
      ty: string;
      name: Cname.t;
    }
  | Task of {
      kind: string;
      h: Chash.t;
    }
  | Custom of {
      ns: string;
      data: string;
    }

val view : t -> view

(**/**)

module Private_ : sig
  val to_string : t -> string
  [@@alert expert "Make sure the string is a valid key"]

  val of_string : string -> t
  [@@alert expert "Make sure the string is a valid key"]
end

(**/**)
