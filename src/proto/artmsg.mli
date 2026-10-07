
(** Code for artmsg.proto *)

(* generated from "./artmsg.proto", do not edit *)



(** {2 Types} *)

type storage_entry = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable key : string;
  mutable value : bytes;
}

type artifact = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 3 fields *)
  mutable kind : string;
  mutable data : bytes;
  mutable api_version : string;
  mutable storage : storage_entry list;
}


(** {2 Basic values} *)

val default_storage_entry : unit -> storage_entry 
(** [default_storage_entry ()] is a new empty value for type [storage_entry] *)

val default_artifact : unit -> artifact 
(** [default_artifact ()] is a new empty value for type [artifact] *)


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

val make_artifact : 
  ?kind:string ->
  ?data:bytes ->
  ?api_version:string ->
  ?storage:storage_entry list ->
  unit ->
  artifact
(** [make_artifact … ()] is a builder for type [artifact] *)

val copy_artifact : artifact -> artifact

val artifact_has_kind : artifact -> bool
  (** presence of field "kind" in [artifact] *)

val artifact_set_kind : artifact -> string -> unit
  (** set field kind in artifact *)

val artifact_has_data : artifact -> bool
  (** presence of field "data" in [artifact] *)

val artifact_set_data : artifact -> bytes -> unit
  (** set field data in artifact *)

val artifact_has_api_version : artifact -> bool
  (** presence of field "api_version" in [artifact] *)

val artifact_set_api_version : artifact -> string -> unit
  (** set field api_version in artifact *)

val artifact_set_storage : artifact -> storage_entry list -> unit
  (** set field storage in artifact *)


(** {2 Formatters} *)

val pp_storage_entry : Format.formatter -> storage_entry -> unit 
(** [pp_storage_entry v] formats v *)

val pp_artifact : Format.formatter -> artifact -> unit 
(** [pp_artifact v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_storage_entry : storage_entry -> Pbrt.Encoder.t -> unit
(** [encode_pb_storage_entry v encoder] encodes [v] with the given [encoder] *)

val encode_pb_artifact : artifact -> Pbrt.Encoder.t -> unit
(** [encode_pb_artifact v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_storage_entry : Pbrt.Decoder.t -> storage_entry
(** [decode_pb_storage_entry decoder] decodes a [storage_entry] binary value from [decoder] *)

val decode_pb_artifact : Pbrt.Decoder.t -> artifact
(** [decode_pb_artifact decoder] decodes a [artifact] binary value from [decoder] *)


(** {2 Protobuf YoJson Encoding} *)

val encode_json_storage_entry : storage_entry -> Yojson.Basic.t
(** [encode_json_storage_entry v encoder] encodes [v] to to json *)

val encode_json_artifact : artifact -> Yojson.Basic.t
(** [encode_json_artifact v encoder] encodes [v] to to json *)


(** {2 JSON Decoding} *)

val decode_json_storage_entry : Yojson.Basic.t -> storage_entry
(** [decode_json_storage_entry decoder] decodes a [storage_entry] value from [decoder] *)

val decode_json_artifact : Yojson.Basic.t -> artifact
(** [decode_json_artifact decoder] decodes a [artifact] value from [decoder] *)
