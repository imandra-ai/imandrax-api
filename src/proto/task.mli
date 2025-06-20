
(** Code for task.proto *)

(* generated from "task.proto", do not edit *)



(** {2 Types} *)

type task_kind =
  | Task_unspecified 
  | Task_eval 
  | Task_check_po 
  | Task_proof_check 
  | Task_decomp 

type task_id = {
  id : string;
}

type task = {
  id : task_id option;
  kind : task_kind;
}

type origin = {
  from_sym : string;
  count : int32;
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

val default_origin : 
  ?from_sym:string ->
  ?count:int32 ->
  unit ->
  origin
(** [default_origin ()] is the default value for type [origin] *)


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

val make_origin : 
  from_sym:string ->
  count:int32 ->
  unit ->
  origin
(** [make_origin … ()] is a builder for type [origin] *)


(** {2 Formatters} *)

val pp_task_kind : Format.formatter -> task_kind -> unit 
(** [pp_task_kind v] formats v *)

val pp_task_id : Format.formatter -> task_id -> unit 
(** [pp_task_id v] formats v *)

val pp_task : Format.formatter -> task -> unit 
(** [pp_task v] formats v *)

val pp_origin : Format.formatter -> origin -> unit 
(** [pp_origin v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_task_kind : task_kind -> Pbrt.Encoder.t -> unit
(** [encode_pb_task_kind v encoder] encodes [v] with the given [encoder] *)

val encode_pb_task_id : task_id -> Pbrt.Encoder.t -> unit
(** [encode_pb_task_id v encoder] encodes [v] with the given [encoder] *)

val encode_pb_task : task -> Pbrt.Encoder.t -> unit
(** [encode_pb_task v encoder] encodes [v] with the given [encoder] *)

val encode_pb_origin : origin -> Pbrt.Encoder.t -> unit
(** [encode_pb_origin v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_task_kind : Pbrt.Decoder.t -> task_kind
(** [decode_pb_task_kind decoder] decodes a [task_kind] binary value from [decoder] *)

val decode_pb_task_id : Pbrt.Decoder.t -> task_id
(** [decode_pb_task_id decoder] decodes a [task_id] binary value from [decoder] *)

val decode_pb_task : Pbrt.Decoder.t -> task
(** [decode_pb_task decoder] decodes a [task] binary value from [decoder] *)

val decode_pb_origin : Pbrt.Decoder.t -> origin
(** [decode_pb_origin decoder] decodes a [origin] binary value from [decoder] *)


(** {2 Protobuf YoJson Encoding} *)

val encode_json_task_kind : task_kind -> Yojson.Basic.t
(** [encode_json_task_kind v encoder] encodes [v] to to json *)

val encode_json_task_id : task_id -> Yojson.Basic.t
(** [encode_json_task_id v encoder] encodes [v] to to json *)

val encode_json_task : task -> Yojson.Basic.t
(** [encode_json_task v encoder] encodes [v] to to json *)

val encode_json_origin : origin -> Yojson.Basic.t
(** [encode_json_origin v encoder] encodes [v] to to json *)


(** {2 JSON Decoding} *)

val decode_json_task_kind : Yojson.Basic.t -> task_kind
(** [decode_json_task_kind decoder] decodes a [task_kind] value from [decoder] *)

val decode_json_task_id : Yojson.Basic.t -> task_id
(** [decode_json_task_id decoder] decodes a [task_id] value from [decoder] *)

val decode_json_task : Yojson.Basic.t -> task
(** [decode_json_task decoder] decodes a [task] value from [decoder] *)

val decode_json_origin : Yojson.Basic.t -> origin
(** [decode_json_origin decoder] decodes a [origin] value from [decoder] *)


(** {2 Services} *)
