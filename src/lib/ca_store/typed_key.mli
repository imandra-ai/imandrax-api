(** Key with a type witness *)

type +'a t = private Key.t

val show : _ t -> string
val pp : _ t Fmt.printer
val to_raw : _ t -> Key.t
val unsafe_of_raw : Key.t -> 'a t [@@alert cast "cast from raw key"]
