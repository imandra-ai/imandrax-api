
(** Code for locs.proto *)

(* generated from "locs.proto", do not edit *)



(** {2 Types} *)

type position = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable line : int32;
  mutable col : int32;
}

type location = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable file : string;
  mutable start : position option;
  mutable stop : position option;
}


(** {2 Basic values} *)

val default_position : unit -> position 
(** [default_position ()] is a new empty value for type [position] *)

val default_location : unit -> location 
(** [default_location ()] is a new empty value for type [location] *)


(** {2 Make functions} *)

val make_position : 
  ?line:int32 ->
  ?col:int32 ->
  unit ->
  position
(** [make_position … ()] is a builder for type [position] *)

val copy_position : position -> position

val position_has_line : position -> bool
  (** presence of field "line" in [position] *)

val position_set_line : position -> int32 -> unit
  (** set field line in position *)

val position_has_col : position -> bool
  (** presence of field "col" in [position] *)

val position_set_col : position -> int32 -> unit
  (** set field col in position *)

val make_location : 
  ?file:string ->
  ?start:position ->
  ?stop:position ->
  unit ->
  location
(** [make_location … ()] is a builder for type [location] *)

val copy_location : location -> location

val location_has_file : location -> bool
  (** presence of field "file" in [location] *)

val location_set_file : location -> string -> unit
  (** set field file in location *)

val location_set_start : location -> position -> unit
  (** set field start in location *)

val location_set_stop : location -> position -> unit
  (** set field stop in location *)


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
