
(** Code for system.proto *)

(* generated from "system.proto", do not edit *)



(** {2 Types} *)

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

val pp_gc_stats : Format.formatter -> gc_stats -> unit 
(** [pp_gc_stats v] formats v *)

val pp_version_response : Format.formatter -> version_response -> unit 
(** [pp_version_response v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_gc_stats : gc_stats -> Pbrt.Encoder.t -> unit
(** [encode_pb_gc_stats v encoder] encodes [v] with the given [encoder] *)

val encode_pb_version_response : version_response -> Pbrt.Encoder.t -> unit
(** [encode_pb_version_response v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_gc_stats : Pbrt.Decoder.t -> gc_stats
(** [decode_pb_gc_stats decoder] decodes a [gc_stats] binary value from [decoder] *)

val decode_pb_version_response : Pbrt.Decoder.t -> version_response
(** [decode_pb_version_response decoder] decodes a [version_response] binary value from [decoder] *)


(** {2 Protobuf YoJson Encoding} *)

val encode_json_gc_stats : gc_stats -> Yojson.Basic.t
(** [encode_json_gc_stats v encoder] encodes [v] to to json *)

val encode_json_version_response : version_response -> Yojson.Basic.t
(** [encode_json_version_response v encoder] encodes [v] to to json *)


(** {2 JSON Decoding} *)

val decode_json_gc_stats : Yojson.Basic.t -> gc_stats
(** [decode_json_gc_stats decoder] decodes a [gc_stats] value from [decoder] *)

val decode_json_version_response : Yojson.Basic.t -> version_response
(** [decode_json_version_response decoder] decodes a [version_response] value from [decoder] *)


(** {2 Services} *)

(** System service *)
module System : sig
  open Pbrt_services
  open Pbrt_services.Value_mode
  
  module Client : sig
    
    val version : (Utils.empty, unary, version_response, unary) Client.rpc
    
    val gc_stats : (Utils.empty, unary, gc_stats, unary) Client.rpc
    
    val release_memory : (Utils.empty, unary, gc_stats, unary) Client.rpc
  end
  
  module Server : sig
    (** Produce a server implementation from handlers *)
    val make : 
      version:((Utils.empty, unary, version_response, unary) Server.rpc -> 'handler) ->
      gc_stats:((Utils.empty, unary, gc_stats, unary) Server.rpc -> 'handler) ->
      release_memory:((Utils.empty, unary, gc_stats, unary) Server.rpc -> 'handler) ->
      unit -> 'handler Pbrt_services.Server.t
    
    (** The individual server stubs are only exposed for advanced users. Casual users should prefer accessing them through {!make}. *)
    
    val version : (Utils.empty,unary,version_response,unary) Server.rpc
    
    val gc_stats : (Utils.empty,unary,gc_stats,unary) Server.rpc
    
    val release_memory : (Utils.empty,unary,gc_stats,unary) Server.rpc
  end
end
