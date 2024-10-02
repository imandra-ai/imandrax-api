
(** Code for session.proto *)

(* generated from "session.proto", do not edit *)



(** {2 Types} *)

type session = {
  id : string;
}

type session_create = {
  po_check : bool option;
  api_version : string;
}

type session_open = {
  id : session option;
  api_version : string;
}


(** {2 Basic values} *)

val default_session : 
  ?id:string ->
  unit ->
  session
(** [default_session ()] is the default value for type [session] *)

val default_session_create : 
  ?po_check:bool option ->
  ?api_version:string ->
  unit ->
  session_create
(** [default_session_create ()] is the default value for type [session_create] *)

val default_session_open : 
  ?id:session option ->
  ?api_version:string ->
  unit ->
  session_open
(** [default_session_open ()] is the default value for type [session_open] *)


(** {2 Make functions} *)

val make_session : 
  id:string ->
  unit ->
  session
(** [make_session … ()] is a builder for type [session] *)

val make_session_create : 
  ?po_check:bool option ->
  api_version:string ->
  unit ->
  session_create
(** [make_session_create … ()] is a builder for type [session_create] *)

val make_session_open : 
  ?id:session option ->
  api_version:string ->
  unit ->
  session_open
(** [make_session_open … ()] is a builder for type [session_open] *)


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
    
    val keep_session_alive : (session, unary, Utils.empty, unary) Client.rpc
  end
  
  module Server : sig
    (** Produce a server implementation from handlers *)
    val make : 
      create_session:((session_create, unary, session, unary) Server.rpc -> 'handler) ->
      open_session:((session_open, unary, Utils.empty, unary) Server.rpc -> 'handler) ->
      keep_session_alive:((session, unary, Utils.empty, unary) Server.rpc -> 'handler) ->
      unit -> 'handler Pbrt_services.Server.t
    
    (** The individual server stubs are only exposed for advanced users. Casual users should prefer accessing them through {!make}. *)
    
    val create_session : (session_create,unary,session,unary) Server.rpc
    
    val open_session : (session_open,unary,Utils.empty,unary) Server.rpc
    
    val keep_session_alive : (session,unary,Utils.empty,unary) Server.rpc
  end
end
