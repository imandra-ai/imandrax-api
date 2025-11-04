
(** Code for session.proto *)

(* generated from "session.proto", do not edit *)



(** {2 Types} *)

type session = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable id : string;
}

type session_create = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable po_check : bool;
  mutable api_version : string;
}

type session_open = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable id : session option;
  mutable api_version : string;
}


(** {2 Basic values} *)

val default_session : unit -> session 
(** [default_session ()] is a new empty value for type [session] *)

val default_session_create : unit -> session_create 
(** [default_session_create ()] is a new empty value for type [session_create] *)

val default_session_open : unit -> session_open 
(** [default_session_open ()] is a new empty value for type [session_open] *)


(** {2 Make functions} *)

val make_session : 
  ?id:string ->
  unit ->
  session
(** [make_session … ()] is a builder for type [session] *)

val copy_session : session -> session

val session_has_id : session -> bool
  (** presence of field "id" in [session] *)

val session_set_id : session -> string -> unit
  (** set field id in session *)

val make_session_create : 
  ?po_check:bool ->
  ?api_version:string ->
  unit ->
  session_create
(** [make_session_create … ()] is a builder for type [session_create] *)

val copy_session_create : session_create -> session_create

val session_create_has_po_check : session_create -> bool
  (** presence of field "po_check" in [session_create] *)

val session_create_set_po_check : session_create -> bool -> unit
  (** set field po_check in session_create *)

val session_create_has_api_version : session_create -> bool
  (** presence of field "api_version" in [session_create] *)

val session_create_set_api_version : session_create -> string -> unit
  (** set field api_version in session_create *)

val make_session_open : 
  ?id:session ->
  ?api_version:string ->
  unit ->
  session_open
(** [make_session_open … ()] is a builder for type [session_open] *)

val copy_session_open : session_open -> session_open

val session_open_set_id : session_open -> session -> unit
  (** set field id in session_open *)

val session_open_has_api_version : session_open -> bool
  (** presence of field "api_version" in [session_open] *)

val session_open_set_api_version : session_open -> string -> unit
  (** set field api_version in session_open *)


(** {2 Formatters} *)

val pp_session : Format.formatter -> session -> unit 
(** [pp_session v] formats v *)

val pp_session_create : Format.formatter -> session_create -> unit 
(** [pp_session_create v] formats v *)

val pp_session_open : Format.formatter -> session_open -> unit 
(** [pp_session_open v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_session : session -> Pbrt.Encoder.t -> unit
(** [encode_pb_session v encoder] encodes [v] with the given [encoder] *)

val encode_pb_session_create : session_create -> Pbrt.Encoder.t -> unit
(** [encode_pb_session_create v encoder] encodes [v] with the given [encoder] *)

val encode_pb_session_open : session_open -> Pbrt.Encoder.t -> unit
(** [encode_pb_session_open v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_session : Pbrt.Decoder.t -> session
(** [decode_pb_session decoder] decodes a [session] binary value from [decoder] *)

val decode_pb_session_create : Pbrt.Decoder.t -> session_create
(** [decode_pb_session_create decoder] decodes a [session_create] binary value from [decoder] *)

val decode_pb_session_open : Pbrt.Decoder.t -> session_open
(** [decode_pb_session_open decoder] decodes a [session_open] binary value from [decoder] *)


(** {2 Protobuf YoJson Encoding} *)

val encode_json_session : session -> Yojson.Basic.t
(** [encode_json_session v encoder] encodes [v] to to json *)

val encode_json_session_create : session_create -> Yojson.Basic.t
(** [encode_json_session_create v encoder] encodes [v] to to json *)

val encode_json_session_open : session_open -> Yojson.Basic.t
(** [encode_json_session_open v encoder] encodes [v] to to json *)


(** {2 JSON Decoding} *)

val decode_json_session : Yojson.Basic.t -> session
(** [decode_json_session decoder] decodes a [session] value from [decoder] *)

val decode_json_session_create : Yojson.Basic.t -> session_create
(** [decode_json_session_create decoder] decodes a [session_create] value from [decoder] *)

val decode_json_session_open : Yojson.Basic.t -> session_open
(** [decode_json_session_open decoder] decodes a [session_open] value from [decoder] *)


(** {2 Services} *)

(** SessionManager service *)
module SessionManager : sig
  open Pbrt_services
  open Pbrt_services.Value_mode
  
  module Client : sig
    
    val create_session : (session_create, unary, session, unary) Client.rpc
    
    val open_session : (session_open, unary, Utils.empty, unary) Client.rpc
    
    val end_session : (session, unary, Utils.empty, unary) Client.rpc
    
    val keep_session_alive : (session, unary, Utils.empty, unary) Client.rpc
  end
  
  module Server : sig
    (** Produce a server implementation from handlers *)
    val make : 
      create_session:((session_create, unary, session, unary) Server.rpc -> 'handler) ->
      open_session:((session_open, unary, Utils.empty, unary) Server.rpc -> 'handler) ->
      end_session:((session, unary, Utils.empty, unary) Server.rpc -> 'handler) ->
      keep_session_alive:((session, unary, Utils.empty, unary) Server.rpc -> 'handler) ->
      unit -> 'handler Pbrt_services.Server.t
    
    (** The individual server stubs are only exposed for advanced users. Casual users should prefer accessing them through {!make}. *)
    
    val create_session : (session_create,unary,session,unary) Server.rpc
    
    val open_session : (session_open,unary,Utils.empty,unary) Server.rpc
    
    val end_session : (session,unary,Utils.empty,unary) Server.rpc
    
    val keep_session_alive : (session,unary,Utils.empty,unary) Server.rpc
  end
end
