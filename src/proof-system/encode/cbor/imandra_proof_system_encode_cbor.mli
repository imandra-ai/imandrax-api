(** CBOR encoder. Adapted from [containers.cbor]. *)

type 'a enc = Buffer.t -> 'a -> unit

(** {2 Encoders} *)

val int : int enc
val int64 : int64 enc
val float : float enc
val simple : int enc
val bool : bool enc
val text : string enc
val bytes : string enc
val text_slice : Buffer.t -> string -> int -> int -> unit
val bytes_slice : Buffer.t -> string -> int -> int -> unit
val true_ : Buffer.t -> unit
val false_ : Buffer.t -> unit
val null : Buffer.t -> unit
val undefined : Buffer.t -> unit
val array_begin : Buffer.t -> len:int -> unit
val array : Buffer.t -> 'a enc -> 'a array -> unit
val array_l : Buffer.t -> 'a enc -> 'a list -> unit
val map_begin : Buffer.t -> len:int -> unit
val nullable : Buffer.t -> 'a enc -> 'a option -> unit
val tag : Buffer.t -> tag:int -> unit

(** {2 Interface} *)

val encoder : Buffer.t Imandra_proof_system_encode.Encoder.t
(** Main encoder *)
