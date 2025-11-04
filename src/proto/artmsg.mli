
(** Code for artmsg.proto *)

(* generated from "artmsg.proto", do not edit *)



(** {2 Types} *)

type storage_entry = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable key : string;
  mutable value : bytes;
}

type art = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 3 fields *)
  mutable kind : string;
  mutable data : bytes;
  mutable api_version : string;
  mutable storage : storage_entry list;
}


(** {2 Basic values} *)

val default_storage_entry : unit -> storage_entry 
(** [default_storage_entry ()] is a new empty value for type [storage_entry] *)

val default_art : unit -> art 
(** [default_art ()] is a new empty value for type [art] *)


(** {2 Make functions} *)

val make_storage_entry : 
  ?key:string ->
  ?value:bytes ->
  unit ->
  storage_entry
(** [make_storage_entry … ()] is a builder for type [storage_entry] *)

val copy_storage_entry : storage_entry -> storage_entry

val storage_entry_has_key : storage_entry -> bool
  (** presence of field "key" in [storage_entry] *)

val storage_entry_set_key : storage_entry -> string -> unit
  (** set field key in storage_entry *)

val storage_entry_has_value : storage_entry -> bool
  (** presence of field "value" in [storage_entry] *)

val storage_entry_set_value : storage_entry -> bytes -> unit
  (** set field value in storage_entry *)

val make_art : 
  ?kind:string ->
  ?data:bytes ->
  ?api_version:string ->
  ?storage:storage_entry list ->
  unit ->
  art
(** [make_art … ()] is a builder for type [art] *)

val copy_art : art -> art

val art_has_kind : art -> bool
  (** presence of field "kind" in [art] *)

val art_set_kind : art -> string -> unit
  (** set field kind in art *)

val art_has_data : art -> bool
  (** presence of field "data" in [art] *)

val art_set_data : art -> bytes -> unit
  (** set field data in art *)

val art_has_api_version : art -> bool
  (** presence of field "api_version" in [art] *)

val art_set_api_version : art -> string -> unit
  (** set field api_version in art *)

val art_set_storage : art -> storage_entry list -> unit
  (** set field storage in art *)


(** {2 Formatters} *)

val pp_storage_entry : Format.formatter -> storage_entry -> unit 
(** [pp_storage_entry v] formats v *)

val pp_art : Format.formatter -> art -> unit 
(** [pp_art v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_storage_entry : storage_entry -> Pbrt.Encoder.t -> unit
(** [encode_pb_storage_entry v encoder] encodes [v] with the given [encoder] *)

val encode_pb_art : art -> Pbrt.Encoder.t -> unit
(** [encode_pb_art v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_storage_entry : Pbrt.Decoder.t -> storage_entry
(** [decode_pb_storage_entry decoder] decodes a [storage_entry] binary value from [decoder] *)

val decode_pb_art : Pbrt.Decoder.t -> art
(** [decode_pb_art decoder] decodes a [art] binary value from [decoder] *)


(** {2 Protobuf YoJson Encoding} *)

val encode_json_storage_entry : storage_entry -> Yojson.Basic.t
(** [encode_json_storage_entry v encoder] encodes [v] to to json *)

val encode_json_art : art -> Yojson.Basic.t
(** [encode_json_art v encoder] encodes [v] to to json *)


(** {2 JSON Decoding} *)

val decode_json_storage_entry : Yojson.Basic.t -> storage_entry
(** [decode_json_storage_entry decoder] decodes a [storage_entry] value from [decoder] *)

val decode_json_art : Yojson.Basic.t -> art
(** [decode_json_art decoder] decodes a [art] value from [decoder] *)
