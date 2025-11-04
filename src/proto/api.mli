
(** Code for api.proto *)

(* generated from "api.proto", do not edit *)



(** {2 Types} *)

type code_snippet = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable session : Session.session option;
  mutable code : string;
}

type eval_result =
  | Eval_ok 
  | Eval_errors 

type code_snippet_eval_result = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable res : eval_result;
  mutable duration_s : float;
  mutable tasks : Task.task list;
  mutable errors : Error.error list;
}

type parse_query = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable code : string;
}

type artifact_list_query = private {
  mutable task_id : Task.task_id option;
}

type artifact_list_result = private {
  mutable kinds : string list;
}

type artifact_get_query = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable task_id : Task.task_id option;
  mutable kind : string;
}

type artifact = private {
  mutable art : Artmsg.art option;
}

type artifact_zip = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable art_zip : bytes;
}


(** {2 Basic values} *)

val default_code_snippet : unit -> code_snippet 
(** [default_code_snippet ()] is a new empty value for type [code_snippet] *)

val default_eval_result : unit -> eval_result
(** [default_eval_result ()] is a new empty value for type [eval_result] *)

val default_code_snippet_eval_result : unit -> code_snippet_eval_result 
(** [default_code_snippet_eval_result ()] is a new empty value for type [code_snippet_eval_result] *)

val default_parse_query : unit -> parse_query 
(** [default_parse_query ()] is a new empty value for type [parse_query] *)

val default_artifact_list_query : unit -> artifact_list_query 
(** [default_artifact_list_query ()] is a new empty value for type [artifact_list_query] *)

val default_artifact_list_result : unit -> artifact_list_result 
(** [default_artifact_list_result ()] is a new empty value for type [artifact_list_result] *)

val default_artifact_get_query : unit -> artifact_get_query 
(** [default_artifact_get_query ()] is a new empty value for type [artifact_get_query] *)

val default_artifact : unit -> artifact 
(** [default_artifact ()] is a new empty value for type [artifact] *)

val default_artifact_zip : unit -> artifact_zip 
(** [default_artifact_zip ()] is a new empty value for type [artifact_zip] *)


(** {2 Make functions} *)

val make_code_snippet : 
  ?session:Session.session ->
  ?code:string ->
  unit ->
  code_snippet
(** [make_code_snippet … ()] is a builder for type [code_snippet] *)

val copy_code_snippet : code_snippet -> code_snippet

val code_snippet_set_session : code_snippet -> Session.session -> unit
  (** set field session in code_snippet *)

val code_snippet_has_code : code_snippet -> bool
  (** presence of field "code" in [code_snippet] *)

val code_snippet_set_code : code_snippet -> string -> unit
  (** set field code in code_snippet *)

val make_code_snippet_eval_result : 
  ?res:eval_result ->
  ?duration_s:float ->
  ?tasks:Task.task list ->
  ?errors:Error.error list ->
  unit ->
  code_snippet_eval_result
(** [make_code_snippet_eval_result … ()] is a builder for type [code_snippet_eval_result] *)

val copy_code_snippet_eval_result : code_snippet_eval_result -> code_snippet_eval_result

val code_snippet_eval_result_has_res : code_snippet_eval_result -> bool
  (** presence of field "res" in [code_snippet_eval_result] *)

val code_snippet_eval_result_set_res : code_snippet_eval_result -> eval_result -> unit
  (** set field res in code_snippet_eval_result *)

val code_snippet_eval_result_has_duration_s : code_snippet_eval_result -> bool
  (** presence of field "duration_s" in [code_snippet_eval_result] *)

val code_snippet_eval_result_set_duration_s : code_snippet_eval_result -> float -> unit
  (** set field duration_s in code_snippet_eval_result *)

val code_snippet_eval_result_set_tasks : code_snippet_eval_result -> Task.task list -> unit
  (** set field tasks in code_snippet_eval_result *)

val code_snippet_eval_result_set_errors : code_snippet_eval_result -> Error.error list -> unit
  (** set field errors in code_snippet_eval_result *)

val make_parse_query : 
  ?code:string ->
  unit ->
  parse_query
(** [make_parse_query … ()] is a builder for type [parse_query] *)

val copy_parse_query : parse_query -> parse_query

val parse_query_has_code : parse_query -> bool
  (** presence of field "code" in [parse_query] *)

val parse_query_set_code : parse_query -> string -> unit
  (** set field code in parse_query *)

val make_artifact_list_query : 
  ?task_id:Task.task_id ->
  unit ->
  artifact_list_query
(** [make_artifact_list_query … ()] is a builder for type [artifact_list_query] *)

val copy_artifact_list_query : artifact_list_query -> artifact_list_query

val artifact_list_query_set_task_id : artifact_list_query -> Task.task_id -> unit
  (** set field task_id in artifact_list_query *)

val make_artifact_list_result : 
  ?kinds:string list ->
  unit ->
  artifact_list_result
(** [make_artifact_list_result … ()] is a builder for type [artifact_list_result] *)

val copy_artifact_list_result : artifact_list_result -> artifact_list_result

val artifact_list_result_set_kinds : artifact_list_result -> string list -> unit
  (** set field kinds in artifact_list_result *)

val make_artifact_get_query : 
  ?task_id:Task.task_id ->
  ?kind:string ->
  unit ->
  artifact_get_query
(** [make_artifact_get_query … ()] is a builder for type [artifact_get_query] *)

val copy_artifact_get_query : artifact_get_query -> artifact_get_query

val artifact_get_query_set_task_id : artifact_get_query -> Task.task_id -> unit
  (** set field task_id in artifact_get_query *)

val artifact_get_query_has_kind : artifact_get_query -> bool
  (** presence of field "kind" in [artifact_get_query] *)

val artifact_get_query_set_kind : artifact_get_query -> string -> unit
  (** set field kind in artifact_get_query *)

val make_artifact : 
  ?art:Artmsg.art ->
  unit ->
  artifact
(** [make_artifact … ()] is a builder for type [artifact] *)

val copy_artifact : artifact -> artifact

val artifact_set_art : artifact -> Artmsg.art -> unit
  (** set field art in artifact *)

val make_artifact_zip : 
  ?art_zip:bytes ->
  unit ->
  artifact_zip
(** [make_artifact_zip … ()] is a builder for type [artifact_zip] *)

val copy_artifact_zip : artifact_zip -> artifact_zip

val artifact_zip_has_art_zip : artifact_zip -> bool
  (** presence of field "art_zip" in [artifact_zip] *)

val artifact_zip_set_art_zip : artifact_zip -> bytes -> unit
  (** set field art_zip in artifact_zip *)


(** {2 Formatters} *)

val pp_code_snippet : Format.formatter -> code_snippet -> unit 
(** [pp_code_snippet v] formats v *)

val pp_eval_result : Format.formatter -> eval_result -> unit 
(** [pp_eval_result v] formats v *)

val pp_code_snippet_eval_result : Format.formatter -> code_snippet_eval_result -> unit 
(** [pp_code_snippet_eval_result v] formats v *)

val pp_parse_query : Format.formatter -> parse_query -> unit 
(** [pp_parse_query v] formats v *)

val pp_artifact_list_query : Format.formatter -> artifact_list_query -> unit 
(** [pp_artifact_list_query v] formats v *)

val pp_artifact_list_result : Format.formatter -> artifact_list_result -> unit 
(** [pp_artifact_list_result v] formats v *)

val pp_artifact_get_query : Format.formatter -> artifact_get_query -> unit 
(** [pp_artifact_get_query v] formats v *)

val pp_artifact : Format.formatter -> artifact -> unit 
(** [pp_artifact v] formats v *)

val pp_artifact_zip : Format.formatter -> artifact_zip -> unit 
(** [pp_artifact_zip v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_code_snippet : code_snippet -> Pbrt.Encoder.t -> unit
(** [encode_pb_code_snippet v encoder] encodes [v] with the given [encoder] *)

val encode_pb_eval_result : eval_result -> Pbrt.Encoder.t -> unit
(** [encode_pb_eval_result v encoder] encodes [v] with the given [encoder] *)

val encode_pb_code_snippet_eval_result : code_snippet_eval_result -> Pbrt.Encoder.t -> unit
(** [encode_pb_code_snippet_eval_result v encoder] encodes [v] with the given [encoder] *)

val encode_pb_parse_query : parse_query -> Pbrt.Encoder.t -> unit
(** [encode_pb_parse_query v encoder] encodes [v] with the given [encoder] *)

val encode_pb_artifact_list_query : artifact_list_query -> Pbrt.Encoder.t -> unit
(** [encode_pb_artifact_list_query v encoder] encodes [v] with the given [encoder] *)

val encode_pb_artifact_list_result : artifact_list_result -> Pbrt.Encoder.t -> unit
(** [encode_pb_artifact_list_result v encoder] encodes [v] with the given [encoder] *)

val encode_pb_artifact_get_query : artifact_get_query -> Pbrt.Encoder.t -> unit
(** [encode_pb_artifact_get_query v encoder] encodes [v] with the given [encoder] *)

val encode_pb_artifact : artifact -> Pbrt.Encoder.t -> unit
(** [encode_pb_artifact v encoder] encodes [v] with the given [encoder] *)

val encode_pb_artifact_zip : artifact_zip -> Pbrt.Encoder.t -> unit
(** [encode_pb_artifact_zip v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_code_snippet : Pbrt.Decoder.t -> code_snippet
(** [decode_pb_code_snippet decoder] decodes a [code_snippet] binary value from [decoder] *)

val decode_pb_eval_result : Pbrt.Decoder.t -> eval_result
(** [decode_pb_eval_result decoder] decodes a [eval_result] binary value from [decoder] *)

val decode_pb_code_snippet_eval_result : Pbrt.Decoder.t -> code_snippet_eval_result
(** [decode_pb_code_snippet_eval_result decoder] decodes a [code_snippet_eval_result] binary value from [decoder] *)

val decode_pb_parse_query : Pbrt.Decoder.t -> parse_query
(** [decode_pb_parse_query decoder] decodes a [parse_query] binary value from [decoder] *)

val decode_pb_artifact_list_query : Pbrt.Decoder.t -> artifact_list_query
(** [decode_pb_artifact_list_query decoder] decodes a [artifact_list_query] binary value from [decoder] *)

val decode_pb_artifact_list_result : Pbrt.Decoder.t -> artifact_list_result
(** [decode_pb_artifact_list_result decoder] decodes a [artifact_list_result] binary value from [decoder] *)

val decode_pb_artifact_get_query : Pbrt.Decoder.t -> artifact_get_query
(** [decode_pb_artifact_get_query decoder] decodes a [artifact_get_query] binary value from [decoder] *)

val decode_pb_artifact : Pbrt.Decoder.t -> artifact
(** [decode_pb_artifact decoder] decodes a [artifact] binary value from [decoder] *)

val decode_pb_artifact_zip : Pbrt.Decoder.t -> artifact_zip
(** [decode_pb_artifact_zip decoder] decodes a [artifact_zip] binary value from [decoder] *)


(** {2 Protobuf YoJson Encoding} *)

val encode_json_code_snippet : code_snippet -> Yojson.Basic.t
(** [encode_json_code_snippet v encoder] encodes [v] to to json *)

val encode_json_eval_result : eval_result -> Yojson.Basic.t
(** [encode_json_eval_result v encoder] encodes [v] to to json *)

val encode_json_code_snippet_eval_result : code_snippet_eval_result -> Yojson.Basic.t
(** [encode_json_code_snippet_eval_result v encoder] encodes [v] to to json *)

val encode_json_parse_query : parse_query -> Yojson.Basic.t
(** [encode_json_parse_query v encoder] encodes [v] to to json *)

val encode_json_artifact_list_query : artifact_list_query -> Yojson.Basic.t
(** [encode_json_artifact_list_query v encoder] encodes [v] to to json *)

val encode_json_artifact_list_result : artifact_list_result -> Yojson.Basic.t
(** [encode_json_artifact_list_result v encoder] encodes [v] to to json *)

val encode_json_artifact_get_query : artifact_get_query -> Yojson.Basic.t
(** [encode_json_artifact_get_query v encoder] encodes [v] to to json *)

val encode_json_artifact : artifact -> Yojson.Basic.t
(** [encode_json_artifact v encoder] encodes [v] to to json *)

val encode_json_artifact_zip : artifact_zip -> Yojson.Basic.t
(** [encode_json_artifact_zip v encoder] encodes [v] to to json *)


(** {2 JSON Decoding} *)

val decode_json_code_snippet : Yojson.Basic.t -> code_snippet
(** [decode_json_code_snippet decoder] decodes a [code_snippet] value from [decoder] *)

val decode_json_eval_result : Yojson.Basic.t -> eval_result
(** [decode_json_eval_result decoder] decodes a [eval_result] value from [decoder] *)

val decode_json_code_snippet_eval_result : Yojson.Basic.t -> code_snippet_eval_result
(** [decode_json_code_snippet_eval_result decoder] decodes a [code_snippet_eval_result] value from [decoder] *)

val decode_json_parse_query : Yojson.Basic.t -> parse_query
(** [decode_json_parse_query decoder] decodes a [parse_query] value from [decoder] *)

val decode_json_artifact_list_query : Yojson.Basic.t -> artifact_list_query
(** [decode_json_artifact_list_query decoder] decodes a [artifact_list_query] value from [decoder] *)

val decode_json_artifact_list_result : Yojson.Basic.t -> artifact_list_result
(** [decode_json_artifact_list_result decoder] decodes a [artifact_list_result] value from [decoder] *)

val decode_json_artifact_get_query : Yojson.Basic.t -> artifact_get_query
(** [decode_json_artifact_get_query decoder] decodes a [artifact_get_query] value from [decoder] *)

val decode_json_artifact : Yojson.Basic.t -> artifact
(** [decode_json_artifact decoder] decodes a [artifact] value from [decoder] *)

val decode_json_artifact_zip : Yojson.Basic.t -> artifact_zip
(** [decode_json_artifact_zip decoder] decodes a [artifact_zip] value from [decoder] *)


(** {2 Services} *)

(** Eval service *)
module Eval : sig
  open Pbrt_services
  open Pbrt_services.Value_mode
  
  module Client : sig
    
    val eval_code_snippet : (code_snippet, unary, code_snippet_eval_result, unary) Client.rpc
    
    val parse_term : (code_snippet, unary, artifact, unary) Client.rpc
    
    val parse_type : (code_snippet, unary, artifact, unary) Client.rpc
    
    val list_artifacts : (artifact_list_query, unary, artifact_list_result, unary) Client.rpc
    
    val get_artifact : (artifact_get_query, unary, artifact, unary) Client.rpc
    
    val get_artifact_zip : (artifact_get_query, unary, artifact_zip, unary) Client.rpc
  end
  
  module Server : sig
    (** Produce a server implementation from handlers *)
    val make : 
      eval_code_snippet:((code_snippet, unary, code_snippet_eval_result, unary) Server.rpc -> 'handler) ->
      parse_term:((code_snippet, unary, artifact, unary) Server.rpc -> 'handler) ->
      parse_type:((code_snippet, unary, artifact, unary) Server.rpc -> 'handler) ->
      list_artifacts:((artifact_list_query, unary, artifact_list_result, unary) Server.rpc -> 'handler) ->
      get_artifact:((artifact_get_query, unary, artifact, unary) Server.rpc -> 'handler) ->
      get_artifact_zip:((artifact_get_query, unary, artifact_zip, unary) Server.rpc -> 'handler) ->
      unit -> 'handler Pbrt_services.Server.t
    
    (** The individual server stubs are only exposed for advanced users. Casual users should prefer accessing them through {!make}. *)
    
    val eval_code_snippet : (code_snippet,unary,code_snippet_eval_result,unary) Server.rpc
    
    val parse_term : (code_snippet,unary,artifact,unary) Server.rpc
    
    val parse_type : (code_snippet,unary,artifact,unary) Server.rpc
    
    val list_artifacts : (artifact_list_query,unary,artifact_list_result,unary) Server.rpc
    
    val get_artifact : (artifact_get_query,unary,artifact,unary) Server.rpc
    
    val get_artifact_zip : (artifact_get_query,unary,artifact_zip,unary) Server.rpc
  end
end
