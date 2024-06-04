
(** Code for api.proto *)

(* generated from "api.proto", do not edit *)



(** {2 Types} *)

type task_kind =
  | Task_unspecified 
  | Task_eval 
  | Task_check_po 
  | Task_proof_check 

type task_id = {
  id : string;
}

type task = {
  id : task_id option;
  kind : task_kind;
}

type session = {
  id : string;
}

type session_create = {
  po_check : bool option;
}

type session_open = {
  id : session option;
}

type code_snippet = {
  session : session option;
  code : string;
}

type eval_result =
  | Eval_ok 
  | Eval_errors 

type code_snippet_eval_result = {
  res : eval_result;
  duration_s : float;
  tasks : task list;
  errors : Error.error list;
}

type artifact_list_query = {
  task_id : task_id option;
}

type artifact_list_result = {
  kinds : string list;
}

type artifact_get_query = {
  task_id : task_id option;
  kind : string;
}

type artifact_get_result = {
  art : Artmsg.art option;
}

type gc_stats = {
  heap_size_b : int64;
  major_collections : int64;
  minor_collections : int64;
}

type version_response = {
  version : string;
  git_version : string option;
}


(** {2 Basic values} *)

val default_task_kind : unit -> task_kind
(** [default_task_kind ()] is the default value for type [task_kind] *)

val default_task_id : 
  ?id:string ->
  unit ->
  task_id
(** [default_task_id ()] is the default value for type [task_id] *)

val default_task : 
  ?id:task_id option ->
  ?kind:task_kind ->
  unit ->
  task
(** [default_task ()] is the default value for type [task] *)

val default_session : 
  ?id:string ->
  unit ->
  session
(** [default_session ()] is the default value for type [session] *)

val default_session_create : 
  ?po_check:bool option ->
  unit ->
  session_create
(** [default_session_create ()] is the default value for type [session_create] *)

val default_session_open : 
  ?id:session option ->
  unit ->
  session_open
(** [default_session_open ()] is the default value for type [session_open] *)

val default_code_snippet : 
  ?session:session option ->
  ?code:string ->
  unit ->
  code_snippet
(** [default_code_snippet ()] is the default value for type [code_snippet] *)

val default_eval_result : unit -> eval_result
(** [default_eval_result ()] is the default value for type [eval_result] *)

val default_code_snippet_eval_result : 
  ?res:eval_result ->
  ?duration_s:float ->
  ?tasks:task list ->
  ?errors:Error.error list ->
  unit ->
  code_snippet_eval_result
(** [default_code_snippet_eval_result ()] is the default value for type [code_snippet_eval_result] *)

val default_artifact_list_query : 
  ?task_id:task_id option ->
  unit ->
  artifact_list_query
(** [default_artifact_list_query ()] is the default value for type [artifact_list_query] *)

val default_artifact_list_result : 
  ?kinds:string list ->
  unit ->
  artifact_list_result
(** [default_artifact_list_result ()] is the default value for type [artifact_list_result] *)

val default_artifact_get_query : 
  ?task_id:task_id option ->
  ?kind:string ->
  unit ->
  artifact_get_query
(** [default_artifact_get_query ()] is the default value for type [artifact_get_query] *)

val default_artifact_get_result : 
  ?art:Artmsg.art option ->
  unit ->
  artifact_get_result
(** [default_artifact_get_result ()] is the default value for type [artifact_get_result] *)

val default_gc_stats : 
  ?heap_size_b:int64 ->
  ?major_collections:int64 ->
  ?minor_collections:int64 ->
  unit ->
  gc_stats
(** [default_gc_stats ()] is the default value for type [gc_stats] *)

val default_version_response : 
  ?version:string ->
  ?git_version:string option ->
  unit ->
  version_response
(** [default_version_response ()] is the default value for type [version_response] *)


(** {2 Make functions} *)


val make_task_id : 
  id:string ->
  unit ->
  task_id
(** [make_task_id … ()] is a builder for type [task_id] *)

val make_task : 
  ?id:task_id option ->
  kind:task_kind ->
  unit ->
  task
(** [make_task … ()] is a builder for type [task] *)

val make_session : 
  id:string ->
  unit ->
  session
(** [make_session … ()] is a builder for type [session] *)

val make_session_create : 
  ?po_check:bool option ->
  unit ->
  session_create
(** [make_session_create … ()] is a builder for type [session_create] *)

val make_session_open : 
  ?id:session option ->
  unit ->
  session_open
(** [make_session_open … ()] is a builder for type [session_open] *)

val make_code_snippet : 
  ?session:session option ->
  code:string ->
  unit ->
  code_snippet
(** [make_code_snippet … ()] is a builder for type [code_snippet] *)


val make_code_snippet_eval_result : 
  res:eval_result ->
  duration_s:float ->
  tasks:task list ->
  errors:Error.error list ->
  unit ->
  code_snippet_eval_result
(** [make_code_snippet_eval_result … ()] is a builder for type [code_snippet_eval_result] *)

val make_artifact_list_query : 
  ?task_id:task_id option ->
  unit ->
  artifact_list_query
(** [make_artifact_list_query … ()] is a builder for type [artifact_list_query] *)

val make_artifact_list_result : 
  kinds:string list ->
  unit ->
  artifact_list_result
(** [make_artifact_list_result … ()] is a builder for type [artifact_list_result] *)

val make_artifact_get_query : 
  ?task_id:task_id option ->
  kind:string ->
  unit ->
  artifact_get_query
(** [make_artifact_get_query … ()] is a builder for type [artifact_get_query] *)

val make_artifact_get_result : 
  ?art:Artmsg.art option ->
  unit ->
  artifact_get_result
(** [make_artifact_get_result … ()] is a builder for type [artifact_get_result] *)

val make_gc_stats : 
  heap_size_b:int64 ->
  major_collections:int64 ->
  minor_collections:int64 ->
  unit ->
  gc_stats
(** [make_gc_stats … ()] is a builder for type [gc_stats] *)

val make_version_response : 
  version:string ->
  ?git_version:string option ->
  unit ->
  version_response
(** [make_version_response … ()] is a builder for type [version_response] *)


(** {2 Formatters} *)

val pp_task_kind : Format.formatter -> task_kind -> unit 
(** [pp_task_kind v] formats v *)

val pp_task_id : Format.formatter -> task_id -> unit 
(** [pp_task_id v] formats v *)

val pp_task : Format.formatter -> task -> unit 
(** [pp_task v] formats v *)

val pp_session : Format.formatter -> session -> unit 
(** [pp_session v] formats v *)

val pp_session_create : Format.formatter -> session_create -> unit 
(** [pp_session_create v] formats v *)

val pp_session_open : Format.formatter -> session_open -> unit 
(** [pp_session_open v] formats v *)

val pp_code_snippet : Format.formatter -> code_snippet -> unit 
(** [pp_code_snippet v] formats v *)

val pp_eval_result : Format.formatter -> eval_result -> unit 
(** [pp_eval_result v] formats v *)

val pp_code_snippet_eval_result : Format.formatter -> code_snippet_eval_result -> unit 
(** [pp_code_snippet_eval_result v] formats v *)

val pp_artifact_list_query : Format.formatter -> artifact_list_query -> unit 
(** [pp_artifact_list_query v] formats v *)

val pp_artifact_list_result : Format.formatter -> artifact_list_result -> unit 
(** [pp_artifact_list_result v] formats v *)

val pp_artifact_get_query : Format.formatter -> artifact_get_query -> unit 
(** [pp_artifact_get_query v] formats v *)

val pp_artifact_get_result : Format.formatter -> artifact_get_result -> unit 
(** [pp_artifact_get_result v] formats v *)

val pp_gc_stats : Format.formatter -> gc_stats -> unit 
(** [pp_gc_stats v] formats v *)

val pp_version_response : Format.formatter -> version_response -> unit 
(** [pp_version_response v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_task_kind : task_kind -> Pbrt.Encoder.t -> unit
(** [encode_pb_task_kind v encoder] encodes [v] with the given [encoder] *)

val encode_pb_task_id : task_id -> Pbrt.Encoder.t -> unit
(** [encode_pb_task_id v encoder] encodes [v] with the given [encoder] *)

val encode_pb_task : task -> Pbrt.Encoder.t -> unit
(** [encode_pb_task v encoder] encodes [v] with the given [encoder] *)

val encode_pb_session : session -> Pbrt.Encoder.t -> unit
(** [encode_pb_session v encoder] encodes [v] with the given [encoder] *)

val encode_pb_session_create : session_create -> Pbrt.Encoder.t -> unit
(** [encode_pb_session_create v encoder] encodes [v] with the given [encoder] *)

val encode_pb_session_open : session_open -> Pbrt.Encoder.t -> unit
(** [encode_pb_session_open v encoder] encodes [v] with the given [encoder] *)

val encode_pb_code_snippet : code_snippet -> Pbrt.Encoder.t -> unit
(** [encode_pb_code_snippet v encoder] encodes [v] with the given [encoder] *)

val encode_pb_eval_result : eval_result -> Pbrt.Encoder.t -> unit
(** [encode_pb_eval_result v encoder] encodes [v] with the given [encoder] *)

val encode_pb_code_snippet_eval_result : code_snippet_eval_result -> Pbrt.Encoder.t -> unit
(** [encode_pb_code_snippet_eval_result v encoder] encodes [v] with the given [encoder] *)

val encode_pb_artifact_list_query : artifact_list_query -> Pbrt.Encoder.t -> unit
(** [encode_pb_artifact_list_query v encoder] encodes [v] with the given [encoder] *)

val encode_pb_artifact_list_result : artifact_list_result -> Pbrt.Encoder.t -> unit
(** [encode_pb_artifact_list_result v encoder] encodes [v] with the given [encoder] *)

val encode_pb_artifact_get_query : artifact_get_query -> Pbrt.Encoder.t -> unit
(** [encode_pb_artifact_get_query v encoder] encodes [v] with the given [encoder] *)

val encode_pb_artifact_get_result : artifact_get_result -> Pbrt.Encoder.t -> unit
(** [encode_pb_artifact_get_result v encoder] encodes [v] with the given [encoder] *)

val encode_pb_gc_stats : gc_stats -> Pbrt.Encoder.t -> unit
(** [encode_pb_gc_stats v encoder] encodes [v] with the given [encoder] *)

val encode_pb_version_response : version_response -> Pbrt.Encoder.t -> unit
(** [encode_pb_version_response v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_task_kind : Pbrt.Decoder.t -> task_kind
(** [decode_pb_task_kind decoder] decodes a [task_kind] binary value from [decoder] *)

val decode_pb_task_id : Pbrt.Decoder.t -> task_id
(** [decode_pb_task_id decoder] decodes a [task_id] binary value from [decoder] *)

val decode_pb_task : Pbrt.Decoder.t -> task
(** [decode_pb_task decoder] decodes a [task] binary value from [decoder] *)

val decode_pb_session : Pbrt.Decoder.t -> session
(** [decode_pb_session decoder] decodes a [session] binary value from [decoder] *)

val decode_pb_session_create : Pbrt.Decoder.t -> session_create
(** [decode_pb_session_create decoder] decodes a [session_create] binary value from [decoder] *)

val decode_pb_session_open : Pbrt.Decoder.t -> session_open
(** [decode_pb_session_open decoder] decodes a [session_open] binary value from [decoder] *)

val decode_pb_code_snippet : Pbrt.Decoder.t -> code_snippet
(** [decode_pb_code_snippet decoder] decodes a [code_snippet] binary value from [decoder] *)

val decode_pb_eval_result : Pbrt.Decoder.t -> eval_result
(** [decode_pb_eval_result decoder] decodes a [eval_result] binary value from [decoder] *)

val decode_pb_code_snippet_eval_result : Pbrt.Decoder.t -> code_snippet_eval_result
(** [decode_pb_code_snippet_eval_result decoder] decodes a [code_snippet_eval_result] binary value from [decoder] *)

val decode_pb_artifact_list_query : Pbrt.Decoder.t -> artifact_list_query
(** [decode_pb_artifact_list_query decoder] decodes a [artifact_list_query] binary value from [decoder] *)

val decode_pb_artifact_list_result : Pbrt.Decoder.t -> artifact_list_result
(** [decode_pb_artifact_list_result decoder] decodes a [artifact_list_result] binary value from [decoder] *)

val decode_pb_artifact_get_query : Pbrt.Decoder.t -> artifact_get_query
(** [decode_pb_artifact_get_query decoder] decodes a [artifact_get_query] binary value from [decoder] *)

val decode_pb_artifact_get_result : Pbrt.Decoder.t -> artifact_get_result
(** [decode_pb_artifact_get_result decoder] decodes a [artifact_get_result] binary value from [decoder] *)

val decode_pb_gc_stats : Pbrt.Decoder.t -> gc_stats
(** [decode_pb_gc_stats decoder] decodes a [gc_stats] binary value from [decoder] *)

val decode_pb_version_response : Pbrt.Decoder.t -> version_response
(** [decode_pb_version_response decoder] decodes a [version_response] binary value from [decoder] *)


(** {2 Protobuf YoJson Encoding} *)

val encode_json_task_kind : task_kind -> Yojson.Basic.t
(** [encode_json_task_kind v encoder] encodes [v] to to json *)

val encode_json_task_id : task_id -> Yojson.Basic.t
(** [encode_json_task_id v encoder] encodes [v] to to json *)

val encode_json_task : task -> Yojson.Basic.t
(** [encode_json_task v encoder] encodes [v] to to json *)

val encode_json_session : session -> Yojson.Basic.t
(** [encode_json_session v encoder] encodes [v] to to json *)

val encode_json_session_create : session_create -> Yojson.Basic.t
(** [encode_json_session_create v encoder] encodes [v] to to json *)

val encode_json_session_open : session_open -> Yojson.Basic.t
(** [encode_json_session_open v encoder] encodes [v] to to json *)

val encode_json_code_snippet : code_snippet -> Yojson.Basic.t
(** [encode_json_code_snippet v encoder] encodes [v] to to json *)

val encode_json_eval_result : eval_result -> Yojson.Basic.t
(** [encode_json_eval_result v encoder] encodes [v] to to json *)

val encode_json_code_snippet_eval_result : code_snippet_eval_result -> Yojson.Basic.t
(** [encode_json_code_snippet_eval_result v encoder] encodes [v] to to json *)

val encode_json_artifact_list_query : artifact_list_query -> Yojson.Basic.t
(** [encode_json_artifact_list_query v encoder] encodes [v] to to json *)

val encode_json_artifact_list_result : artifact_list_result -> Yojson.Basic.t
(** [encode_json_artifact_list_result v encoder] encodes [v] to to json *)

val encode_json_artifact_get_query : artifact_get_query -> Yojson.Basic.t
(** [encode_json_artifact_get_query v encoder] encodes [v] to to json *)

val encode_json_artifact_get_result : artifact_get_result -> Yojson.Basic.t
(** [encode_json_artifact_get_result v encoder] encodes [v] to to json *)

val encode_json_gc_stats : gc_stats -> Yojson.Basic.t
(** [encode_json_gc_stats v encoder] encodes [v] to to json *)

val encode_json_version_response : version_response -> Yojson.Basic.t
(** [encode_json_version_response v encoder] encodes [v] to to json *)


(** {2 JSON Decoding} *)

val decode_json_task_kind : Yojson.Basic.t -> task_kind
(** [decode_json_task_kind decoder] decodes a [task_kind] value from [decoder] *)

val decode_json_task_id : Yojson.Basic.t -> task_id
(** [decode_json_task_id decoder] decodes a [task_id] value from [decoder] *)

val decode_json_task : Yojson.Basic.t -> task
(** [decode_json_task decoder] decodes a [task] value from [decoder] *)

val decode_json_session : Yojson.Basic.t -> session
(** [decode_json_session decoder] decodes a [session] value from [decoder] *)

val decode_json_session_create : Yojson.Basic.t -> session_create
(** [decode_json_session_create decoder] decodes a [session_create] value from [decoder] *)

val decode_json_session_open : Yojson.Basic.t -> session_open
(** [decode_json_session_open decoder] decodes a [session_open] value from [decoder] *)

val decode_json_code_snippet : Yojson.Basic.t -> code_snippet
(** [decode_json_code_snippet decoder] decodes a [code_snippet] value from [decoder] *)

val decode_json_eval_result : Yojson.Basic.t -> eval_result
(** [decode_json_eval_result decoder] decodes a [eval_result] value from [decoder] *)

val decode_json_code_snippet_eval_result : Yojson.Basic.t -> code_snippet_eval_result
(** [decode_json_code_snippet_eval_result decoder] decodes a [code_snippet_eval_result] value from [decoder] *)

val decode_json_artifact_list_query : Yojson.Basic.t -> artifact_list_query
(** [decode_json_artifact_list_query decoder] decodes a [artifact_list_query] value from [decoder] *)

val decode_json_artifact_list_result : Yojson.Basic.t -> artifact_list_result
(** [decode_json_artifact_list_result decoder] decodes a [artifact_list_result] value from [decoder] *)

val decode_json_artifact_get_query : Yojson.Basic.t -> artifact_get_query
(** [decode_json_artifact_get_query decoder] decodes a [artifact_get_query] value from [decoder] *)

val decode_json_artifact_get_result : Yojson.Basic.t -> artifact_get_result
(** [decode_json_artifact_get_result decoder] decodes a [artifact_get_result] value from [decoder] *)

val decode_json_gc_stats : Yojson.Basic.t -> gc_stats
(** [decode_json_gc_stats decoder] decodes a [gc_stats] value from [decoder] *)

val decode_json_version_response : Yojson.Basic.t -> version_response
(** [decode_json_version_response decoder] decodes a [version_response] value from [decoder] *)


(** {2 Services} *)

(** SessionManager service *)
module SessionManager : sig
  open Pbrt_services
  open Pbrt_services.Value_mode
  
  module Client : sig
    
    val create_session : (session_create, unary, session, unary) Client.rpc
    
    val open_session : (session_open, unary, unit, unary) Client.rpc
    
    val keep_session_alive : (session, unary, unit, unary) Client.rpc
  end
  
  module Server : sig
    (** Produce a server implementation from handlers *)
    val make : 
      create_session:((session_create, unary, session, unary) Server.rpc -> 'handler) ->
      open_session:((session_open, unary, unit, unary) Server.rpc -> 'handler) ->
      keep_session_alive:((session, unary, unit, unary) Server.rpc -> 'handler) ->
      unit -> 'handler Pbrt_services.Server.t
  end
end

(** Eval service *)
module Eval : sig
  open Pbrt_services
  open Pbrt_services.Value_mode
  
  module Client : sig
    
    val eval_code_snippet : (code_snippet, unary, code_snippet_eval_result, unary) Client.rpc
    
    val list_artifacts : (artifact_list_query, unary, artifact_list_result, unary) Client.rpc
    
    val get_artifact : (artifact_get_query, unary, artifact_get_result, unary) Client.rpc
  end
  
  module Server : sig
    (** Produce a server implementation from handlers *)
    val make : 
      eval_code_snippet:((code_snippet, unary, code_snippet_eval_result, unary) Server.rpc -> 'handler) ->
      list_artifacts:((artifact_list_query, unary, artifact_list_result, unary) Server.rpc -> 'handler) ->
      get_artifact:((artifact_get_query, unary, artifact_get_result, unary) Server.rpc -> 'handler) ->
      unit -> 'handler Pbrt_services.Server.t
  end
end

(** System service *)
module System : sig
  open Pbrt_services
  open Pbrt_services.Value_mode
  
  module Client : sig
    
    val version : (unit, unary, version_response, unary) Client.rpc
    
    val gc_stats : (unit, unary, gc_stats, unary) Client.rpc
    
    val release_memory : (unit, unary, gc_stats, unary) Client.rpc
  end
  
  module Server : sig
    (** Produce a server implementation from handlers *)
    val make : 
      version:((unit, unary, version_response, unary) Server.rpc -> 'handler) ->
      gc_stats:((unit, unary, gc_stats, unary) Server.rpc -> 'handler) ->
      release_memory:((unit, unary, gc_stats, unary) Server.rpc -> 'handler) ->
      unit -> 'handler Pbrt_services.Server.t
  end
end
