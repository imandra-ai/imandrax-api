
(** Code for simple_api.proto *)

(* generated from "simple_api.proto", do not edit *)



(** {2 Types} *)

type session_create_req = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable api_version : string;
}

type lift_bool =
  | Default 
  | Nested_equalities 
  | Equalities 
  | All 

type decompose_req = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 7 fields *)
  mutable session : Session.session option;
  mutable name : string;
  mutable assuming : string;
  mutable basis : string list;
  mutable rule_specs : string list;
  mutable prune : bool;
  mutable ctx_simp : bool;
  mutable lift_bool : lift_bool;
  mutable str : bool;
  mutable timeout : int32;
}

type decompose_req_full_by_name = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 5 fields *)
  mutable name : string;
  mutable assuming : string;
  mutable basis : string list;
  mutable rule_specs : string list;
  mutable prune : bool;
  mutable ctx_simp : bool;
  mutable lift_bool : lift_bool;
}

type decompose_req_full_local_var_get = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable name : string;
}

type decompose_req_full_prune = private {
  mutable d : decompose_req_full_decomp option;
}

and decompose_req_full_decomp =
  | From_artifact of Artmsg.art
  | By_name of decompose_req_full_by_name
  | Merge of decompose_req_full_merge
  | Compound_merge of decompose_req_full_compound_merge
  | Prune of decompose_req_full_prune
  | Combine of decompose_req_full_combine
  | Get of decompose_req_full_local_var_get
  | Set of decompose_req_full_local_var_let

and decompose_req_full_merge = private {
  mutable d1 : decompose_req_full_decomp option;
  mutable d2 : decompose_req_full_decomp option;
}

and decompose_req_full_compound_merge = private {
  mutable d1 : decompose_req_full_decomp option;
  mutable d2 : decompose_req_full_decomp option;
}

and decompose_req_full_combine = private {
  mutable d : decompose_req_full_decomp option;
}

and decompose_req_full_local_var_let = private {
  mutable bindings : decompose_req_full_local_var_binding list;
  mutable and_then : decompose_req_full_decomp option;
}

and decompose_req_full_local_var_binding = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable name : string;
  mutable d : decompose_req_full_decomp option;
}

type decompose_req_full = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable session : Session.session option;
  mutable decomp : decompose_req_full_decomp option;
  mutable str : bool;
  mutable timeout : int32;
}

type decompose_res_res =
  | Artifact of Artmsg.art
  | Err

and decompose_res = private {
  mutable res : decompose_res_res option;
  mutable errors : Error.error list;
  mutable task : Task.task option;
}

type eval_src_req = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable session : Session.session option;
  mutable src : string;
  mutable async_only : bool;
}

type eval_output = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable success : bool;
  mutable value_as_ocaml : string;
  mutable errors : Error.error list;
}

type proved = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable proof_pp : string;
}

type model_type =
  | Counter_example 
  | Instance 

type model = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable m_type : model_type;
  mutable src : string;
  mutable artifact : Artmsg.art option;
}

type counter_sat = private {
  mutable model : model option;
}

type verified_upto = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable msg : string;
}

type po_res_res =
  | Unknown of Utils.string_msg
  | Err
  | Proof of proved
  | Instance of counter_sat
  | Verified_upto of verified_upto

and po_res = private {
  mutable res : po_res_res option;
  mutable errors : Error.error list;
  mutable task : Task.task option;
  mutable origin : Task.origin option;
}

type eval_res = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable success : bool;
  mutable messages : string list;
  mutable errors : Error.error list;
  mutable tasks : Task.task list;
  mutable po_results : po_res list;
  mutable eval_results : eval_output list;
  mutable decomp_results : decompose_res list;
}

type verify_src_req = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable session : Session.session option;
  mutable src : string;
  mutable hints : string;
}

type verify_name_req = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable session : Session.session option;
  mutable name : string;
  mutable hints : string;
}

type instance_src_req = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable session : Session.session option;
  mutable src : string;
  mutable hints : string;
}

type instance_name_req = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable session : Session.session option;
  mutable name : string;
  mutable hints : string;
}

type unsat = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable proof_pp : string;
}

type refuted = private {
  mutable model : model option;
}

type sat = private {
  mutable model : model option;
}

type verify_res_res =
  | Unknown of Utils.string_msg
  | Err
  | Proved of proved
  | Refuted of refuted
  | Verified_upto of verified_upto

and verify_res = private {
  mutable res : verify_res_res option;
  mutable errors : Error.error list;
  mutable task : Task.task option;
}

type instance_res_res =
  | Unknown of Utils.string_msg
  | Err
  | Unsat of unsat
  | Sat of sat

and instance_res = private {
  mutable res : instance_res_res option;
  mutable errors : Error.error list;
  mutable task : Task.task option;
}

type typecheck_req = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable session : Session.session option;
  mutable src : string;
}

type typecheck_res = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable success : bool;
  mutable types : string;
  mutable errors : Error.error list;
}

type oneshot_req = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable input : string;
  mutable timeout : float;
}

type oneshot_res_stats = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable time : float;
}

type oneshot_res = private {
  mutable results : string list;
  mutable errors : string list;
  mutable stats : oneshot_res_stats option;
  mutable detailed_results : string list;
}

type get_decl_req = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable session : Session.session option;
  mutable name : string list;
  mutable str : bool;
}

type decl_with_name = private {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable name : string;
  mutable artifact : Artmsg.art option;
  mutable str : string;
}

type get_decl_res = private {
  mutable decls : decl_with_name list;
  mutable not_found : string list;
}


(** {2 Basic values} *)

val default_session_create_req : unit -> session_create_req 
(** [default_session_create_req ()] is a new empty value for type [session_create_req] *)

val default_lift_bool : unit -> lift_bool
(** [default_lift_bool ()] is a new empty value for type [lift_bool] *)

val default_decompose_req : unit -> decompose_req 
(** [default_decompose_req ()] is a new empty value for type [decompose_req] *)

val default_decompose_req_full_by_name : unit -> decompose_req_full_by_name 
(** [default_decompose_req_full_by_name ()] is a new empty value for type [decompose_req_full_by_name] *)

val default_decompose_req_full_local_var_get : unit -> decompose_req_full_local_var_get 
(** [default_decompose_req_full_local_var_get ()] is a new empty value for type [decompose_req_full_local_var_get] *)

val default_decompose_req_full_prune : unit -> decompose_req_full_prune 
(** [default_decompose_req_full_prune ()] is a new empty value for type [decompose_req_full_prune] *)

val default_decompose_req_full_decomp : unit -> decompose_req_full_decomp
(** [default_decompose_req_full_decomp ()] is a new empty value for type [decompose_req_full_decomp] *)

val default_decompose_req_full_merge : unit -> decompose_req_full_merge 
(** [default_decompose_req_full_merge ()] is a new empty value for type [decompose_req_full_merge] *)

val default_decompose_req_full_compound_merge : unit -> decompose_req_full_compound_merge 
(** [default_decompose_req_full_compound_merge ()] is a new empty value for type [decompose_req_full_compound_merge] *)

val default_decompose_req_full_combine : unit -> decompose_req_full_combine 
(** [default_decompose_req_full_combine ()] is a new empty value for type [decompose_req_full_combine] *)

val default_decompose_req_full_local_var_let : unit -> decompose_req_full_local_var_let 
(** [default_decompose_req_full_local_var_let ()] is a new empty value for type [decompose_req_full_local_var_let] *)

val default_decompose_req_full_local_var_binding : unit -> decompose_req_full_local_var_binding 
(** [default_decompose_req_full_local_var_binding ()] is a new empty value for type [decompose_req_full_local_var_binding] *)

val default_decompose_req_full : unit -> decompose_req_full 
(** [default_decompose_req_full ()] is a new empty value for type [decompose_req_full] *)

val default_decompose_res_res : unit -> decompose_res_res
(** [default_decompose_res_res ()] is a new empty value for type [decompose_res_res] *)

val default_decompose_res : unit -> decompose_res 
(** [default_decompose_res ()] is a new empty value for type [decompose_res] *)

val default_eval_src_req : unit -> eval_src_req 
(** [default_eval_src_req ()] is a new empty value for type [eval_src_req] *)

val default_eval_output : unit -> eval_output 
(** [default_eval_output ()] is a new empty value for type [eval_output] *)

val default_proved : unit -> proved 
(** [default_proved ()] is a new empty value for type [proved] *)

val default_model_type : unit -> model_type
(** [default_model_type ()] is a new empty value for type [model_type] *)

val default_model : unit -> model 
(** [default_model ()] is a new empty value for type [model] *)

val default_counter_sat : unit -> counter_sat 
(** [default_counter_sat ()] is a new empty value for type [counter_sat] *)

val default_verified_upto : unit -> verified_upto 
(** [default_verified_upto ()] is a new empty value for type [verified_upto] *)

val default_po_res_res : unit -> po_res_res
(** [default_po_res_res ()] is a new empty value for type [po_res_res] *)

val default_po_res : unit -> po_res 
(** [default_po_res ()] is a new empty value for type [po_res] *)

val default_eval_res : unit -> eval_res 
(** [default_eval_res ()] is a new empty value for type [eval_res] *)

val default_verify_src_req : unit -> verify_src_req 
(** [default_verify_src_req ()] is a new empty value for type [verify_src_req] *)

val default_verify_name_req : unit -> verify_name_req 
(** [default_verify_name_req ()] is a new empty value for type [verify_name_req] *)

val default_instance_src_req : unit -> instance_src_req 
(** [default_instance_src_req ()] is a new empty value for type [instance_src_req] *)

val default_instance_name_req : unit -> instance_name_req 
(** [default_instance_name_req ()] is a new empty value for type [instance_name_req] *)

val default_unsat : unit -> unsat 
(** [default_unsat ()] is a new empty value for type [unsat] *)

val default_refuted : unit -> refuted 
(** [default_refuted ()] is a new empty value for type [refuted] *)

val default_sat : unit -> sat 
(** [default_sat ()] is a new empty value for type [sat] *)

val default_verify_res_res : unit -> verify_res_res
(** [default_verify_res_res ()] is a new empty value for type [verify_res_res] *)

val default_verify_res : unit -> verify_res 
(** [default_verify_res ()] is a new empty value for type [verify_res] *)

val default_instance_res_res : unit -> instance_res_res
(** [default_instance_res_res ()] is a new empty value for type [instance_res_res] *)

val default_instance_res : unit -> instance_res 
(** [default_instance_res ()] is a new empty value for type [instance_res] *)

val default_typecheck_req : unit -> typecheck_req 
(** [default_typecheck_req ()] is a new empty value for type [typecheck_req] *)

val default_typecheck_res : unit -> typecheck_res 
(** [default_typecheck_res ()] is a new empty value for type [typecheck_res] *)

val default_oneshot_req : unit -> oneshot_req 
(** [default_oneshot_req ()] is a new empty value for type [oneshot_req] *)

val default_oneshot_res_stats : unit -> oneshot_res_stats 
(** [default_oneshot_res_stats ()] is a new empty value for type [oneshot_res_stats] *)

val default_oneshot_res : unit -> oneshot_res 
(** [default_oneshot_res ()] is a new empty value for type [oneshot_res] *)

val default_get_decl_req : unit -> get_decl_req 
(** [default_get_decl_req ()] is a new empty value for type [get_decl_req] *)

val default_decl_with_name : unit -> decl_with_name 
(** [default_decl_with_name ()] is a new empty value for type [decl_with_name] *)

val default_get_decl_res : unit -> get_decl_res 
(** [default_get_decl_res ()] is a new empty value for type [get_decl_res] *)


(** {2 Make functions} *)

val make_session_create_req : 
  ?api_version:string ->
  unit ->
  session_create_req
(** [make_session_create_req … ()] is a builder for type [session_create_req] *)

val copy_session_create_req : session_create_req -> session_create_req

val session_create_req_has_api_version : session_create_req -> bool
  (** presence of field "api_version" in [session_create_req] *)

val session_create_req_set_api_version : session_create_req -> string -> unit
  (** set field api_version in session_create_req *)

val make_decompose_req : 
  ?session:Session.session ->
  ?name:string ->
  ?assuming:string ->
  ?basis:string list ->
  ?rule_specs:string list ->
  ?prune:bool ->
  ?ctx_simp:bool ->
  ?lift_bool:lift_bool ->
  ?str:bool ->
  ?timeout:int32 ->
  unit ->
  decompose_req
(** [make_decompose_req … ()] is a builder for type [decompose_req] *)

val copy_decompose_req : decompose_req -> decompose_req

val decompose_req_set_session : decompose_req -> Session.session -> unit
  (** set field session in decompose_req *)

val decompose_req_has_name : decompose_req -> bool
  (** presence of field "name" in [decompose_req] *)

val decompose_req_set_name : decompose_req -> string -> unit
  (** set field name in decompose_req *)

val decompose_req_has_assuming : decompose_req -> bool
  (** presence of field "assuming" in [decompose_req] *)

val decompose_req_set_assuming : decompose_req -> string -> unit
  (** set field assuming in decompose_req *)

val decompose_req_set_basis : decompose_req -> string list -> unit
  (** set field basis in decompose_req *)

val decompose_req_set_rule_specs : decompose_req -> string list -> unit
  (** set field rule_specs in decompose_req *)

val decompose_req_has_prune : decompose_req -> bool
  (** presence of field "prune" in [decompose_req] *)

val decompose_req_set_prune : decompose_req -> bool -> unit
  (** set field prune in decompose_req *)

val decompose_req_has_ctx_simp : decompose_req -> bool
  (** presence of field "ctx_simp" in [decompose_req] *)

val decompose_req_set_ctx_simp : decompose_req -> bool -> unit
  (** set field ctx_simp in decompose_req *)

val decompose_req_has_lift_bool : decompose_req -> bool
  (** presence of field "lift_bool" in [decompose_req] *)

val decompose_req_set_lift_bool : decompose_req -> lift_bool -> unit
  (** set field lift_bool in decompose_req *)

val decompose_req_has_str : decompose_req -> bool
  (** presence of field "str" in [decompose_req] *)

val decompose_req_set_str : decompose_req -> bool -> unit
  (** set field str in decompose_req *)

val decompose_req_has_timeout : decompose_req -> bool
  (** presence of field "timeout" in [decompose_req] *)

val decompose_req_set_timeout : decompose_req -> int32 -> unit
  (** set field timeout in decompose_req *)

val make_decompose_req_full_by_name : 
  ?name:string ->
  ?assuming:string ->
  ?basis:string list ->
  ?rule_specs:string list ->
  ?prune:bool ->
  ?ctx_simp:bool ->
  ?lift_bool:lift_bool ->
  unit ->
  decompose_req_full_by_name
(** [make_decompose_req_full_by_name … ()] is a builder for type [decompose_req_full_by_name] *)

val copy_decompose_req_full_by_name : decompose_req_full_by_name -> decompose_req_full_by_name

val decompose_req_full_by_name_has_name : decompose_req_full_by_name -> bool
  (** presence of field "name" in [decompose_req_full_by_name] *)

val decompose_req_full_by_name_set_name : decompose_req_full_by_name -> string -> unit
  (** set field name in decompose_req_full_by_name *)

val decompose_req_full_by_name_has_assuming : decompose_req_full_by_name -> bool
  (** presence of field "assuming" in [decompose_req_full_by_name] *)

val decompose_req_full_by_name_set_assuming : decompose_req_full_by_name -> string -> unit
  (** set field assuming in decompose_req_full_by_name *)

val decompose_req_full_by_name_set_basis : decompose_req_full_by_name -> string list -> unit
  (** set field basis in decompose_req_full_by_name *)

val decompose_req_full_by_name_set_rule_specs : decompose_req_full_by_name -> string list -> unit
  (** set field rule_specs in decompose_req_full_by_name *)

val decompose_req_full_by_name_has_prune : decompose_req_full_by_name -> bool
  (** presence of field "prune" in [decompose_req_full_by_name] *)

val decompose_req_full_by_name_set_prune : decompose_req_full_by_name -> bool -> unit
  (** set field prune in decompose_req_full_by_name *)

val decompose_req_full_by_name_has_ctx_simp : decompose_req_full_by_name -> bool
  (** presence of field "ctx_simp" in [decompose_req_full_by_name] *)

val decompose_req_full_by_name_set_ctx_simp : decompose_req_full_by_name -> bool -> unit
  (** set field ctx_simp in decompose_req_full_by_name *)

val decompose_req_full_by_name_has_lift_bool : decompose_req_full_by_name -> bool
  (** presence of field "lift_bool" in [decompose_req_full_by_name] *)

val decompose_req_full_by_name_set_lift_bool : decompose_req_full_by_name -> lift_bool -> unit
  (** set field lift_bool in decompose_req_full_by_name *)

val make_decompose_req_full_local_var_get : 
  ?name:string ->
  unit ->
  decompose_req_full_local_var_get
(** [make_decompose_req_full_local_var_get … ()] is a builder for type [decompose_req_full_local_var_get] *)

val copy_decompose_req_full_local_var_get : decompose_req_full_local_var_get -> decompose_req_full_local_var_get

val decompose_req_full_local_var_get_has_name : decompose_req_full_local_var_get -> bool
  (** presence of field "name" in [decompose_req_full_local_var_get] *)

val decompose_req_full_local_var_get_set_name : decompose_req_full_local_var_get -> string -> unit
  (** set field name in decompose_req_full_local_var_get *)

val make_decompose_req_full_prune : 
  ?d:decompose_req_full_decomp ->
  unit ->
  decompose_req_full_prune
(** [make_decompose_req_full_prune … ()] is a builder for type [decompose_req_full_prune] *)

val copy_decompose_req_full_prune : decompose_req_full_prune -> decompose_req_full_prune

val decompose_req_full_prune_set_d : decompose_req_full_prune -> decompose_req_full_decomp -> unit
  (** set field d in decompose_req_full_prune *)

val make_decompose_req_full_merge : 
  ?d1:decompose_req_full_decomp ->
  ?d2:decompose_req_full_decomp ->
  unit ->
  decompose_req_full_merge
(** [make_decompose_req_full_merge … ()] is a builder for type [decompose_req_full_merge] *)

val copy_decompose_req_full_merge : decompose_req_full_merge -> decompose_req_full_merge

val decompose_req_full_merge_set_d1 : decompose_req_full_merge -> decompose_req_full_decomp -> unit
  (** set field d1 in decompose_req_full_merge *)

val decompose_req_full_merge_set_d2 : decompose_req_full_merge -> decompose_req_full_decomp -> unit
  (** set field d2 in decompose_req_full_merge *)

val make_decompose_req_full_compound_merge : 
  ?d1:decompose_req_full_decomp ->
  ?d2:decompose_req_full_decomp ->
  unit ->
  decompose_req_full_compound_merge
(** [make_decompose_req_full_compound_merge … ()] is a builder for type [decompose_req_full_compound_merge] *)

val copy_decompose_req_full_compound_merge : decompose_req_full_compound_merge -> decompose_req_full_compound_merge

val decompose_req_full_compound_merge_set_d1 : decompose_req_full_compound_merge -> decompose_req_full_decomp -> unit
  (** set field d1 in decompose_req_full_compound_merge *)

val decompose_req_full_compound_merge_set_d2 : decompose_req_full_compound_merge -> decompose_req_full_decomp -> unit
  (** set field d2 in decompose_req_full_compound_merge *)

val make_decompose_req_full_combine : 
  ?d:decompose_req_full_decomp ->
  unit ->
  decompose_req_full_combine
(** [make_decompose_req_full_combine … ()] is a builder for type [decompose_req_full_combine] *)

val copy_decompose_req_full_combine : decompose_req_full_combine -> decompose_req_full_combine

val decompose_req_full_combine_set_d : decompose_req_full_combine -> decompose_req_full_decomp -> unit
  (** set field d in decompose_req_full_combine *)

val make_decompose_req_full_local_var_let : 
  ?bindings:decompose_req_full_local_var_binding list ->
  ?and_then:decompose_req_full_decomp ->
  unit ->
  decompose_req_full_local_var_let
(** [make_decompose_req_full_local_var_let … ()] is a builder for type [decompose_req_full_local_var_let] *)

val copy_decompose_req_full_local_var_let : decompose_req_full_local_var_let -> decompose_req_full_local_var_let

val decompose_req_full_local_var_let_set_bindings : decompose_req_full_local_var_let -> decompose_req_full_local_var_binding list -> unit
  (** set field bindings in decompose_req_full_local_var_let *)

val decompose_req_full_local_var_let_set_and_then : decompose_req_full_local_var_let -> decompose_req_full_decomp -> unit
  (** set field and_then in decompose_req_full_local_var_let *)

val make_decompose_req_full_local_var_binding : 
  ?name:string ->
  ?d:decompose_req_full_decomp ->
  unit ->
  decompose_req_full_local_var_binding
(** [make_decompose_req_full_local_var_binding … ()] is a builder for type [decompose_req_full_local_var_binding] *)

val copy_decompose_req_full_local_var_binding : decompose_req_full_local_var_binding -> decompose_req_full_local_var_binding

val decompose_req_full_local_var_binding_has_name : decompose_req_full_local_var_binding -> bool
  (** presence of field "name" in [decompose_req_full_local_var_binding] *)

val decompose_req_full_local_var_binding_set_name : decompose_req_full_local_var_binding -> string -> unit
  (** set field name in decompose_req_full_local_var_binding *)

val decompose_req_full_local_var_binding_set_d : decompose_req_full_local_var_binding -> decompose_req_full_decomp -> unit
  (** set field d in decompose_req_full_local_var_binding *)

val make_decompose_req_full : 
  ?session:Session.session ->
  ?decomp:decompose_req_full_decomp ->
  ?str:bool ->
  ?timeout:int32 ->
  unit ->
  decompose_req_full
(** [make_decompose_req_full … ()] is a builder for type [decompose_req_full] *)

val copy_decompose_req_full : decompose_req_full -> decompose_req_full

val decompose_req_full_set_session : decompose_req_full -> Session.session -> unit
  (** set field session in decompose_req_full *)

val decompose_req_full_set_decomp : decompose_req_full -> decompose_req_full_decomp -> unit
  (** set field decomp in decompose_req_full *)

val decompose_req_full_has_str : decompose_req_full -> bool
  (** presence of field "str" in [decompose_req_full] *)

val decompose_req_full_set_str : decompose_req_full -> bool -> unit
  (** set field str in decompose_req_full *)

val decompose_req_full_has_timeout : decompose_req_full -> bool
  (** presence of field "timeout" in [decompose_req_full] *)

val decompose_req_full_set_timeout : decompose_req_full -> int32 -> unit
  (** set field timeout in decompose_req_full *)

val make_decompose_res : 
  ?res:decompose_res_res ->
  ?errors:Error.error list ->
  ?task:Task.task ->
  unit ->
  decompose_res
(** [make_decompose_res … ()] is a builder for type [decompose_res] *)

val copy_decompose_res : decompose_res -> decompose_res

val decompose_res_set_res : decompose_res -> decompose_res_res -> unit
  (** set field res in decompose_res *)

val decompose_res_set_errors : decompose_res -> Error.error list -> unit
  (** set field errors in decompose_res *)

val decompose_res_set_task : decompose_res -> Task.task -> unit
  (** set field task in decompose_res *)

val make_eval_src_req : 
  ?session:Session.session ->
  ?src:string ->
  ?async_only:bool ->
  unit ->
  eval_src_req
(** [make_eval_src_req … ()] is a builder for type [eval_src_req] *)

val copy_eval_src_req : eval_src_req -> eval_src_req

val eval_src_req_set_session : eval_src_req -> Session.session -> unit
  (** set field session in eval_src_req *)

val eval_src_req_has_src : eval_src_req -> bool
  (** presence of field "src" in [eval_src_req] *)

val eval_src_req_set_src : eval_src_req -> string -> unit
  (** set field src in eval_src_req *)

val eval_src_req_has_async_only : eval_src_req -> bool
  (** presence of field "async_only" in [eval_src_req] *)

val eval_src_req_set_async_only : eval_src_req -> bool -> unit
  (** set field async_only in eval_src_req *)

val make_eval_output : 
  ?success:bool ->
  ?value_as_ocaml:string ->
  ?errors:Error.error list ->
  unit ->
  eval_output
(** [make_eval_output … ()] is a builder for type [eval_output] *)

val copy_eval_output : eval_output -> eval_output

val eval_output_has_success : eval_output -> bool
  (** presence of field "success" in [eval_output] *)

val eval_output_set_success : eval_output -> bool -> unit
  (** set field success in eval_output *)

val eval_output_has_value_as_ocaml : eval_output -> bool
  (** presence of field "value_as_ocaml" in [eval_output] *)

val eval_output_set_value_as_ocaml : eval_output -> string -> unit
  (** set field value_as_ocaml in eval_output *)

val eval_output_set_errors : eval_output -> Error.error list -> unit
  (** set field errors in eval_output *)

val make_proved : 
  ?proof_pp:string ->
  unit ->
  proved
(** [make_proved … ()] is a builder for type [proved] *)

val copy_proved : proved -> proved

val proved_has_proof_pp : proved -> bool
  (** presence of field "proof_pp" in [proved] *)

val proved_set_proof_pp : proved -> string -> unit
  (** set field proof_pp in proved *)

val make_model : 
  ?m_type:model_type ->
  ?src:string ->
  ?artifact:Artmsg.art ->
  unit ->
  model
(** [make_model … ()] is a builder for type [model] *)

val copy_model : model -> model

val model_has_m_type : model -> bool
  (** presence of field "m_type" in [model] *)

val model_set_m_type : model -> model_type -> unit
  (** set field m_type in model *)

val model_has_src : model -> bool
  (** presence of field "src" in [model] *)

val model_set_src : model -> string -> unit
  (** set field src in model *)

val model_set_artifact : model -> Artmsg.art -> unit
  (** set field artifact in model *)

val make_counter_sat : 
  ?model:model ->
  unit ->
  counter_sat
(** [make_counter_sat … ()] is a builder for type [counter_sat] *)

val copy_counter_sat : counter_sat -> counter_sat

val counter_sat_set_model : counter_sat -> model -> unit
  (** set field model in counter_sat *)

val make_verified_upto : 
  ?msg:string ->
  unit ->
  verified_upto
(** [make_verified_upto … ()] is a builder for type [verified_upto] *)

val copy_verified_upto : verified_upto -> verified_upto

val verified_upto_has_msg : verified_upto -> bool
  (** presence of field "msg" in [verified_upto] *)

val verified_upto_set_msg : verified_upto -> string -> unit
  (** set field msg in verified_upto *)

val make_po_res : 
  ?res:po_res_res ->
  ?errors:Error.error list ->
  ?task:Task.task ->
  ?origin:Task.origin ->
  unit ->
  po_res
(** [make_po_res … ()] is a builder for type [po_res] *)

val copy_po_res : po_res -> po_res

val po_res_set_res : po_res -> po_res_res -> unit
  (** set field res in po_res *)

val po_res_set_errors : po_res -> Error.error list -> unit
  (** set field errors in po_res *)

val po_res_set_task : po_res -> Task.task -> unit
  (** set field task in po_res *)

val po_res_set_origin : po_res -> Task.origin -> unit
  (** set field origin in po_res *)

val make_eval_res : 
  ?success:bool ->
  ?messages:string list ->
  ?errors:Error.error list ->
  ?tasks:Task.task list ->
  ?po_results:po_res list ->
  ?eval_results:eval_output list ->
  ?decomp_results:decompose_res list ->
  unit ->
  eval_res
(** [make_eval_res … ()] is a builder for type [eval_res] *)

val copy_eval_res : eval_res -> eval_res

val eval_res_has_success : eval_res -> bool
  (** presence of field "success" in [eval_res] *)

val eval_res_set_success : eval_res -> bool -> unit
  (** set field success in eval_res *)

val eval_res_set_messages : eval_res -> string list -> unit
  (** set field messages in eval_res *)

val eval_res_set_errors : eval_res -> Error.error list -> unit
  (** set field errors in eval_res *)

val eval_res_set_tasks : eval_res -> Task.task list -> unit
  (** set field tasks in eval_res *)

val eval_res_set_po_results : eval_res -> po_res list -> unit
  (** set field po_results in eval_res *)

val eval_res_set_eval_results : eval_res -> eval_output list -> unit
  (** set field eval_results in eval_res *)

val eval_res_set_decomp_results : eval_res -> decompose_res list -> unit
  (** set field decomp_results in eval_res *)

val make_verify_src_req : 
  ?session:Session.session ->
  ?src:string ->
  ?hints:string ->
  unit ->
  verify_src_req
(** [make_verify_src_req … ()] is a builder for type [verify_src_req] *)

val copy_verify_src_req : verify_src_req -> verify_src_req

val verify_src_req_set_session : verify_src_req -> Session.session -> unit
  (** set field session in verify_src_req *)

val verify_src_req_has_src : verify_src_req -> bool
  (** presence of field "src" in [verify_src_req] *)

val verify_src_req_set_src : verify_src_req -> string -> unit
  (** set field src in verify_src_req *)

val verify_src_req_has_hints : verify_src_req -> bool
  (** presence of field "hints" in [verify_src_req] *)

val verify_src_req_set_hints : verify_src_req -> string -> unit
  (** set field hints in verify_src_req *)

val make_verify_name_req : 
  ?session:Session.session ->
  ?name:string ->
  ?hints:string ->
  unit ->
  verify_name_req
(** [make_verify_name_req … ()] is a builder for type [verify_name_req] *)

val copy_verify_name_req : verify_name_req -> verify_name_req

val verify_name_req_set_session : verify_name_req -> Session.session -> unit
  (** set field session in verify_name_req *)

val verify_name_req_has_name : verify_name_req -> bool
  (** presence of field "name" in [verify_name_req] *)

val verify_name_req_set_name : verify_name_req -> string -> unit
  (** set field name in verify_name_req *)

val verify_name_req_has_hints : verify_name_req -> bool
  (** presence of field "hints" in [verify_name_req] *)

val verify_name_req_set_hints : verify_name_req -> string -> unit
  (** set field hints in verify_name_req *)

val make_instance_src_req : 
  ?session:Session.session ->
  ?src:string ->
  ?hints:string ->
  unit ->
  instance_src_req
(** [make_instance_src_req … ()] is a builder for type [instance_src_req] *)

val copy_instance_src_req : instance_src_req -> instance_src_req

val instance_src_req_set_session : instance_src_req -> Session.session -> unit
  (** set field session in instance_src_req *)

val instance_src_req_has_src : instance_src_req -> bool
  (** presence of field "src" in [instance_src_req] *)

val instance_src_req_set_src : instance_src_req -> string -> unit
  (** set field src in instance_src_req *)

val instance_src_req_has_hints : instance_src_req -> bool
  (** presence of field "hints" in [instance_src_req] *)

val instance_src_req_set_hints : instance_src_req -> string -> unit
  (** set field hints in instance_src_req *)

val make_instance_name_req : 
  ?session:Session.session ->
  ?name:string ->
  ?hints:string ->
  unit ->
  instance_name_req
(** [make_instance_name_req … ()] is a builder for type [instance_name_req] *)

val copy_instance_name_req : instance_name_req -> instance_name_req

val instance_name_req_set_session : instance_name_req -> Session.session -> unit
  (** set field session in instance_name_req *)

val instance_name_req_has_name : instance_name_req -> bool
  (** presence of field "name" in [instance_name_req] *)

val instance_name_req_set_name : instance_name_req -> string -> unit
  (** set field name in instance_name_req *)

val instance_name_req_has_hints : instance_name_req -> bool
  (** presence of field "hints" in [instance_name_req] *)

val instance_name_req_set_hints : instance_name_req -> string -> unit
  (** set field hints in instance_name_req *)

val make_unsat : 
  ?proof_pp:string ->
  unit ->
  unsat
(** [make_unsat … ()] is a builder for type [unsat] *)

val copy_unsat : unsat -> unsat

val unsat_has_proof_pp : unsat -> bool
  (** presence of field "proof_pp" in [unsat] *)

val unsat_set_proof_pp : unsat -> string -> unit
  (** set field proof_pp in unsat *)

val make_refuted : 
  ?model:model ->
  unit ->
  refuted
(** [make_refuted … ()] is a builder for type [refuted] *)

val copy_refuted : refuted -> refuted

val refuted_set_model : refuted -> model -> unit
  (** set field model in refuted *)

val make_sat : 
  ?model:model ->
  unit ->
  sat
(** [make_sat … ()] is a builder for type [sat] *)

val copy_sat : sat -> sat

val sat_set_model : sat -> model -> unit
  (** set field model in sat *)

val make_verify_res : 
  ?res:verify_res_res ->
  ?errors:Error.error list ->
  ?task:Task.task ->
  unit ->
  verify_res
(** [make_verify_res … ()] is a builder for type [verify_res] *)

val copy_verify_res : verify_res -> verify_res

val verify_res_set_res : verify_res -> verify_res_res -> unit
  (** set field res in verify_res *)

val verify_res_set_errors : verify_res -> Error.error list -> unit
  (** set field errors in verify_res *)

val verify_res_set_task : verify_res -> Task.task -> unit
  (** set field task in verify_res *)

val make_instance_res : 
  ?res:instance_res_res ->
  ?errors:Error.error list ->
  ?task:Task.task ->
  unit ->
  instance_res
(** [make_instance_res … ()] is a builder for type [instance_res] *)

val copy_instance_res : instance_res -> instance_res

val instance_res_set_res : instance_res -> instance_res_res -> unit
  (** set field res in instance_res *)

val instance_res_set_errors : instance_res -> Error.error list -> unit
  (** set field errors in instance_res *)

val instance_res_set_task : instance_res -> Task.task -> unit
  (** set field task in instance_res *)

val make_typecheck_req : 
  ?session:Session.session ->
  ?src:string ->
  unit ->
  typecheck_req
(** [make_typecheck_req … ()] is a builder for type [typecheck_req] *)

val copy_typecheck_req : typecheck_req -> typecheck_req

val typecheck_req_set_session : typecheck_req -> Session.session -> unit
  (** set field session in typecheck_req *)

val typecheck_req_has_src : typecheck_req -> bool
  (** presence of field "src" in [typecheck_req] *)

val typecheck_req_set_src : typecheck_req -> string -> unit
  (** set field src in typecheck_req *)

val make_typecheck_res : 
  ?success:bool ->
  ?types:string ->
  ?errors:Error.error list ->
  unit ->
  typecheck_res
(** [make_typecheck_res … ()] is a builder for type [typecheck_res] *)

val copy_typecheck_res : typecheck_res -> typecheck_res

val typecheck_res_has_success : typecheck_res -> bool
  (** presence of field "success" in [typecheck_res] *)

val typecheck_res_set_success : typecheck_res -> bool -> unit
  (** set field success in typecheck_res *)

val typecheck_res_has_types : typecheck_res -> bool
  (** presence of field "types" in [typecheck_res] *)

val typecheck_res_set_types : typecheck_res -> string -> unit
  (** set field types in typecheck_res *)

val typecheck_res_set_errors : typecheck_res -> Error.error list -> unit
  (** set field errors in typecheck_res *)

val make_oneshot_req : 
  ?input:string ->
  ?timeout:float ->
  unit ->
  oneshot_req
(** [make_oneshot_req … ()] is a builder for type [oneshot_req] *)

val copy_oneshot_req : oneshot_req -> oneshot_req

val oneshot_req_has_input : oneshot_req -> bool
  (** presence of field "input" in [oneshot_req] *)

val oneshot_req_set_input : oneshot_req -> string -> unit
  (** set field input in oneshot_req *)

val oneshot_req_has_timeout : oneshot_req -> bool
  (** presence of field "timeout" in [oneshot_req] *)

val oneshot_req_set_timeout : oneshot_req -> float -> unit
  (** set field timeout in oneshot_req *)

val make_oneshot_res_stats : 
  ?time:float ->
  unit ->
  oneshot_res_stats
(** [make_oneshot_res_stats … ()] is a builder for type [oneshot_res_stats] *)

val copy_oneshot_res_stats : oneshot_res_stats -> oneshot_res_stats

val oneshot_res_stats_has_time : oneshot_res_stats -> bool
  (** presence of field "time" in [oneshot_res_stats] *)

val oneshot_res_stats_set_time : oneshot_res_stats -> float -> unit
  (** set field time in oneshot_res_stats *)

val make_oneshot_res : 
  ?results:string list ->
  ?errors:string list ->
  ?stats:oneshot_res_stats ->
  ?detailed_results:string list ->
  unit ->
  oneshot_res
(** [make_oneshot_res … ()] is a builder for type [oneshot_res] *)

val copy_oneshot_res : oneshot_res -> oneshot_res

val oneshot_res_set_results : oneshot_res -> string list -> unit
  (** set field results in oneshot_res *)

val oneshot_res_set_errors : oneshot_res -> string list -> unit
  (** set field errors in oneshot_res *)

val oneshot_res_set_stats : oneshot_res -> oneshot_res_stats -> unit
  (** set field stats in oneshot_res *)

val oneshot_res_set_detailed_results : oneshot_res -> string list -> unit
  (** set field detailed_results in oneshot_res *)

val make_get_decl_req : 
  ?session:Session.session ->
  ?name:string list ->
  ?str:bool ->
  unit ->
  get_decl_req
(** [make_get_decl_req … ()] is a builder for type [get_decl_req] *)

val copy_get_decl_req : get_decl_req -> get_decl_req

val get_decl_req_set_session : get_decl_req -> Session.session -> unit
  (** set field session in get_decl_req *)

val get_decl_req_set_name : get_decl_req -> string list -> unit
  (** set field name in get_decl_req *)

val get_decl_req_has_str : get_decl_req -> bool
  (** presence of field "str" in [get_decl_req] *)

val get_decl_req_set_str : get_decl_req -> bool -> unit
  (** set field str in get_decl_req *)

val make_decl_with_name : 
  ?name:string ->
  ?artifact:Artmsg.art ->
  ?str:string ->
  unit ->
  decl_with_name
(** [make_decl_with_name … ()] is a builder for type [decl_with_name] *)

val copy_decl_with_name : decl_with_name -> decl_with_name

val decl_with_name_has_name : decl_with_name -> bool
  (** presence of field "name" in [decl_with_name] *)

val decl_with_name_set_name : decl_with_name -> string -> unit
  (** set field name in decl_with_name *)

val decl_with_name_set_artifact : decl_with_name -> Artmsg.art -> unit
  (** set field artifact in decl_with_name *)

val decl_with_name_has_str : decl_with_name -> bool
  (** presence of field "str" in [decl_with_name] *)

val decl_with_name_set_str : decl_with_name -> string -> unit
  (** set field str in decl_with_name *)

val make_get_decl_res : 
  ?decls:decl_with_name list ->
  ?not_found:string list ->
  unit ->
  get_decl_res
(** [make_get_decl_res … ()] is a builder for type [get_decl_res] *)

val copy_get_decl_res : get_decl_res -> get_decl_res

val get_decl_res_set_decls : get_decl_res -> decl_with_name list -> unit
  (** set field decls in get_decl_res *)

val get_decl_res_set_not_found : get_decl_res -> string list -> unit
  (** set field not_found in get_decl_res *)


(** {2 Formatters} *)

val pp_session_create_req : Format.formatter -> session_create_req -> unit 
(** [pp_session_create_req v] formats v *)

val pp_lift_bool : Format.formatter -> lift_bool -> unit 
(** [pp_lift_bool v] formats v *)

val pp_decompose_req : Format.formatter -> decompose_req -> unit 
(** [pp_decompose_req v] formats v *)

val pp_decompose_req_full_by_name : Format.formatter -> decompose_req_full_by_name -> unit 
(** [pp_decompose_req_full_by_name v] formats v *)

val pp_decompose_req_full_local_var_get : Format.formatter -> decompose_req_full_local_var_get -> unit 
(** [pp_decompose_req_full_local_var_get v] formats v *)

val pp_decompose_req_full_prune : Format.formatter -> decompose_req_full_prune -> unit 
(** [pp_decompose_req_full_prune v] formats v *)

val pp_decompose_req_full_decomp : Format.formatter -> decompose_req_full_decomp -> unit 
(** [pp_decompose_req_full_decomp v] formats v *)

val pp_decompose_req_full_merge : Format.formatter -> decompose_req_full_merge -> unit 
(** [pp_decompose_req_full_merge v] formats v *)

val pp_decompose_req_full_compound_merge : Format.formatter -> decompose_req_full_compound_merge -> unit 
(** [pp_decompose_req_full_compound_merge v] formats v *)

val pp_decompose_req_full_combine : Format.formatter -> decompose_req_full_combine -> unit 
(** [pp_decompose_req_full_combine v] formats v *)

val pp_decompose_req_full_local_var_let : Format.formatter -> decompose_req_full_local_var_let -> unit 
(** [pp_decompose_req_full_local_var_let v] formats v *)

val pp_decompose_req_full_local_var_binding : Format.formatter -> decompose_req_full_local_var_binding -> unit 
(** [pp_decompose_req_full_local_var_binding v] formats v *)

val pp_decompose_req_full : Format.formatter -> decompose_req_full -> unit 
(** [pp_decompose_req_full v] formats v *)

val pp_decompose_res_res : Format.formatter -> decompose_res_res -> unit 
(** [pp_decompose_res_res v] formats v *)

val pp_decompose_res : Format.formatter -> decompose_res -> unit 
(** [pp_decompose_res v] formats v *)

val pp_eval_src_req : Format.formatter -> eval_src_req -> unit 
(** [pp_eval_src_req v] formats v *)

val pp_eval_output : Format.formatter -> eval_output -> unit 
(** [pp_eval_output v] formats v *)

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

val pp_po_res_res : Format.formatter -> po_res_res -> unit 
(** [pp_po_res_res v] formats v *)

val pp_po_res : Format.formatter -> po_res -> unit 
(** [pp_po_res v] formats v *)

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

val pp_oneshot_req : Format.formatter -> oneshot_req -> unit 
(** [pp_oneshot_req v] formats v *)

val pp_oneshot_res_stats : Format.formatter -> oneshot_res_stats -> unit 
(** [pp_oneshot_res_stats v] formats v *)

val pp_oneshot_res : Format.formatter -> oneshot_res -> unit 
(** [pp_oneshot_res v] formats v *)

val pp_get_decl_req : Format.formatter -> get_decl_req -> unit 
(** [pp_get_decl_req v] formats v *)

val pp_decl_with_name : Format.formatter -> decl_with_name -> unit 
(** [pp_decl_with_name v] formats v *)

val pp_get_decl_res : Format.formatter -> get_decl_res -> unit 
(** [pp_get_decl_res v] formats v *)


(** {2 Protobuf Encoding} *)

val encode_pb_session_create_req : session_create_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_session_create_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_lift_bool : lift_bool -> Pbrt.Encoder.t -> unit
(** [encode_pb_lift_bool v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_req : decompose_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_req_full_by_name : decompose_req_full_by_name -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_req_full_by_name v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_req_full_local_var_get : decompose_req_full_local_var_get -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_req_full_local_var_get v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_req_full_prune : decompose_req_full_prune -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_req_full_prune v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_req_full_decomp : decompose_req_full_decomp -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_req_full_decomp v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_req_full_merge : decompose_req_full_merge -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_req_full_merge v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_req_full_compound_merge : decompose_req_full_compound_merge -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_req_full_compound_merge v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_req_full_combine : decompose_req_full_combine -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_req_full_combine v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_req_full_local_var_let : decompose_req_full_local_var_let -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_req_full_local_var_let v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_req_full_local_var_binding : decompose_req_full_local_var_binding -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_req_full_local_var_binding v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_req_full : decompose_req_full -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_req_full v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_res_res : decompose_res_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_res_res v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decompose_res : decompose_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_decompose_res v encoder] encodes [v] with the given [encoder] *)

val encode_pb_eval_src_req : eval_src_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_eval_src_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_eval_output : eval_output -> Pbrt.Encoder.t -> unit
(** [encode_pb_eval_output v encoder] encodes [v] with the given [encoder] *)

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

val encode_pb_po_res_res : po_res_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_po_res_res v encoder] encodes [v] with the given [encoder] *)

val encode_pb_po_res : po_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_po_res v encoder] encodes [v] with the given [encoder] *)

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

val encode_pb_oneshot_req : oneshot_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_oneshot_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_oneshot_res_stats : oneshot_res_stats -> Pbrt.Encoder.t -> unit
(** [encode_pb_oneshot_res_stats v encoder] encodes [v] with the given [encoder] *)

val encode_pb_oneshot_res : oneshot_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_oneshot_res v encoder] encodes [v] with the given [encoder] *)

val encode_pb_get_decl_req : get_decl_req -> Pbrt.Encoder.t -> unit
(** [encode_pb_get_decl_req v encoder] encodes [v] with the given [encoder] *)

val encode_pb_decl_with_name : decl_with_name -> Pbrt.Encoder.t -> unit
(** [encode_pb_decl_with_name v encoder] encodes [v] with the given [encoder] *)

val encode_pb_get_decl_res : get_decl_res -> Pbrt.Encoder.t -> unit
(** [encode_pb_get_decl_res v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_session_create_req : Pbrt.Decoder.t -> session_create_req
(** [decode_pb_session_create_req decoder] decodes a [session_create_req] binary value from [decoder] *)

val decode_pb_lift_bool : Pbrt.Decoder.t -> lift_bool
(** [decode_pb_lift_bool decoder] decodes a [lift_bool] binary value from [decoder] *)

val decode_pb_decompose_req : Pbrt.Decoder.t -> decompose_req
(** [decode_pb_decompose_req decoder] decodes a [decompose_req] binary value from [decoder] *)

val decode_pb_decompose_req_full_by_name : Pbrt.Decoder.t -> decompose_req_full_by_name
(** [decode_pb_decompose_req_full_by_name decoder] decodes a [decompose_req_full_by_name] binary value from [decoder] *)

val decode_pb_decompose_req_full_local_var_get : Pbrt.Decoder.t -> decompose_req_full_local_var_get
(** [decode_pb_decompose_req_full_local_var_get decoder] decodes a [decompose_req_full_local_var_get] binary value from [decoder] *)

val decode_pb_decompose_req_full_prune : Pbrt.Decoder.t -> decompose_req_full_prune
(** [decode_pb_decompose_req_full_prune decoder] decodes a [decompose_req_full_prune] binary value from [decoder] *)

val decode_pb_decompose_req_full_decomp : Pbrt.Decoder.t -> decompose_req_full_decomp
(** [decode_pb_decompose_req_full_decomp decoder] decodes a [decompose_req_full_decomp] binary value from [decoder] *)

val decode_pb_decompose_req_full_merge : Pbrt.Decoder.t -> decompose_req_full_merge
(** [decode_pb_decompose_req_full_merge decoder] decodes a [decompose_req_full_merge] binary value from [decoder] *)

val decode_pb_decompose_req_full_compound_merge : Pbrt.Decoder.t -> decompose_req_full_compound_merge
(** [decode_pb_decompose_req_full_compound_merge decoder] decodes a [decompose_req_full_compound_merge] binary value from [decoder] *)

val decode_pb_decompose_req_full_combine : Pbrt.Decoder.t -> decompose_req_full_combine
(** [decode_pb_decompose_req_full_combine decoder] decodes a [decompose_req_full_combine] binary value from [decoder] *)

val decode_pb_decompose_req_full_local_var_let : Pbrt.Decoder.t -> decompose_req_full_local_var_let
(** [decode_pb_decompose_req_full_local_var_let decoder] decodes a [decompose_req_full_local_var_let] binary value from [decoder] *)

val decode_pb_decompose_req_full_local_var_binding : Pbrt.Decoder.t -> decompose_req_full_local_var_binding
(** [decode_pb_decompose_req_full_local_var_binding decoder] decodes a [decompose_req_full_local_var_binding] binary value from [decoder] *)

val decode_pb_decompose_req_full : Pbrt.Decoder.t -> decompose_req_full
(** [decode_pb_decompose_req_full decoder] decodes a [decompose_req_full] binary value from [decoder] *)

val decode_pb_decompose_res_res : Pbrt.Decoder.t -> decompose_res_res
(** [decode_pb_decompose_res_res decoder] decodes a [decompose_res_res] binary value from [decoder] *)

val decode_pb_decompose_res : Pbrt.Decoder.t -> decompose_res
(** [decode_pb_decompose_res decoder] decodes a [decompose_res] binary value from [decoder] *)

val decode_pb_eval_src_req : Pbrt.Decoder.t -> eval_src_req
(** [decode_pb_eval_src_req decoder] decodes a [eval_src_req] binary value from [decoder] *)

val decode_pb_eval_output : Pbrt.Decoder.t -> eval_output
(** [decode_pb_eval_output decoder] decodes a [eval_output] binary value from [decoder] *)

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

val decode_pb_po_res_res : Pbrt.Decoder.t -> po_res_res
(** [decode_pb_po_res_res decoder] decodes a [po_res_res] binary value from [decoder] *)

val decode_pb_po_res : Pbrt.Decoder.t -> po_res
(** [decode_pb_po_res decoder] decodes a [po_res] binary value from [decoder] *)

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

val decode_pb_oneshot_req : Pbrt.Decoder.t -> oneshot_req
(** [decode_pb_oneshot_req decoder] decodes a [oneshot_req] binary value from [decoder] *)

val decode_pb_oneshot_res_stats : Pbrt.Decoder.t -> oneshot_res_stats
(** [decode_pb_oneshot_res_stats decoder] decodes a [oneshot_res_stats] binary value from [decoder] *)

val decode_pb_oneshot_res : Pbrt.Decoder.t -> oneshot_res
(** [decode_pb_oneshot_res decoder] decodes a [oneshot_res] binary value from [decoder] *)

val decode_pb_get_decl_req : Pbrt.Decoder.t -> get_decl_req
(** [decode_pb_get_decl_req decoder] decodes a [get_decl_req] binary value from [decoder] *)

val decode_pb_decl_with_name : Pbrt.Decoder.t -> decl_with_name
(** [decode_pb_decl_with_name decoder] decodes a [decl_with_name] binary value from [decoder] *)

val decode_pb_get_decl_res : Pbrt.Decoder.t -> get_decl_res
(** [decode_pb_get_decl_res decoder] decodes a [get_decl_res] binary value from [decoder] *)


(** {2 Protobuf YoJson Encoding} *)

val encode_json_session_create_req : session_create_req -> Yojson.Basic.t
(** [encode_json_session_create_req v encoder] encodes [v] to to json *)

val encode_json_lift_bool : lift_bool -> Yojson.Basic.t
(** [encode_json_lift_bool v encoder] encodes [v] to to json *)

val encode_json_decompose_req : decompose_req -> Yojson.Basic.t
(** [encode_json_decompose_req v encoder] encodes [v] to to json *)

val encode_json_decompose_req_full_by_name : decompose_req_full_by_name -> Yojson.Basic.t
(** [encode_json_decompose_req_full_by_name v encoder] encodes [v] to to json *)

val encode_json_decompose_req_full_local_var_get : decompose_req_full_local_var_get -> Yojson.Basic.t
(** [encode_json_decompose_req_full_local_var_get v encoder] encodes [v] to to json *)

val encode_json_decompose_req_full_prune : decompose_req_full_prune -> Yojson.Basic.t
(** [encode_json_decompose_req_full_prune v encoder] encodes [v] to to json *)

val encode_json_decompose_req_full_decomp : decompose_req_full_decomp -> Yojson.Basic.t
(** [encode_json_decompose_req_full_decomp v encoder] encodes [v] to to json *)

val encode_json_decompose_req_full_merge : decompose_req_full_merge -> Yojson.Basic.t
(** [encode_json_decompose_req_full_merge v encoder] encodes [v] to to json *)

val encode_json_decompose_req_full_compound_merge : decompose_req_full_compound_merge -> Yojson.Basic.t
(** [encode_json_decompose_req_full_compound_merge v encoder] encodes [v] to to json *)

val encode_json_decompose_req_full_combine : decompose_req_full_combine -> Yojson.Basic.t
(** [encode_json_decompose_req_full_combine v encoder] encodes [v] to to json *)

val encode_json_decompose_req_full_local_var_let : decompose_req_full_local_var_let -> Yojson.Basic.t
(** [encode_json_decompose_req_full_local_var_let v encoder] encodes [v] to to json *)

val encode_json_decompose_req_full_local_var_binding : decompose_req_full_local_var_binding -> Yojson.Basic.t
(** [encode_json_decompose_req_full_local_var_binding v encoder] encodes [v] to to json *)

val encode_json_decompose_req_full : decompose_req_full -> Yojson.Basic.t
(** [encode_json_decompose_req_full v encoder] encodes [v] to to json *)

val encode_json_decompose_res_res : decompose_res_res -> Yojson.Basic.t
(** [encode_json_decompose_res_res v encoder] encodes [v] to to json *)

val encode_json_decompose_res : decompose_res -> Yojson.Basic.t
(** [encode_json_decompose_res v encoder] encodes [v] to to json *)

val encode_json_eval_src_req : eval_src_req -> Yojson.Basic.t
(** [encode_json_eval_src_req v encoder] encodes [v] to to json *)

val encode_json_eval_output : eval_output -> Yojson.Basic.t
(** [encode_json_eval_output v encoder] encodes [v] to to json *)

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

val encode_json_po_res_res : po_res_res -> Yojson.Basic.t
(** [encode_json_po_res_res v encoder] encodes [v] to to json *)

val encode_json_po_res : po_res -> Yojson.Basic.t
(** [encode_json_po_res v encoder] encodes [v] to to json *)

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

val encode_json_oneshot_req : oneshot_req -> Yojson.Basic.t
(** [encode_json_oneshot_req v encoder] encodes [v] to to json *)

val encode_json_oneshot_res_stats : oneshot_res_stats -> Yojson.Basic.t
(** [encode_json_oneshot_res_stats v encoder] encodes [v] to to json *)

val encode_json_oneshot_res : oneshot_res -> Yojson.Basic.t
(** [encode_json_oneshot_res v encoder] encodes [v] to to json *)

val encode_json_get_decl_req : get_decl_req -> Yojson.Basic.t
(** [encode_json_get_decl_req v encoder] encodes [v] to to json *)

val encode_json_decl_with_name : decl_with_name -> Yojson.Basic.t
(** [encode_json_decl_with_name v encoder] encodes [v] to to json *)

val encode_json_get_decl_res : get_decl_res -> Yojson.Basic.t
(** [encode_json_get_decl_res v encoder] encodes [v] to to json *)


(** {2 JSON Decoding} *)

val decode_json_session_create_req : Yojson.Basic.t -> session_create_req
(** [decode_json_session_create_req decoder] decodes a [session_create_req] value from [decoder] *)

val decode_json_lift_bool : Yojson.Basic.t -> lift_bool
(** [decode_json_lift_bool decoder] decodes a [lift_bool] value from [decoder] *)

val decode_json_decompose_req : Yojson.Basic.t -> decompose_req
(** [decode_json_decompose_req decoder] decodes a [decompose_req] value from [decoder] *)

val decode_json_decompose_req_full_by_name : Yojson.Basic.t -> decompose_req_full_by_name
(** [decode_json_decompose_req_full_by_name decoder] decodes a [decompose_req_full_by_name] value from [decoder] *)

val decode_json_decompose_req_full_local_var_get : Yojson.Basic.t -> decompose_req_full_local_var_get
(** [decode_json_decompose_req_full_local_var_get decoder] decodes a [decompose_req_full_local_var_get] value from [decoder] *)

val decode_json_decompose_req_full_prune : Yojson.Basic.t -> decompose_req_full_prune
(** [decode_json_decompose_req_full_prune decoder] decodes a [decompose_req_full_prune] value from [decoder] *)

val decode_json_decompose_req_full_decomp : Yojson.Basic.t -> decompose_req_full_decomp
(** [decode_json_decompose_req_full_decomp decoder] decodes a [decompose_req_full_decomp] value from [decoder] *)

val decode_json_decompose_req_full_merge : Yojson.Basic.t -> decompose_req_full_merge
(** [decode_json_decompose_req_full_merge decoder] decodes a [decompose_req_full_merge] value from [decoder] *)

val decode_json_decompose_req_full_compound_merge : Yojson.Basic.t -> decompose_req_full_compound_merge
(** [decode_json_decompose_req_full_compound_merge decoder] decodes a [decompose_req_full_compound_merge] value from [decoder] *)

val decode_json_decompose_req_full_combine : Yojson.Basic.t -> decompose_req_full_combine
(** [decode_json_decompose_req_full_combine decoder] decodes a [decompose_req_full_combine] value from [decoder] *)

val decode_json_decompose_req_full_local_var_let : Yojson.Basic.t -> decompose_req_full_local_var_let
(** [decode_json_decompose_req_full_local_var_let decoder] decodes a [decompose_req_full_local_var_let] value from [decoder] *)

val decode_json_decompose_req_full_local_var_binding : Yojson.Basic.t -> decompose_req_full_local_var_binding
(** [decode_json_decompose_req_full_local_var_binding decoder] decodes a [decompose_req_full_local_var_binding] value from [decoder] *)

val decode_json_decompose_req_full : Yojson.Basic.t -> decompose_req_full
(** [decode_json_decompose_req_full decoder] decodes a [decompose_req_full] value from [decoder] *)

val decode_json_decompose_res_res : Yojson.Basic.t -> decompose_res_res
(** [decode_json_decompose_res_res decoder] decodes a [decompose_res_res] value from [decoder] *)

val decode_json_decompose_res : Yojson.Basic.t -> decompose_res
(** [decode_json_decompose_res decoder] decodes a [decompose_res] value from [decoder] *)

val decode_json_eval_src_req : Yojson.Basic.t -> eval_src_req
(** [decode_json_eval_src_req decoder] decodes a [eval_src_req] value from [decoder] *)

val decode_json_eval_output : Yojson.Basic.t -> eval_output
(** [decode_json_eval_output decoder] decodes a [eval_output] value from [decoder] *)

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

val decode_json_po_res_res : Yojson.Basic.t -> po_res_res
(** [decode_json_po_res_res decoder] decodes a [po_res_res] value from [decoder] *)

val decode_json_po_res : Yojson.Basic.t -> po_res
(** [decode_json_po_res decoder] decodes a [po_res] value from [decoder] *)

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

val decode_json_oneshot_req : Yojson.Basic.t -> oneshot_req
(** [decode_json_oneshot_req decoder] decodes a [oneshot_req] value from [decoder] *)

val decode_json_oneshot_res_stats : Yojson.Basic.t -> oneshot_res_stats
(** [decode_json_oneshot_res_stats decoder] decodes a [oneshot_res_stats] value from [decoder] *)

val decode_json_oneshot_res : Yojson.Basic.t -> oneshot_res
(** [decode_json_oneshot_res decoder] decodes a [oneshot_res] value from [decoder] *)

val decode_json_get_decl_req : Yojson.Basic.t -> get_decl_req
(** [decode_json_get_decl_req decoder] decodes a [get_decl_req] value from [decoder] *)

val decode_json_decl_with_name : Yojson.Basic.t -> decl_with_name
(** [decode_json_decl_with_name decoder] decodes a [decl_with_name] value from [decoder] *)

val decode_json_get_decl_res : Yojson.Basic.t -> get_decl_res
(** [decode_json_get_decl_res decoder] decodes a [get_decl_res] value from [decoder] *)


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
    
    val decompose_full : (decompose_req_full, unary, decompose_res, unary) Client.rpc
    
    val typecheck : (typecheck_req, unary, typecheck_res, unary) Client.rpc
    
    val get_decl : (get_decl_req, unary, get_decl_res, unary) Client.rpc
    
    val oneshot : (oneshot_req, unary, oneshot_res, unary) Client.rpc
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
      decompose_full:((decompose_req_full, unary, decompose_res, unary) Server.rpc -> 'handler) ->
      typecheck:((typecheck_req, unary, typecheck_res, unary) Server.rpc -> 'handler) ->
      get_decl:((get_decl_req, unary, get_decl_res, unary) Server.rpc -> 'handler) ->
      oneshot:((oneshot_req, unary, oneshot_res, unary) Server.rpc -> 'handler) ->
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
    
    val decompose_full : (decompose_req_full,unary,decompose_res,unary) Server.rpc
    
    val typecheck : (typecheck_req,unary,typecheck_res,unary) Server.rpc
    
    val get_decl : (get_decl_req,unary,get_decl_res,unary) Server.rpc
    
    val oneshot : (oneshot_req,unary,oneshot_res,unary) Server.rpc
  end
end
