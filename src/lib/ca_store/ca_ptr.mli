(** Content-addressed pointer.

    A [ca_ptr] is a unique (cryptographic) name for data stored in
    the {!Storage.t}.
    Data [d] is stored under key [chash(serialize(d))].
*)

(** Raw untyped pointer.  *)
module Raw : sig
  type t [@@deriving show, eq, ord, twine]
  (** Raw ca_ptr, without typing. *)

  val to_string : t -> string
  val slugify : t -> string
  val unslugify_exn : string -> t
end

type 'a t [@@deriving twine]
(** Content-addressed pointer for type ['a] *)

val raw : _ t -> Raw.t

val to_twine' : _ t Imandrakit_twine.encoder
(** Type erasing twine *)

val of_twine' : _ t Imandrakit_twine.decoder
(** Type erasing twine *)

(**/**)

module Private_ : sig
  val unsafe_of_raw : Raw.t -> 'a t
  [@@alert expert "cast from raw pointer"]
  (** Cast from a raw pointer. Make sure you know the actual type. *)

  val raw_of_key : Key.t -> Raw.t
  val raw_to_key : Raw.t -> Key.t
end

(**/**)

val store : #Writer.t -> (_, 'a) Ca_codec.t -> 'a -> 'a t
val store_l : #Writer.t -> (_, 'a) Ca_codec.t -> 'a list -> 'a t list

val get : #Reader.t -> ('st, 'a) Ca_codec.t -> 'st -> 'a t -> 'a Error.result
(** [get reader codec ptr] returns the value stored in [storage]
    under pointer [ptr]. *)

val try_get :
  #Reader.t -> ('st, 'a) Ca_codec.t -> 'st -> 'a t -> 'a Error.result option
(** [try_get reader codec ptr] returns [None] if [ptr] is not present,
    or else it behaves like [get reader codec ptr] *)

val get_exn : #Reader.t -> ('st, 'a) Ca_codec.t -> 'st -> 'a t -> 'a

val get_l_exn : #Reader.t -> ('st, 'a) Ca_codec.t -> 'st -> 'a t list -> 'a list
(** Retrieve a bunch of pointers at once *)

val show : _ t -> string
val pp : _ t Fmt.printer
