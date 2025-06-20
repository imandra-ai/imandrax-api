
(** Code for simple_api.proto *)

(* generated from "simple_api.proto", do not edit *)



(** {2 Types} *)

type session_create_req = {
  api_version : string;
}

type lift_bool =
  | Default 
  | Nested_equalities 
  | Equalities 
  | All 

type decompose_req = {
  session : Session.session option;
  name : string;
  assuming : string option;
  basis : string list;
  rule_specs : string list;
  prune : bool;
  ctx_simp : bool option;
  lift_bool : lift_bool option;
  str : bool option;
  timeout : int32 option;
}

type decompose_res_res =
  | Artifact of Artmsg.art
  | Err

and decompose_res = {
  res : decompose_res_res;
  errors : Error.error list;
  task : Task.task option;
}

type eval_src_req = {
  session : Session.session option;
  src : string;
}

type eval_output = {
  success : bool;
  value_as_ocaml : string option;
}

type pooutput = unit

type proved = {
  proof_pp : string option;
}

type model_type =
  | Counter_example 
  | Instance 

type model = {
  m_type : model_type;
  src : string;
  artifact : Artmsg.art option;
}

type counter_sat = {
  model : model option;
}

type verified_upto = {
  msg : string option;
}

type pores_res =
  | Unknown of Utils.string_msg
  | Err
  | Proof of proved
  | Instance of counter_sat
  | Verified_upto of verified_upto

and pores = {
  res : pores_res;
  errors : Error.error list;
  task : Task.task option;
}

type eval_res = {
  success : bool;
  messages : string list;
  errors : Error.error list;
  tasks : Task.task list;
  po_results : pores list;
  eval_results : eval_output list;
  decomp_results : decompose_res list;
}

type verify_src_req = {
  session : Session.session option;
  src : string;
  hints : string option;
}

type verify_name_req = {
  session : Session.session option;
  name : string;
  hints : string option;
}

type instance_src_req = {
  session : Session.session option;
  src : string;
  hints : string option;
}

type instance_name_req = {
  session : Session.session option;
  name : string;
  hints : string option;
}

type unsat = {
  proof_pp : string option;
}

type refuted = {
  model : model option;
}

type sat = {
  model : model option;
}

type verify_res_res =
  | Unknown of Utils.string_msg
  | Err
  | Proved of proved
  | Refuted of refuted
  | Verified_upto of verified_upto

and verify_res = {
  res : verify_res_res;
  errors : Error.error list;
  task : Task.task option;
}

type instance_res_res =
  | Unknown of Utils.string_msg
  | Err
  | Unsat of unsat
  | Sat of sat

and instance_res = {
  res : instance_res_res;
  errors : Error.error list;
  task : Task.task option;
}

type typecheck_req = {
  session : Session.session option;
  src : string;
}

type typecheck_res = {
  success : bool;
  types : string;
  errors : Error.error list;
}


(** {2 Basic values} *)

val default_session_create_req : 
  ?api_version:string ->
  unit ->
  session_create_req
(** [default_session_create_req ()] is the default value for type [session_create_req] *)

val default_lift_bool : unit -> lift_bool
(** [default_lift_bool ()] is the default value for type [lift_bool] *)

val default_decompose_req : 
  ?session:Session.session option ->
  ?name:string ->
  ?assuming:string option ->
  ?basis:string list ->
  ?rule_specs:string list ->
  ?prune:bool ->
  ?ctx_simp:bool option ->
  ?lift_bool:lift_bool option ->
  ?str:bool option ->
  ?timeout:int32 option ->
  unit ->
  decompose_req
(** [default_decompose_req ()] is the default value for type [decompose_req] *)

val default_decompose_res_res : unit -> decompose_res_res
(** [default_decompose_res_res ()] is the default value for type [decompose_res_res] *)

val default_decompose_res : 
  ?res:decompose_res_res ->
  ?errors:Error.error list ->
  ?task:Task.task option ->
  unit ->
  decompose_res
(** [default_decompose_res ()] is the default value for type [decompose_res] *)

val default_eval_src_req : 
  ?session:Session.session option ->
  ?src:string ->
  unit ->
  eval_src_req
(** [default_eval_src_req ()] is the default value for type [eval_src_req] *)

val default_eval_output : 
  ?success:bool ->
  ?value_as_ocaml:string option ->
  unit ->
  eval_output
(** [default_eval_output ()] is the default value for type [eval_output] *)

val default_pooutput : unit
(** [default_pooutput ()] is the default value for type [pooutput] *)

val default_proved : 
  ?proof_pp:string option ->
  unit ->
  proved
(** [default_proved ()] is the default value for type [proved] *)

val default_model_type : unit -> model_type
(** [default_model_type ()] is the default value for type [model_type] *)

val default_model : 
  ?m_type:model_type ->
  ?src:string ->
  ?artifact:Artmsg.art option ->
  unit ->
  model
(** [default_model ()] is the default value for type [model] *)

val default_counter_sat : 
  ?model:model option ->
  unit ->
  counter_sat
(** [default_counter_sat ()] is the default value for type [counter_sat] *)

val default_verified_upto : 
  ?msg:string option ->
  unit ->
  verified_upto
(** [default_verified_upto ()] is the default value for type [verified_upto] *)

val default_pores_res : unit -> pores_res
(** [default_pores_res ()] is the default value for type [pores_res] *)

val default_pores : 
  ?res:pores_res ->
  ?errors:Error.error list ->
  ?task:Task.task option ->
  unit ->
  pores
(** [default_pores ()] is the default value for type [pores] *)

val default_eval_res : 
  ?success:bool ->
  ?messages:string list ->
  ?errors:Error.error list ->
  ?tasks:Task.task list ->
  ?po_results:pores list ->
  ?eval_results:eval_output list ->
  ?decomp_results:decompose_res list ->
  unit ->
  eval_res
(** [default_eval_res ()] is the default value for type [eval_res] *)

val default_verify_src_req : 
  ?session:Session.session option ->
  ?src:string ->
  ?hints:string option ->
  unit ->
  verify_src_req
(** [default_verify_src_req ()] is the default value for type [verify_src_req] *)

val default_verify_name_req : 
  ?session:Session.session option ->
  ?name:string ->
  ?hints:string option ->
  unit ->
  verify_name_req
(** [default_verify_name_req ()] is the default value for type [verify_name_req] *)

val default_instance_src_req : 
  ?session:Session.session option ->
  ?src:string ->
  ?hints:string option ->
  unit ->
  instance_src_req
(** [default_instance_src_req ()] is the default value for type [instance_src_req] *)

val default_instance_name_req : 
  ?session:Session.session option ->
  ?name:string ->
  ?hints:string option ->
  unit ->
  instance_name_req
(** [default_instance_name_req ()] is the default value for type [instance_name_req] *)

val default_unsat : 
  ?proof_pp:string option ->
  unit ->
  unsat
(** [default_unsat ()] is the default value for type [unsat] *)

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

val default_verify_res_res : unit -> verify_res_res
(** [default_verify_res_res ()] is the default value for type [verify_res_res] *)

val default_verify_res : 
  ?res:verify_res_res ->
  ?errors:Error.error list ->
  ?task:Task.task option ->
  unit ->
  verify_res
(** [default_verify_res ()] is the default value for type [verify_res] *)

val default_instance_res_res : unit -> instance_res_res
(** [default_instance_res_res ()] is the default value for type [instance_res_res] *)

val default_instance_res : 
  ?res:instance_res_res ->
  ?errors:Error.error list ->
  ?task:Task.task option ->
  unit ->
  instance_res
(** [default_instance_res ()] is the default value for type [instance_res] *)

val default_typecheck_req : 
  ?session:Session.session option ->
  ?src:string ->
  unit ->
  typecheck_req
(** [default_typecheck_req ()] is the default value for type [typecheck_req] *)

val default_typecheck_res : 
  ?success:bool ->
  ?types:string ->
  ?errors:Error.error list ->
  unit ->
  typecheck_res
(** [default_typecheck_res ()] is the default value for type [typecheck_res] *)


(** {2 Make functions} *)

val make_session_create_req : 
  api_version:string ->
  unit ->
  session_create_req
(** [make_session_create_req … ()] is a builder for type [session_create_req] *)


val make_decompose_req : 
  ?session:Session.session option ->
  name:string ->
  ?assuming:string option ->
  basis:string list ->
  rule_specs:string list ->
  prune:bool ->
  ?ctx_simp:bool option ->
  ?lift_bool:lift_bool option ->
  ?str:bool option ->
  ?timeout:int32 option ->
  unit ->
  decompose_req
(** [make_decompose_req … ()] is a builder for type [decompose_req] *)


val make_decompose_res : 
  res:decompose_res_res ->
  errors:Error.error list ->
  ?task:Task.task option ->
  unit ->
  decompose_res
(** [make_decompose_res … ()] is a builder for type [decompose_res] *)

val make_eval_src_req : 
  ?session:Session.session option ->
  src:string ->
  unit ->
  eval_src_req
(** [make_eval_src_req … ()] is a builder for type [eval_src_req] *)

val make_eval_output : 
  success:bool ->
  ?value_as_ocaml:string option ->
  unit ->
  eval_output
(** [make_eval_output … ()] is a builder for type [eval_output] *)


val make_proved : 
  ?proof_pp:string option ->
  unit ->
  proved
(** [make_proved … ()] is a builder for type [proved] *)


val make_model : 
  m_type:model_type ->
  src:string ->
  ?artifact:Artmsg.art option ->
  unit ->
  model
(** [make_model … ()] is a builder for type [model] *)

val make_counter_sat : 
  ?model:model option ->
  unit ->
  counter_sat
(** [make_counter_sat … ()] is a builder for type [counter_sat] *)

val make_verified_upto : 
  ?msg:string option ->
  unit ->
  verified_upto
(** [make_verified_upto … ()] is a builder for type [verified_upto] *)


val make_pores : 
  res:pores_res ->
  errors:Error.error list ->
  ?task:Task.task option ->
  unit ->
  pores
(** [make_pores … ()] is a builder for type [pores] *)

val make_eval_res : 
  success:bool ->
  messages:string list ->
  errors:Error.error list ->
  tasks:Task.task list ->
  po_results:pores list ->
  eval_results:eval_output list ->
  decomp_results:decompose_res list ->
  unit ->
  eval_res
(** [make_eval_res … ()] is a builder for type [eval_res] *)

val make_verify_src_req : 
  ?session:Session.session option ->
  src:string ->
  ?hints:string option ->
  unit ->
  verify_src_req
(** [make_verify_src_req … ()] is a builder for type [verify_src_req] *)

val make_verify_name_req : 
  ?session:Session.session option ->
  name:string ->
  ?hints:string option ->
  unit ->
  verify_name_req
(** [make_verify_name_req … ()] is a builder for type [verify_name_req] *)

val make_instance_src_req : 
  ?session:Session.session option ->
  src:string ->
  ?hints:string option ->
  unit ->
  instance_src_req
(** [make_instance_src_req … ()] is a builder for type [instance_src_req] *)

val make_instance_name_req : 
  ?session:Session.session option ->
  name:string ->
  ?hints:string option ->
  unit ->
  instance_name_req
(** [make_instance_name_req … ()] is a builder for type [instance_name_req] *)

val make_unsat : 
  ?proof_pp:string option ->
  unit ->
  unsat
(** [make_unsat … ()] is a builder for type [unsat] *)

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


val make_verify_res : 
  res:verify_res_res ->
  errors:Error.error list ->
  ?task:Task.task option ->
  unit ->
  verify_res
(** [make_verify_res … ()] is a builder for type [verify_res] *)


val make_instance_res : 
  res:instance_res_res ->
  errors:Error.error list ->
  ?task:Task.task option ->
  unit ->
  instance_res
(** [make_instance_res … ()] is a builder for type [instance_res] *)

val make_typecheck_req : 
  ?session:Session.session option ->
  src:string ->
  unit ->
  typecheck_req
(** [make_typecheck_req … ()] is a builder for type [typecheck_req] *)

val make_typecheck_res : 
  success:bool ->
  types:string ->
  errors:Error.error list ->
  unit ->
  typecheck_res
(** [make_typecheck_res … ()] is a builder for type [typecheck_res] *)


(** {2 Formatters} *)

val pp_session_create_req : Format.formatter -> session_create_req -> unit 
(** [pp_session_create_req v] formats v *)

val pp_lift_bool : Format.formatter -> lift_bool -> unit 
(** [pp_lift_bool v] formats v *)

val pp_decompose_req : Format.formatter -> decompose_req -> unit 
(** [pp_decompose_req v] formats v *)

val pp_decompose_res_res : Format.formatter -> decompose_res_res -> unit 
(** [pp_decompose_res_res v] formats v *)

val pp_decompose_res : Format.formatter -> decompose_res -> unit 
(** [pp_decompose_res v] formats v *)

val pp_eval_src_req : Format.formatter -> eval_src_req -> unit 
(** [pp_eval_src_req v] formats v *)

val pp_eval_output : Format.formatter -> eval_output -> unit 
(** [pp_eval_output v] formats v *)

val pp_pooutput : Format.formatter -> pooutput -> unit 
(** [pp_pooutput v] formats v *)

val pp_proved : Format.formatter -> proved -> unit 
(** [pp_proved v] formats v *)

val pp_model_type : Format.formatter -> model_type -> unit 
(** [pp_model_type v] formats v *)

val pp_model : Format.formatter -> model -> unit 
(** [pp_model v] formats v *)

val pp_counter_sat : Format.formatter -> counter_sat -> unit 
(** [pp_counter_sat v] formats v *)

val pp_verified_upto : Format.formatter -> verified_upto -> unit 
(** [pp_verified_upto v] formats v *)

val pp_pores_res : Format.formatter -> pores_res -> unit 
(** [pp_pores_res v] formats v *)

val pp_pores : Format.formatter -> pores -> unit 
(** [pp_pores v] formats v *)

val pp_eval_res : Format.formatter -> eval_res -> unit 
(** [pp_eval_res v] formats v *)

val pp_verify_src_req : Format.formatter -> verify_src_req -> unit 
(** [pp_verify_src_req v] formats v *)

val pp_verify_name_req : Format.formatter -> verify_name_req -> unit 
(** [pp_verify_name_req v] formats v *)

val pp_instance_src_req : Format.formatter -> instance_src_req -> unit 
(** [pp_instance_src_req v] formats v *)

val pp_instance_name_req : Format.formatter -> instance_name_req -> unit 
(** [pp_instance_name_req v] formats v *)

val pp_unsat : Format.formatter -> unsat -> unit 
(** [pp_unsat v] formats v *)

val pp_refuted : Format.formatter -> refuted -> unit 
(** [pp_refuted v] formats v *)

val pp_sat : Format.formatter -> sat -> unit 
(** [pp_sat v] formats v *)

val pp_verify_res_res : Format.formatter -> verify_res_res -> unit 
(** [pp_verify_res_res v] formats v *)

val pp_verify_res : Format.formatter -> verify_res -> unit 
(** [pp_verify_res v] formats v *)

val pp_instance_res_res : Format.formatter -> instance_res_res -> unit 
(** [pp_instance_res_res v] formats v *)

val pp_instance_res : Format.formatter -> instance_res -> unit 
(** [pp_instance_res v] formats v *)

val pp_typecheck_req : Format.formatter -> typecheck_req -> unit 
(** [pp_typecheck_req v] formats v *)

val pp_typecheck_res : Format.formatter -> typecheck_res -> unit 
(** [pp_typecheck_res v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_session_create_req : session_create_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_session_create_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_lift_bool : lift_bool -> Pbrt.Encoder.t -> unit
(** [encode_pb_lift_bool v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_req : decompose_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_res_res : decompose_res_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_res_res v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_res : decompose_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_res v encoder] encodes [v] with the given [encoder] *)

val encode_pb_eval_src_req : eval_src_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_eval_src_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_eval_output : eval_output -> Pbrt.Encoder.t -> unit
(** [encode_pb_eval_output v encoder] encodes [v] with the given [encoder] *)

val encode_pb_pooutput : pooutput -> Pbrt.Encoder.t -> unit
(** [encode_pb_pooutput v encoder] encodes [v] with the given [encoder] *)

val encode_pb_proved : proved -> Pbrt.Encoder.t -> unit
(** [encode_pb_proved v encoder] encodes [v] with the given [encoder] *)

val encode_pb_model_type : model_type -> Pbrt.Encoder.t -> unit
(** [encode_pb_model_type v encoder] encodes [v] with the given [encoder] *)

val encode_pb_model : model -> Pbrt.Encoder.t -> unit
(** [encode_pb_model v encoder] encodes [v] with the given [encoder] *)

val encode_pb_counter_sat : counter_sat -> Pbrt.Encoder.t -> unit
(** [encode_pb_counter_sat v encoder] encodes [v] with the given [encoder] *)

val encode_pb_verified_upto : verified_upto -> Pbrt.Encoder.t -> unit
(** [encode_pb_verified_upto v encoder] encodes [v] with the given [encoder] *)

val encode_pb_pores_res : pores_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_pores_res v encoder] encodes [v] with the given [encoder] *)

val encode_pb_pores : pores -> Pbrt.Encoder.t -> unit
(** [encode_pb_pores v encoder] encodes [v] with the given [encoder] *)

val encode_pb_eval_res : eval_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_eval_res v encoder] encodes [v] with the given [encoder] *)

val encode_pb_verify_src_req : verify_src_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_verify_src_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_verify_name_req : verify_name_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_verify_name_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_instance_src_req : instance_src_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_instance_src_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_instance_name_req : instance_name_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_instance_name_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_unsat : unsat -> Pbrt.Encoder.t -> unit
(** [encode_pb_unsat v encoder] encodes [v] with the given [encoder] *)

val encode_pb_refuted : refuted -> Pbrt.Encoder.t -> unit
(** [encode_pb_refuted v encoder] encodes [v] with the given [encoder] *)

val encode_pb_sat : sat -> Pbrt.Encoder.t -> unit
(** [encode_pb_sat v encoder] encodes [v] with the given [encoder] *)

val encode_pb_verify_res_res : verify_res_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_verify_res_res v encoder] encodes [v] with the given [encoder] *)

val encode_pb_verify_res : verify_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_verify_res v encoder] encodes [v] with the given [encoder] *)

val encode_pb_instance_res_res : instance_res_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_instance_res_res v encoder] encodes [v] with the given [encoder] *)

val encode_pb_instance_res : instance_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_instance_res v encoder] encodes [v] with the given [encoder] *)

val encode_pb_typecheck_req : typecheck_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_typecheck_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_typecheck_res : typecheck_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_typecheck_res v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_session_create_req : Pbrt.Decoder.t -> session_create_req
(** [decode_pb_session_create_req decoder] decodes a [session_create_req] binary value from [decoder] *)

val decode_pb_lift_bool : Pbrt.Decoder.t -> lift_bool
(** [decode_pb_lift_bool decoder] decodes a [lift_bool] binary value from [decoder] *)

val decode_pb_decompose_req : Pbrt.Decoder.t -> decompose_req
(** [decode_pb_decompose_req decoder] decodes a [decompose_req] binary value from [decoder] *)

val decode_pb_decompose_res_res : Pbrt.Decoder.t -> decompose_res_res
(** [decode_pb_decompose_res_res decoder] decodes a [decompose_res_res] binary value from [decoder] *)

val decode_pb_decompose_res : Pbrt.Decoder.t -> decompose_res
(** [decode_pb_decompose_res decoder] decodes a [decompose_res] binary value from [decoder] *)

val decode_pb_eval_src_req : Pbrt.Decoder.t -> eval_src_req
(** [decode_pb_eval_src_req decoder] decodes a [eval_src_req] binary value from [decoder] *)

val decode_pb_eval_output : Pbrt.Decoder.t -> eval_output
(** [decode_pb_eval_output decoder] decodes a [eval_output] binary value from [decoder] *)

val decode_pb_pooutput : Pbrt.Decoder.t -> pooutput
(** [decode_pb_pooutput decoder] decodes a [pooutput] binary value from [decoder] *)

val decode_pb_proved : Pbrt.Decoder.t -> proved
(** [decode_pb_proved decoder] decodes a [proved] binary value from [decoder] *)

val decode_pb_model_type : Pbrt.Decoder.t -> model_type
(** [decode_pb_model_type decoder] decodes a [model_type] binary value from [decoder] *)

val decode_pb_model : Pbrt.Decoder.t -> model
(** [decode_pb_model decoder] decodes a [model] binary value from [decoder] *)

val decode_pb_counter_sat : Pbrt.Decoder.t -> counter_sat
(** [decode_pb_counter_sat decoder] decodes a [counter_sat] binary value from [decoder] *)

val decode_pb_verified_upto : Pbrt.Decoder.t -> verified_upto
(** [decode_pb_verified_upto decoder] decodes a [verified_upto] binary value from [decoder] *)

val decode_pb_pores_res : Pbrt.Decoder.t -> pores_res
(** [decode_pb_pores_res decoder] decodes a [pores_res] binary value from [decoder] *)

val decode_pb_pores : Pbrt.Decoder.t -> pores
(** [decode_pb_pores decoder] decodes a [pores] binary value from [decoder] *)

val decode_pb_eval_res : Pbrt.Decoder.t -> eval_res
(** [decode_pb_eval_res decoder] decodes a [eval_res] binary value from [decoder] *)

val decode_pb_verify_src_req : Pbrt.Decoder.t -> verify_src_req
(** [decode_pb_verify_src_req decoder] decodes a [verify_src_req] binary value from [decoder] *)

val decode_pb_verify_name_req : Pbrt.Decoder.t -> verify_name_req
(** [decode_pb_verify_name_req decoder] decodes a [verify_name_req] binary value from [decoder] *)

val decode_pb_instance_src_req : Pbrt.Decoder.t -> instance_src_req
(** [decode_pb_instance_src_req decoder] decodes a [instance_src_req] binary value from [decoder] *)

val decode_pb_instance_name_req : Pbrt.Decoder.t -> instance_name_req
(** [decode_pb_instance_name_req decoder] decodes a [instance_name_req] binary value from [decoder] *)

val decode_pb_unsat : Pbrt.Decoder.t -> unsat
(** [decode_pb_unsat decoder] decodes a [unsat] binary value from [decoder] *)

val decode_pb_refuted : Pbrt.Decoder.t -> refuted
(** [decode_pb_refuted decoder] decodes a [refuted] binary value from [decoder] *)

val decode_pb_sat : Pbrt.Decoder.t -> sat
(** [decode_pb_sat decoder] decodes a [sat] binary value from [decoder] *)

val decode_pb_verify_res_res : Pbrt.Decoder.t -> verify_res_res
(** [decode_pb_verify_res_res decoder] decodes a [verify_res_res] binary value from [decoder] *)

val decode_pb_verify_res : Pbrt.Decoder.t -> verify_res
(** [decode_pb_verify_res decoder] decodes a [verify_res] binary value from [decoder] *)

val decode_pb_instance_res_res : Pbrt.Decoder.t -> instance_res_res
(** [decode_pb_instance_res_res decoder] decodes a [instance_res_res] binary value from [decoder] *)

val decode_pb_instance_res : Pbrt.Decoder.t -> instance_res
(** [decode_pb_instance_res decoder] decodes a [instance_res] binary value from [decoder] *)

val decode_pb_typecheck_req : Pbrt.Decoder.t -> typecheck_req
(** [decode_pb_typecheck_req decoder] decodes a [typecheck_req] binary value from [decoder] *)

val decode_pb_typecheck_res : Pbrt.Decoder.t -> typecheck_res
(** [decode_pb_typecheck_res decoder] decodes a [typecheck_res] binary value from [decoder] *)


(** {2 Protobuf YoJson Encoding} *)

val encode_json_session_create_req : session_create_req -> Yojson.Basic.t
(** [encode_json_session_create_req v encoder] encodes [v] to to json *)

val encode_json_lift_bool : lift_bool -> Yojson.Basic.t
(** [encode_json_lift_bool v encoder] encodes [v] to to json *)

val encode_json_decompose_req : decompose_req -> Yojson.Basic.t
(** [encode_json_decompose_req v encoder] encodes [v] to to json *)

val encode_json_decompose_res_res : decompose_res_res -> Yojson.Basic.t
(** [encode_json_decompose_res_res v encoder] encodes [v] to to json *)

val encode_json_decompose_res : decompose_res -> Yojson.Basic.t
(** [encode_json_decompose_res v encoder] encodes [v] to to json *)

val encode_json_eval_src_req : eval_src_req -> Yojson.Basic.t
(** [encode_json_eval_src_req v encoder] encodes [v] to to json *)

val encode_json_eval_output : eval_output -> Yojson.Basic.t
(** [encode_json_eval_output v encoder] encodes [v] to to json *)

val encode_json_pooutput : pooutput -> Yojson.Basic.t
(** [encode_json_pooutput v encoder] encodes [v] to to json *)

val encode_json_proved : proved -> Yojson.Basic.t
(** [encode_json_proved v encoder] encodes [v] to to json *)

val encode_json_model_type : model_type -> Yojson.Basic.t
(** [encode_json_model_type v encoder] encodes [v] to to json *)

val encode_json_model : model -> Yojson.Basic.t
(** [encode_json_model v encoder] encodes [v] to to json *)

val encode_json_counter_sat : counter_sat -> Yojson.Basic.t
(** [encode_json_counter_sat v encoder] encodes [v] to to json *)

val encode_json_verified_upto : verified_upto -> Yojson.Basic.t
(** [encode_json_verified_upto v encoder] encodes [v] to to json *)

val encode_json_pores_res : pores_res -> Yojson.Basic.t
(** [encode_json_pores_res v encoder] encodes [v] to to json *)

val encode_json_pores : pores -> Yojson.Basic.t
(** [encode_json_pores v encoder] encodes [v] to to json *)

val encode_json_eval_res : eval_res -> Yojson.Basic.t
(** [encode_json_eval_res v encoder] encodes [v] to to json *)

val encode_json_verify_src_req : verify_src_req -> Yojson.Basic.t
(** [encode_json_verify_src_req v encoder] encodes [v] to to json *)

val encode_json_verify_name_req : verify_name_req -> Yojson.Basic.t
(** [encode_json_verify_name_req v encoder] encodes [v] to to json *)

val encode_json_instance_src_req : instance_src_req -> Yojson.Basic.t
(** [encode_json_instance_src_req v encoder] encodes [v] to to json *)

val encode_json_instance_name_req : instance_name_req -> Yojson.Basic.t
(** [encode_json_instance_name_req v encoder] encodes [v] to to json *)

val encode_json_unsat : unsat -> Yojson.Basic.t
(** [encode_json_unsat v encoder] encodes [v] to to json *)

val encode_json_refuted : refuted -> Yojson.Basic.t
(** [encode_json_refuted v encoder] encodes [v] to to json *)

val encode_json_sat : sat -> Yojson.Basic.t
(** [encode_json_sat v encoder] encodes [v] to to json *)

val encode_json_verify_res_res : verify_res_res -> Yojson.Basic.t
(** [encode_json_verify_res_res v encoder] encodes [v] to to json *)

val encode_json_verify_res : verify_res -> Yojson.Basic.t
(** [encode_json_verify_res v encoder] encodes [v] to to json *)

val encode_json_instance_res_res : instance_res_res -> Yojson.Basic.t
(** [encode_json_instance_res_res v encoder] encodes [v] to to json *)

val encode_json_instance_res : instance_res -> Yojson.Basic.t
(** [encode_json_instance_res v encoder] encodes [v] to to json *)

val encode_json_typecheck_req : typecheck_req -> Yojson.Basic.t
(** [encode_json_typecheck_req v encoder] encodes [v] to to json *)

val encode_json_typecheck_res : typecheck_res -> Yojson.Basic.t
(** [encode_json_typecheck_res v encoder] encodes [v] to to json *)


(** {2 JSON Decoding} *)

val decode_json_session_create_req : Yojson.Basic.t -> session_create_req
(** [decode_json_session_create_req decoder] decodes a [session_create_req] value from [decoder] *)

val decode_json_lift_bool : Yojson.Basic.t -> lift_bool
(** [decode_json_lift_bool decoder] decodes a [lift_bool] value from [decoder] *)

val decode_json_decompose_req : Yojson.Basic.t -> decompose_req
(** [decode_json_decompose_req decoder] decodes a [decompose_req] value from [decoder] *)

val decode_json_decompose_res_res : Yojson.Basic.t -> decompose_res_res
(** [decode_json_decompose_res_res decoder] decodes a [decompose_res_res] value from [decoder] *)

val decode_json_decompose_res : Yojson.Basic.t -> decompose_res
(** [decode_json_decompose_res decoder] decodes a [decompose_res] value from [decoder] *)

val decode_json_eval_src_req : Yojson.Basic.t -> eval_src_req
(** [decode_json_eval_src_req decoder] decodes a [eval_src_req] value from [decoder] *)

val decode_json_eval_output : Yojson.Basic.t -> eval_output
(** [decode_json_eval_output decoder] decodes a [eval_output] value from [decoder] *)

val decode_json_pooutput : Yojson.Basic.t -> pooutput
(** [decode_json_pooutput decoder] decodes a [pooutput] value from [decoder] *)

val decode_json_proved : Yojson.Basic.t -> proved
(** [decode_json_proved decoder] decodes a [proved] value from [decoder] *)

val decode_json_model_type : Yojson.Basic.t -> model_type
(** [decode_json_model_type decoder] decodes a [model_type] value from [decoder] *)

val decode_json_model : Yojson.Basic.t -> model
(** [decode_json_model decoder] decodes a [model] value from [decoder] *)

val decode_json_counter_sat : Yojson.Basic.t -> counter_sat
(** [decode_json_counter_sat decoder] decodes a [counter_sat] value from [decoder] *)

val decode_json_verified_upto : Yojson.Basic.t -> verified_upto
(** [decode_json_verified_upto decoder] decodes a [verified_upto] value from [decoder] *)

val decode_json_pores_res : Yojson.Basic.t -> pores_res
(** [decode_json_pores_res decoder] decodes a [pores_res] value from [decoder] *)

val decode_json_pores : Yojson.Basic.t -> pores
(** [decode_json_pores decoder] decodes a [pores] value from [decoder] *)

val decode_json_eval_res : Yojson.Basic.t -> eval_res
(** [decode_json_eval_res decoder] decodes a [eval_res] value from [decoder] *)

val decode_json_verify_src_req : Yojson.Basic.t -> verify_src_req
(** [decode_json_verify_src_req decoder] decodes a [verify_src_req] value from [decoder] *)

val decode_json_verify_name_req : Yojson.Basic.t -> verify_name_req
(** [decode_json_verify_name_req decoder] decodes a [verify_name_req] value from [decoder] *)

val decode_json_instance_src_req : Yojson.Basic.t -> instance_src_req
(** [decode_json_instance_src_req decoder] decodes a [instance_src_req] value from [decoder] *)

val decode_json_instance_name_req : Yojson.Basic.t -> instance_name_req
(** [decode_json_instance_name_req decoder] decodes a [instance_name_req] value from [decoder] *)

val decode_json_unsat : Yojson.Basic.t -> unsat
(** [decode_json_unsat decoder] decodes a [unsat] value from [decoder] *)

val decode_json_refuted : Yojson.Basic.t -> refuted
(** [decode_json_refuted decoder] decodes a [refuted] value from [decoder] *)

val decode_json_sat : Yojson.Basic.t -> sat
(** [decode_json_sat decoder] decodes a [sat] value from [decoder] *)

val decode_json_verify_res_res : Yojson.Basic.t -> verify_res_res
(** [decode_json_verify_res_res decoder] decodes a [verify_res_res] value from [decoder] *)

val decode_json_verify_res : Yojson.Basic.t -> verify_res
(** [decode_json_verify_res decoder] decodes a [verify_res] value from [decoder] *)

val decode_json_instance_res_res : Yojson.Basic.t -> instance_res_res
(** [decode_json_instance_res_res decoder] decodes a [instance_res_res] value from [decoder] *)

val decode_json_instance_res : Yojson.Basic.t -> instance_res
(** [decode_json_instance_res decoder] decodes a [instance_res] value from [decoder] *)

val decode_json_typecheck_req : Yojson.Basic.t -> typecheck_req
(** [decode_json_typecheck_req decoder] decodes a [typecheck_req] value from [decoder] *)

val decode_json_typecheck_res : Yojson.Basic.t -> typecheck_res
(** [decode_json_typecheck_res decoder] decodes a [typecheck_res] value from [decoder] *)


(** {2 Services} *)

(** Simple service *)
module Simple : sig
  open Pbrt_services
  open Pbrt_services.Value_mode
  
  module Client : sig
    
    val status : (Utils.empty, unary, Utils.string_msg, unary) Client.rpc
    
    val shutdown : (Utils.empty, unary, Utils.empty, unary) Client.rpc
    
    val create_session : (session_create_req, unary, Session.session, unary) Client.rpc
    
    val end_session : (Session.session, unary, Utils.empty, unary) Client.rpc
    
    val eval_src : (eval_src_req, unary, eval_res, unary) Client.rpc
    
    val verify_src : (verify_src_req, unary, verify_res, unary) Client.rpc
    
    val verify_name : (verify_name_req, unary, verify_res, unary) Client.rpc
    
    val instance_src : (instance_src_req, unary, instance_res, unary) Client.rpc
    
    val instance_name : (instance_name_req, unary, instance_res, unary) Client.rpc
    
    val decompose : (decompose_req, unary, decompose_res, unary) Client.rpc
    
    val typecheck : (typecheck_req, unary, typecheck_res, unary) Client.rpc
  end
  
  module Server : sig
    (** Produce a server implementation from handlers *)
    val make : 
      status:((Utils.empty, unary, Utils.string_msg, unary) Server.rpc -> 'handler) ->
      shutdown:((Utils.empty, unary, Utils.empty, unary) Server.rpc -> 'handler) ->
      create_session:((session_create_req, unary, Session.session, unary) Server.rpc -> 'handler) ->
      end_session:((Session.session, unary, Utils.empty, unary) Server.rpc -> 'handler) ->
      eval_src:((eval_src_req, unary, eval_res, unary) Server.rpc -> 'handler) ->
      verify_src:((verify_src_req, unary, verify_res, unary) Server.rpc -> 'handler) ->
      verify_name:((verify_name_req, unary, verify_res, unary) Server.rpc -> 'handler) ->
      instance_src:((instance_src_req, unary, instance_res, unary) Server.rpc -> 'handler) ->
      instance_name:((instance_name_req, unary, instance_res, unary) Server.rpc -> 'handler) ->
      decompose:((decompose_req, unary, decompose_res, unary) Server.rpc -> 'handler) ->
      typecheck:((typecheck_req, unary, typecheck_res, unary) Server.rpc -> 'handler) ->
      unit -> 'handler Pbrt_services.Server.t
    
    (** The individual server stubs are only exposed for advanced users. Casual users should prefer accessing them through {!make}. *)
    
    val status : (Utils.empty,unary,Utils.string_msg,unary) Server.rpc
    
    val shutdown : (Utils.empty,unary,Utils.empty,unary) Server.rpc
    
    val create_session : (session_create_req,unary,Session.session,unary) Server.rpc
    
    val end_session : (Session.session,unary,Utils.empty,unary) Server.rpc
    
    val eval_src : (eval_src_req,unary,eval_res,unary) Server.rpc
    
    val verify_src : (verify_src_req,unary,verify_res,unary) Server.rpc
    
    val verify_name : (verify_name_req,unary,verify_res,unary) Server.rpc
    
    val instance_src : (instance_src_req,unary,instance_res,unary) Server.rpc
    
    val instance_name : (instance_name_req,unary,instance_res,unary) Server.rpc
    
    val decompose : (decompose_req,unary,decompose_res,unary) Server.rpc
    
    val typecheck : (typecheck_req,unary,typecheck_res,unary) Server.rpc
  end
end
