
(** Code for locs.proto *)

(* generated from "locs.proto", do not edit *)



(** {2 Types} *)

type position = {
  line : int32;
  col : int32;
}

type location = {
  file : string option;
  start : position option;
  stop : position option;
}


(** {2 Basic values} *)

val default_position : 
  ?line:int32 ->
  ?col:int32 ->
  unit ->
  position
(** [default_position ()] is the default value for type [position] *)

val default_location : 
  ?file:string option ->
  ?start:position option ->
  ?stop:position option ->
  unit ->
  location
(** [default_location ()] is the default value for type [location] *)


(** {2 Make functions} *)

val make_position : 
  line:int32 ->
  col:int32 ->
  unit ->
  position
(** [make_position … ()] is a builder for type [position] *)

val make_location : 
  ?file:string option ->
  ?start:position option ->
  ?stop:position option ->
  unit ->
  location
(** [make_location … ()] is a builder for type [location] *)


(** {2 Formatters} *)

val pp_position : Format.formatter -> position -> unit 
(** [pp_position v] formats v *)

val pp_location : Format.formatter -> location -> unit 
(** [pp_location v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_position : position -> Pbrt.Encoder.t -> unit
(** [encode_pb_position v encoder] encodes [v] with the given [encoder] *)

val encode_pb_location : location -> Pbrt.Encoder.t -> unit
(** [encode_pb_location v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_position : Pbrt.Decoder.t -> position
(** [decode_pb_position decoder] decodes a [position] binary value from [decoder] *)

val decode_pb_location : Pbrt.Decoder.t -> location
(** [decode_pb_location decoder] decodes a [location] binary value from [decoder] *)


(** {2 Protobuf YoJson Encoding} *)

val encode_json_position : position -> Yojson.Basic.t
(** [encode_json_position v encoder] encodes [v] to to json *)

val encode_json_location : location -> Yojson.Basic.t
(** [encode_json_location v encoder] encodes [v] to to json *)


(** {2 JSON Decoding} *)

val decode_json_position : Yojson.Basic.t -> position
(** [decode_json_position decoder] decodes a [position] value from [decoder] *)

val decode_json_location : Yojson.Basic.t -> location
(** [decode_json_location decoder] decodes a [location] value from [decoder] *)


(** {2 Services} *)
