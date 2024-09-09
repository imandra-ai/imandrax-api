(* prelude *)

type fn = string

type ('a, 'res) encoder = Cbor_enc.t -> 'a -> unit
(** An encoder to CBOR, with a phantom type *)

(* end prelude *)
