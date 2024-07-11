
(** Code for simple_api.proto *)

(* generated from "simple_api.proto", do not edit *)



(** {2 Types} *)

type decompose_req = {
  session : Session.session option;
  name : string;
  assuming : string option;
  prune : bool;
  max_rounds : int32 option;
  stop_at : int32 option;
}

type decompose_region = {
  constraints_pp : string list;
  invariant_pp : string;
  ast_json : string option;
}

type decompose_res = {
  regions : decompose_region list;
}

type eval_src_req = {
  session : Session.session option;
  src : string;
}

type eval_res = {
  success : bool;
  messages : string list;
  errors : Error.error list;
}

type hints_unroll = {
  smt_solver : string option;
  max_steps : int32 option;
}

type hints_induct_functional = {
  f_name : string;
}

type hints_induct_structural_style =
  | Additive 
  | Multiplicative 

type hints_induct_structural = {
  style : hints_induct_structural_style;
  vars : string list;
}

type hints_induct =
  | Default
  | Functional of hints_induct_functional
  | Structural of hints_induct_structural

type hints =
  | Auto
  | Unroll of hints_unroll
  | Induct of hints_induct

type verify_src_req = {
  session : Session.session option;
  src : string;
  hints : hints option;
}

type verify_name_req = {
  session : Session.session option;
  name : string;
  hints : hints option;
}

type instance_src_req = {
  session : Session.session option;
  src : string;
  hints : hints option;
}

type instance_name_req = {
  session : Session.session option;
  name : string;
  hints : hints option;
}

type proved = {
  proof_pp : string option;
}

type unsat = {
  proof_pp : string option;
}

type model_type =
  | Counter_example 
  | Instance 

type model = {
  m_type : model_type;
  src : string;
}

type refuted = {
  model : model option;
}

type sat = {
  model : model option;
}

type verify_res =
  | Unknown of Utils.string_msg
  | Err of Error.error
  | Proved of proved
  | Refuted of refuted

type instance_res =
  | Unknown of Utils.string_msg
  | Err of Error.error
  | Unsat of unsat
  | Sat of sat


(** {2 Basic values} *)

val default_decompose_req : 
  ?session:Session.session option ->
  ?name:string ->
  ?assuming:string option ->
  ?prune:bool ->
  ?max_rounds:int32 option ->
  ?stop_at:int32 option ->
  unit ->
  decompose_req
(** [default_decompose_req ()] is the default value for type [decompose_req] *)

val default_decompose_region : 
  ?constraints_pp:string list ->
  ?invariant_pp:string ->
  ?ast_json:string option ->
  unit ->
  decompose_region
(** [default_decompose_region ()] is the default value for type [decompose_region] *)

val default_decompose_res : 
  ?regions:decompose_region list ->
  unit ->
  decompose_res
(** [default_decompose_res ()] is the default value for type [decompose_res] *)

val default_eval_src_req : 
  ?session:Session.session option ->
  ?src:string ->
  unit ->
  eval_src_req
(** [default_eval_src_req ()] is the default value for type [eval_src_req] *)

val default_eval_res : 
  ?success:bool ->
  ?messages:string list ->
  ?errors:Error.error list ->
  unit ->
  eval_res
(** [default_eval_res ()] is the default value for type [eval_res] *)

val default_hints_unroll : 
  ?smt_solver:string option ->
  ?max_steps:int32 option ->
  unit ->
  hints_unroll
(** [default_hints_unroll ()] is the default value for type [hints_unroll] *)

val default_hints_induct_functional : 
  ?f_name:string ->
  unit ->
  hints_induct_functional
(** [default_hints_induct_functional ()] is the default value for type [hints_induct_functional] *)

val default_hints_induct_structural_style : unit -> hints_induct_structural_style
(** [default_hints_induct_structural_style ()] is the default value for type [hints_induct_structural_style] *)

val default_hints_induct_structural : 
  ?style:hints_induct_structural_style ->
  ?vars:string list ->
  unit ->
  hints_induct_structural
(** [default_hints_induct_structural ()] is the default value for type [hints_induct_structural] *)

val default_hints_induct : unit -> hints_induct
(** [default_hints_induct ()] is the default value for type [hints_induct] *)

val default_hints : unit -> hints
(** [default_hints ()] is the default value for type [hints] *)

val default_verify_src_req : 
  ?session:Session.session option ->
  ?src:string ->
  ?hints:hints option ->
  unit ->
  verify_src_req
(** [default_verify_src_req ()] is the default value for type [verify_src_req] *)

val default_verify_name_req : 
  ?session:Session.session option ->
  ?name:string ->
  ?hints:hints option ->
  unit ->
  verify_name_req
(** [default_verify_name_req ()] is the default value for type [verify_name_req] *)

val default_instance_src_req : 
  ?session:Session.session option ->
  ?src:string ->
  ?hints:hints option ->
  unit ->
  instance_src_req
(** [default_instance_src_req ()] is the default value for type [instance_src_req] *)

val default_instance_name_req : 
  ?session:Session.session option ->
  ?name:string ->
  ?hints:hints option ->
  unit ->
  instance_name_req
(** [default_instance_name_req ()] is the default value for type [instance_name_req] *)

val default_proved : 
  ?proof_pp:string option ->
  unit ->
  proved
(** [default_proved ()] is the default value for type [proved] *)

val default_unsat : 
  ?proof_pp:string option ->
  unit ->
  unsat
(** [default_unsat ()] is the default value for type [unsat] *)

val default_model_type : unit -> model_type
(** [default_model_type ()] is the default value for type [model_type] *)

val default_model : 
  ?m_type:model_type ->
  ?src:string ->
  unit ->
  model
(** [default_model ()] is the default value for type [model] *)

val default_refuted : 
  ?model:model option ->
  unit ->
  refuted
(** [default_refuted ()] is the default value for type [refuted] *)

val default_sat : 
  ?model:model option ->
  unit ->
  sat
(** [default_sat ()] is the default value for type [sat] *)

val default_verify_res : unit -> verify_res
(** [default_verify_res ()] is the default value for type [verify_res] *)

val default_instance_res : unit -> instance_res
(** [default_instance_res ()] is the default value for type [instance_res] *)


(** {2 Make functions} *)

val make_decompose_req : 
  ?session:Session.session option ->
  name:string ->
  ?assuming:string option ->
  prune:bool ->
  ?max_rounds:int32 option ->
  ?stop_at:int32 option ->
  unit ->
  decompose_req
(** [make_decompose_req … ()] is a builder for type [decompose_req] *)

val make_decompose_region : 
  constraints_pp:string list ->
  invariant_pp:string ->
  ?ast_json:string option ->
  unit ->
  decompose_region
(** [make_decompose_region … ()] is a builder for type [decompose_region] *)

val make_decompose_res : 
  regions:decompose_region list ->
  unit ->
  decompose_res
(** [make_decompose_res … ()] is a builder for type [decompose_res] *)

val make_eval_src_req : 
  ?session:Session.session option ->
  src:string ->
  unit ->
  eval_src_req
(** [make_eval_src_req … ()] is a builder for type [eval_src_req] *)

val make_eval_res : 
  success:bool ->
  messages:string list ->
  errors:Error.error list ->
  unit ->
  eval_res
(** [make_eval_res … ()] is a builder for type [eval_res] *)

val make_hints_unroll : 
  ?smt_solver:string option ->
  ?max_steps:int32 option ->
  unit ->
  hints_unroll
(** [make_hints_unroll … ()] is a builder for type [hints_unroll] *)

val make_hints_induct_functional : 
  f_name:string ->
  unit ->
  hints_induct_functional
(** [make_hints_induct_functional … ()] is a builder for type [hints_induct_functional] *)


val make_hints_induct_structural : 
  style:hints_induct_structural_style ->
  vars:string list ->
  unit ->
  hints_induct_structural
(** [make_hints_induct_structural … ()] is a builder for type [hints_induct_structural] *)



val make_verify_src_req : 
  ?session:Session.session option ->
  src:string ->
  ?hints:hints option ->
  unit ->
  verify_src_req
(** [make_verify_src_req … ()] is a builder for type [verify_src_req] *)

val make_verify_name_req : 
  ?session:Session.session option ->
  name:string ->
  ?hints:hints option ->
  unit ->
  verify_name_req
(** [make_verify_name_req … ()] is a builder for type [verify_name_req] *)

val make_instance_src_req : 
  ?session:Session.session option ->
  src:string ->
  ?hints:hints option ->
  unit ->
  instance_src_req
(** [make_instance_src_req … ()] is a builder for type [instance_src_req] *)

val make_instance_name_req : 
  ?session:Session.session option ->
  name:string ->
  ?hints:hints option ->
  unit ->
  instance_name_req
(** [make_instance_name_req … ()] is a builder for type [instance_name_req] *)

val make_proved : 
  ?proof_pp:string option ->
  unit ->
  proved
(** [make_proved … ()] is a builder for type [proved] *)

val make_unsat : 
  ?proof_pp:string option ->
  unit ->
  unsat
(** [make_unsat … ()] is a builder for type [unsat] *)


val make_model : 
  m_type:model_type ->
  src:string ->
  unit ->
  model
(** [make_model … ()] is a builder for type [model] *)

val make_refuted : 
  ?model:model option ->
  unit ->
  refuted
(** [make_refuted … ()] is a builder for type [refuted] *)

val make_sat : 
  ?model:model option ->
  unit ->
  sat
(** [make_sat … ()] is a builder for type [sat] *)




(** {2 Formatters} *)

val pp_decompose_req : Format.formatter -> decompose_req -> unit 
(** [pp_decompose_req v] formats v *)

val pp_decompose_region : Format.formatter -> decompose_region -> unit 
(** [pp_decompose_region v] formats v *)

val pp_decompose_res : Format.formatter -> decompose_res -> unit 
(** [pp_decompose_res v] formats v *)

val pp_eval_src_req : Format.formatter -> eval_src_req -> unit 
(** [pp_eval_src_req v] formats v *)

val pp_eval_res : Format.formatter -> eval_res -> unit 
(** [pp_eval_res v] formats v *)

val pp_hints_unroll : Format.formatter -> hints_unroll -> unit 
(** [pp_hints_unroll v] formats v *)

val pp_hints_induct_functional : Format.formatter -> hints_induct_functional -> unit 
(** [pp_hints_induct_functional v] formats v *)

val pp_hints_induct_structural_style : Format.formatter -> hints_induct_structural_style -> unit 
(** [pp_hints_induct_structural_style v] formats v *)

val pp_hints_induct_structural : Format.formatter -> hints_induct_structural -> unit 
(** [pp_hints_induct_structural v] formats v *)

val pp_hints_induct : Format.formatter -> hints_induct -> unit 
(** [pp_hints_induct v] formats v *)

val pp_hints : Format.formatter -> hints -> unit 
(** [pp_hints v] formats v *)

val pp_verify_src_req : Format.formatter -> verify_src_req -> unit 
(** [pp_verify_src_req v] formats v *)

val pp_verify_name_req : Format.formatter -> verify_name_req -> unit 
(** [pp_verify_name_req v] formats v *)

val pp_instance_src_req : Format.formatter -> instance_src_req -> unit 
(** [pp_instance_src_req v] formats v *)

val pp_instance_name_req : Format.formatter -> instance_name_req -> unit 
(** [pp_instance_name_req v] formats v *)

val pp_proved : Format.formatter -> proved -> unit 
(** [pp_proved v] formats v *)

val pp_unsat : Format.formatter -> unsat -> unit 
(** [pp_unsat v] formats v *)

val pp_model_type : Format.formatter -> model_type -> unit 
(** [pp_model_type v] formats v *)

val pp_model : Format.formatter -> model -> unit 
(** [pp_model v] formats v *)

val pp_refuted : Format.formatter -> refuted -> unit 
(** [pp_refuted v] formats v *)

val pp_sat : Format.formatter -> sat -> unit 
(** [pp_sat v] formats v *)

val pp_verify_res : Format.formatter -> verify_res -> unit 
(** [pp_verify_res v] formats v *)

val pp_instance_res : Format.formatter -> instance_res -> unit 
(** [pp_instance_res v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_decompose_req : decompose_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_region : decompose_region -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_region v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_res : decompose_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_res v encoder] encodes [v] with the given [encoder] *)

val encode_pb_eval_src_req : eval_src_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_eval_src_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_eval_res : eval_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_eval_res v encoder] encodes [v] with the given [encoder] *)

val encode_pb_hints_unroll : hints_unroll -> Pbrt.Encoder.t -> unit
(** [encode_pb_hints_unroll v encoder] encodes [v] with the given [encoder] *)

val encode_pb_hints_induct_functional : hints_induct_functional -> Pbrt.Encoder.t -> unit
(** [encode_pb_hints_induct_functional v encoder] encodes [v] with the given [encoder] *)

val encode_pb_hints_induct_structural_style : hints_induct_structural_style -> Pbrt.Encoder.t -> unit
(** [encode_pb_hints_induct_structural_style v encoder] encodes [v] with the given [encoder] *)

val encode_pb_hints_induct_structural : hints_induct_structural -> Pbrt.Encoder.t -> unit
(** [encode_pb_hints_induct_structural v encoder] encodes [v] with the given [encoder] *)

val encode_pb_hints_induct : hints_induct -> Pbrt.Encoder.t -> unit
(** [encode_pb_hints_induct v encoder] encodes [v] with the given [encoder] *)

val encode_pb_hints : hints -> Pbrt.Encoder.t -> unit
(** [encode_pb_hints v encoder] encodes [v] with the given [encoder] *)

val encode_pb_verify_src_req : verify_src_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_verify_src_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_verify_name_req : verify_name_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_verify_name_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_instance_src_req : instance_src_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_instance_src_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_instance_name_req : instance_name_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_instance_name_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_proved : proved -> Pbrt.Encoder.t -> unit
(** [encode_pb_proved v encoder] encodes [v] with the given [encoder] *)

val encode_pb_unsat : unsat -> Pbrt.Encoder.t -> unit
(** [encode_pb_unsat v encoder] encodes [v] with the given [encoder] *)

val encode_pb_model_type : model_type -> Pbrt.Encoder.t -> unit
(** [encode_pb_model_type v encoder] encodes [v] with the given [encoder] *)

val encode_pb_model : model -> Pbrt.Encoder.t -> unit
(** [encode_pb_model v encoder] encodes [v] with the given [encoder] *)

val encode_pb_refuted : refuted -> Pbrt.Encoder.t -> unit
(** [encode_pb_refuted v encoder] encodes [v] with the given [encoder] *)

val encode_pb_sat : sat -> Pbrt.Encoder.t -> unit
(** [encode_pb_sat v encoder] encodes [v] with the given [encoder] *)

val encode_pb_verify_res : verify_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_verify_res v encoder] encodes [v] with the given [encoder] *)

val encode_pb_instance_res : instance_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_instance_res v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_decompose_req : Pbrt.Decoder.t -> decompose_req
(** [decode_pb_decompose_req decoder] decodes a [decompose_req] binary value from [decoder] *)

val decode_pb_decompose_region : Pbrt.Decoder.t -> decompose_region
(** [decode_pb_decompose_region decoder] decodes a [decompose_region] binary value from [decoder] *)

val decode_pb_decompose_res : Pbrt.Decoder.t -> decompose_res
(** [decode_pb_decompose_res decoder] decodes a [decompose_res] binary value from [decoder] *)

val decode_pb_eval_src_req : Pbrt.Decoder.t -> eval_src_req
(** [decode_pb_eval_src_req decoder] decodes a [eval_src_req] binary value from [decoder] *)

val decode_pb_eval_res : Pbrt.Decoder.t -> eval_res
(** [decode_pb_eval_res decoder] decodes a [eval_res] binary value from [decoder] *)

val decode_pb_hints_unroll : Pbrt.Decoder.t -> hints_unroll
(** [decode_pb_hints_unroll decoder] decodes a [hints_unroll] binary value from [decoder] *)

val decode_pb_hints_induct_functional : Pbrt.Decoder.t -> hints_induct_functional
(** [decode_pb_hints_induct_functional decoder] decodes a [hints_induct_functional] binary value from [decoder] *)

val decode_pb_hints_induct_structural_style : Pbrt.Decoder.t -> hints_induct_structural_style
(** [decode_pb_hints_induct_structural_style decoder] decodes a [hints_induct_structural_style] binary value from [decoder] *)

val decode_pb_hints_induct_structural : Pbrt.Decoder.t -> hints_induct_structural
(** [decode_pb_hints_induct_structural decoder] decodes a [hints_induct_structural] binary value from [decoder] *)

val decode_pb_hints_induct : Pbrt.Decoder.t -> hints_induct
(** [decode_pb_hints_induct decoder] decodes a [hints_induct] binary value from [decoder] *)

val decode_pb_hints : Pbrt.Decoder.t -> hints
(** [decode_pb_hints decoder] decodes a [hints] binary value from [decoder] *)

val decode_pb_verify_src_req : Pbrt.Decoder.t -> verify_src_req
(** [decode_pb_verify_src_req decoder] decodes a [verify_src_req] binary value from [decoder] *)

val decode_pb_verify_name_req : Pbrt.Decoder.t -> verify_name_req
(** [decode_pb_verify_name_req decoder] decodes a [verify_name_req] binary value from [decoder] *)

val decode_pb_instance_src_req : Pbrt.Decoder.t -> instance_src_req
(** [decode_pb_instance_src_req decoder] decodes a [instance_src_req] binary value from [decoder] *)

val decode_pb_instance_name_req : Pbrt.Decoder.t -> instance_name_req
(** [decode_pb_instance_name_req decoder] decodes a [instance_name_req] binary value from [decoder] *)

val decode_pb_proved : Pbrt.Decoder.t -> proved
(** [decode_pb_proved decoder] decodes a [proved] binary value from [decoder] *)

val decode_pb_unsat : Pbrt.Decoder.t -> unsat
(** [decode_pb_unsat decoder] decodes a [unsat] binary value from [decoder] *)

val decode_pb_model_type : Pbrt.Decoder.t -> model_type
(** [decode_pb_model_type decoder] decodes a [model_type] binary value from [decoder] *)

val decode_pb_model : Pbrt.Decoder.t -> model
(** [decode_pb_model decoder] decodes a [model] binary value from [decoder] *)

val decode_pb_refuted : Pbrt.Decoder.t -> refuted
(** [decode_pb_refuted decoder] decodes a [refuted] binary value from [decoder] *)

val decode_pb_sat : Pbrt.Decoder.t -> sat
(** [decode_pb_sat decoder] decodes a [sat] binary value from [decoder] *)

val decode_pb_verify_res : Pbrt.Decoder.t -> verify_res
(** [decode_pb_verify_res decoder] decodes a [verify_res] binary value from [decoder] *)

val decode_pb_instance_res : Pbrt.Decoder.t -> instance_res
(** [decode_pb_instance_res decoder] decodes a [instance_res] binary value from [decoder] *)


(** {2 Protobuf YoJson Encoding} *)

val encode_json_decompose_req : decompose_req -> Yojson.Basic.t
(** [encode_json_decompose_req v encoder] encodes [v] to to json *)

val encode_json_decompose_region : decompose_region -> Yojson.Basic.t
(** [encode_json_decompose_region v encoder] encodes [v] to to json *)

val encode_json_decompose_res : decompose_res -> Yojson.Basic.t
(** [encode_json_decompose_res v encoder] encodes [v] to to json *)

val encode_json_eval_src_req : eval_src_req -> Yojson.Basic.t
(** [encode_json_eval_src_req v encoder] encodes [v] to to json *)

val encode_json_eval_res : eval_res -> Yojson.Basic.t
(** [encode_json_eval_res v encoder] encodes [v] to to json *)

val encode_json_hints_unroll : hints_unroll -> Yojson.Basic.t
(** [encode_json_hints_unroll v encoder] encodes [v] to to json *)

val encode_json_hints_induct_functional : hints_induct_functional -> Yojson.Basic.t
(** [encode_json_hints_induct_functional v encoder] encodes [v] to to json *)

val encode_json_hints_induct_structural_style : hints_induct_structural_style -> Yojson.Basic.t
(** [encode_json_hints_induct_structural_style v encoder] encodes [v] to to json *)

val encode_json_hints_induct_structural : hints_induct_structural -> Yojson.Basic.t
(** [encode_json_hints_induct_structural v encoder] encodes [v] to to json *)

val encode_json_hints_induct : hints_induct -> Yojson.Basic.t
(** [encode_json_hints_induct v encoder] encodes [v] to to json *)

val encode_json_hints : hints -> Yojson.Basic.t
(** [encode_json_hints v encoder] encodes [v] to to json *)

val encode_json_verify_src_req : verify_src_req -> Yojson.Basic.t
(** [encode_json_verify_src_req v encoder] encodes [v] to to json *)

val encode_json_verify_name_req : verify_name_req -> Yojson.Basic.t
(** [encode_json_verify_name_req v encoder] encodes [v] to to json *)

val encode_json_instance_src_req : instance_src_req -> Yojson.Basic.t
(** [encode_json_instance_src_req v encoder] encodes [v] to to json *)

val encode_json_instance_name_req : instance_name_req -> Yojson.Basic.t
(** [encode_json_instance_name_req v encoder] encodes [v] to to json *)

val encode_json_proved : proved -> Yojson.Basic.t
(** [encode_json_proved v encoder] encodes [v] to to json *)

val encode_json_unsat : unsat -> Yojson.Basic.t
(** [encode_json_unsat v encoder] encodes [v] to to json *)

val encode_json_model_type : model_type -> Yojson.Basic.t
(** [encode_json_model_type v encoder] encodes [v] to to json *)

val encode_json_model : model -> Yojson.Basic.t
(** [encode_json_model v encoder] encodes [v] to to json *)

val encode_json_refuted : refuted -> Yojson.Basic.t
(** [encode_json_refuted v encoder] encodes [v] to to json *)

val encode_json_sat : sat -> Yojson.Basic.t
(** [encode_json_sat v encoder] encodes [v] to to json *)

val encode_json_verify_res : verify_res -> Yojson.Basic.t
(** [encode_json_verify_res v encoder] encodes [v] to to json *)

val encode_json_instance_res : instance_res -> Yojson.Basic.t
(** [encode_json_instance_res v encoder] encodes [v] to to json *)


(** {2 JSON Decoding} *)

val decode_json_decompose_req : Yojson.Basic.t -> decompose_req
(** [decode_json_decompose_req decoder] decodes a [decompose_req] value from [decoder] *)

val decode_json_decompose_region : Yojson.Basic.t -> decompose_region
(** [decode_json_decompose_region decoder] decodes a [decompose_region] value from [decoder] *)

val decode_json_decompose_res : Yojson.Basic.t -> decompose_res
(** [decode_json_decompose_res decoder] decodes a [decompose_res] value from [decoder] *)

val decode_json_eval_src_req : Yojson.Basic.t -> eval_src_req
(** [decode_json_eval_src_req decoder] decodes a [eval_src_req] value from [decoder] *)

val decode_json_eval_res : Yojson.Basic.t -> eval_res
(** [decode_json_eval_res decoder] decodes a [eval_res] value from [decoder] *)

val decode_json_hints_unroll : Yojson.Basic.t -> hints_unroll
(** [decode_json_hints_unroll decoder] decodes a [hints_unroll] value from [decoder] *)

val decode_json_hints_induct_functional : Yojson.Basic.t -> hints_induct_functional
(** [decode_json_hints_induct_functional decoder] decodes a [hints_induct_functional] value from [decoder] *)

val decode_json_hints_induct_structural_style : Yojson.Basic.t -> hints_induct_structural_style
(** [decode_json_hints_induct_structural_style decoder] decodes a [hints_induct_structural_style] value from [decoder] *)

val decode_json_hints_induct_structural : Yojson.Basic.t -> hints_induct_structural
(** [decode_json_hints_induct_structural decoder] decodes a [hints_induct_structural] value from [decoder] *)

val decode_json_hints_induct : Yojson.Basic.t -> hints_induct
(** [decode_json_hints_induct decoder] decodes a [hints_induct] value from [decoder] *)

val decode_json_hints : Yojson.Basic.t -> hints
(** [decode_json_hints decoder] decodes a [hints] value from [decoder] *)

val decode_json_verify_src_req : Yojson.Basic.t -> verify_src_req
(** [decode_json_verify_src_req decoder] decodes a [verify_src_req] value from [decoder] *)

val decode_json_verify_name_req : Yojson.Basic.t -> verify_name_req
(** [decode_json_verify_name_req decoder] decodes a [verify_name_req] value from [decoder] *)

val decode_json_instance_src_req : Yojson.Basic.t -> instance_src_req
(** [decode_json_instance_src_req decoder] decodes a [instance_src_req] value from [decoder] *)

val decode_json_instance_name_req : Yojson.Basic.t -> instance_name_req
(** [decode_json_instance_name_req decoder] decodes a [instance_name_req] value from [decoder] *)

val decode_json_proved : Yojson.Basic.t -> proved
(** [decode_json_proved decoder] decodes a [proved] value from [decoder] *)

val decode_json_unsat : Yojson.Basic.t -> unsat
(** [decode_json_unsat decoder] decodes a [unsat] value from [decoder] *)

val decode_json_model_type : Yojson.Basic.t -> model_type
(** [decode_json_model_type decoder] decodes a [model_type] value from [decoder] *)

val decode_json_model : Yojson.Basic.t -> model
(** [decode_json_model decoder] decodes a [model] value from [decoder] *)

val decode_json_refuted : Yojson.Basic.t -> refuted
(** [decode_json_refuted decoder] decodes a [refuted] value from [decoder] *)

val decode_json_sat : Yojson.Basic.t -> sat
(** [decode_json_sat decoder] decodes a [sat] value from [decoder] *)

val decode_json_verify_res : Yojson.Basic.t -> verify_res
(** [decode_json_verify_res decoder] decodes a [verify_res] value from [decoder] *)

val decode_json_instance_res : Yojson.Basic.t -> instance_res
(** [decode_json_instance_res decoder] decodes a [instance_res] value from [decoder] *)


(** {2 Services} *)

(** Simple service *)
module Simple : sig
  open Pbrt_services
  open Pbrt_services.Value_mode
  
  module Client : sig
    
    val status : (Utils.empty, unary, Utils.string_msg, unary) Client.rpc
    
    val shutdown : (Utils.empty, unary, Utils.empty, unary) Client.rpc
    
    val decompose : (decompose_req, unary, decompose_res, unary) Client.rpc
    
    val create_session : (Utils.empty, unary, Session.session, unary) Client.rpc
    
    val eval_src : (eval_src_req, unary, eval_res, unary) Client.rpc
    
    val verify_src : (verify_src_req, unary, verify_res, unary) Client.rpc
    
    val verify_name : (verify_name_req, unary, verify_res, unary) Client.rpc
    
    val instance_src : (instance_src_req, unary, instance_res, unary) Client.rpc
    
    val instance_name : (instance_name_req, unary, instance_res, unary) Client.rpc
  end
  
  module Server : sig
    (** Produce a server implementation from handlers *)
    val make : 
      status:((Utils.empty, unary, Utils.string_msg, unary) Server.rpc -> 'handler) ->
      shutdown:((Utils.empty, unary, Utils.empty, unary) Server.rpc -> 'handler) ->
      decompose:((decompose_req, unary, decompose_res, unary) Server.rpc -> 'handler) ->
      create_session:((Utils.empty, unary, Session.session, unary) Server.rpc -> 'handler) ->
      eval_src:((eval_src_req, unary, eval_res, unary) Server.rpc -> 'handler) ->
      verify_src:((verify_src_req, unary, verify_res, unary) Server.rpc -> 'handler) ->
      verify_name:((verify_name_req, unary, verify_res, unary) Server.rpc -> 'handler) ->
      instance_src:((instance_src_req, unary, instance_res, unary) Server.rpc -> 'handler) ->
      instance_name:((instance_name_req, unary, instance_res, unary) Server.rpc -> 'handler) ->
      unit -> 'handler Pbrt_services.Server.t
    
    (** The individual server stubs are only exposed for advanced users. Casual users should prefer accessing them through {!make}. *)
    
    val status : (Utils.empty,unary,Utils.string_msg,unary) Server.rpc
    
    val shutdown : (Utils.empty,unary,Utils.empty,unary) Server.rpc
    
    val decompose : (decompose_req,unary,decompose_res,unary) Server.rpc
    
    val create_session : (Utils.empty,unary,Session.session,unary) Server.rpc
    
    val eval_src : (eval_src_req,unary,eval_res,unary) Server.rpc
    
    val verify_src : (verify_src_req,unary,verify_res,unary) Server.rpc
    
    val verify_name : (verify_name_req,unary,verify_res,unary) Server.rpc
    
    val instance_src : (instance_src_req,unary,instance_res,unary) Server.rpc
    
    val instance_name : (instance_name_req,unary,instance_res,unary) Server.rpc
  end
end
