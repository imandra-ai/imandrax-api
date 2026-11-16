(** The text form decoders reply with: one labelled S-expression per value. *)

(** What a decoder replies to one request. Anything else that goes wrong is not
    a reply: the adapter exits. *)
type reply =
  | Value of Value.t
  | Decode_error of string  (** the decoder rejected the input *)

val reply_to_string : reply -> string
(** The reply line for [r]. [F32] leaves are written as f64, the way a decoder
    reports them. *)

val parse_reply : string -> (reply, string) result
(** Parse one reply line. [Error] means the line is not in the text form, which
    is a bug in the adapter, not in the decoder. *)

val hex_of_string : string -> string
(** Lowercase hex digits of the bytes of a string *)
