[@@@ocaml.warning "-27-30-39-44"]

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

type decompose_req_full_by_name = {
  name : string;
  assuming : string option;
  basis : string list;
  rule_specs : string list;
  prune : bool;
  ctx_simp : bool option;
  lift_bool : lift_bool option;
}

type decompose_req_full_local_var_get = {
  name : string;
}

type decompose_req_full_prune = {
  d : decompose_req_full_decomp option;
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

and decompose_req_full_merge = {
  d1 : decompose_req_full_decomp option;
  d2 : decompose_req_full_decomp option;
}

and decompose_req_full_compound_merge = {
  d1 : decompose_req_full_decomp option;
  d2 : decompose_req_full_decomp option;
}

and decompose_req_full_combine = {
  d : decompose_req_full_decomp option;
}

and decompose_req_full_local_var_let = {
  bindings : decompose_req_full_local_var_binding list;
  and_then : decompose_req_full_decomp option;
}

and decompose_req_full_local_var_binding = {
  name : string;
  d : decompose_req_full_decomp option;
}

type decompose_req_full = {
  session : Session.session option;
  decomp : decompose_req_full_decomp option;
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
  async_only : bool option;
}

type eval_output = {
  success : bool;
  value_as_ocaml : string option;
  errors : Error.error list;
}

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

type po_res_res =
  | Unknown of Utils.string_msg
  | Err
  | Proof of proved
  | Instance of counter_sat
  | Verified_upto of verified_upto

and po_res = {
  res : po_res_res;
  errors : Error.error list;
  task : Task.task option;
  origin : Task.origin option;
}

type eval_res = {
  success : bool;
  messages : string list;
  errors : Error.error list;
  tasks : Task.task list;
  po_results : po_res list;
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

type oneshot_req = {
  input : string;
  timeout : float option;
}

type oneshot_res_stats = {
  time : float;
}

type oneshot_res = {
  results : string list;
  errors : string list;
  stats : oneshot_res_stats option;
  detailed_results : string list;
}

let rec default_session_create_req 
  ?api_version:((api_version:string) = "")
  () : session_create_req  = {
  api_version;
}

let rec default_lift_bool () = (Default:lift_bool)

let rec default_decompose_req 
  ?session:((session:Session.session option) = None)
  ?name:((name:string) = "")
  ?assuming:((assuming:string option) = None)
  ?basis:((basis:string list) = [])
  ?rule_specs:((rule_specs:string list) = [])
  ?prune:((prune:bool) = false)
  ?ctx_simp:((ctx_simp:bool option) = None)
  ?lift_bool:((lift_bool:lift_bool option) = None)
  ?str:((str:bool option) = None)
  ?timeout:((timeout:int32 option) = None)
  () : decompose_req  = {
  session;
  name;
  assuming;
  basis;
  rule_specs;
  prune;
  ctx_simp;
  lift_bool;
  str;
  timeout;
}

let rec default_decompose_req_full_by_name 
  ?name:((name:string) = "")
  ?assuming:((assuming:string option) = None)
  ?basis:((basis:string list) = [])
  ?rule_specs:((rule_specs:string list) = [])
  ?prune:((prune:bool) = false)
  ?ctx_simp:((ctx_simp:bool option) = None)
  ?lift_bool:((lift_bool:lift_bool option) = None)
  () : decompose_req_full_by_name  = {
  name;
  assuming;
  basis;
  rule_specs;
  prune;
  ctx_simp;
  lift_bool;
}

let rec default_decompose_req_full_local_var_get 
  ?name:((name:string) = "")
  () : decompose_req_full_local_var_get  = {
  name;
}

let rec default_decompose_req_full_prune 
  ?d:((d:decompose_req_full_decomp option) = None)
  () : decompose_req_full_prune  = {
  d;
}

and default_decompose_req_full_decomp () : decompose_req_full_decomp = From_artifact (Artmsg.default_art ())

and default_decompose_req_full_merge 
  ?d1:((d1:decompose_req_full_decomp option) = None)
  ?d2:((d2:decompose_req_full_decomp option) = None)
  () : decompose_req_full_merge  = {
  d1;
  d2;
}

and default_decompose_req_full_compound_merge 
  ?d1:((d1:decompose_req_full_decomp option) = None)
  ?d2:((d2:decompose_req_full_decomp option) = None)
  () : decompose_req_full_compound_merge  = {
  d1;
  d2;
}

and default_decompose_req_full_combine 
  ?d:((d:decompose_req_full_decomp option) = None)
  () : decompose_req_full_combine  = {
  d;
}

and default_decompose_req_full_local_var_let 
  ?bindings:((bindings:decompose_req_full_local_var_binding list) = [])
  ?and_then:((and_then:decompose_req_full_decomp option) = None)
  () : decompose_req_full_local_var_let  = {
  bindings;
  and_then;
}

and default_decompose_req_full_local_var_binding 
  ?name:((name:string) = "")
  ?d:((d:decompose_req_full_decomp option) = None)
  () : decompose_req_full_local_var_binding  = {
  name;
  d;
}

let rec default_decompose_req_full 
  ?session:((session:Session.session option) = None)
  ?decomp:((decomp:decompose_req_full_decomp option) = None)
  ?str:((str:bool option) = None)
  ?timeout:((timeout:int32 option) = None)
  () : decompose_req_full  = {
  session;
  decomp;
  str;
  timeout;
}

let rec default_decompose_res_res () : decompose_res_res = Artifact (Artmsg.default_art ())

and default_decompose_res 
  ?res:((res:decompose_res_res) = Artifact (Artmsg.default_art ()))
  ?errors:((errors:Error.error list) = [])
  ?task:((task:Task.task option) = None)
  () : decompose_res  = {
  res;
  errors;
  task;
}

let rec default_eval_src_req 
  ?session:((session:Session.session option) = None)
  ?src:((src:string) = "")
  ?async_only:((async_only:bool option) = None)
  () : eval_src_req  = {
  session;
  src;
  async_only;
}

let rec default_eval_output 
  ?success:((success:bool) = false)
  ?value_as_ocaml:((value_as_ocaml:string option) = None)
  ?errors:((errors:Error.error list) = [])
  () : eval_output  = {
  success;
  value_as_ocaml;
  errors;
}

let rec default_proved 
  ?proof_pp:((proof_pp:string option) = None)
  () : proved  = {
  proof_pp;
}

let rec default_model_type () = (Counter_example:model_type)

let rec default_model 
  ?m_type:((m_type:model_type) = default_model_type ())
  ?src:((src:string) = "")
  ?artifact:((artifact:Artmsg.art option) = None)
  () : model  = {
  m_type;
  src;
  artifact;
}

let rec default_counter_sat 
  ?model:((model:model option) = None)
  () : counter_sat  = {
  model;
}

let rec default_verified_upto 
  ?msg:((msg:string option) = None)
  () : verified_upto  = {
  msg;
}

let rec default_po_res_res () : po_res_res = Unknown (Utils.default_string_msg ())

and default_po_res 
  ?res:((res:po_res_res) = Unknown (Utils.default_string_msg ()))
  ?errors:((errors:Error.error list) = [])
  ?task:((task:Task.task option) = None)
  ?origin:((origin:Task.origin option) = None)
  () : po_res  = {
  res;
  errors;
  task;
  origin;
}

let rec default_eval_res 
  ?success:((success:bool) = false)
  ?messages:((messages:string list) = [])
  ?errors:((errors:Error.error list) = [])
  ?tasks:((tasks:Task.task list) = [])
  ?po_results:((po_results:po_res list) = [])
  ?eval_results:((eval_results:eval_output list) = [])
  ?decomp_results:((decomp_results:decompose_res list) = [])
  () : eval_res  = {
  success;
  messages;
  errors;
  tasks;
  po_results;
  eval_results;
  decomp_results;
}

let rec default_verify_src_req 
  ?session:((session:Session.session option) = None)
  ?src:((src:string) = "")
  ?hints:((hints:string option) = None)
  () : verify_src_req  = {
  session;
  src;
  hints;
}

let rec default_verify_name_req 
  ?session:((session:Session.session option) = None)
  ?name:((name:string) = "")
  ?hints:((hints:string option) = None)
  () : verify_name_req  = {
  session;
  name;
  hints;
}

let rec default_instance_src_req 
  ?session:((session:Session.session option) = None)
  ?src:((src:string) = "")
  ?hints:((hints:string option) = None)
  () : instance_src_req  = {
  session;
  src;
  hints;
}

let rec default_instance_name_req 
  ?session:((session:Session.session option) = None)
  ?name:((name:string) = "")
  ?hints:((hints:string option) = None)
  () : instance_name_req  = {
  session;
  name;
  hints;
}

let rec default_unsat 
  ?proof_pp:((proof_pp:string option) = None)
  () : unsat  = {
  proof_pp;
}

let rec default_refuted 
  ?model:((model:model option) = None)
  () : refuted  = {
  model;
}

let rec default_sat 
  ?model:((model:model option) = None)
  () : sat  = {
  model;
}

let rec default_verify_res_res () : verify_res_res = Unknown (Utils.default_string_msg ())

and default_verify_res 
  ?res:((res:verify_res_res) = Unknown (Utils.default_string_msg ()))
  ?errors:((errors:Error.error list) = [])
  ?task:((task:Task.task option) = None)
  () : verify_res  = {
  res;
  errors;
  task;
}

let rec default_instance_res_res () : instance_res_res = Unknown (Utils.default_string_msg ())

and default_instance_res 
  ?res:((res:instance_res_res) = Unknown (Utils.default_string_msg ()))
  ?errors:((errors:Error.error list) = [])
  ?task:((task:Task.task option) = None)
  () : instance_res  = {
  res;
  errors;
  task;
}

let rec default_typecheck_req 
  ?session:((session:Session.session option) = None)
  ?src:((src:string) = "")
  () : typecheck_req  = {
  session;
  src;
}

let rec default_typecheck_res 
  ?success:((success:bool) = false)
  ?types:((types:string) = "")
  ?errors:((errors:Error.error list) = [])
  () : typecheck_res  = {
  success;
  types;
  errors;
}

let rec default_oneshot_req 
  ?input:((input:string) = "")
  ?timeout:((timeout:float option) = None)
  () : oneshot_req  = {
  input;
  timeout;
}

let rec default_oneshot_res_stats 
  ?time:((time:float) = 0.)
  () : oneshot_res_stats  = {
  time;
}

let rec default_oneshot_res 
  ?results:((results:string list) = [])
  ?errors:((errors:string list) = [])
  ?stats:((stats:oneshot_res_stats option) = None)
  ?detailed_results:((detailed_results:string list) = [])
  () : oneshot_res  = {
  results;
  errors;
  stats;
  detailed_results;
}

type session_create_req_mutable = {
  mutable api_version : string;
}

let default_session_create_req_mutable () : session_create_req_mutable = {
  api_version = "";
}

type decompose_req_mutable = {
  mutable session : Session.session option;
  mutable name : string;
  mutable assuming : string option;
  mutable basis : string list;
  mutable rule_specs : string list;
  mutable prune : bool;
  mutable ctx_simp : bool option;
  mutable lift_bool : lift_bool option;
  mutable str : bool option;
  mutable timeout : int32 option;
}

let default_decompose_req_mutable () : decompose_req_mutable = {
  session = None;
  name = "";
  assuming = None;
  basis = [];
  rule_specs = [];
  prune = false;
  ctx_simp = None;
  lift_bool = None;
  str = None;
  timeout = None;
}

type decompose_req_full_by_name_mutable = {
  mutable name : string;
  mutable assuming : string option;
  mutable basis : string list;
  mutable rule_specs : string list;
  mutable prune : bool;
  mutable ctx_simp : bool option;
  mutable lift_bool : lift_bool option;
}

let default_decompose_req_full_by_name_mutable () : decompose_req_full_by_name_mutable = {
  name = "";
  assuming = None;
  basis = [];
  rule_specs = [];
  prune = false;
  ctx_simp = None;
  lift_bool = None;
}

type decompose_req_full_local_var_get_mutable = {
  mutable name : string;
}

let default_decompose_req_full_local_var_get_mutable () : decompose_req_full_local_var_get_mutable = {
  name = "";
}

type decompose_req_full_prune_mutable = {
  mutable d : decompose_req_full_decomp option;
}

let default_decompose_req_full_prune_mutable () : decompose_req_full_prune_mutable = {
  d = None;
}

type decompose_req_full_merge_mutable = {
  mutable d1 : decompose_req_full_decomp option;
  mutable d2 : decompose_req_full_decomp option;
}

let default_decompose_req_full_merge_mutable () : decompose_req_full_merge_mutable = {
  d1 = None;
  d2 = None;
}

type decompose_req_full_compound_merge_mutable = {
  mutable d1 : decompose_req_full_decomp option;
  mutable d2 : decompose_req_full_decomp option;
}

let default_decompose_req_full_compound_merge_mutable () : decompose_req_full_compound_merge_mutable = {
  d1 = None;
  d2 = None;
}

type decompose_req_full_combine_mutable = {
  mutable d : decompose_req_full_decomp option;
}

let default_decompose_req_full_combine_mutable () : decompose_req_full_combine_mutable = {
  d = None;
}

type decompose_req_full_local_var_let_mutable = {
  mutable bindings : decompose_req_full_local_var_binding list;
  mutable and_then : decompose_req_full_decomp option;
}

let default_decompose_req_full_local_var_let_mutable () : decompose_req_full_local_var_let_mutable = {
  bindings = [];
  and_then = None;
}

type decompose_req_full_local_var_binding_mutable = {
  mutable name : string;
  mutable d : decompose_req_full_decomp option;
}

let default_decompose_req_full_local_var_binding_mutable () : decompose_req_full_local_var_binding_mutable = {
  name = "";
  d = None;
}

type decompose_req_full_mutable = {
  mutable session : Session.session option;
  mutable decomp : decompose_req_full_decomp option;
  mutable str : bool option;
  mutable timeout : int32 option;
}

let default_decompose_req_full_mutable () : decompose_req_full_mutable = {
  session = None;
  decomp = None;
  str = None;
  timeout = None;
}

type decompose_res_mutable = {
  mutable res : decompose_res_res;
  mutable errors : Error.error list;
  mutable task : Task.task option;
}

let default_decompose_res_mutable () : decompose_res_mutable = {
  res = Artifact (Artmsg.default_art ());
  errors = [];
  task = None;
}

type eval_src_req_mutable = {
  mutable session : Session.session option;
  mutable src : string;
  mutable async_only : bool option;
}

let default_eval_src_req_mutable () : eval_src_req_mutable = {
  session = None;
  src = "";
  async_only = None;
}

type eval_output_mutable = {
  mutable success : bool;
  mutable value_as_ocaml : string option;
  mutable errors : Error.error list;
}

let default_eval_output_mutable () : eval_output_mutable = {
  success = false;
  value_as_ocaml = None;
  errors = [];
}

type proved_mutable = {
  mutable proof_pp : string option;
}

let default_proved_mutable () : proved_mutable = {
  proof_pp = None;
}

type model_mutable = {
  mutable m_type : model_type;
  mutable src : string;
  mutable artifact : Artmsg.art option;
}

let default_model_mutable () : model_mutable = {
  m_type = default_model_type ();
  src = "";
  artifact = None;
}

type counter_sat_mutable = {
  mutable model : model option;
}

let default_counter_sat_mutable () : counter_sat_mutable = {
  model = None;
}

type verified_upto_mutable = {
  mutable msg : string option;
}

let default_verified_upto_mutable () : verified_upto_mutable = {
  msg = None;
}

type po_res_mutable = {
  mutable res : po_res_res;
  mutable errors : Error.error list;
  mutable task : Task.task option;
  mutable origin : Task.origin option;
}

let default_po_res_mutable () : po_res_mutable = {
  res = Unknown (Utils.default_string_msg ());
  errors = [];
  task = None;
  origin = None;
}

type eval_res_mutable = {
  mutable success : bool;
  mutable messages : string list;
  mutable errors : Error.error list;
  mutable tasks : Task.task list;
  mutable po_results : po_res list;
  mutable eval_results : eval_output list;
  mutable decomp_results : decompose_res list;
}

let default_eval_res_mutable () : eval_res_mutable = {
  success = false;
  messages = [];
  errors = [];
  tasks = [];
  po_results = [];
  eval_results = [];
  decomp_results = [];
}

type verify_src_req_mutable = {
  mutable session : Session.session option;
  mutable src : string;
  mutable hints : string option;
}

let default_verify_src_req_mutable () : verify_src_req_mutable = {
  session = None;
  src = "";
  hints = None;
}

type verify_name_req_mutable = {
  mutable session : Session.session option;
  mutable name : string;
  mutable hints : string option;
}

let default_verify_name_req_mutable () : verify_name_req_mutable = {
  session = None;
  name = "";
  hints = None;
}

type instance_src_req_mutable = {
  mutable session : Session.session option;
  mutable src : string;
  mutable hints : string option;
}

let default_instance_src_req_mutable () : instance_src_req_mutable = {
  session = None;
  src = "";
  hints = None;
}

type instance_name_req_mutable = {
  mutable session : Session.session option;
  mutable name : string;
  mutable hints : string option;
}

let default_instance_name_req_mutable () : instance_name_req_mutable = {
  session = None;
  name = "";
  hints = None;
}

type unsat_mutable = {
  mutable proof_pp : string option;
}

let default_unsat_mutable () : unsat_mutable = {
  proof_pp = None;
}

type refuted_mutable = {
  mutable model : model option;
}

let default_refuted_mutable () : refuted_mutable = {
  model = None;
}

type sat_mutable = {
  mutable model : model option;
}

let default_sat_mutable () : sat_mutable = {
  model = None;
}

type verify_res_mutable = {
  mutable res : verify_res_res;
  mutable errors : Error.error list;
  mutable task : Task.task option;
}

let default_verify_res_mutable () : verify_res_mutable = {
  res = Unknown (Utils.default_string_msg ());
  errors = [];
  task = None;
}

type instance_res_mutable = {
  mutable res : instance_res_res;
  mutable errors : Error.error list;
  mutable task : Task.task option;
}

let default_instance_res_mutable () : instance_res_mutable = {
  res = Unknown (Utils.default_string_msg ());
  errors = [];
  task = None;
}

type typecheck_req_mutable = {
  mutable session : Session.session option;
  mutable src : string;
}

let default_typecheck_req_mutable () : typecheck_req_mutable = {
  session = None;
  src = "";
}

type typecheck_res_mutable = {
  mutable success : bool;
  mutable types : string;
  mutable errors : Error.error list;
}

let default_typecheck_res_mutable () : typecheck_res_mutable = {
  success = false;
  types = "";
  errors = [];
}

type oneshot_req_mutable = {
  mutable input : string;
  mutable timeout : float option;
}

let default_oneshot_req_mutable () : oneshot_req_mutable = {
  input = "";
  timeout = None;
}

type oneshot_res_stats_mutable = {
  mutable time : float;
}

let default_oneshot_res_stats_mutable () : oneshot_res_stats_mutable = {
  time = 0.;
}

type oneshot_res_mutable = {
  mutable results : string list;
  mutable errors : string list;
  mutable stats : oneshot_res_stats option;
  mutable detailed_results : string list;
}

let default_oneshot_res_mutable () : oneshot_res_mutable = {
  results = [];
  errors = [];
  stats = None;
  detailed_results = [];
}


(** {2 Make functions} *)

let rec make_session_create_req 
  ~(api_version:string)
  () : session_create_req  = {
  api_version;
}


let rec make_decompose_req 
  ?session:((session:Session.session option) = None)
  ~(name:string)
  ?assuming:((assuming:string option) = None)
  ~(basis:string list)
  ~(rule_specs:string list)
  ~(prune:bool)
  ?ctx_simp:((ctx_simp:bool option) = None)
  ?lift_bool:((lift_bool:lift_bool option) = None)
  ?str:((str:bool option) = None)
  ?timeout:((timeout:int32 option) = None)
  () : decompose_req  = {
  session;
  name;
  assuming;
  basis;
  rule_specs;
  prune;
  ctx_simp;
  lift_bool;
  str;
  timeout;
}

let rec make_decompose_req_full_by_name 
  ~(name:string)
  ?assuming:((assuming:string option) = None)
  ~(basis:string list)
  ~(rule_specs:string list)
  ~(prune:bool)
  ?ctx_simp:((ctx_simp:bool option) = None)
  ?lift_bool:((lift_bool:lift_bool option) = None)
  () : decompose_req_full_by_name  = {
  name;
  assuming;
  basis;
  rule_specs;
  prune;
  ctx_simp;
  lift_bool;
}

let rec make_decompose_req_full_local_var_get 
  ~(name:string)
  () : decompose_req_full_local_var_get  = {
  name;
}

let rec make_decompose_req_full_prune 
  ?d:((d:decompose_req_full_decomp option) = None)
  () : decompose_req_full_prune  = {
  d;
}


and make_decompose_req_full_merge 
  ?d1:((d1:decompose_req_full_decomp option) = None)
  ?d2:((d2:decompose_req_full_decomp option) = None)
  () : decompose_req_full_merge  = {
  d1;
  d2;
}

and make_decompose_req_full_compound_merge 
  ?d1:((d1:decompose_req_full_decomp option) = None)
  ?d2:((d2:decompose_req_full_decomp option) = None)
  () : decompose_req_full_compound_merge  = {
  d1;
  d2;
}

and make_decompose_req_full_combine 
  ?d:((d:decompose_req_full_decomp option) = None)
  () : decompose_req_full_combine  = {
  d;
}

and make_decompose_req_full_local_var_let 
  ~(bindings:decompose_req_full_local_var_binding list)
  ?and_then:((and_then:decompose_req_full_decomp option) = None)
  () : decompose_req_full_local_var_let  = {
  bindings;
  and_then;
}

and make_decompose_req_full_local_var_binding 
  ~(name:string)
  ?d:((d:decompose_req_full_decomp option) = None)
  () : decompose_req_full_local_var_binding  = {
  name;
  d;
}

let rec make_decompose_req_full 
  ?session:((session:Session.session option) = None)
  ?decomp:((decomp:decompose_req_full_decomp option) = None)
  ?str:((str:bool option) = None)
  ?timeout:((timeout:int32 option) = None)
  () : decompose_req_full  = {
  session;
  decomp;
  str;
  timeout;
}


let rec make_decompose_res 
  ~(res:decompose_res_res)
  ~(errors:Error.error list)
  ?task:((task:Task.task option) = None)
  () : decompose_res  = {
  res;
  errors;
  task;
}

let rec make_eval_src_req 
  ?session:((session:Session.session option) = None)
  ~(src:string)
  ?async_only:((async_only:bool option) = None)
  () : eval_src_req  = {
  session;
  src;
  async_only;
}

let rec make_eval_output 
  ~(success:bool)
  ?value_as_ocaml:((value_as_ocaml:string option) = None)
  ~(errors:Error.error list)
  () : eval_output  = {
  success;
  value_as_ocaml;
  errors;
}

let rec make_proved 
  ?proof_pp:((proof_pp:string option) = None)
  () : proved  = {
  proof_pp;
}


let rec make_model 
  ~(m_type:model_type)
  ~(src:string)
  ?artifact:((artifact:Artmsg.art option) = None)
  () : model  = {
  m_type;
  src;
  artifact;
}

let rec make_counter_sat 
  ?model:((model:model option) = None)
  () : counter_sat  = {
  model;
}

let rec make_verified_upto 
  ?msg:((msg:string option) = None)
  () : verified_upto  = {
  msg;
}


let rec make_po_res 
  ~(res:po_res_res)
  ~(errors:Error.error list)
  ?task:((task:Task.task option) = None)
  ?origin:((origin:Task.origin option) = None)
  () : po_res  = {
  res;
  errors;
  task;
  origin;
}

let rec make_eval_res 
  ~(success:bool)
  ~(messages:string list)
  ~(errors:Error.error list)
  ~(tasks:Task.task list)
  ~(po_results:po_res list)
  ~(eval_results:eval_output list)
  ~(decomp_results:decompose_res list)
  () : eval_res  = {
  success;
  messages;
  errors;
  tasks;
  po_results;
  eval_results;
  decomp_results;
}

let rec make_verify_src_req 
  ?session:((session:Session.session option) = None)
  ~(src:string)
  ?hints:((hints:string option) = None)
  () : verify_src_req  = {
  session;
  src;
  hints;
}

let rec make_verify_name_req 
  ?session:((session:Session.session option) = None)
  ~(name:string)
  ?hints:((hints:string option) = None)
  () : verify_name_req  = {
  session;
  name;
  hints;
}

let rec make_instance_src_req 
  ?session:((session:Session.session option) = None)
  ~(src:string)
  ?hints:((hints:string option) = None)
  () : instance_src_req  = {
  session;
  src;
  hints;
}

let rec make_instance_name_req 
  ?session:((session:Session.session option) = None)
  ~(name:string)
  ?hints:((hints:string option) = None)
  () : instance_name_req  = {
  session;
  name;
  hints;
}

let rec make_unsat 
  ?proof_pp:((proof_pp:string option) = None)
  () : unsat  = {
  proof_pp;
}

let rec make_refuted 
  ?model:((model:model option) = None)
  () : refuted  = {
  model;
}

let rec make_sat 
  ?model:((model:model option) = None)
  () : sat  = {
  model;
}


let rec make_verify_res 
  ~(res:verify_res_res)
  ~(errors:Error.error list)
  ?task:((task:Task.task option) = None)
  () : verify_res  = {
  res;
  errors;
  task;
}


let rec make_instance_res 
  ~(res:instance_res_res)
  ~(errors:Error.error list)
  ?task:((task:Task.task option) = None)
  () : instance_res  = {
  res;
  errors;
  task;
}

let rec make_typecheck_req 
  ?session:((session:Session.session option) = None)
  ~(src:string)
  () : typecheck_req  = {
  session;
  src;
}

let rec make_typecheck_res 
  ~(success:bool)
  ~(types:string)
  ~(errors:Error.error list)
  () : typecheck_res  = {
  success;
  types;
  errors;
}

let rec make_oneshot_req 
  ~(input:string)
  ?timeout:((timeout:float option) = None)
  () : oneshot_req  = {
  input;
  timeout;
}

let rec make_oneshot_res_stats 
  ~(time:float)
  () : oneshot_res_stats  = {
  time;
}

let rec make_oneshot_res 
  ~(results:string list)
  ~(errors:string list)
  ?stats:((stats:oneshot_res_stats option) = None)
  ~(detailed_results:string list)
  () : oneshot_res  = {
  results;
  errors;
  stats;
  detailed_results;
}

[@@@ocaml.warning "-27-30-39"]

(** {2 Formatters} *)

let rec pp_session_create_req fmt (v:session_create_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "api_version" Pbrt.Pp.pp_string fmt v.api_version;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_lift_bool fmt (v:lift_bool) =
  match v with
  | Default -> Format.fprintf fmt "Default"
  | Nested_equalities -> Format.fprintf fmt "Nested_equalities"
  | Equalities -> Format.fprintf fmt "Equalities"
  | All -> Format.fprintf fmt "All"

let rec pp_decompose_req fmt (v:decompose_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~first:false "name" Pbrt.Pp.pp_string fmt v.name;
    Pbrt.Pp.pp_record_field ~first:false "assuming" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.assuming;
    Pbrt.Pp.pp_record_field ~first:false "basis" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.basis;
    Pbrt.Pp.pp_record_field ~first:false "rule_specs" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.rule_specs;
    Pbrt.Pp.pp_record_field ~first:false "prune" Pbrt.Pp.pp_bool fmt v.prune;
    Pbrt.Pp.pp_record_field ~first:false "ctx_simp" (Pbrt.Pp.pp_option Pbrt.Pp.pp_bool) fmt v.ctx_simp;
    Pbrt.Pp.pp_record_field ~first:false "lift_bool" (Pbrt.Pp.pp_option pp_lift_bool) fmt v.lift_bool;
    Pbrt.Pp.pp_record_field ~first:false "str" (Pbrt.Pp.pp_option Pbrt.Pp.pp_bool) fmt v.str;
    Pbrt.Pp.pp_record_field ~first:false "timeout" (Pbrt.Pp.pp_option Pbrt.Pp.pp_int32) fmt v.timeout;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_decompose_req_full_by_name fmt (v:decompose_req_full_by_name) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "name" Pbrt.Pp.pp_string fmt v.name;
    Pbrt.Pp.pp_record_field ~first:false "assuming" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.assuming;
    Pbrt.Pp.pp_record_field ~first:false "basis" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.basis;
    Pbrt.Pp.pp_record_field ~first:false "rule_specs" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.rule_specs;
    Pbrt.Pp.pp_record_field ~first:false "prune" Pbrt.Pp.pp_bool fmt v.prune;
    Pbrt.Pp.pp_record_field ~first:false "ctx_simp" (Pbrt.Pp.pp_option Pbrt.Pp.pp_bool) fmt v.ctx_simp;
    Pbrt.Pp.pp_record_field ~first:false "lift_bool" (Pbrt.Pp.pp_option pp_lift_bool) fmt v.lift_bool;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_decompose_req_full_local_var_get fmt (v:decompose_req_full_local_var_get) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "name" Pbrt.Pp.pp_string fmt v.name;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_decompose_req_full_prune fmt (v:decompose_req_full_prune) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "d" (Pbrt.Pp.pp_option pp_decompose_req_full_decomp) fmt v.d;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

and pp_decompose_req_full_decomp fmt (v:decompose_req_full_decomp) =
  match v with
  | From_artifact x -> Format.fprintf fmt "@[<hv2>From_artifact(@,%a)@]" Artmsg.pp_art x
  | By_name x -> Format.fprintf fmt "@[<hv2>By_name(@,%a)@]" pp_decompose_req_full_by_name x
  | Merge x -> Format.fprintf fmt "@[<hv2>Merge(@,%a)@]" pp_decompose_req_full_merge x
  | Compound_merge x -> Format.fprintf fmt "@[<hv2>Compound_merge(@,%a)@]" pp_decompose_req_full_compound_merge x
  | Prune x -> Format.fprintf fmt "@[<hv2>Prune(@,%a)@]" pp_decompose_req_full_prune x
  | Combine x -> Format.fprintf fmt "@[<hv2>Combine(@,%a)@]" pp_decompose_req_full_combine x
  | Get x -> Format.fprintf fmt "@[<hv2>Get(@,%a)@]" pp_decompose_req_full_local_var_get x
  | Set x -> Format.fprintf fmt "@[<hv2>Set(@,%a)@]" pp_decompose_req_full_local_var_let x

and pp_decompose_req_full_merge fmt (v:decompose_req_full_merge) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "d1" (Pbrt.Pp.pp_option pp_decompose_req_full_decomp) fmt v.d1;
    Pbrt.Pp.pp_record_field ~first:false "d2" (Pbrt.Pp.pp_option pp_decompose_req_full_decomp) fmt v.d2;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

and pp_decompose_req_full_compound_merge fmt (v:decompose_req_full_compound_merge) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "d1" (Pbrt.Pp.pp_option pp_decompose_req_full_decomp) fmt v.d1;
    Pbrt.Pp.pp_record_field ~first:false "d2" (Pbrt.Pp.pp_option pp_decompose_req_full_decomp) fmt v.d2;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

and pp_decompose_req_full_combine fmt (v:decompose_req_full_combine) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "d" (Pbrt.Pp.pp_option pp_decompose_req_full_decomp) fmt v.d;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

and pp_decompose_req_full_local_var_let fmt (v:decompose_req_full_local_var_let) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "bindings" (Pbrt.Pp.pp_list pp_decompose_req_full_local_var_binding) fmt v.bindings;
    Pbrt.Pp.pp_record_field ~first:false "and_then" (Pbrt.Pp.pp_option pp_decompose_req_full_decomp) fmt v.and_then;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

and pp_decompose_req_full_local_var_binding fmt (v:decompose_req_full_local_var_binding) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "name" Pbrt.Pp.pp_string fmt v.name;
    Pbrt.Pp.pp_record_field ~first:false "d" (Pbrt.Pp.pp_option pp_decompose_req_full_decomp) fmt v.d;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_decompose_req_full fmt (v:decompose_req_full) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~first:false "decomp" (Pbrt.Pp.pp_option pp_decompose_req_full_decomp) fmt v.decomp;
    Pbrt.Pp.pp_record_field ~first:false "str" (Pbrt.Pp.pp_option Pbrt.Pp.pp_bool) fmt v.str;
    Pbrt.Pp.pp_record_field ~first:false "timeout" (Pbrt.Pp.pp_option Pbrt.Pp.pp_int32) fmt v.timeout;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_decompose_res_res fmt (v:decompose_res_res) =
  match v with
  | Artifact x -> Format.fprintf fmt "@[<hv2>Artifact(@,%a)@]" Artmsg.pp_art x
  | Err  -> Format.fprintf fmt "Err"

and pp_decompose_res fmt (v:decompose_res) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "res" pp_decompose_res_res fmt v.res;
    Pbrt.Pp.pp_record_field ~first:false "errors" (Pbrt.Pp.pp_list Error.pp_error) fmt v.errors;
    Pbrt.Pp.pp_record_field ~first:false "task" (Pbrt.Pp.pp_option Task.pp_task) fmt v.task;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_eval_src_req fmt (v:eval_src_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~first:false "src" Pbrt.Pp.pp_string fmt v.src;
    Pbrt.Pp.pp_record_field ~first:false "async_only" (Pbrt.Pp.pp_option Pbrt.Pp.pp_bool) fmt v.async_only;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_eval_output fmt (v:eval_output) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "success" Pbrt.Pp.pp_bool fmt v.success;
    Pbrt.Pp.pp_record_field ~first:false "value_as_ocaml" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.value_as_ocaml;
    Pbrt.Pp.pp_record_field ~first:false "errors" (Pbrt.Pp.pp_list Error.pp_error) fmt v.errors;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_proved fmt (v:proved) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "proof_pp" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.proof_pp;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_model_type fmt (v:model_type) =
  match v with
  | Counter_example -> Format.fprintf fmt "Counter_example"
  | Instance -> Format.fprintf fmt "Instance"

let rec pp_model fmt (v:model) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "m_type" pp_model_type fmt v.m_type;
    Pbrt.Pp.pp_record_field ~first:false "src" Pbrt.Pp.pp_string fmt v.src;
    Pbrt.Pp.pp_record_field ~first:false "artifact" (Pbrt.Pp.pp_option Artmsg.pp_art) fmt v.artifact;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_counter_sat fmt (v:counter_sat) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "model" (Pbrt.Pp.pp_option pp_model) fmt v.model;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_verified_upto fmt (v:verified_upto) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "msg" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.msg;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_po_res_res fmt (v:po_res_res) =
  match v with
  | Unknown x -> Format.fprintf fmt "@[<hv2>Unknown(@,%a)@]" Utils.pp_string_msg x
  | Err  -> Format.fprintf fmt "Err"
  | Proof x -> Format.fprintf fmt "@[<hv2>Proof(@,%a)@]" pp_proved x
  | Instance x -> Format.fprintf fmt "@[<hv2>Instance(@,%a)@]" pp_counter_sat x
  | Verified_upto x -> Format.fprintf fmt "@[<hv2>Verified_upto(@,%a)@]" pp_verified_upto x

and pp_po_res fmt (v:po_res) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "res" pp_po_res_res fmt v.res;
    Pbrt.Pp.pp_record_field ~first:false "errors" (Pbrt.Pp.pp_list Error.pp_error) fmt v.errors;
    Pbrt.Pp.pp_record_field ~first:false "task" (Pbrt.Pp.pp_option Task.pp_task) fmt v.task;
    Pbrt.Pp.pp_record_field ~first:false "origin" (Pbrt.Pp.pp_option Task.pp_origin) fmt v.origin;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_eval_res fmt (v:eval_res) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "success" Pbrt.Pp.pp_bool fmt v.success;
    Pbrt.Pp.pp_record_field ~first:false "messages" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.messages;
    Pbrt.Pp.pp_record_field ~first:false "errors" (Pbrt.Pp.pp_list Error.pp_error) fmt v.errors;
    Pbrt.Pp.pp_record_field ~first:false "tasks" (Pbrt.Pp.pp_list Task.pp_task) fmt v.tasks;
    Pbrt.Pp.pp_record_field ~first:false "po_results" (Pbrt.Pp.pp_list pp_po_res) fmt v.po_results;
    Pbrt.Pp.pp_record_field ~first:false "eval_results" (Pbrt.Pp.pp_list pp_eval_output) fmt v.eval_results;
    Pbrt.Pp.pp_record_field ~first:false "decomp_results" (Pbrt.Pp.pp_list pp_decompose_res) fmt v.decomp_results;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_verify_src_req fmt (v:verify_src_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~first:false "src" Pbrt.Pp.pp_string fmt v.src;
    Pbrt.Pp.pp_record_field ~first:false "hints" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.hints;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_verify_name_req fmt (v:verify_name_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~first:false "name" Pbrt.Pp.pp_string fmt v.name;
    Pbrt.Pp.pp_record_field ~first:false "hints" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.hints;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_instance_src_req fmt (v:instance_src_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~first:false "src" Pbrt.Pp.pp_string fmt v.src;
    Pbrt.Pp.pp_record_field ~first:false "hints" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.hints;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_instance_name_req fmt (v:instance_name_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~first:false "name" Pbrt.Pp.pp_string fmt v.name;
    Pbrt.Pp.pp_record_field ~first:false "hints" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.hints;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_unsat fmt (v:unsat) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "proof_pp" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.proof_pp;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_refuted fmt (v:refuted) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "model" (Pbrt.Pp.pp_option pp_model) fmt v.model;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_sat fmt (v:sat) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "model" (Pbrt.Pp.pp_option pp_model) fmt v.model;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_verify_res_res fmt (v:verify_res_res) =
  match v with
  | Unknown x -> Format.fprintf fmt "@[<hv2>Unknown(@,%a)@]" Utils.pp_string_msg x
  | Err  -> Format.fprintf fmt "Err"
  | Proved x -> Format.fprintf fmt "@[<hv2>Proved(@,%a)@]" pp_proved x
  | Refuted x -> Format.fprintf fmt "@[<hv2>Refuted(@,%a)@]" pp_refuted x
  | Verified_upto x -> Format.fprintf fmt "@[<hv2>Verified_upto(@,%a)@]" pp_verified_upto x

and pp_verify_res fmt (v:verify_res) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "res" pp_verify_res_res fmt v.res;
    Pbrt.Pp.pp_record_field ~first:false "errors" (Pbrt.Pp.pp_list Error.pp_error) fmt v.errors;
    Pbrt.Pp.pp_record_field ~first:false "task" (Pbrt.Pp.pp_option Task.pp_task) fmt v.task;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_instance_res_res fmt (v:instance_res_res) =
  match v with
  | Unknown x -> Format.fprintf fmt "@[<hv2>Unknown(@,%a)@]" Utils.pp_string_msg x
  | Err  -> Format.fprintf fmt "Err"
  | Unsat x -> Format.fprintf fmt "@[<hv2>Unsat(@,%a)@]" pp_unsat x
  | Sat x -> Format.fprintf fmt "@[<hv2>Sat(@,%a)@]" pp_sat x

and pp_instance_res fmt (v:instance_res) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "res" pp_instance_res_res fmt v.res;
    Pbrt.Pp.pp_record_field ~first:false "errors" (Pbrt.Pp.pp_list Error.pp_error) fmt v.errors;
    Pbrt.Pp.pp_record_field ~first:false "task" (Pbrt.Pp.pp_option Task.pp_task) fmt v.task;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_typecheck_req fmt (v:typecheck_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~first:false "src" Pbrt.Pp.pp_string fmt v.src;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_typecheck_res fmt (v:typecheck_res) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "success" Pbrt.Pp.pp_bool fmt v.success;
    Pbrt.Pp.pp_record_field ~first:false "types" Pbrt.Pp.pp_string fmt v.types;
    Pbrt.Pp.pp_record_field ~first:false "errors" (Pbrt.Pp.pp_list Error.pp_error) fmt v.errors;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_oneshot_req fmt (v:oneshot_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "input" Pbrt.Pp.pp_string fmt v.input;
    Pbrt.Pp.pp_record_field ~first:false "timeout" (Pbrt.Pp.pp_option Pbrt.Pp.pp_float) fmt v.timeout;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_oneshot_res_stats fmt (v:oneshot_res_stats) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "time" Pbrt.Pp.pp_float fmt v.time;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_oneshot_res fmt (v:oneshot_res) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "results" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.results;
    Pbrt.Pp.pp_record_field ~first:false "errors" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.errors;
    Pbrt.Pp.pp_record_field ~first:false "stats" (Pbrt.Pp.pp_option pp_oneshot_res_stats) fmt v.stats;
    Pbrt.Pp.pp_record_field ~first:false "detailed_results" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.detailed_results;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_session_create_req (v:session_create_req) encoder = 
  Pbrt.Encoder.string v.api_version encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ()

let rec encode_pb_lift_bool (v:lift_bool) encoder =
  match v with
  | Default -> Pbrt.Encoder.int_as_varint (0) encoder
  | Nested_equalities -> Pbrt.Encoder.int_as_varint 1 encoder
  | Equalities -> Pbrt.Encoder.int_as_varint 2 encoder
  | All -> Pbrt.Encoder.int_as_varint 3 encoder

let rec encode_pb_decompose_req (v:decompose_req) encoder = 
  begin match v.session with
  | Some x -> 
    Pbrt.Encoder.nested Session.encode_pb_session x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  Pbrt.Encoder.string v.name encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  begin match v.assuming with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  ) v.basis encoder;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 5 Pbrt.Bytes encoder; 
  ) v.rule_specs encoder;
  Pbrt.Encoder.bool v.prune encoder;
  Pbrt.Encoder.key 6 Pbrt.Varint encoder; 
  begin match v.ctx_simp with
  | Some x -> 
    Pbrt.Encoder.bool x encoder;
    Pbrt.Encoder.key 7 Pbrt.Varint encoder; 
  | None -> ();
  end;
  begin match v.lift_bool with
  | Some x -> 
    encode_pb_lift_bool x encoder;
    Pbrt.Encoder.key 8 Pbrt.Varint encoder; 
  | None -> ();
  end;
  begin match v.str with
  | Some x -> 
    Pbrt.Encoder.bool x encoder;
    Pbrt.Encoder.key 9 Pbrt.Varint encoder; 
  | None -> ();
  end;
  begin match v.timeout with
  | Some x -> 
    Pbrt.Encoder.int32_as_varint x encoder;
    Pbrt.Encoder.key 10 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_decompose_req_full_by_name (v:decompose_req_full_by_name) encoder = 
  Pbrt.Encoder.string v.name encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  begin match v.assuming with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  ) v.basis encoder;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 5 Pbrt.Bytes encoder; 
  ) v.rule_specs encoder;
  Pbrt.Encoder.bool v.prune encoder;
  Pbrt.Encoder.key 6 Pbrt.Varint encoder; 
  begin match v.ctx_simp with
  | Some x -> 
    Pbrt.Encoder.bool x encoder;
    Pbrt.Encoder.key 7 Pbrt.Varint encoder; 
  | None -> ();
  end;
  begin match v.lift_bool with
  | Some x -> 
    encode_pb_lift_bool x encoder;
    Pbrt.Encoder.key 8 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_decompose_req_full_local_var_get (v:decompose_req_full_local_var_get) encoder = 
  Pbrt.Encoder.string v.name encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ()

let rec encode_pb_decompose_req_full_prune (v:decompose_req_full_prune) encoder = 
  begin match v.d with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_decompose_req_full_decomp x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

and encode_pb_decompose_req_full_decomp (v:decompose_req_full_decomp) encoder = 
  begin match v with
  | From_artifact x ->
    Pbrt.Encoder.nested Artmsg.encode_pb_art x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | By_name x ->
    Pbrt.Encoder.nested encode_pb_decompose_req_full_by_name x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | Merge x ->
    Pbrt.Encoder.nested encode_pb_decompose_req_full_merge x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | Compound_merge x ->
    Pbrt.Encoder.nested encode_pb_decompose_req_full_compound_merge x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  | Prune x ->
    Pbrt.Encoder.nested encode_pb_decompose_req_full_prune x encoder;
    Pbrt.Encoder.key 5 Pbrt.Bytes encoder; 
  | Combine x ->
    Pbrt.Encoder.nested encode_pb_decompose_req_full_combine x encoder;
    Pbrt.Encoder.key 6 Pbrt.Bytes encoder; 
  | Get x ->
    Pbrt.Encoder.nested encode_pb_decompose_req_full_local_var_get x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  | Set x ->
    Pbrt.Encoder.nested encode_pb_decompose_req_full_local_var_let x encoder;
    Pbrt.Encoder.key 11 Pbrt.Bytes encoder; 
  end

and encode_pb_decompose_req_full_merge (v:decompose_req_full_merge) encoder = 
  begin match v.d1 with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_decompose_req_full_decomp x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  begin match v.d2 with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_decompose_req_full_decomp x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

and encode_pb_decompose_req_full_compound_merge (v:decompose_req_full_compound_merge) encoder = 
  begin match v.d1 with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_decompose_req_full_decomp x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  begin match v.d2 with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_decompose_req_full_decomp x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

and encode_pb_decompose_req_full_combine (v:decompose_req_full_combine) encoder = 
  begin match v.d with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_decompose_req_full_decomp x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

and encode_pb_decompose_req_full_local_var_let (v:decompose_req_full_local_var_let) encoder = 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested encode_pb_decompose_req_full_local_var_binding x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ) v.bindings encoder;
  begin match v.and_then with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_decompose_req_full_decomp x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

and encode_pb_decompose_req_full_local_var_binding (v:decompose_req_full_local_var_binding) encoder = 
  Pbrt.Encoder.string v.name encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  begin match v.d with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_decompose_req_full_decomp x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_decompose_req_full (v:decompose_req_full) encoder = 
  begin match v.session with
  | Some x -> 
    Pbrt.Encoder.nested Session.encode_pb_session x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  begin match v.decomp with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_decompose_req_full_decomp x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  begin match v.str with
  | Some x -> 
    Pbrt.Encoder.bool x encoder;
    Pbrt.Encoder.key 9 Pbrt.Varint encoder; 
  | None -> ();
  end;
  begin match v.timeout with
  | Some x -> 
    Pbrt.Encoder.int32_as_varint x encoder;
    Pbrt.Encoder.key 10 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_decompose_res_res (v:decompose_res_res) encoder = 
  begin match v with
  | Artifact x ->
    Pbrt.Encoder.nested Artmsg.encode_pb_art x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | Err ->
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
    Pbrt.Encoder.empty_nested encoder
  end

and encode_pb_decompose_res (v:decompose_res) encoder = 
  begin match v.res with
  | Artifact x ->
    Pbrt.Encoder.nested Artmsg.encode_pb_art x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | Err ->
    Pbrt.Encoder.empty_nested encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  end;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested Error.encode_pb_error x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  ) v.errors encoder;
  begin match v.task with
  | Some x -> 
    Pbrt.Encoder.nested Task.encode_pb_task x encoder;
    Pbrt.Encoder.key 11 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_eval_src_req (v:eval_src_req) encoder = 
  begin match v.session with
  | Some x -> 
    Pbrt.Encoder.nested Session.encode_pb_session x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  Pbrt.Encoder.string v.src encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  begin match v.async_only with
  | Some x -> 
    Pbrt.Encoder.bool x encoder;
    Pbrt.Encoder.key 3 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_eval_output (v:eval_output) encoder = 
  Pbrt.Encoder.bool v.success encoder;
  Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  begin match v.value_as_ocaml with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested Error.encode_pb_error x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  ) v.errors encoder;
  ()

let rec encode_pb_proved (v:proved) encoder = 
  begin match v.proof_pp with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_model_type (v:model_type) encoder =
  match v with
  | Counter_example -> Pbrt.Encoder.int_as_varint (0) encoder
  | Instance -> Pbrt.Encoder.int_as_varint 1 encoder

let rec encode_pb_model (v:model) encoder = 
  encode_pb_model_type v.m_type encoder;
  Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  Pbrt.Encoder.string v.src encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  begin match v.artifact with
  | Some x -> 
    Pbrt.Encoder.nested Artmsg.encode_pb_art x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_counter_sat (v:counter_sat) encoder = 
  begin match v.model with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_model x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_verified_upto (v:verified_upto) encoder = 
  begin match v.msg with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_po_res_res (v:po_res_res) encoder = 
  begin match v with
  | Unknown x ->
    Pbrt.Encoder.nested Utils.encode_pb_string_msg x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | Err ->
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
    Pbrt.Encoder.empty_nested encoder
  | Proof x ->
    Pbrt.Encoder.nested encode_pb_proved x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | Instance x ->
    Pbrt.Encoder.nested encode_pb_counter_sat x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  | Verified_upto x ->
    Pbrt.Encoder.nested encode_pb_verified_upto x encoder;
    Pbrt.Encoder.key 5 Pbrt.Bytes encoder; 
  end

and encode_pb_po_res (v:po_res) encoder = 
  begin match v.res with
  | Unknown x ->
    Pbrt.Encoder.nested Utils.encode_pb_string_msg x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | Err ->
    Pbrt.Encoder.empty_nested encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | Proof x ->
    Pbrt.Encoder.nested encode_pb_proved x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | Instance x ->
    Pbrt.Encoder.nested encode_pb_counter_sat x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  | Verified_upto x ->
    Pbrt.Encoder.nested encode_pb_verified_upto x encoder;
    Pbrt.Encoder.key 5 Pbrt.Bytes encoder; 
  end;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested Error.encode_pb_error x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  ) v.errors encoder;
  begin match v.task with
  | Some x -> 
    Pbrt.Encoder.nested Task.encode_pb_task x encoder;
    Pbrt.Encoder.key 11 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  begin match v.origin with
  | Some x -> 
    Pbrt.Encoder.nested Task.encode_pb_origin x encoder;
    Pbrt.Encoder.key 12 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_eval_res (v:eval_res) encoder = 
  Pbrt.Encoder.bool v.success encoder;
  Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  ) v.messages encoder;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested Error.encode_pb_error x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  ) v.errors encoder;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested Task.encode_pb_task x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  ) v.tasks encoder;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested encode_pb_po_res x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  ) v.po_results encoder;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested encode_pb_eval_output x encoder;
    Pbrt.Encoder.key 11 Pbrt.Bytes encoder; 
  ) v.eval_results encoder;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested encode_pb_decompose_res x encoder;
    Pbrt.Encoder.key 12 Pbrt.Bytes encoder; 
  ) v.decomp_results encoder;
  ()

let rec encode_pb_verify_src_req (v:verify_src_req) encoder = 
  begin match v.session with
  | Some x -> 
    Pbrt.Encoder.nested Session.encode_pb_session x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  Pbrt.Encoder.string v.src encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  begin match v.hints with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_verify_name_req (v:verify_name_req) encoder = 
  begin match v.session with
  | Some x -> 
    Pbrt.Encoder.nested Session.encode_pb_session x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  Pbrt.Encoder.string v.name encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  begin match v.hints with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_instance_src_req (v:instance_src_req) encoder = 
  begin match v.session with
  | Some x -> 
    Pbrt.Encoder.nested Session.encode_pb_session x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  Pbrt.Encoder.string v.src encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  begin match v.hints with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_instance_name_req (v:instance_name_req) encoder = 
  begin match v.session with
  | Some x -> 
    Pbrt.Encoder.nested Session.encode_pb_session x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  Pbrt.Encoder.string v.name encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  begin match v.hints with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_unsat (v:unsat) encoder = 
  begin match v.proof_pp with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_refuted (v:refuted) encoder = 
  begin match v.model with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_model x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_sat (v:sat) encoder = 
  begin match v.model with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_model x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_verify_res_res (v:verify_res_res) encoder = 
  begin match v with
  | Unknown x ->
    Pbrt.Encoder.nested Utils.encode_pb_string_msg x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | Err ->
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
    Pbrt.Encoder.empty_nested encoder
  | Proved x ->
    Pbrt.Encoder.nested encode_pb_proved x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | Refuted x ->
    Pbrt.Encoder.nested encode_pb_refuted x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  | Verified_upto x ->
    Pbrt.Encoder.nested encode_pb_verified_upto x encoder;
    Pbrt.Encoder.key 5 Pbrt.Bytes encoder; 
  end

and encode_pb_verify_res (v:verify_res) encoder = 
  begin match v.res with
  | Unknown x ->
    Pbrt.Encoder.nested Utils.encode_pb_string_msg x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | Err ->
    Pbrt.Encoder.empty_nested encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | Proved x ->
    Pbrt.Encoder.nested encode_pb_proved x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | Refuted x ->
    Pbrt.Encoder.nested encode_pb_refuted x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  | Verified_upto x ->
    Pbrt.Encoder.nested encode_pb_verified_upto x encoder;
    Pbrt.Encoder.key 5 Pbrt.Bytes encoder; 
  end;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested Error.encode_pb_error x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  ) v.errors encoder;
  begin match v.task with
  | Some x -> 
    Pbrt.Encoder.nested Task.encode_pb_task x encoder;
    Pbrt.Encoder.key 11 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_instance_res_res (v:instance_res_res) encoder = 
  begin match v with
  | Unknown x ->
    Pbrt.Encoder.nested Utils.encode_pb_string_msg x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | Err ->
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
    Pbrt.Encoder.empty_nested encoder
  | Unsat x ->
    Pbrt.Encoder.nested encode_pb_unsat x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | Sat x ->
    Pbrt.Encoder.nested encode_pb_sat x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  end

and encode_pb_instance_res (v:instance_res) encoder = 
  begin match v.res with
  | Unknown x ->
    Pbrt.Encoder.nested Utils.encode_pb_string_msg x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | Err ->
    Pbrt.Encoder.empty_nested encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | Unsat x ->
    Pbrt.Encoder.nested encode_pb_unsat x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | Sat x ->
    Pbrt.Encoder.nested encode_pb_sat x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  end;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested Error.encode_pb_error x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  ) v.errors encoder;
  begin match v.task with
  | Some x -> 
    Pbrt.Encoder.nested Task.encode_pb_task x encoder;
    Pbrt.Encoder.key 11 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_typecheck_req (v:typecheck_req) encoder = 
  begin match v.session with
  | Some x -> 
    Pbrt.Encoder.nested Session.encode_pb_session x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  Pbrt.Encoder.string v.src encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  ()

let rec encode_pb_typecheck_res (v:typecheck_res) encoder = 
  Pbrt.Encoder.bool v.success encoder;
  Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  Pbrt.Encoder.string v.types encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested Error.encode_pb_error x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  ) v.errors encoder;
  ()

let rec encode_pb_oneshot_req (v:oneshot_req) encoder = 
  Pbrt.Encoder.string v.input encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  begin match v.timeout with
  | Some x -> 
    Pbrt.Encoder.float_as_bits64 x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bits64 encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_oneshot_res_stats (v:oneshot_res_stats) encoder = 
  Pbrt.Encoder.float_as_bits64 v.time encoder;
  Pbrt.Encoder.key 1 Pbrt.Bits64 encoder; 
  ()

let rec encode_pb_oneshot_res (v:oneshot_res) encoder = 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ) v.results encoder;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  ) v.errors encoder;
  begin match v.stats with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_oneshot_res_stats x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  ) v.detailed_results encoder;
  ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_session_create_req d =
  let v = default_session_create_req_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.api_version <- Pbrt.Decoder.string d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(session_create_req), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    api_version = v.api_version;
  } : session_create_req)

let rec decode_pb_lift_bool d = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> (Default:lift_bool)
  | 1 -> (Nested_equalities:lift_bool)
  | 2 -> (Equalities:lift_bool)
  | 3 -> (All:lift_bool)
  | _ -> Pbrt.Decoder.malformed_variant "lift_bool"

let rec decode_pb_decompose_req d =
  let v = default_decompose_req_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.rule_specs <- List.rev v.rule_specs;
      v.basis <- List.rev v.basis;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.session <- Some (Session.decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.name <- Pbrt.Decoder.string d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.assuming <- Some (Pbrt.Decoder.string d);
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req), field(3)" pk
    | Some (4, Pbrt.Bytes) -> begin
      v.basis <- (Pbrt.Decoder.string d) :: v.basis;
    end
    | Some (4, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req), field(4)" pk
    | Some (5, Pbrt.Bytes) -> begin
      v.rule_specs <- (Pbrt.Decoder.string d) :: v.rule_specs;
    end
    | Some (5, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req), field(5)" pk
    | Some (6, Pbrt.Varint) -> begin
      v.prune <- Pbrt.Decoder.bool d;
    end
    | Some (6, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req), field(6)" pk
    | Some (7, Pbrt.Varint) -> begin
      v.ctx_simp <- Some (Pbrt.Decoder.bool d);
    end
    | Some (7, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req), field(7)" pk
    | Some (8, Pbrt.Varint) -> begin
      v.lift_bool <- Some (decode_pb_lift_bool d);
    end
    | Some (8, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req), field(8)" pk
    | Some (9, Pbrt.Varint) -> begin
      v.str <- Some (Pbrt.Decoder.bool d);
    end
    | Some (9, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req), field(9)" pk
    | Some (10, Pbrt.Varint) -> begin
      v.timeout <- Some (Pbrt.Decoder.int32_as_varint d);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req), field(10)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    session = v.session;
    name = v.name;
    assuming = v.assuming;
    basis = v.basis;
    rule_specs = v.rule_specs;
    prune = v.prune;
    ctx_simp = v.ctx_simp;
    lift_bool = v.lift_bool;
    str = v.str;
    timeout = v.timeout;
  } : decompose_req)

let rec decode_pb_decompose_req_full_by_name d =
  let v = default_decompose_req_full_by_name_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.rule_specs <- List.rev v.rule_specs;
      v.basis <- List.rev v.basis;
    ); continue__ := false
    | Some (2, Pbrt.Bytes) -> begin
      v.name <- Pbrt.Decoder.string d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_by_name), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.assuming <- Some (Pbrt.Decoder.string d);
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_by_name), field(3)" pk
    | Some (4, Pbrt.Bytes) -> begin
      v.basis <- (Pbrt.Decoder.string d) :: v.basis;
    end
    | Some (4, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_by_name), field(4)" pk
    | Some (5, Pbrt.Bytes) -> begin
      v.rule_specs <- (Pbrt.Decoder.string d) :: v.rule_specs;
    end
    | Some (5, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_by_name), field(5)" pk
    | Some (6, Pbrt.Varint) -> begin
      v.prune <- Pbrt.Decoder.bool d;
    end
    | Some (6, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_by_name), field(6)" pk
    | Some (7, Pbrt.Varint) -> begin
      v.ctx_simp <- Some (Pbrt.Decoder.bool d);
    end
    | Some (7, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_by_name), field(7)" pk
    | Some (8, Pbrt.Varint) -> begin
      v.lift_bool <- Some (decode_pb_lift_bool d);
    end
    | Some (8, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_by_name), field(8)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    name = v.name;
    assuming = v.assuming;
    basis = v.basis;
    rule_specs = v.rule_specs;
    prune = v.prune;
    ctx_simp = v.ctx_simp;
    lift_bool = v.lift_bool;
  } : decompose_req_full_by_name)

let rec decode_pb_decompose_req_full_local_var_get d =
  let v = default_decompose_req_full_local_var_get_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.name <- Pbrt.Decoder.string d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_local_var_get), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    name = v.name;
  } : decompose_req_full_local_var_get)

let rec decode_pb_decompose_req_full_prune d =
  let v = default_decompose_req_full_prune_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.d <- Some (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_prune), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    d = v.d;
  } : decompose_req_full_prune)

and decode_pb_decompose_req_full_decomp d = 
  let rec loop () = 
    let ret:decompose_req_full_decomp = match Pbrt.Decoder.key d with
      | None -> Pbrt.Decoder.malformed_variant "decompose_req_full_decomp"
      | Some (1, _) -> (From_artifact (Artmsg.decode_pb_art (Pbrt.Decoder.nested d)) : decompose_req_full_decomp) 
      | Some (2, _) -> (By_name (decode_pb_decompose_req_full_by_name (Pbrt.Decoder.nested d)) : decompose_req_full_decomp) 
      | Some (3, _) -> (Merge (decode_pb_decompose_req_full_merge (Pbrt.Decoder.nested d)) : decompose_req_full_decomp) 
      | Some (4, _) -> (Compound_merge (decode_pb_decompose_req_full_compound_merge (Pbrt.Decoder.nested d)) : decompose_req_full_decomp) 
      | Some (5, _) -> (Prune (decode_pb_decompose_req_full_prune (Pbrt.Decoder.nested d)) : decompose_req_full_decomp) 
      | Some (6, _) -> (Combine (decode_pb_decompose_req_full_combine (Pbrt.Decoder.nested d)) : decompose_req_full_decomp) 
      | Some (10, _) -> (Get (decode_pb_decompose_req_full_local_var_get (Pbrt.Decoder.nested d)) : decompose_req_full_decomp) 
      | Some (11, _) -> (Set (decode_pb_decompose_req_full_local_var_let (Pbrt.Decoder.nested d)) : decompose_req_full_decomp) 
      | Some (n, payload_kind) -> (
        Pbrt.Decoder.skip d payload_kind; 
        loop () 
      )
    in
    ret
  in
  loop ()

and decode_pb_decompose_req_full_merge d =
  let v = default_decompose_req_full_merge_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.d1 <- Some (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_merge), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.d2 <- Some (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_merge), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    d1 = v.d1;
    d2 = v.d2;
  } : decompose_req_full_merge)

and decode_pb_decompose_req_full_compound_merge d =
  let v = default_decompose_req_full_compound_merge_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.d1 <- Some (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_compound_merge), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.d2 <- Some (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_compound_merge), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    d1 = v.d1;
    d2 = v.d2;
  } : decompose_req_full_compound_merge)

and decode_pb_decompose_req_full_combine d =
  let v = default_decompose_req_full_combine_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.d <- Some (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_combine), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    d = v.d;
  } : decompose_req_full_combine)

and decode_pb_decompose_req_full_local_var_let d =
  let v = default_decompose_req_full_local_var_let_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.bindings <- List.rev v.bindings;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.bindings <- (decode_pb_decompose_req_full_local_var_binding (Pbrt.Decoder.nested d)) :: v.bindings;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_local_var_let), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.and_then <- Some (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_local_var_let), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    bindings = v.bindings;
    and_then = v.and_then;
  } : decompose_req_full_local_var_let)

and decode_pb_decompose_req_full_local_var_binding d =
  let v = default_decompose_req_full_local_var_binding_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.name <- Pbrt.Decoder.string d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_local_var_binding), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.d <- Some (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full_local_var_binding), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    name = v.name;
    d = v.d;
  } : decompose_req_full_local_var_binding)

let rec decode_pb_decompose_req_full d =
  let v = default_decompose_req_full_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.session <- Some (Session.decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.decomp <- Some (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full), field(2)" pk
    | Some (9, Pbrt.Varint) -> begin
      v.str <- Some (Pbrt.Decoder.bool d);
    end
    | Some (9, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full), field(9)" pk
    | Some (10, Pbrt.Varint) -> begin
      v.timeout <- Some (Pbrt.Decoder.int32_as_varint d);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_req_full), field(10)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    session = v.session;
    decomp = v.decomp;
    str = v.str;
    timeout = v.timeout;
  } : decompose_req_full)

let rec decode_pb_decompose_res_res d = 
  let rec loop () = 
    let ret:decompose_res_res = match Pbrt.Decoder.key d with
      | None -> Pbrt.Decoder.malformed_variant "decompose_res_res"
      | Some (1, _) -> (Artifact (Artmsg.decode_pb_art (Pbrt.Decoder.nested d)) : decompose_res_res) 
      | Some (2, _) -> begin 
        Pbrt.Decoder.empty_nested d ;
        (Err : decompose_res_res)
      end
      | Some (n, payload_kind) -> (
        Pbrt.Decoder.skip d payload_kind; 
        loop () 
      )
    in
    ret
  in
  loop ()

and decode_pb_decompose_res d =
  let v = default_decompose_res_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.errors <- List.rev v.errors;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.res <- Artifact (Artmsg.decode_pb_art (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_res), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      Pbrt.Decoder.empty_nested d;
      v.res <- Err;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_res), field(2)" pk
    | Some (10, Pbrt.Bytes) -> begin
      v.errors <- (Error.decode_pb_error (Pbrt.Decoder.nested d)) :: v.errors;
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_res), field(10)" pk
    | Some (11, Pbrt.Bytes) -> begin
      v.task <- Some (Task.decode_pb_task (Pbrt.Decoder.nested d));
    end
    | Some (11, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(decompose_res), field(11)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    res = v.res;
    errors = v.errors;
    task = v.task;
  } : decompose_res)

let rec decode_pb_eval_src_req d =
  let v = default_eval_src_req_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.session <- Some (Session.decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(eval_src_req), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.src <- Pbrt.Decoder.string d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(eval_src_req), field(2)" pk
    | Some (3, Pbrt.Varint) -> begin
      v.async_only <- Some (Pbrt.Decoder.bool d);
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(eval_src_req), field(3)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    session = v.session;
    src = v.src;
    async_only = v.async_only;
  } : eval_src_req)

let rec decode_pb_eval_output d =
  let v = default_eval_output_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.errors <- List.rev v.errors;
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.success <- Pbrt.Decoder.bool d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(eval_output), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.value_as_ocaml <- Some (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(eval_output), field(2)" pk
    | Some (10, Pbrt.Bytes) -> begin
      v.errors <- (Error.decode_pb_error (Pbrt.Decoder.nested d)) :: v.errors;
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(eval_output), field(10)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    success = v.success;
    value_as_ocaml = v.value_as_ocaml;
    errors = v.errors;
  } : eval_output)

let rec decode_pb_proved d =
  let v = default_proved_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.proof_pp <- Some (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(proved), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    proof_pp = v.proof_pp;
  } : proved)

let rec decode_pb_model_type d = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> (Counter_example:model_type)
  | 1 -> (Instance:model_type)
  | _ -> Pbrt.Decoder.malformed_variant "model_type"

let rec decode_pb_model d =
  let v = default_model_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.m_type <- decode_pb_model_type d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(model), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.src <- Pbrt.Decoder.string d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(model), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.artifact <- Some (Artmsg.decode_pb_art (Pbrt.Decoder.nested d));
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(model), field(3)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    m_type = v.m_type;
    src = v.src;
    artifact = v.artifact;
  } : model)

let rec decode_pb_counter_sat d =
  let v = default_counter_sat_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.model <- Some (decode_pb_model (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(counter_sat), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    model = v.model;
  } : counter_sat)

let rec decode_pb_verified_upto d =
  let v = default_verified_upto_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.msg <- Some (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(verified_upto), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    msg = v.msg;
  } : verified_upto)

let rec decode_pb_po_res_res d = 
  let rec loop () = 
    let ret:po_res_res = match Pbrt.Decoder.key d with
      | None -> Pbrt.Decoder.malformed_variant "po_res_res"
      | Some (1, _) -> (Unknown (Utils.decode_pb_string_msg (Pbrt.Decoder.nested d)) : po_res_res) 
      | Some (2, _) -> begin 
        Pbrt.Decoder.empty_nested d ;
        (Err : po_res_res)
      end
      | Some (3, _) -> (Proof (decode_pb_proved (Pbrt.Decoder.nested d)) : po_res_res) 
      | Some (4, _) -> (Instance (decode_pb_counter_sat (Pbrt.Decoder.nested d)) : po_res_res) 
      | Some (5, _) -> (Verified_upto (decode_pb_verified_upto (Pbrt.Decoder.nested d)) : po_res_res) 
      | Some (n, payload_kind) -> (
        Pbrt.Decoder.skip d payload_kind; 
        loop () 
      )
    in
    ret
  in
  loop ()

and decode_pb_po_res d =
  let v = default_po_res_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.errors <- List.rev v.errors;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.res <- Unknown (Utils.decode_pb_string_msg (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(po_res), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      Pbrt.Decoder.empty_nested d;
      v.res <- Err;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(po_res), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.res <- Proof (decode_pb_proved (Pbrt.Decoder.nested d));
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(po_res), field(3)" pk
    | Some (4, Pbrt.Bytes) -> begin
      v.res <- Instance (decode_pb_counter_sat (Pbrt.Decoder.nested d));
    end
    | Some (4, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(po_res), field(4)" pk
    | Some (5, Pbrt.Bytes) -> begin
      v.res <- Verified_upto (decode_pb_verified_upto (Pbrt.Decoder.nested d));
    end
    | Some (5, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(po_res), field(5)" pk
    | Some (10, Pbrt.Bytes) -> begin
      v.errors <- (Error.decode_pb_error (Pbrt.Decoder.nested d)) :: v.errors;
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(po_res), field(10)" pk
    | Some (11, Pbrt.Bytes) -> begin
      v.task <- Some (Task.decode_pb_task (Pbrt.Decoder.nested d));
    end
    | Some (11, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(po_res), field(11)" pk
    | Some (12, Pbrt.Bytes) -> begin
      v.origin <- Some (Task.decode_pb_origin (Pbrt.Decoder.nested d));
    end
    | Some (12, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(po_res), field(12)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    res = v.res;
    errors = v.errors;
    task = v.task;
    origin = v.origin;
  } : po_res)

let rec decode_pb_eval_res d =
  let v = default_eval_res_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.decomp_results <- List.rev v.decomp_results;
      v.eval_results <- List.rev v.eval_results;
      v.po_results <- List.rev v.po_results;
      v.tasks <- List.rev v.tasks;
      v.errors <- List.rev v.errors;
      v.messages <- List.rev v.messages;
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.success <- Pbrt.Decoder.bool d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(eval_res), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.messages <- (Pbrt.Decoder.string d) :: v.messages;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(eval_res), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.errors <- (Error.decode_pb_error (Pbrt.Decoder.nested d)) :: v.errors;
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(eval_res), field(3)" pk
    | Some (4, Pbrt.Bytes) -> begin
      v.tasks <- (Task.decode_pb_task (Pbrt.Decoder.nested d)) :: v.tasks;
    end
    | Some (4, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(eval_res), field(4)" pk
    | Some (10, Pbrt.Bytes) -> begin
      v.po_results <- (decode_pb_po_res (Pbrt.Decoder.nested d)) :: v.po_results;
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(eval_res), field(10)" pk
    | Some (11, Pbrt.Bytes) -> begin
      v.eval_results <- (decode_pb_eval_output (Pbrt.Decoder.nested d)) :: v.eval_results;
    end
    | Some (11, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(eval_res), field(11)" pk
    | Some (12, Pbrt.Bytes) -> begin
      v.decomp_results <- (decode_pb_decompose_res (Pbrt.Decoder.nested d)) :: v.decomp_results;
    end
    | Some (12, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(eval_res), field(12)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    success = v.success;
    messages = v.messages;
    errors = v.errors;
    tasks = v.tasks;
    po_results = v.po_results;
    eval_results = v.eval_results;
    decomp_results = v.decomp_results;
  } : eval_res)

let rec decode_pb_verify_src_req d =
  let v = default_verify_src_req_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.session <- Some (Session.decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(verify_src_req), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.src <- Pbrt.Decoder.string d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(verify_src_req), field(2)" pk
    | Some (10, Pbrt.Bytes) -> begin
      v.hints <- Some (Pbrt.Decoder.string d);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(verify_src_req), field(10)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    session = v.session;
    src = v.src;
    hints = v.hints;
  } : verify_src_req)

let rec decode_pb_verify_name_req d =
  let v = default_verify_name_req_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.session <- Some (Session.decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(verify_name_req), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.name <- Pbrt.Decoder.string d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(verify_name_req), field(2)" pk
    | Some (10, Pbrt.Bytes) -> begin
      v.hints <- Some (Pbrt.Decoder.string d);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(verify_name_req), field(10)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    session = v.session;
    name = v.name;
    hints = v.hints;
  } : verify_name_req)

let rec decode_pb_instance_src_req d =
  let v = default_instance_src_req_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.session <- Some (Session.decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(instance_src_req), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.src <- Pbrt.Decoder.string d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(instance_src_req), field(2)" pk
    | Some (10, Pbrt.Bytes) -> begin
      v.hints <- Some (Pbrt.Decoder.string d);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(instance_src_req), field(10)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    session = v.session;
    src = v.src;
    hints = v.hints;
  } : instance_src_req)

let rec decode_pb_instance_name_req d =
  let v = default_instance_name_req_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.session <- Some (Session.decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(instance_name_req), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.name <- Pbrt.Decoder.string d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(instance_name_req), field(2)" pk
    | Some (10, Pbrt.Bytes) -> begin
      v.hints <- Some (Pbrt.Decoder.string d);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(instance_name_req), field(10)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    session = v.session;
    name = v.name;
    hints = v.hints;
  } : instance_name_req)

let rec decode_pb_unsat d =
  let v = default_unsat_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.proof_pp <- Some (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(unsat), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    proof_pp = v.proof_pp;
  } : unsat)

let rec decode_pb_refuted d =
  let v = default_refuted_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.model <- Some (decode_pb_model (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(refuted), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    model = v.model;
  } : refuted)

let rec decode_pb_sat d =
  let v = default_sat_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.model <- Some (decode_pb_model (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(sat), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    model = v.model;
  } : sat)

let rec decode_pb_verify_res_res d = 
  let rec loop () = 
    let ret:verify_res_res = match Pbrt.Decoder.key d with
      | None -> Pbrt.Decoder.malformed_variant "verify_res_res"
      | Some (1, _) -> (Unknown (Utils.decode_pb_string_msg (Pbrt.Decoder.nested d)) : verify_res_res) 
      | Some (2, _) -> begin 
        Pbrt.Decoder.empty_nested d ;
        (Err : verify_res_res)
      end
      | Some (3, _) -> (Proved (decode_pb_proved (Pbrt.Decoder.nested d)) : verify_res_res) 
      | Some (4, _) -> (Refuted (decode_pb_refuted (Pbrt.Decoder.nested d)) : verify_res_res) 
      | Some (5, _) -> (Verified_upto (decode_pb_verified_upto (Pbrt.Decoder.nested d)) : verify_res_res) 
      | Some (n, payload_kind) -> (
        Pbrt.Decoder.skip d payload_kind; 
        loop () 
      )
    in
    ret
  in
  loop ()

and decode_pb_verify_res d =
  let v = default_verify_res_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.errors <- List.rev v.errors;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.res <- Unknown (Utils.decode_pb_string_msg (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(verify_res), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      Pbrt.Decoder.empty_nested d;
      v.res <- Err;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(verify_res), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.res <- Proved (decode_pb_proved (Pbrt.Decoder.nested d));
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(verify_res), field(3)" pk
    | Some (4, Pbrt.Bytes) -> begin
      v.res <- Refuted (decode_pb_refuted (Pbrt.Decoder.nested d));
    end
    | Some (4, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(verify_res), field(4)" pk
    | Some (5, Pbrt.Bytes) -> begin
      v.res <- Verified_upto (decode_pb_verified_upto (Pbrt.Decoder.nested d));
    end
    | Some (5, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(verify_res), field(5)" pk
    | Some (10, Pbrt.Bytes) -> begin
      v.errors <- (Error.decode_pb_error (Pbrt.Decoder.nested d)) :: v.errors;
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(verify_res), field(10)" pk
    | Some (11, Pbrt.Bytes) -> begin
      v.task <- Some (Task.decode_pb_task (Pbrt.Decoder.nested d));
    end
    | Some (11, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(verify_res), field(11)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    res = v.res;
    errors = v.errors;
    task = v.task;
  } : verify_res)

let rec decode_pb_instance_res_res d = 
  let rec loop () = 
    let ret:instance_res_res = match Pbrt.Decoder.key d with
      | None -> Pbrt.Decoder.malformed_variant "instance_res_res"
      | Some (1, _) -> (Unknown (Utils.decode_pb_string_msg (Pbrt.Decoder.nested d)) : instance_res_res) 
      | Some (2, _) -> begin 
        Pbrt.Decoder.empty_nested d ;
        (Err : instance_res_res)
      end
      | Some (3, _) -> (Unsat (decode_pb_unsat (Pbrt.Decoder.nested d)) : instance_res_res) 
      | Some (4, _) -> (Sat (decode_pb_sat (Pbrt.Decoder.nested d)) : instance_res_res) 
      | Some (n, payload_kind) -> (
        Pbrt.Decoder.skip d payload_kind; 
        loop () 
      )
    in
    ret
  in
  loop ()

and decode_pb_instance_res d =
  let v = default_instance_res_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.errors <- List.rev v.errors;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.res <- Unknown (Utils.decode_pb_string_msg (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(instance_res), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      Pbrt.Decoder.empty_nested d;
      v.res <- Err;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(instance_res), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.res <- Unsat (decode_pb_unsat (Pbrt.Decoder.nested d));
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(instance_res), field(3)" pk
    | Some (4, Pbrt.Bytes) -> begin
      v.res <- Sat (decode_pb_sat (Pbrt.Decoder.nested d));
    end
    | Some (4, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(instance_res), field(4)" pk
    | Some (10, Pbrt.Bytes) -> begin
      v.errors <- (Error.decode_pb_error (Pbrt.Decoder.nested d)) :: v.errors;
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(instance_res), field(10)" pk
    | Some (11, Pbrt.Bytes) -> begin
      v.task <- Some (Task.decode_pb_task (Pbrt.Decoder.nested d));
    end
    | Some (11, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(instance_res), field(11)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    res = v.res;
    errors = v.errors;
    task = v.task;
  } : instance_res)

let rec decode_pb_typecheck_req d =
  let v = default_typecheck_req_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.session <- Some (Session.decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(typecheck_req), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.src <- Pbrt.Decoder.string d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(typecheck_req), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    session = v.session;
    src = v.src;
  } : typecheck_req)

let rec decode_pb_typecheck_res d =
  let v = default_typecheck_res_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.errors <- List.rev v.errors;
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.success <- Pbrt.Decoder.bool d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(typecheck_res), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.types <- Pbrt.Decoder.string d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(typecheck_res), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.errors <- (Error.decode_pb_error (Pbrt.Decoder.nested d)) :: v.errors;
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(typecheck_res), field(3)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    success = v.success;
    types = v.types;
    errors = v.errors;
  } : typecheck_res)

let rec decode_pb_oneshot_req d =
  let v = default_oneshot_req_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.input <- Pbrt.Decoder.string d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(oneshot_req), field(1)" pk
    | Some (2, Pbrt.Bits64) -> begin
      v.timeout <- Some (Pbrt.Decoder.float_as_bits64 d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(oneshot_req), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    input = v.input;
    timeout = v.timeout;
  } : oneshot_req)

let rec decode_pb_oneshot_res_stats d =
  let v = default_oneshot_res_stats_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bits64) -> begin
      v.time <- Pbrt.Decoder.float_as_bits64 d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(oneshot_res_stats), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    time = v.time;
  } : oneshot_res_stats)

let rec decode_pb_oneshot_res d =
  let v = default_oneshot_res_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.detailed_results <- List.rev v.detailed_results;
      v.errors <- List.rev v.errors;
      v.results <- List.rev v.results;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.results <- (Pbrt.Decoder.string d) :: v.results;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(oneshot_res), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.errors <- (Pbrt.Decoder.string d) :: v.errors;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(oneshot_res), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.stats <- Some (decode_pb_oneshot_res_stats (Pbrt.Decoder.nested d));
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(oneshot_res), field(3)" pk
    | Some (10, Pbrt.Bytes) -> begin
      v.detailed_results <- (Pbrt.Decoder.string d) :: v.detailed_results;
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(oneshot_res), field(10)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    results = v.results;
    errors = v.errors;
    stats = v.stats;
    detailed_results = v.detailed_results;
  } : oneshot_res)

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_session_create_req (v:session_create_req) = 
  let assoc = [] in 
  let assoc = ("apiVersion", Pbrt_yojson.make_string v.api_version) :: assoc in
  `Assoc assoc

let rec encode_json_lift_bool (v:lift_bool) = 
  match v with
  | Default -> `String "Default"
  | Nested_equalities -> `String "NestedEqualities"
  | Equalities -> `String "Equalities"
  | All -> `String "All"

let rec encode_json_decompose_req (v:decompose_req) = 
  let assoc = [] in 
  let assoc = match v.session with
    | None -> assoc
    | Some v -> ("session", Session.encode_json_session v) :: assoc
  in
  let assoc = ("name", Pbrt_yojson.make_string v.name) :: assoc in
  let assoc = match v.assuming with
    | None -> assoc
    | Some v -> ("assuming", Pbrt_yojson.make_string v) :: assoc
  in
  let assoc =
    let l = v.basis |> List.map Pbrt_yojson.make_string in
    ("basis", `List l) :: assoc 
  in
  let assoc =
    let l = v.rule_specs |> List.map Pbrt_yojson.make_string in
    ("ruleSpecs", `List l) :: assoc 
  in
  let assoc = ("prune", Pbrt_yojson.make_bool v.prune) :: assoc in
  let assoc = match v.ctx_simp with
    | None -> assoc
    | Some v -> ("ctxSimp", Pbrt_yojson.make_bool v) :: assoc
  in
  let assoc = match v.lift_bool with
    | None -> assoc
    | Some v -> ("liftBool", encode_json_lift_bool v) :: assoc
  in
  let assoc = match v.str with
    | None -> assoc
    | Some v -> ("str", Pbrt_yojson.make_bool v) :: assoc
  in
  let assoc = match v.timeout with
    | None -> assoc
    | Some v -> ("timeout", Pbrt_yojson.make_int (Int32.to_int v)) :: assoc
  in
  `Assoc assoc

let rec encode_json_decompose_req_full_by_name (v:decompose_req_full_by_name) = 
  let assoc = [] in 
  let assoc = ("name", Pbrt_yojson.make_string v.name) :: assoc in
  let assoc = match v.assuming with
    | None -> assoc
    | Some v -> ("assuming", Pbrt_yojson.make_string v) :: assoc
  in
  let assoc =
    let l = v.basis |> List.map Pbrt_yojson.make_string in
    ("basis", `List l) :: assoc 
  in
  let assoc =
    let l = v.rule_specs |> List.map Pbrt_yojson.make_string in
    ("ruleSpecs", `List l) :: assoc 
  in
  let assoc = ("prune", Pbrt_yojson.make_bool v.prune) :: assoc in
  let assoc = match v.ctx_simp with
    | None -> assoc
    | Some v -> ("ctxSimp", Pbrt_yojson.make_bool v) :: assoc
  in
  let assoc = match v.lift_bool with
    | None -> assoc
    | Some v -> ("liftBool", encode_json_lift_bool v) :: assoc
  in
  `Assoc assoc

let rec encode_json_decompose_req_full_local_var_get (v:decompose_req_full_local_var_get) = 
  let assoc = [] in 
  let assoc = ("name", Pbrt_yojson.make_string v.name) :: assoc in
  `Assoc assoc

let rec encode_json_decompose_req_full_prune (v:decompose_req_full_prune) = 
  let assoc = [] in 
  let assoc = match v.d with
    | None -> assoc
    | Some v -> ("d", encode_json_decompose_req_full_decomp v) :: assoc
  in
  `Assoc assoc

and encode_json_decompose_req_full_decomp (v:decompose_req_full_decomp) = 
  begin match v with
  | From_artifact v -> `Assoc [("fromArtifact", Artmsg.encode_json_art v)]
  | By_name v -> `Assoc [("byName", encode_json_decompose_req_full_by_name v)]
  | Merge v -> `Assoc [("merge", encode_json_decompose_req_full_merge v)]
  | Compound_merge v -> `Assoc [("compoundMerge", encode_json_decompose_req_full_compound_merge v)]
  | Prune v -> `Assoc [("prune", encode_json_decompose_req_full_prune v)]
  | Combine v -> `Assoc [("combine", encode_json_decompose_req_full_combine v)]
  | Get v -> `Assoc [("get", encode_json_decompose_req_full_local_var_get v)]
  | Set v -> `Assoc [("set", encode_json_decompose_req_full_local_var_let v)]
  end

and encode_json_decompose_req_full_merge (v:decompose_req_full_merge) = 
  let assoc = [] in 
  let assoc = match v.d1 with
    | None -> assoc
    | Some v -> ("d1", encode_json_decompose_req_full_decomp v) :: assoc
  in
  let assoc = match v.d2 with
    | None -> assoc
    | Some v -> ("d2", encode_json_decompose_req_full_decomp v) :: assoc
  in
  `Assoc assoc

and encode_json_decompose_req_full_compound_merge (v:decompose_req_full_compound_merge) = 
  let assoc = [] in 
  let assoc = match v.d1 with
    | None -> assoc
    | Some v -> ("d1", encode_json_decompose_req_full_decomp v) :: assoc
  in
  let assoc = match v.d2 with
    | None -> assoc
    | Some v -> ("d2", encode_json_decompose_req_full_decomp v) :: assoc
  in
  `Assoc assoc

and encode_json_decompose_req_full_combine (v:decompose_req_full_combine) = 
  let assoc = [] in 
  let assoc = match v.d with
    | None -> assoc
    | Some v -> ("d", encode_json_decompose_req_full_decomp v) :: assoc
  in
  `Assoc assoc

and encode_json_decompose_req_full_local_var_let (v:decompose_req_full_local_var_let) = 
  let assoc = [] in 
  let assoc =
    let l = v.bindings |> List.map encode_json_decompose_req_full_local_var_binding in
    ("bindings", `List l) :: assoc 
  in
  let assoc = match v.and_then with
    | None -> assoc
    | Some v -> ("andThen", encode_json_decompose_req_full_decomp v) :: assoc
  in
  `Assoc assoc

and encode_json_decompose_req_full_local_var_binding (v:decompose_req_full_local_var_binding) = 
  let assoc = [] in 
  let assoc = ("name", Pbrt_yojson.make_string v.name) :: assoc in
  let assoc = match v.d with
    | None -> assoc
    | Some v -> ("d", encode_json_decompose_req_full_decomp v) :: assoc
  in
  `Assoc assoc

let rec encode_json_decompose_req_full (v:decompose_req_full) = 
  let assoc = [] in 
  let assoc = match v.session with
    | None -> assoc
    | Some v -> ("session", Session.encode_json_session v) :: assoc
  in
  let assoc = match v.decomp with
    | None -> assoc
    | Some v -> ("decomp", encode_json_decompose_req_full_decomp v) :: assoc
  in
  let assoc = match v.str with
    | None -> assoc
    | Some v -> ("str", Pbrt_yojson.make_bool v) :: assoc
  in
  let assoc = match v.timeout with
    | None -> assoc
    | Some v -> ("timeout", Pbrt_yojson.make_int (Int32.to_int v)) :: assoc
  in
  `Assoc assoc

let rec encode_json_decompose_res_res (v:decompose_res_res) = 
  begin match v with
  | Artifact v -> `Assoc [("artifact", Artmsg.encode_json_art v)]
  | Err -> `Assoc [("err", `Null)]
  end

and encode_json_decompose_res (v:decompose_res) = 
  let assoc = [] in 
  let assoc = match v.res with
      | Artifact v -> ("artifact", Artmsg.encode_json_art v) :: assoc
      | Err -> ("err", `Null) :: assoc
  in (* match v.res *)
  let assoc =
    let l = v.errors |> List.map Error.encode_json_error in
    ("errors", `List l) :: assoc 
  in
  let assoc = match v.task with
    | None -> assoc
    | Some v -> ("task", Task.encode_json_task v) :: assoc
  in
  `Assoc assoc

let rec encode_json_eval_src_req (v:eval_src_req) = 
  let assoc = [] in 
  let assoc = match v.session with
    | None -> assoc
    | Some v -> ("session", Session.encode_json_session v) :: assoc
  in
  let assoc = ("src", Pbrt_yojson.make_string v.src) :: assoc in
  let assoc = match v.async_only with
    | None -> assoc
    | Some v -> ("asyncOnly", Pbrt_yojson.make_bool v) :: assoc
  in
  `Assoc assoc

let rec encode_json_eval_output (v:eval_output) = 
  let assoc = [] in 
  let assoc = ("success", Pbrt_yojson.make_bool v.success) :: assoc in
  let assoc = match v.value_as_ocaml with
    | None -> assoc
    | Some v -> ("valueAsOcaml", Pbrt_yojson.make_string v) :: assoc
  in
  let assoc =
    let l = v.errors |> List.map Error.encode_json_error in
    ("errors", `List l) :: assoc 
  in
  `Assoc assoc

let rec encode_json_proved (v:proved) = 
  let assoc = [] in 
  let assoc = match v.proof_pp with
    | None -> assoc
    | Some v -> ("proofPp", Pbrt_yojson.make_string v) :: assoc
  in
  `Assoc assoc

let rec encode_json_model_type (v:model_type) = 
  match v with
  | Counter_example -> `String "Counter_example"
  | Instance -> `String "Instance"

let rec encode_json_model (v:model) = 
  let assoc = [] in 
  let assoc = ("mType", encode_json_model_type v.m_type) :: assoc in
  let assoc = ("src", Pbrt_yojson.make_string v.src) :: assoc in
  let assoc = match v.artifact with
    | None -> assoc
    | Some v -> ("artifact", Artmsg.encode_json_art v) :: assoc
  in
  `Assoc assoc

let rec encode_json_counter_sat (v:counter_sat) = 
  let assoc = [] in 
  let assoc = match v.model with
    | None -> assoc
    | Some v -> ("model", encode_json_model v) :: assoc
  in
  `Assoc assoc

let rec encode_json_verified_upto (v:verified_upto) = 
  let assoc = [] in 
  let assoc = match v.msg with
    | None -> assoc
    | Some v -> ("msg", Pbrt_yojson.make_string v) :: assoc
  in
  `Assoc assoc

let rec encode_json_po_res_res (v:po_res_res) = 
  begin match v with
  | Unknown v -> `Assoc [("unknown", Utils.encode_json_string_msg v)]
  | Err -> `Assoc [("err", `Null)]
  | Proof v -> `Assoc [("proof", encode_json_proved v)]
  | Instance v -> `Assoc [("instance", encode_json_counter_sat v)]
  | Verified_upto v -> `Assoc [("verifiedUpto", encode_json_verified_upto v)]
  end

and encode_json_po_res (v:po_res) = 
  let assoc = [] in 
  let assoc = match v.res with
      | Unknown v -> ("unknown", Utils.encode_json_string_msg v) :: assoc
      | Err -> ("err", `Null) :: assoc
      | Proof v -> ("proof", encode_json_proved v) :: assoc
      | Instance v -> ("instance", encode_json_counter_sat v) :: assoc
      | Verified_upto v -> ("verifiedUpto", encode_json_verified_upto v) :: assoc
  in (* match v.res *)
  let assoc =
    let l = v.errors |> List.map Error.encode_json_error in
    ("errors", `List l) :: assoc 
  in
  let assoc = match v.task with
    | None -> assoc
    | Some v -> ("task", Task.encode_json_task v) :: assoc
  in
  let assoc = match v.origin with
    | None -> assoc
    | Some v -> ("origin", Task.encode_json_origin v) :: assoc
  in
  `Assoc assoc

let rec encode_json_eval_res (v:eval_res) = 
  let assoc = [] in 
  let assoc = ("success", Pbrt_yojson.make_bool v.success) :: assoc in
  let assoc =
    let l = v.messages |> List.map Pbrt_yojson.make_string in
    ("messages", `List l) :: assoc 
  in
  let assoc =
    let l = v.errors |> List.map Error.encode_json_error in
    ("errors", `List l) :: assoc 
  in
  let assoc =
    let l = v.tasks |> List.map Task.encode_json_task in
    ("tasks", `List l) :: assoc 
  in
  let assoc =
    let l = v.po_results |> List.map encode_json_po_res in
    ("poResults", `List l) :: assoc 
  in
  let assoc =
    let l = v.eval_results |> List.map encode_json_eval_output in
    ("evalResults", `List l) :: assoc 
  in
  let assoc =
    let l = v.decomp_results |> List.map encode_json_decompose_res in
    ("decompResults", `List l) :: assoc 
  in
  `Assoc assoc

let rec encode_json_verify_src_req (v:verify_src_req) = 
  let assoc = [] in 
  let assoc = match v.session with
    | None -> assoc
    | Some v -> ("session", Session.encode_json_session v) :: assoc
  in
  let assoc = ("src", Pbrt_yojson.make_string v.src) :: assoc in
  let assoc = match v.hints with
    | None -> assoc
    | Some v -> ("hints", Pbrt_yojson.make_string v) :: assoc
  in
  `Assoc assoc

let rec encode_json_verify_name_req (v:verify_name_req) = 
  let assoc = [] in 
  let assoc = match v.session with
    | None -> assoc
    | Some v -> ("session", Session.encode_json_session v) :: assoc
  in
  let assoc = ("name", Pbrt_yojson.make_string v.name) :: assoc in
  let assoc = match v.hints with
    | None -> assoc
    | Some v -> ("hints", Pbrt_yojson.make_string v) :: assoc
  in
  `Assoc assoc

let rec encode_json_instance_src_req (v:instance_src_req) = 
  let assoc = [] in 
  let assoc = match v.session with
    | None -> assoc
    | Some v -> ("session", Session.encode_json_session v) :: assoc
  in
  let assoc = ("src", Pbrt_yojson.make_string v.src) :: assoc in
  let assoc = match v.hints with
    | None -> assoc
    | Some v -> ("hints", Pbrt_yojson.make_string v) :: assoc
  in
  `Assoc assoc

let rec encode_json_instance_name_req (v:instance_name_req) = 
  let assoc = [] in 
  let assoc = match v.session with
    | None -> assoc
    | Some v -> ("session", Session.encode_json_session v) :: assoc
  in
  let assoc = ("name", Pbrt_yojson.make_string v.name) :: assoc in
  let assoc = match v.hints with
    | None -> assoc
    | Some v -> ("hints", Pbrt_yojson.make_string v) :: assoc
  in
  `Assoc assoc

let rec encode_json_unsat (v:unsat) = 
  let assoc = [] in 
  let assoc = match v.proof_pp with
    | None -> assoc
    | Some v -> ("proofPp", Pbrt_yojson.make_string v) :: assoc
  in
  `Assoc assoc

let rec encode_json_refuted (v:refuted) = 
  let assoc = [] in 
  let assoc = match v.model with
    | None -> assoc
    | Some v -> ("model", encode_json_model v) :: assoc
  in
  `Assoc assoc

let rec encode_json_sat (v:sat) = 
  let assoc = [] in 
  let assoc = match v.model with
    | None -> assoc
    | Some v -> ("model", encode_json_model v) :: assoc
  in
  `Assoc assoc

let rec encode_json_verify_res_res (v:verify_res_res) = 
  begin match v with
  | Unknown v -> `Assoc [("unknown", Utils.encode_json_string_msg v)]
  | Err -> `Assoc [("err", `Null)]
  | Proved v -> `Assoc [("proved", encode_json_proved v)]
  | Refuted v -> `Assoc [("refuted", encode_json_refuted v)]
  | Verified_upto v -> `Assoc [("verifiedUpto", encode_json_verified_upto v)]
  end

and encode_json_verify_res (v:verify_res) = 
  let assoc = [] in 
  let assoc = match v.res with
      | Unknown v -> ("unknown", Utils.encode_json_string_msg v) :: assoc
      | Err -> ("err", `Null) :: assoc
      | Proved v -> ("proved", encode_json_proved v) :: assoc
      | Refuted v -> ("refuted", encode_json_refuted v) :: assoc
      | Verified_upto v -> ("verifiedUpto", encode_json_verified_upto v) :: assoc
  in (* match v.res *)
  let assoc =
    let l = v.errors |> List.map Error.encode_json_error in
    ("errors", `List l) :: assoc 
  in
  let assoc = match v.task with
    | None -> assoc
    | Some v -> ("task", Task.encode_json_task v) :: assoc
  in
  `Assoc assoc

let rec encode_json_instance_res_res (v:instance_res_res) = 
  begin match v with
  | Unknown v -> `Assoc [("unknown", Utils.encode_json_string_msg v)]
  | Err -> `Assoc [("err", `Null)]
  | Unsat v -> `Assoc [("unsat", encode_json_unsat v)]
  | Sat v -> `Assoc [("sat", encode_json_sat v)]
  end

and encode_json_instance_res (v:instance_res) = 
  let assoc = [] in 
  let assoc = match v.res with
      | Unknown v -> ("unknown", Utils.encode_json_string_msg v) :: assoc
      | Err -> ("err", `Null) :: assoc
      | Unsat v -> ("unsat", encode_json_unsat v) :: assoc
      | Sat v -> ("sat", encode_json_sat v) :: assoc
  in (* match v.res *)
  let assoc =
    let l = v.errors |> List.map Error.encode_json_error in
    ("errors", `List l) :: assoc 
  in
  let assoc = match v.task with
    | None -> assoc
    | Some v -> ("task", Task.encode_json_task v) :: assoc
  in
  `Assoc assoc

let rec encode_json_typecheck_req (v:typecheck_req) = 
  let assoc = [] in 
  let assoc = match v.session with
    | None -> assoc
    | Some v -> ("session", Session.encode_json_session v) :: assoc
  in
  let assoc = ("src", Pbrt_yojson.make_string v.src) :: assoc in
  `Assoc assoc

let rec encode_json_typecheck_res (v:typecheck_res) = 
  let assoc = [] in 
  let assoc = ("success", Pbrt_yojson.make_bool v.success) :: assoc in
  let assoc = ("types", Pbrt_yojson.make_string v.types) :: assoc in
  let assoc =
    let l = v.errors |> List.map Error.encode_json_error in
    ("errors", `List l) :: assoc 
  in
  `Assoc assoc

let rec encode_json_oneshot_req (v:oneshot_req) = 
  let assoc = [] in 
  let assoc = ("input", Pbrt_yojson.make_string v.input) :: assoc in
  let assoc = match v.timeout with
    | None -> assoc
    | Some v -> ("timeout", Pbrt_yojson.make_string (string_of_float v)) :: assoc
  in
  `Assoc assoc

let rec encode_json_oneshot_res_stats (v:oneshot_res_stats) = 
  let assoc = [] in 
  let assoc = ("time", Pbrt_yojson.make_string (string_of_float v.time)) :: assoc in
  `Assoc assoc

let rec encode_json_oneshot_res (v:oneshot_res) = 
  let assoc = [] in 
  let assoc =
    let l = v.results |> List.map Pbrt_yojson.make_string in
    ("results", `List l) :: assoc 
  in
  let assoc =
    let l = v.errors |> List.map Pbrt_yojson.make_string in
    ("errors", `List l) :: assoc 
  in
  let assoc = match v.stats with
    | None -> assoc
    | Some v -> ("stats", encode_json_oneshot_res_stats v) :: assoc
  in
  let assoc =
    let l = v.detailed_results |> List.map Pbrt_yojson.make_string in
    ("detailedResults", `List l) :: assoc 
  in
  `Assoc assoc

[@@@ocaml.warning "-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_session_create_req d =
  let v = default_session_create_req_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("apiVersion", json_value) -> 
      v.api_version <- Pbrt_yojson.string json_value "session_create_req" "api_version"
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    api_version = v.api_version;
  } : session_create_req)

let rec decode_json_lift_bool json =
  match json with
  | `String "Default" -> (Default : lift_bool)
  | `String "NestedEqualities" -> (Nested_equalities : lift_bool)
  | `String "Equalities" -> (Equalities : lift_bool)
  | `String "All" -> (All : lift_bool)
  | _ -> Pbrt_yojson.E.malformed_variant "lift_bool"

let rec decode_json_decompose_req d =
  let v = default_decompose_req_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      v.session <- Some ((Session.decode_json_session json_value))
    | ("name", json_value) -> 
      v.name <- Pbrt_yojson.string json_value "decompose_req" "name"
    | ("assuming", json_value) -> 
      v.assuming <- Some (Pbrt_yojson.string json_value "decompose_req" "assuming")
    | ("basis", `List l) -> begin
      v.basis <- List.map (function
        | json_value -> Pbrt_yojson.string json_value "decompose_req" "basis"
      ) l;
    end
    | ("ruleSpecs", `List l) -> begin
      v.rule_specs <- List.map (function
        | json_value -> Pbrt_yojson.string json_value "decompose_req" "rule_specs"
      ) l;
    end
    | ("prune", json_value) -> 
      v.prune <- Pbrt_yojson.bool json_value "decompose_req" "prune"
    | ("ctxSimp", json_value) -> 
      v.ctx_simp <- Some (Pbrt_yojson.bool json_value "decompose_req" "ctx_simp")
    | ("liftBool", json_value) -> 
      v.lift_bool <- Some ((decode_json_lift_bool json_value))
    | ("str", json_value) -> 
      v.str <- Some (Pbrt_yojson.bool json_value "decompose_req" "str")
    | ("timeout", json_value) -> 
      v.timeout <- Some (Pbrt_yojson.int32 json_value "decompose_req" "timeout")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    session = v.session;
    name = v.name;
    assuming = v.assuming;
    basis = v.basis;
    rule_specs = v.rule_specs;
    prune = v.prune;
    ctx_simp = v.ctx_simp;
    lift_bool = v.lift_bool;
    str = v.str;
    timeout = v.timeout;
  } : decompose_req)

let rec decode_json_decompose_req_full_by_name d =
  let v = default_decompose_req_full_by_name_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("name", json_value) -> 
      v.name <- Pbrt_yojson.string json_value "decompose_req_full_by_name" "name"
    | ("assuming", json_value) -> 
      v.assuming <- Some (Pbrt_yojson.string json_value "decompose_req_full_by_name" "assuming")
    | ("basis", `List l) -> begin
      v.basis <- List.map (function
        | json_value -> Pbrt_yojson.string json_value "decompose_req_full_by_name" "basis"
      ) l;
    end
    | ("ruleSpecs", `List l) -> begin
      v.rule_specs <- List.map (function
        | json_value -> Pbrt_yojson.string json_value "decompose_req_full_by_name" "rule_specs"
      ) l;
    end
    | ("prune", json_value) -> 
      v.prune <- Pbrt_yojson.bool json_value "decompose_req_full_by_name" "prune"
    | ("ctxSimp", json_value) -> 
      v.ctx_simp <- Some (Pbrt_yojson.bool json_value "decompose_req_full_by_name" "ctx_simp")
    | ("liftBool", json_value) -> 
      v.lift_bool <- Some ((decode_json_lift_bool json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    name = v.name;
    assuming = v.assuming;
    basis = v.basis;
    rule_specs = v.rule_specs;
    prune = v.prune;
    ctx_simp = v.ctx_simp;
    lift_bool = v.lift_bool;
  } : decompose_req_full_by_name)

let rec decode_json_decompose_req_full_local_var_get d =
  let v = default_decompose_req_full_local_var_get_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("name", json_value) -> 
      v.name <- Pbrt_yojson.string json_value "decompose_req_full_local_var_get" "name"
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    name = v.name;
  } : decompose_req_full_local_var_get)

let rec decode_json_decompose_req_full_prune d =
  let v = default_decompose_req_full_prune_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("d", json_value) -> 
      v.d <- Some ((decode_json_decompose_req_full_decomp json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    d = v.d;
  } : decompose_req_full_prune)

and decode_json_decompose_req_full_decomp json =
  let assoc = match json with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  let rec loop = function
    | [] -> Pbrt_yojson.E.malformed_variant "decompose_req_full_decomp"
    | ("fromArtifact", json_value)::_ -> 
      (From_artifact ((Artmsg.decode_json_art json_value)) : decompose_req_full_decomp)
    | ("byName", json_value)::_ -> 
      (By_name ((decode_json_decompose_req_full_by_name json_value)) : decompose_req_full_decomp)
    | ("merge", json_value)::_ -> 
      (Merge ((decode_json_decompose_req_full_merge json_value)) : decompose_req_full_decomp)
    | ("compoundMerge", json_value)::_ -> 
      (Compound_merge ((decode_json_decompose_req_full_compound_merge json_value)) : decompose_req_full_decomp)
    | ("prune", json_value)::_ -> 
      (Prune ((decode_json_decompose_req_full_prune json_value)) : decompose_req_full_decomp)
    | ("combine", json_value)::_ -> 
      (Combine ((decode_json_decompose_req_full_combine json_value)) : decompose_req_full_decomp)
    | ("get", json_value)::_ -> 
      (Get ((decode_json_decompose_req_full_local_var_get json_value)) : decompose_req_full_decomp)
    | ("set", json_value)::_ -> 
      (Set ((decode_json_decompose_req_full_local_var_let json_value)) : decompose_req_full_decomp)
    
    | _ :: tl -> loop tl
  in
  loop assoc

and decode_json_decompose_req_full_merge d =
  let v = default_decompose_req_full_merge_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("d1", json_value) -> 
      v.d1 <- Some ((decode_json_decompose_req_full_decomp json_value))
    | ("d2", json_value) -> 
      v.d2 <- Some ((decode_json_decompose_req_full_decomp json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    d1 = v.d1;
    d2 = v.d2;
  } : decompose_req_full_merge)

and decode_json_decompose_req_full_compound_merge d =
  let v = default_decompose_req_full_compound_merge_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("d1", json_value) -> 
      v.d1 <- Some ((decode_json_decompose_req_full_decomp json_value))
    | ("d2", json_value) -> 
      v.d2 <- Some ((decode_json_decompose_req_full_decomp json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    d1 = v.d1;
    d2 = v.d2;
  } : decompose_req_full_compound_merge)

and decode_json_decompose_req_full_combine d =
  let v = default_decompose_req_full_combine_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("d", json_value) -> 
      v.d <- Some ((decode_json_decompose_req_full_decomp json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    d = v.d;
  } : decompose_req_full_combine)

and decode_json_decompose_req_full_local_var_let d =
  let v = default_decompose_req_full_local_var_let_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("bindings", `List l) -> begin
      v.bindings <- List.map (function
        | json_value -> (decode_json_decompose_req_full_local_var_binding json_value)
      ) l;
    end
    | ("andThen", json_value) -> 
      v.and_then <- Some ((decode_json_decompose_req_full_decomp json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    bindings = v.bindings;
    and_then = v.and_then;
  } : decompose_req_full_local_var_let)

and decode_json_decompose_req_full_local_var_binding d =
  let v = default_decompose_req_full_local_var_binding_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("name", json_value) -> 
      v.name <- Pbrt_yojson.string json_value "decompose_req_full_local_var_binding" "name"
    | ("d", json_value) -> 
      v.d <- Some ((decode_json_decompose_req_full_decomp json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    name = v.name;
    d = v.d;
  } : decompose_req_full_local_var_binding)

let rec decode_json_decompose_req_full d =
  let v = default_decompose_req_full_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      v.session <- Some ((Session.decode_json_session json_value))
    | ("decomp", json_value) -> 
      v.decomp <- Some ((decode_json_decompose_req_full_decomp json_value))
    | ("str", json_value) -> 
      v.str <- Some (Pbrt_yojson.bool json_value "decompose_req_full" "str")
    | ("timeout", json_value) -> 
      v.timeout <- Some (Pbrt_yojson.int32 json_value "decompose_req_full" "timeout")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    session = v.session;
    decomp = v.decomp;
    str = v.str;
    timeout = v.timeout;
  } : decompose_req_full)

let rec decode_json_decompose_res_res json =
  let assoc = match json with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  let rec loop = function
    | [] -> Pbrt_yojson.E.malformed_variant "decompose_res_res"
    | ("artifact", json_value)::_ -> 
      (Artifact ((Artmsg.decode_json_art json_value)) : decompose_res_res)
    | ("err", _)::_-> (Err : decompose_res_res)
    
    | _ :: tl -> loop tl
  in
  loop assoc

and decode_json_decompose_res d =
  let v = default_decompose_res_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("artifact", json_value) -> 
      v.res <- Artifact ((Artmsg.decode_json_art json_value))
    | ("err", _) -> v.res <- Err
    | ("errors", `List l) -> begin
      v.errors <- List.map (function
        | json_value -> (Error.decode_json_error json_value)
      ) l;
    end
    | ("task", json_value) -> 
      v.task <- Some ((Task.decode_json_task json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    res = v.res;
    errors = v.errors;
    task = v.task;
  } : decompose_res)

let rec decode_json_eval_src_req d =
  let v = default_eval_src_req_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      v.session <- Some ((Session.decode_json_session json_value))
    | ("src", json_value) -> 
      v.src <- Pbrt_yojson.string json_value "eval_src_req" "src"
    | ("asyncOnly", json_value) -> 
      v.async_only <- Some (Pbrt_yojson.bool json_value "eval_src_req" "async_only")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    session = v.session;
    src = v.src;
    async_only = v.async_only;
  } : eval_src_req)

let rec decode_json_eval_output d =
  let v = default_eval_output_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("success", json_value) -> 
      v.success <- Pbrt_yojson.bool json_value "eval_output" "success"
    | ("valueAsOcaml", json_value) -> 
      v.value_as_ocaml <- Some (Pbrt_yojson.string json_value "eval_output" "value_as_ocaml")
    | ("errors", `List l) -> begin
      v.errors <- List.map (function
        | json_value -> (Error.decode_json_error json_value)
      ) l;
    end
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    success = v.success;
    value_as_ocaml = v.value_as_ocaml;
    errors = v.errors;
  } : eval_output)

let rec decode_json_proved d =
  let v = default_proved_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("proofPp", json_value) -> 
      v.proof_pp <- Some (Pbrt_yojson.string json_value "proved" "proof_pp")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    proof_pp = v.proof_pp;
  } : proved)

let rec decode_json_model_type json =
  match json with
  | `String "Counter_example" -> (Counter_example : model_type)
  | `String "Instance" -> (Instance : model_type)
  | _ -> Pbrt_yojson.E.malformed_variant "model_type"

let rec decode_json_model d =
  let v = default_model_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("mType", json_value) -> 
      v.m_type <- (decode_json_model_type json_value)
    | ("src", json_value) -> 
      v.src <- Pbrt_yojson.string json_value "model" "src"
    | ("artifact", json_value) -> 
      v.artifact <- Some ((Artmsg.decode_json_art json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    m_type = v.m_type;
    src = v.src;
    artifact = v.artifact;
  } : model)

let rec decode_json_counter_sat d =
  let v = default_counter_sat_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("model", json_value) -> 
      v.model <- Some ((decode_json_model json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    model = v.model;
  } : counter_sat)

let rec decode_json_verified_upto d =
  let v = default_verified_upto_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("msg", json_value) -> 
      v.msg <- Some (Pbrt_yojson.string json_value "verified_upto" "msg")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    msg = v.msg;
  } : verified_upto)

let rec decode_json_po_res_res json =
  let assoc = match json with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  let rec loop = function
    | [] -> Pbrt_yojson.E.malformed_variant "po_res_res"
    | ("unknown", json_value)::_ -> 
      (Unknown ((Utils.decode_json_string_msg json_value)) : po_res_res)
    | ("err", _)::_-> (Err : po_res_res)
    | ("proof", json_value)::_ -> 
      (Proof ((decode_json_proved json_value)) : po_res_res)
    | ("instance", json_value)::_ -> 
      (Instance ((decode_json_counter_sat json_value)) : po_res_res)
    | ("verifiedUpto", json_value)::_ -> 
      (Verified_upto ((decode_json_verified_upto json_value)) : po_res_res)
    
    | _ :: tl -> loop tl
  in
  loop assoc

and decode_json_po_res d =
  let v = default_po_res_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("unknown", json_value) -> 
      v.res <- Unknown ((Utils.decode_json_string_msg json_value))
    | ("err", _) -> v.res <- Err
    | ("proof", json_value) -> 
      v.res <- Proof ((decode_json_proved json_value))
    | ("instance", json_value) -> 
      v.res <- Instance ((decode_json_counter_sat json_value))
    | ("verifiedUpto", json_value) -> 
      v.res <- Verified_upto ((decode_json_verified_upto json_value))
    | ("errors", `List l) -> begin
      v.errors <- List.map (function
        | json_value -> (Error.decode_json_error json_value)
      ) l;
    end
    | ("task", json_value) -> 
      v.task <- Some ((Task.decode_json_task json_value))
    | ("origin", json_value) -> 
      v.origin <- Some ((Task.decode_json_origin json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    res = v.res;
    errors = v.errors;
    task = v.task;
    origin = v.origin;
  } : po_res)

let rec decode_json_eval_res d =
  let v = default_eval_res_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("success", json_value) -> 
      v.success <- Pbrt_yojson.bool json_value "eval_res" "success"
    | ("messages", `List l) -> begin
      v.messages <- List.map (function
        | json_value -> Pbrt_yojson.string json_value "eval_res" "messages"
      ) l;
    end
    | ("errors", `List l) -> begin
      v.errors <- List.map (function
        | json_value -> (Error.decode_json_error json_value)
      ) l;
    end
    | ("tasks", `List l) -> begin
      v.tasks <- List.map (function
        | json_value -> (Task.decode_json_task json_value)
      ) l;
    end
    | ("poResults", `List l) -> begin
      v.po_results <- List.map (function
        | json_value -> (decode_json_po_res json_value)
      ) l;
    end
    | ("evalResults", `List l) -> begin
      v.eval_results <- List.map (function
        | json_value -> (decode_json_eval_output json_value)
      ) l;
    end
    | ("decompResults", `List l) -> begin
      v.decomp_results <- List.map (function
        | json_value -> (decode_json_decompose_res json_value)
      ) l;
    end
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    success = v.success;
    messages = v.messages;
    errors = v.errors;
    tasks = v.tasks;
    po_results = v.po_results;
    eval_results = v.eval_results;
    decomp_results = v.decomp_results;
  } : eval_res)

let rec decode_json_verify_src_req d =
  let v = default_verify_src_req_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      v.session <- Some ((Session.decode_json_session json_value))
    | ("src", json_value) -> 
      v.src <- Pbrt_yojson.string json_value "verify_src_req" "src"
    | ("hints", json_value) -> 
      v.hints <- Some (Pbrt_yojson.string json_value "verify_src_req" "hints")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    session = v.session;
    src = v.src;
    hints = v.hints;
  } : verify_src_req)

let rec decode_json_verify_name_req d =
  let v = default_verify_name_req_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      v.session <- Some ((Session.decode_json_session json_value))
    | ("name", json_value) -> 
      v.name <- Pbrt_yojson.string json_value "verify_name_req" "name"
    | ("hints", json_value) -> 
      v.hints <- Some (Pbrt_yojson.string json_value "verify_name_req" "hints")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    session = v.session;
    name = v.name;
    hints = v.hints;
  } : verify_name_req)

let rec decode_json_instance_src_req d =
  let v = default_instance_src_req_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      v.session <- Some ((Session.decode_json_session json_value))
    | ("src", json_value) -> 
      v.src <- Pbrt_yojson.string json_value "instance_src_req" "src"
    | ("hints", json_value) -> 
      v.hints <- Some (Pbrt_yojson.string json_value "instance_src_req" "hints")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    session = v.session;
    src = v.src;
    hints = v.hints;
  } : instance_src_req)

let rec decode_json_instance_name_req d =
  let v = default_instance_name_req_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      v.session <- Some ((Session.decode_json_session json_value))
    | ("name", json_value) -> 
      v.name <- Pbrt_yojson.string json_value "instance_name_req" "name"
    | ("hints", json_value) -> 
      v.hints <- Some (Pbrt_yojson.string json_value "instance_name_req" "hints")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    session = v.session;
    name = v.name;
    hints = v.hints;
  } : instance_name_req)

let rec decode_json_unsat d =
  let v = default_unsat_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("proofPp", json_value) -> 
      v.proof_pp <- Some (Pbrt_yojson.string json_value "unsat" "proof_pp")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    proof_pp = v.proof_pp;
  } : unsat)

let rec decode_json_refuted d =
  let v = default_refuted_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("model", json_value) -> 
      v.model <- Some ((decode_json_model json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    model = v.model;
  } : refuted)

let rec decode_json_sat d =
  let v = default_sat_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("model", json_value) -> 
      v.model <- Some ((decode_json_model json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    model = v.model;
  } : sat)

let rec decode_json_verify_res_res json =
  let assoc = match json with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  let rec loop = function
    | [] -> Pbrt_yojson.E.malformed_variant "verify_res_res"
    | ("unknown", json_value)::_ -> 
      (Unknown ((Utils.decode_json_string_msg json_value)) : verify_res_res)
    | ("err", _)::_-> (Err : verify_res_res)
    | ("proved", json_value)::_ -> 
      (Proved ((decode_json_proved json_value)) : verify_res_res)
    | ("refuted", json_value)::_ -> 
      (Refuted ((decode_json_refuted json_value)) : verify_res_res)
    | ("verifiedUpto", json_value)::_ -> 
      (Verified_upto ((decode_json_verified_upto json_value)) : verify_res_res)
    
    | _ :: tl -> loop tl
  in
  loop assoc

and decode_json_verify_res d =
  let v = default_verify_res_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("unknown", json_value) -> 
      v.res <- Unknown ((Utils.decode_json_string_msg json_value))
    | ("err", _) -> v.res <- Err
    | ("proved", json_value) -> 
      v.res <- Proved ((decode_json_proved json_value))
    | ("refuted", json_value) -> 
      v.res <- Refuted ((decode_json_refuted json_value))
    | ("verifiedUpto", json_value) -> 
      v.res <- Verified_upto ((decode_json_verified_upto json_value))
    | ("errors", `List l) -> begin
      v.errors <- List.map (function
        | json_value -> (Error.decode_json_error json_value)
      ) l;
    end
    | ("task", json_value) -> 
      v.task <- Some ((Task.decode_json_task json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    res = v.res;
    errors = v.errors;
    task = v.task;
  } : verify_res)

let rec decode_json_instance_res_res json =
  let assoc = match json with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  let rec loop = function
    | [] -> Pbrt_yojson.E.malformed_variant "instance_res_res"
    | ("unknown", json_value)::_ -> 
      (Unknown ((Utils.decode_json_string_msg json_value)) : instance_res_res)
    | ("err", _)::_-> (Err : instance_res_res)
    | ("unsat", json_value)::_ -> 
      (Unsat ((decode_json_unsat json_value)) : instance_res_res)
    | ("sat", json_value)::_ -> 
      (Sat ((decode_json_sat json_value)) : instance_res_res)
    
    | _ :: tl -> loop tl
  in
  loop assoc

and decode_json_instance_res d =
  let v = default_instance_res_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("unknown", json_value) -> 
      v.res <- Unknown ((Utils.decode_json_string_msg json_value))
    | ("err", _) -> v.res <- Err
    | ("unsat", json_value) -> 
      v.res <- Unsat ((decode_json_unsat json_value))
    | ("sat", json_value) -> 
      v.res <- Sat ((decode_json_sat json_value))
    | ("errors", `List l) -> begin
      v.errors <- List.map (function
        | json_value -> (Error.decode_json_error json_value)
      ) l;
    end
    | ("task", json_value) -> 
      v.task <- Some ((Task.decode_json_task json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    res = v.res;
    errors = v.errors;
    task = v.task;
  } : instance_res)

let rec decode_json_typecheck_req d =
  let v = default_typecheck_req_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      v.session <- Some ((Session.decode_json_session json_value))
    | ("src", json_value) -> 
      v.src <- Pbrt_yojson.string json_value "typecheck_req" "src"
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    session = v.session;
    src = v.src;
  } : typecheck_req)

let rec decode_json_typecheck_res d =
  let v = default_typecheck_res_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("success", json_value) -> 
      v.success <- Pbrt_yojson.bool json_value "typecheck_res" "success"
    | ("types", json_value) -> 
      v.types <- Pbrt_yojson.string json_value "typecheck_res" "types"
    | ("errors", `List l) -> begin
      v.errors <- List.map (function
        | json_value -> (Error.decode_json_error json_value)
      ) l;
    end
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    success = v.success;
    types = v.types;
    errors = v.errors;
  } : typecheck_res)

let rec decode_json_oneshot_req d =
  let v = default_oneshot_req_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("input", json_value) -> 
      v.input <- Pbrt_yojson.string json_value "oneshot_req" "input"
    | ("timeout", json_value) -> 
      v.timeout <- Some (Pbrt_yojson.float json_value "oneshot_req" "timeout")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    input = v.input;
    timeout = v.timeout;
  } : oneshot_req)

let rec decode_json_oneshot_res_stats d =
  let v = default_oneshot_res_stats_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("time", json_value) -> 
      v.time <- Pbrt_yojson.float json_value "oneshot_res_stats" "time"
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    time = v.time;
  } : oneshot_res_stats)

let rec decode_json_oneshot_res d =
  let v = default_oneshot_res_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("results", `List l) -> begin
      v.results <- List.map (function
        | json_value -> Pbrt_yojson.string json_value "oneshot_res" "results"
      ) l;
    end
    | ("errors", `List l) -> begin
      v.errors <- List.map (function
        | json_value -> Pbrt_yojson.string json_value "oneshot_res" "errors"
      ) l;
    end
    | ("stats", json_value) -> 
      v.stats <- Some ((decode_json_oneshot_res_stats json_value))
    | ("detailedResults", `List l) -> begin
      v.detailed_results <- List.map (function
        | json_value -> Pbrt_yojson.string json_value "oneshot_res" "detailed_results"
      ) l;
    end
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    results = v.results;
    errors = v.errors;
    stats = v.stats;
    detailed_results = v.detailed_results;
  } : oneshot_res)

module Simple = struct
  open Pbrt_services.Value_mode
  module Client = struct
    open Pbrt_services
    
    let status : (Utils.empty, unary, Utils.string_msg, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"simple"]
        ~service_name:"Simple" ~rpc_name:"status"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:Utils.encode_json_empty
        ~encode_pb_req:Utils.encode_pb_empty
        ~decode_json_res:Utils.decode_json_string_msg
        ~decode_pb_res:Utils.decode_pb_string_msg
        () : (Utils.empty, unary, Utils.string_msg, unary) Client.rpc)
    open Pbrt_services
    
    let shutdown : (Utils.empty, unary, Utils.empty, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"simple"]
        ~service_name:"Simple" ~rpc_name:"shutdown"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:Utils.encode_json_empty
        ~encode_pb_req:Utils.encode_pb_empty
        ~decode_json_res:Utils.decode_json_empty
        ~decode_pb_res:Utils.decode_pb_empty
        () : (Utils.empty, unary, Utils.empty, unary) Client.rpc)
    open Pbrt_services
    
    let create_session : (session_create_req, unary, Session.session, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"simple"]
        ~service_name:"Simple" ~rpc_name:"create_session"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_session_create_req
        ~encode_pb_req:encode_pb_session_create_req
        ~decode_json_res:Session.decode_json_session
        ~decode_pb_res:Session.decode_pb_session
        () : (session_create_req, unary, Session.session, unary) Client.rpc)
    open Pbrt_services
    
    let end_session : (Session.session, unary, Utils.empty, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"simple"]
        ~service_name:"Simple" ~rpc_name:"end_session"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:Session.encode_json_session
        ~encode_pb_req:Session.encode_pb_session
        ~decode_json_res:Utils.decode_json_empty
        ~decode_pb_res:Utils.decode_pb_empty
        () : (Session.session, unary, Utils.empty, unary) Client.rpc)
    open Pbrt_services
    
    let eval_src : (eval_src_req, unary, eval_res, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"simple"]
        ~service_name:"Simple" ~rpc_name:"eval_src"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_eval_src_req
        ~encode_pb_req:encode_pb_eval_src_req
        ~decode_json_res:decode_json_eval_res
        ~decode_pb_res:decode_pb_eval_res
        () : (eval_src_req, unary, eval_res, unary) Client.rpc)
    open Pbrt_services
    
    let verify_src : (verify_src_req, unary, verify_res, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"simple"]
        ~service_name:"Simple" ~rpc_name:"verify_src"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_verify_src_req
        ~encode_pb_req:encode_pb_verify_src_req
        ~decode_json_res:decode_json_verify_res
        ~decode_pb_res:decode_pb_verify_res
        () : (verify_src_req, unary, verify_res, unary) Client.rpc)
    open Pbrt_services
    
    let verify_name : (verify_name_req, unary, verify_res, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"simple"]
        ~service_name:"Simple" ~rpc_name:"verify_name"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_verify_name_req
        ~encode_pb_req:encode_pb_verify_name_req
        ~decode_json_res:decode_json_verify_res
        ~decode_pb_res:decode_pb_verify_res
        () : (verify_name_req, unary, verify_res, unary) Client.rpc)
    open Pbrt_services
    
    let instance_src : (instance_src_req, unary, instance_res, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"simple"]
        ~service_name:"Simple" ~rpc_name:"instance_src"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_instance_src_req
        ~encode_pb_req:encode_pb_instance_src_req
        ~decode_json_res:decode_json_instance_res
        ~decode_pb_res:decode_pb_instance_res
        () : (instance_src_req, unary, instance_res, unary) Client.rpc)
    open Pbrt_services
    
    let instance_name : (instance_name_req, unary, instance_res, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"simple"]
        ~service_name:"Simple" ~rpc_name:"instance_name"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_instance_name_req
        ~encode_pb_req:encode_pb_instance_name_req
        ~decode_json_res:decode_json_instance_res
        ~decode_pb_res:decode_pb_instance_res
        () : (instance_name_req, unary, instance_res, unary) Client.rpc)
    open Pbrt_services
    
    let decompose : (decompose_req, unary, decompose_res, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"simple"]
        ~service_name:"Simple" ~rpc_name:"decompose"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_decompose_req
        ~encode_pb_req:encode_pb_decompose_req
        ~decode_json_res:decode_json_decompose_res
        ~decode_pb_res:decode_pb_decompose_res
        () : (decompose_req, unary, decompose_res, unary) Client.rpc)
    open Pbrt_services
    
    let decompose_full : (decompose_req_full, unary, decompose_res, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"simple"]
        ~service_name:"Simple" ~rpc_name:"decompose_full"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_decompose_req_full
        ~encode_pb_req:encode_pb_decompose_req_full
        ~decode_json_res:decode_json_decompose_res
        ~decode_pb_res:decode_pb_decompose_res
        () : (decompose_req_full, unary, decompose_res, unary) Client.rpc)
    open Pbrt_services
    
    let typecheck : (typecheck_req, unary, typecheck_res, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"simple"]
        ~service_name:"Simple" ~rpc_name:"typecheck"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_typecheck_req
        ~encode_pb_req:encode_pb_typecheck_req
        ~decode_json_res:decode_json_typecheck_res
        ~decode_pb_res:decode_pb_typecheck_res
        () : (typecheck_req, unary, typecheck_res, unary) Client.rpc)
    open Pbrt_services
    
    let oneshot : (oneshot_req, unary, oneshot_res, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"simple"]
        ~service_name:"Simple" ~rpc_name:"oneshot"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_oneshot_req
        ~encode_pb_req:encode_pb_oneshot_req
        ~decode_json_res:decode_json_oneshot_res
        ~decode_pb_res:decode_pb_oneshot_res
        () : (oneshot_req, unary, oneshot_res, unary) Client.rpc)
  end
  
  module Server = struct
    open Pbrt_services
    
    let status : (Utils.empty,unary,Utils.string_msg,unary) Server.rpc = 
      (Server.mk_rpc ~name:"status"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:Utils.encode_json_string_msg
        ~encode_pb_res:Utils.encode_pb_string_msg
        ~decode_json_req:Utils.decode_json_empty
        ~decode_pb_req:Utils.decode_pb_empty
        () : _ Server.rpc)
    
    let shutdown : (Utils.empty,unary,Utils.empty,unary) Server.rpc = 
      (Server.mk_rpc ~name:"shutdown"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:Utils.encode_json_empty
        ~encode_pb_res:Utils.encode_pb_empty
        ~decode_json_req:Utils.decode_json_empty
        ~decode_pb_req:Utils.decode_pb_empty
        () : _ Server.rpc)
    
    let create_session : (session_create_req,unary,Session.session,unary) Server.rpc = 
      (Server.mk_rpc ~name:"create_session"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:Session.encode_json_session
        ~encode_pb_res:Session.encode_pb_session
        ~decode_json_req:decode_json_session_create_req
        ~decode_pb_req:decode_pb_session_create_req
        () : _ Server.rpc)
    
    let end_session : (Session.session,unary,Utils.empty,unary) Server.rpc = 
      (Server.mk_rpc ~name:"end_session"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:Utils.encode_json_empty
        ~encode_pb_res:Utils.encode_pb_empty
        ~decode_json_req:Session.decode_json_session
        ~decode_pb_req:Session.decode_pb_session
        () : _ Server.rpc)
    
    let eval_src : (eval_src_req,unary,eval_res,unary) Server.rpc = 
      (Server.mk_rpc ~name:"eval_src"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_eval_res
        ~encode_pb_res:encode_pb_eval_res
        ~decode_json_req:decode_json_eval_src_req
        ~decode_pb_req:decode_pb_eval_src_req
        () : _ Server.rpc)
    
    let verify_src : (verify_src_req,unary,verify_res,unary) Server.rpc = 
      (Server.mk_rpc ~name:"verify_src"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_verify_res
        ~encode_pb_res:encode_pb_verify_res
        ~decode_json_req:decode_json_verify_src_req
        ~decode_pb_req:decode_pb_verify_src_req
        () : _ Server.rpc)
    
    let verify_name : (verify_name_req,unary,verify_res,unary) Server.rpc = 
      (Server.mk_rpc ~name:"verify_name"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_verify_res
        ~encode_pb_res:encode_pb_verify_res
        ~decode_json_req:decode_json_verify_name_req
        ~decode_pb_req:decode_pb_verify_name_req
        () : _ Server.rpc)
    
    let instance_src : (instance_src_req,unary,instance_res,unary) Server.rpc = 
      (Server.mk_rpc ~name:"instance_src"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_instance_res
        ~encode_pb_res:encode_pb_instance_res
        ~decode_json_req:decode_json_instance_src_req
        ~decode_pb_req:decode_pb_instance_src_req
        () : _ Server.rpc)
    
    let instance_name : (instance_name_req,unary,instance_res,unary) Server.rpc = 
      (Server.mk_rpc ~name:"instance_name"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_instance_res
        ~encode_pb_res:encode_pb_instance_res
        ~decode_json_req:decode_json_instance_name_req
        ~decode_pb_req:decode_pb_instance_name_req
        () : _ Server.rpc)
    
    let decompose : (decompose_req,unary,decompose_res,unary) Server.rpc = 
      (Server.mk_rpc ~name:"decompose"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_decompose_res
        ~encode_pb_res:encode_pb_decompose_res
        ~decode_json_req:decode_json_decompose_req
        ~decode_pb_req:decode_pb_decompose_req
        () : _ Server.rpc)
    
    let decompose_full : (decompose_req_full,unary,decompose_res,unary) Server.rpc = 
      (Server.mk_rpc ~name:"decompose_full"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_decompose_res
        ~encode_pb_res:encode_pb_decompose_res
        ~decode_json_req:decode_json_decompose_req_full
        ~decode_pb_req:decode_pb_decompose_req_full
        () : _ Server.rpc)
    
    let typecheck : (typecheck_req,unary,typecheck_res,unary) Server.rpc = 
      (Server.mk_rpc ~name:"typecheck"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_typecheck_res
        ~encode_pb_res:encode_pb_typecheck_res
        ~decode_json_req:decode_json_typecheck_req
        ~decode_pb_req:decode_pb_typecheck_req
        () : _ Server.rpc)
    
    let oneshot : (oneshot_req,unary,oneshot_res,unary) Server.rpc = 
      (Server.mk_rpc ~name:"oneshot"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_oneshot_res
        ~encode_pb_res:encode_pb_oneshot_res
        ~decode_json_req:decode_json_oneshot_req
        ~decode_pb_req:decode_pb_oneshot_req
        () : _ Server.rpc)
    
    let make
      ~status:__handler__status
      ~shutdown:__handler__shutdown
      ~create_session:__handler__create_session
      ~end_session:__handler__end_session
      ~eval_src:__handler__eval_src
      ~verify_src:__handler__verify_src
      ~verify_name:__handler__verify_name
      ~instance_src:__handler__instance_src
      ~instance_name:__handler__instance_name
      ~decompose:__handler__decompose
      ~decompose_full:__handler__decompose_full
      ~typecheck:__handler__typecheck
      ~oneshot:__handler__oneshot
      () : _ Server.t =
      { Server.
        service_name="Simple";
        package=["imandrax";"simple"];
        handlers=[
           (__handler__status status);
           (__handler__shutdown shutdown);
           (__handler__create_session create_session);
           (__handler__end_session end_session);
           (__handler__eval_src eval_src);
           (__handler__verify_src verify_src);
           (__handler__verify_name verify_name);
           (__handler__instance_src instance_src);
           (__handler__instance_name instance_name);
           (__handler__decompose decompose);
           (__handler__decompose_full decompose_full);
           (__handler__typecheck typecheck);
           (__handler__oneshot oneshot);
        ];
      }
  end
  
end
