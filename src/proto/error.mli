
(** Code for error.proto *)

(* generated from "error.proto", do not edit *)



(** {2 Types} *)

type error_message = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable msg : string;
  mutable locs : Locs.location list;
  mutable backtrace : string;
}

type error = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable msg : error_message option;
  mutable kind : string;
  mutable stack : error_message list;
  mutable process : string;
}


(** {2 Basic values} *)

val default_error_message : unit -> error_message 
(** [default_error_message ()] is a new empty value for type [error_message] *)

val default_error : unit -> error 
(** [default_error ()] is a new empty value for type [error] *)


(** {2 Make functions} *)

val make_error_message : 
  ?msg:string ->
  ?locs:Locs.location list ->
  ?backtrace:string ->
  unit ->
  error_message
(** [make_error_message … ()] is a builder for type [error_message] *)

val copy_error_message : error_message -> error_message

val error_message_has_msg : error_message -> bool
  (** presence of field "msg" in [error_message] *)

val error_message_set_msg : error_message -> string -> unit
  (** set field msg in error_message *)

val error_message_set_locs : error_message -> Locs.location list -> unit
  (** set field locs in error_message *)

val error_message_has_backtrace : error_message -> bool
  (** presence of field "backtrace" in [error_message] *)

val error_message_set_backtrace : error_message -> string -> unit
  (** set field backtrace in error_message *)

val make_error : 
  ?msg:error_message ->
  ?kind:string ->
  ?stack:error_message list ->
  ?process:string ->
  unit ->
  error
(** [make_error … ()] is a builder for type [error] *)

val copy_error : error -> error

val error_set_msg : error -> error_message -> unit
  (** set field msg in error *)

val error_has_kind : error -> bool
  (** presence of field "kind" in [error] *)

val error_set_kind : error -> string -> unit
  (** set field kind in error *)

val error_set_stack : error -> error_message list -> unit
  (** set field stack in error *)

val error_has_process : error -> bool
  (** presence of field "process" in [error] *)

val error_set_process : error -> string -> unit
  (** set field process in error *)


(** {2 Formatters} *)

val pp_error_message : Format.formatter -> error_message -> unit 
(** [pp_error_message v] formats v *)

val pp_error : Format.formatter -> error -> unit 
(** [pp_error v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_error_message : error_message -> Pbrt.Encoder.t -> unit
(** [encode_pb_error_message v encoder] encodes [v] with the given [encoder] *)

val encode_pb_error : error -> Pbrt.Encoder.t -> unit
(** [encode_pb_error v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_error_message : Pbrt.Decoder.t -> error_message
(** [decode_pb_error_message decoder] decodes a [error_message] binary value from [decoder] *)

val decode_pb_error : Pbrt.Decoder.t -> error
(** [decode_pb_error decoder] decodes a [error] binary value from [decoder] *)


(** {2 Protobuf YoJson Encoding} *)

val encode_json_error_message : error_message -> Yojson.Basic.t
(** [encode_json_error_message v encoder] encodes [v] to to json *)

val encode_json_error : error -> Yojson.Basic.t
(** [encode_json_error v encoder] encodes [v] to to json *)


(** {2 JSON Decoding} *)

val decode_json_error_message : Yojson.Basic.t -> error_message
(** [decode_json_error_message decoder] decodes a [error_message] value from [decoder] *)

val decode_json_error : Yojson.Basic.t -> error
(** [decode_json_error decoder] decodes a [error] value from [decoder] *)


(** {2 Services} *)
