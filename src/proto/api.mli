
(** Code for api.proto *)

(* generated from "api.proto", do not edit *)



(** {2 Types} *)

type empty = unit

type gc_stats = {
  heap_size_b : int32;
  major_collections : int32;
  minor_collections : int32;
}


(** {2 Basic values} *)

val default_empty : unit
(** [default_empty ()] is the default value for type [empty] *)

val default_gc_stats : 
  ?heap_size_b:int32 ->
  ?major_collections:int32 ->
  ?minor_collections:int32 ->
  unit ->
  gc_stats
(** [default_gc_stats ()] is the default value for type [gc_stats] *)


(** {2 Make functions} *)


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

val pp_gc_stats : Format.formatter -> gc_stats -> unit 
(** [pp_gc_stats v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_empty : empty -> Pbrt.Encoder.t -> unit
(** [encode_pb_empty v encoder] encodes [v] with the given [encoder] *)

val encode_pb_gc_stats : gc_stats -> Pbrt.Encoder.t -> unit
(** [encode_pb_gc_stats v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_empty : Pbrt.Decoder.t -> empty
(** [decode_pb_empty decoder] decodes a [empty] binary value from [decoder] *)

val decode_pb_gc_stats : Pbrt.Decoder.t -> gc_stats
(** [decode_pb_gc_stats decoder] decodes a [gc_stats] binary value from [decoder] *)


(** {2 Protobuf YoJson Encoding} *)

val encode_json_empty : empty -> Yojson.Basic.t
(** [encode_json_empty v encoder] encodes [v] to to json *)

val encode_json_gc_stats : gc_stats -> Yojson.Basic.t
(** [encode_json_gc_stats v encoder] encodes [v] to to json *)


(** {2 JSON Decoding} *)

val decode_json_empty : Yojson.Basic.t -> empty
(** [decode_json_empty decoder] decodes a [empty] value from [decoder] *)

val decode_json_gc_stats : Yojson.Basic.t -> gc_stats
(** [decode_json_gc_stats decoder] decodes a [gc_stats] value from [decoder] *)


(** {2 Services} *)

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
