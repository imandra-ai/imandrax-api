
(** Code for utils.proto *)

(* generated from "utils.proto", do not edit *)



(** {2 Types} *)

type empty = unit

type string_msg = {
  msg : string;
}


(** {2 Basic values} *)

val default_empty : unit
(** [default_empty ()] is the default value for type [empty] *)

val default_string_msg : 
  ?msg:string ->
  unit ->
  string_msg
(** [default_string_msg ()] is the default value for type [string_msg] *)


(** {2 Make functions} *)


val make_string_msg : 
  msg:string ->
  unit ->
  string_msg
(** [make_string_msg … ()] is a builder for type [string_msg] *)


(** {2 Formatters} *)

val pp_empty : Format.formatter -> empty -> unit 
(** [pp_empty v] formats v *)

val pp_string_msg : Format.formatter -> string_msg -> unit 
(** [pp_string_msg v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_empty : empty -> Pbrt.Encoder.t -> unit
(** [encode_pb_empty v encoder] encodes [v] with the given [encoder] *)

val encode_pb_string_msg : string_msg -> Pbrt.Encoder.t -> unit
(** [encode_pb_string_msg v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_empty : Pbrt.Decoder.t -> empty
(** [decode_pb_empty decoder] decodes a [empty] binary value from [decoder] *)

val decode_pb_string_msg : Pbrt.Decoder.t -> string_msg
(** [decode_pb_string_msg decoder] decodes a [string_msg] binary value from [decoder] *)


(** {2 Protobuf YoJson Encoding} *)

val encode_json_empty : empty -> Yojson.Basic.t
(** [encode_json_empty v encoder] encodes [v] to to json *)

val encode_json_string_msg : string_msg -> Yojson.Basic.t
(** [encode_json_string_msg v encoder] encodes [v] to to json *)


(** {2 JSON Decoding} *)

val decode_json_empty : Yojson.Basic.t -> empty
(** [decode_json_empty decoder] decodes a [empty] value from [decoder] *)

val decode_json_string_msg : Yojson.Basic.t -> string_msg
(** [decode_json_string_msg decoder] decodes a [string_msg] value from [decoder] *)


(** {2 Services} *)
