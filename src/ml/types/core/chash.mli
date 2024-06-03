(** Cryptographic hash *)

type t = private string [@@deriving twine, eq, ord, show]
(** A cryptographic hash *)

val hash : t -> int

(**/**)

module Private_ : sig
  val dummy : t

  val n_bits : int

  val _of_bin : string -> t
  (** Turn a binary blob into a chash. This will perform a runtime check for length. *)
end

(**/**)
