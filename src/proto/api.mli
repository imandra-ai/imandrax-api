
(** Code for api.proto *)

(* generated from "api.proto", do not edit *)



(** {2 Types} *)

type empty = unit

type position = {
  line : int32;
  col : int32;
}

type location = {
  file : string;
  start : position option;
  stop : position option;
}

type error = {
  msg : string;
  kind : string;
  loc : location option;
}

type task_id = {
  id : bytes;
}

type session = {
  id : int32;
}

type session_create = {
  po_check : bool option;
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
  tasks : task_id list;
  errors : error list;
}

type gc_stats = {
  heap_size_b : int32;
  major_collections : int32;
  minor_collections : int32;
}


(** {2 Basic values} *)

val default_empty : unit
(** [default_empty ()] is the default value for type [empty] *)

val default_position : 
  ?line:int32 ->
  ?col:int32 ->
  unit ->
  position
(** [default_position ()] is the default value for type [position] *)

val default_location : 
  ?file:string ->
  ?start:position option ->
  ?stop:position option ->
  unit ->
  location
(** [default_location ()] is the default value for type [location] *)

val default_error : 
  ?msg:string ->
  ?kind:string ->
  ?loc:location option ->
  unit ->
  error
(** [default_error ()] is the default value for type [error] *)

val default_task_id : 
  ?id:bytes ->
  unit ->
  task_id
(** [default_task_id ()] is the default value for type [task_id] *)

val default_session : 
  ?id:int32 ->
  unit ->
  session
(** [default_session ()] is the default value for type [session] *)

val default_session_create : 
  ?po_check:bool option ->
  unit ->
  session_create
(** [default_session_create ()] is the default value for type [session_create] *)

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
  ?tasks:task_id list ->
  ?errors:error list ->
  unit ->
  code_snippet_eval_result
(** [default_code_snippet_eval_result ()] is the default value for type [code_snippet_eval_result] *)

val default_gc_stats : 
  ?heap_size_b:int32 ->
  ?major_collections:int32 ->
  ?minor_collections:int32 ->
  unit ->
  gc_stats
(** [default_gc_stats ()] is the default value for type [gc_stats] *)


(** {2 Make functions} *)


val make_position : 
  line:int32 ->
  col:int32 ->
  unit ->
  position
(** [make_position … ()] is a builder for type [position] *)

val make_location : 
  file:string ->
  ?start:position option ->
  ?stop:position option ->
  unit ->
  location
(** [make_location … ()] is a builder for type [location] *)

val make_error : 
  msg:string ->
  kind:string ->
  ?loc:location option ->
  unit ->
  error
(** [make_error … ()] is a builder for type [error] *)

val make_task_id : 
  id:bytes ->
  unit ->
  task_id
(** [make_task_id … ()] is a builder for type [task_id] *)

val make_session : 
  id:int32 ->
  unit ->
  session
(** [make_session … ()] is a builder for type [session] *)

val make_session_create : 
  ?po_check:bool option ->
  unit ->
  session_create
(** [make_session_create … ()] is a builder for type [session_create] *)

val make_code_snippet : 
  ?session:session option ->
  code:string ->
  unit ->
  code_snippet
(** [make_code_snippet … ()] is a builder for type [code_snippet] *)


val make_code_snippet_eval_result : 
  res:eval_result ->
  duration_s:float ->
  tasks:task_id list ->
  errors:error list ->
  unit ->
  code_snippet_eval_result
(** [make_code_snippet_eval_result … ()] is a builder for type [code_snippet_eval_result] *)

val make_gc_stats : 
  heap_size_b:int32 ->
  major_collections:int32 ->
  minor_collections:int32 ->
  unit ->
  gc_stats
(** [make_gc_stats … ()] is a builder for type [gc_stats] *)


(** {2 Formatters} *)

val pp_empty : Format.formatter -> empty -> unit 
(** [pp_empty v] formats v *)

val pp_position : Format.formatter -> position -> unit 
(** [pp_position v] formats v *)

val pp_location : Format.formatter -> location -> unit 
(** [pp_location v] formats v *)

val pp_error : Format.formatter -> error -> unit 
(** [pp_error v] formats v *)

val pp_task_id : Format.formatter -> task_id -> unit 
(** [pp_task_id v] formats v *)

val pp_session : Format.formatter -> session -> unit 
(** [pp_session v] formats v *)

val pp_session_create : Format.formatter -> session_create -> unit 
(** [pp_session_create v] formats v *)

val pp_code_snippet : Format.formatter -> code_snippet -> unit 
(** [pp_code_snippet v] formats v *)

val pp_eval_result : Format.formatter -> eval_result -> unit 
(** [pp_eval_result v] formats v *)

val pp_code_snippet_eval_result : Format.formatter -> code_snippet_eval_result -> unit 
(** [pp_code_snippet_eval_result v] formats v *)

val pp_gc_stats : Format.formatter -> gc_stats -> unit 
(** [pp_gc_stats v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_empty : empty -> Pbrt.Encoder.t -> unit
(** [encode_pb_empty v encoder] encodes [v] with the given [encoder] *)

val encode_pb_position : position -> Pbrt.Encoder.t -> unit
(** [encode_pb_position v encoder] encodes [v] with the given [encoder] *)

val encode_pb_location : location -> Pbrt.Encoder.t -> unit
(** [encode_pb_location v encoder] encodes [v] with the given [encoder] *)

val encode_pb_error : error -> Pbrt.Encoder.t -> unit
(** [encode_pb_error v encoder] encodes [v] with the given [encoder] *)

val encode_pb_task_id : task_id -> Pbrt.Encoder.t -> unit
(** [encode_pb_task_id v encoder] encodes [v] with the given [encoder] *)

val encode_pb_session : session -> Pbrt.Encoder.t -> unit
(** [encode_pb_session v encoder] encodes [v] with the given [encoder] *)

val encode_pb_session_create : session_create -> Pbrt.Encoder.t -> unit
(** [encode_pb_session_create v encoder] encodes [v] with the given [encoder] *)

val encode_pb_code_snippet : code_snippet -> Pbrt.Encoder.t -> unit
(** [encode_pb_code_snippet v encoder] encodes [v] with the given [encoder] *)

val encode_pb_eval_result : eval_result -> Pbrt.Encoder.t -> unit
(** [encode_pb_eval_result v encoder] encodes [v] with the given [encoder] *)

val encode_pb_code_snippet_eval_result : code_snippet_eval_result -> Pbrt.Encoder.t -> unit
(** [encode_pb_code_snippet_eval_result v encoder] encodes [v] with the given [encoder] *)

val encode_pb_gc_stats : gc_stats -> Pbrt.Encoder.t -> unit
(** [encode_pb_gc_stats v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_empty : Pbrt.Decoder.t -> empty
(** [decode_pb_empty decoder] decodes a [empty] binary value from [decoder] *)

val decode_pb_position : Pbrt.Decoder.t -> position
(** [decode_pb_position decoder] decodes a [position] binary value from [decoder] *)

val decode_pb_location : Pbrt.Decoder.t -> location
(** [decode_pb_location decoder] decodes a [location] binary value from [decoder] *)

val decode_pb_error : Pbrt.Decoder.t -> error
(** [decode_pb_error decoder] decodes a [error] binary value from [decoder] *)

val decode_pb_task_id : Pbrt.Decoder.t -> task_id
(** [decode_pb_task_id decoder] decodes a [task_id] binary value from [decoder] *)

val decode_pb_session : Pbrt.Decoder.t -> session
(** [decode_pb_session decoder] decodes a [session] binary value from [decoder] *)

val decode_pb_session_create : Pbrt.Decoder.t -> session_create
(** [decode_pb_session_create decoder] decodes a [session_create] binary value from [decoder] *)

val decode_pb_code_snippet : Pbrt.Decoder.t -> code_snippet
(** [decode_pb_code_snippet decoder] decodes a [code_snippet] binary value from [decoder] *)

val decode_pb_eval_result : Pbrt.Decoder.t -> eval_result
(** [decode_pb_eval_result decoder] decodes a [eval_result] binary value from [decoder] *)

val decode_pb_code_snippet_eval_result : Pbrt.Decoder.t -> code_snippet_eval_result
(** [decode_pb_code_snippet_eval_result decoder] decodes a [code_snippet_eval_result] binary value from [decoder] *)

val decode_pb_gc_stats : Pbrt.Decoder.t -> gc_stats
(** [decode_pb_gc_stats decoder] decodes a [gc_stats] binary value from [decoder] *)


(** {2 Protobuf YoJson Encoding} *)

val encode_json_empty : empty -> Yojson.Basic.t
(** [encode_json_empty v encoder] encodes [v] to to json *)

val encode_json_position : position -> Yojson.Basic.t
(** [encode_json_position v encoder] encodes [v] to to json *)

val encode_json_location : location -> Yojson.Basic.t
(** [encode_json_location v encoder] encodes [v] to to json *)

val encode_json_error : error -> Yojson.Basic.t
(** [encode_json_error v encoder] encodes [v] to to json *)

val encode_json_task_id : task_id -> Yojson.Basic.t
(** [encode_json_task_id v encoder] encodes [v] to to json *)

val encode_json_session : session -> Yojson.Basic.t
(** [encode_json_session v encoder] encodes [v] to to json *)

val encode_json_session_create : session_create -> Yojson.Basic.t
(** [encode_json_session_create v encoder] encodes [v] to to json *)

val encode_json_code_snippet : code_snippet -> Yojson.Basic.t
(** [encode_json_code_snippet v encoder] encodes [v] to to json *)

val encode_json_eval_result : eval_result -> Yojson.Basic.t
(** [encode_json_eval_result v encoder] encodes [v] to to json *)

val encode_json_code_snippet_eval_result : code_snippet_eval_result -> Yojson.Basic.t
(** [encode_json_code_snippet_eval_result v encoder] encodes [v] to to json *)

val encode_json_gc_stats : gc_stats -> Yojson.Basic.t
(** [encode_json_gc_stats v encoder] encodes [v] to to json *)


(** {2 JSON Decoding} *)

val decode_json_empty : Yojson.Basic.t -> empty
(** [decode_json_empty decoder] decodes a [empty] value from [decoder] *)

val decode_json_position : Yojson.Basic.t -> position
(** [decode_json_position decoder] decodes a [position] value from [decoder] *)

val decode_json_location : Yojson.Basic.t -> location
(** [decode_json_location decoder] decodes a [location] value from [decoder] *)

val decode_json_error : Yojson.Basic.t -> error
(** [decode_json_error decoder] decodes a [error] value from [decoder] *)

val decode_json_task_id : Yojson.Basic.t -> task_id
(** [decode_json_task_id decoder] decodes a [task_id] value from [decoder] *)

val decode_json_session : Yojson.Basic.t -> session
(** [decode_json_session decoder] decodes a [session] value from [decoder] *)

val decode_json_session_create : Yojson.Basic.t -> session_create
(** [decode_json_session_create decoder] decodes a [session_create] value from [decoder] *)

val decode_json_code_snippet : Yojson.Basic.t -> code_snippet
(** [decode_json_code_snippet decoder] decodes a [code_snippet] value from [decoder] *)

val decode_json_eval_result : Yojson.Basic.t -> eval_result
(** [decode_json_eval_result decoder] decodes a [eval_result] value from [decoder] *)

val decode_json_code_snippet_eval_result : Yojson.Basic.t -> code_snippet_eval_result
(** [decode_json_code_snippet_eval_result decoder] decodes a [code_snippet_eval_result] value from [decoder] *)

val decode_json_gc_stats : Yojson.Basic.t -> gc_stats
(** [decode_json_gc_stats decoder] decodes a [gc_stats] value from [decoder] *)


(** {2 Services} *)

(** SessionManager service *)
module SessionManager : sig
  open Pbrt_services
  open Pbrt_services.Value_mode
  
  module Client : sig
    
    val create_session : (session_create, unary, session, unary) Client.rpc
    
    val delete_session : (session, unary, unit, unary) Client.rpc
  end
  
  module Server : sig
    (** Produce a server implementation from handlers *)
    val make : 
      create_session:((session_create, unary, session, unary) Server.rpc -> 'handler) ->
      delete_session:((session, unary, unit, unary) Server.rpc -> 'handler) ->
      unit -> 'handler Pbrt_services.Server.t
  end
end

(** Eval service *)
module Eval : sig
  open Pbrt_services
  open Pbrt_services.Value_mode
  
  module Client : sig
    
    val eval_code_snippet : (code_snippet, unary, code_snippet_eval_result, unary) Client.rpc
  end
  
  module Server : sig
    (** Produce a server implementation from handlers *)
    val make : 
      eval_code_snippet:((code_snippet, unary, code_snippet_eval_result, unary) Server.rpc -> 'handler) ->
      unit -> 'handler Pbrt_services.Server.t
  end
end

(** Gc_service service *)
module Gc_service : sig
  open Pbrt_services
  open Pbrt_services.Value_mode
  
  module Client : sig
    
    val get_stats : (unit, unary, gc_stats, unary) Client.rpc
  end
  
  module Server : sig
    (** Produce a server implementation from handlers *)
    val make : 
      get_stats:((unit, unary, gc_stats, unary) Server.rpc -> 'handler) ->
      unit -> 'handler Pbrt_services.Server.t
  end
end
