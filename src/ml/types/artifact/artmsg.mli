
(** Code for artmsg.proto *)

(* generated from "artmsg.proto", do not edit *)



(** {2 Types} *)

type art = {
  kind : string;
  data : bytes;
  api_version : string;
}


(** {2 Basic values} *)

val default_art : 
  ?kind:string ->
  ?data:bytes ->
  ?api_version:string ->
  unit ->
  art
(** [default_art ()] is the default value for type [art] *)


(** {2 Make functions} *)

val make_art : 
  kind:string ->
  data:bytes ->
  api_version:string ->
  unit ->
  art
(** [make_art … ()] is a builder for type [art] *)


(** {2 Formatters} *)

val pp_art : Format.formatter -> art -> unit 
(** [pp_art v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_art : art -> Pbrt.Encoder.t -> unit
(** [encode_pb_art v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_art : Pbrt.Decoder.t -> art
(** [decode_pb_art decoder] decodes a [art] binary value from [decoder] *)
