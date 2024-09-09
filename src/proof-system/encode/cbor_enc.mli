(** CBOR encoder. Adapted from [containers.cbor]. *)

type t
type 'a enc = t -> 'a -> unit

val create : Buffer.t -> t

(** {2 Encoders} *)

val int : int enc
val int64 : int64 enc
val float : float enc
val simple : int enc
val bool : bool enc
val text : string enc
val bytes : string enc
val text_slice : t -> string -> int -> int -> unit
val bytes_slice : t -> string -> int -> int -> unit
val true_ : t -> unit
val false_ : t -> unit
val null : t -> unit
val undefined : t -> unit
val array_begin : t -> len:int -> unit
val map_begin : t -> len:int -> unit
val tag : t -> tag:int -> unit

(** {2 Helpers} *)

val cstor1 : t -> string -> 'a enc -> 'a -> unit
val cstor2 : t -> string -> 'a enc -> 'a -> 'b enc -> 'b -> unit
