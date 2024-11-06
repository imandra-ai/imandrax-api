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

type eval_res = {
  success : bool;
  messages : string list;
  errors : Error.error list;
  tasks : Task.task list;
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
  artifact : Artmsg.art option;
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
  () : decompose_req  = {
  session;
  name;
  assuming;
  basis;
  rule_specs;
  prune;
  ctx_simp;
  lift_bool;
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
  () : eval_src_req  = {
  session;
  src;
}

let rec default_eval_res 
  ?success:((success:bool) = false)
  ?messages:((messages:string list) = [])
  ?errors:((errors:Error.error list) = [])
  ?tasks:((tasks:Task.task list) = [])
  () : eval_res  = {
  success;
  messages;
  errors;
  tasks;
}

let rec default_hints_unroll 
  ?smt_solver:((smt_solver:string option) = None)
  ?max_steps:((max_steps:int32 option) = None)
  () : hints_unroll  = {
  smt_solver;
  max_steps;
}

let rec default_hints_induct_functional 
  ?f_name:((f_name:string) = "")
  () : hints_induct_functional  = {
  f_name;
}

let rec default_hints_induct_structural_style () = (Additive:hints_induct_structural_style)

let rec default_hints_induct_structural 
  ?style:((style:hints_induct_structural_style) = default_hints_induct_structural_style ())
  ?vars:((vars:string list) = [])
  () : hints_induct_structural  = {
  style;
  vars;
}

let rec default_hints_induct (): hints_induct = Default

let rec default_hints (): hints = Auto

let rec default_verify_src_req 
  ?session:((session:Session.session option) = None)
  ?src:((src:string) = "")
  ?hints:((hints:hints option) = None)
  () : verify_src_req  = {
  session;
  src;
  hints;
}

let rec default_verify_name_req 
  ?session:((session:Session.session option) = None)
  ?name:((name:string) = "")
  ?hints:((hints:hints option) = None)
  () : verify_name_req  = {
  session;
  name;
  hints;
}

let rec default_instance_src_req 
  ?session:((session:Session.session option) = None)
  ?src:((src:string) = "")
  ?hints:((hints:hints option) = None)
  () : instance_src_req  = {
  session;
  src;
  hints;
}

let rec default_instance_name_req 
  ?session:((session:Session.session option) = None)
  ?name:((name:string) = "")
  ?hints:((hints:hints option) = None)
  () : instance_name_req  = {
  session;
  name;
  hints;
}

let rec default_proved 
  ?proof_pp:((proof_pp:string option) = None)
  () : proved  = {
  proof_pp;
}

let rec default_unsat 
  ?proof_pp:((proof_pp:string option) = None)
  () : unsat  = {
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
}

let default_eval_src_req_mutable () : eval_src_req_mutable = {
  session = None;
  src = "";
}

type eval_res_mutable = {
  mutable success : bool;
  mutable messages : string list;
  mutable errors : Error.error list;
  mutable tasks : Task.task list;
}

let default_eval_res_mutable () : eval_res_mutable = {
  success = false;
  messages = [];
  errors = [];
  tasks = [];
}

type hints_unroll_mutable = {
  mutable smt_solver : string option;
  mutable max_steps : int32 option;
}

let default_hints_unroll_mutable () : hints_unroll_mutable = {
  smt_solver = None;
  max_steps = None;
}

type hints_induct_functional_mutable = {
  mutable f_name : string;
}

let default_hints_induct_functional_mutable () : hints_induct_functional_mutable = {
  f_name = "";
}

type hints_induct_structural_mutable = {
  mutable style : hints_induct_structural_style;
  mutable vars : string list;
}

let default_hints_induct_structural_mutable () : hints_induct_structural_mutable = {
  style = default_hints_induct_structural_style ();
  vars = [];
}

type verify_src_req_mutable = {
  mutable session : Session.session option;
  mutable src : string;
  mutable hints : hints option;
}

let default_verify_src_req_mutable () : verify_src_req_mutable = {
  session = None;
  src = "";
  hints = None;
}

type verify_name_req_mutable = {
  mutable session : Session.session option;
  mutable name : string;
  mutable hints : hints option;
}

let default_verify_name_req_mutable () : verify_name_req_mutable = {
  session = None;
  name = "";
  hints = None;
}

type instance_src_req_mutable = {
  mutable session : Session.session option;
  mutable src : string;
  mutable hints : hints option;
}

let default_instance_src_req_mutable () : instance_src_req_mutable = {
  session = None;
  src = "";
  hints = None;
}

type instance_name_req_mutable = {
  mutable session : Session.session option;
  mutable name : string;
  mutable hints : hints option;
}

let default_instance_name_req_mutable () : instance_name_req_mutable = {
  session = None;
  name = "";
  hints = None;
}

type proved_mutable = {
  mutable proof_pp : string option;
}

let default_proved_mutable () : proved_mutable = {
  proof_pp = None;
}

type unsat_mutable = {
  mutable proof_pp : string option;
}

let default_unsat_mutable () : unsat_mutable = {
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
  () : decompose_req  = {
  session;
  name;
  assuming;
  basis;
  rule_specs;
  prune;
  ctx_simp;
  lift_bool;
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
  () : eval_src_req  = {
  session;
  src;
}

let rec make_eval_res 
  ~(success:bool)
  ~(messages:string list)
  ~(errors:Error.error list)
  ~(tasks:Task.task list)
  () : eval_res  = {
  success;
  messages;
  errors;
  tasks;
}

let rec make_hints_unroll 
  ?smt_solver:((smt_solver:string option) = None)
  ?max_steps:((max_steps:int32 option) = None)
  () : hints_unroll  = {
  smt_solver;
  max_steps;
}

let rec make_hints_induct_functional 
  ~(f_name:string)
  () : hints_induct_functional  = {
  f_name;
}


let rec make_hints_induct_structural 
  ~(style:hints_induct_structural_style)
  ~(vars:string list)
  () : hints_induct_structural  = {
  style;
  vars;
}



let rec make_verify_src_req 
  ?session:((session:Session.session option) = None)
  ~(src:string)
  ?hints:((hints:hints option) = None)
  () : verify_src_req  = {
  session;
  src;
  hints;
}

let rec make_verify_name_req 
  ?session:((session:Session.session option) = None)
  ~(name:string)
  ?hints:((hints:hints option) = None)
  () : verify_name_req  = {
  session;
  name;
  hints;
}

let rec make_instance_src_req 
  ?session:((session:Session.session option) = None)
  ~(src:string)
  ?hints:((hints:hints option) = None)
  () : instance_src_req  = {
  session;
  src;
  hints;
}

let rec make_instance_name_req 
  ?session:((session:Session.session option) = None)
  ~(name:string)
  ?hints:((hints:hints option) = None)
  () : instance_name_req  = {
  session;
  name;
  hints;
}

let rec make_proved 
  ?proof_pp:((proof_pp:string option) = None)
  () : proved  = {
  proof_pp;
}

let rec make_unsat 
  ?proof_pp:((proof_pp:string option) = None)
  () : unsat  = {
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
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_eval_res fmt (v:eval_res) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "success" Pbrt.Pp.pp_bool fmt v.success;
    Pbrt.Pp.pp_record_field ~first:false "messages" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.messages;
    Pbrt.Pp.pp_record_field ~first:false "errors" (Pbrt.Pp.pp_list Error.pp_error) fmt v.errors;
    Pbrt.Pp.pp_record_field ~first:false "tasks" (Pbrt.Pp.pp_list Task.pp_task) fmt v.tasks;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_hints_unroll fmt (v:hints_unroll) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "smt_solver" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.smt_solver;
    Pbrt.Pp.pp_record_field ~first:false "max_steps" (Pbrt.Pp.pp_option Pbrt.Pp.pp_int32) fmt v.max_steps;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_hints_induct_functional fmt (v:hints_induct_functional) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "f_name" Pbrt.Pp.pp_string fmt v.f_name;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_hints_induct_structural_style fmt (v:hints_induct_structural_style) =
  match v with
  | Additive -> Format.fprintf fmt "Additive"
  | Multiplicative -> Format.fprintf fmt "Multiplicative"

let rec pp_hints_induct_structural fmt (v:hints_induct_structural) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "style" pp_hints_induct_structural_style fmt v.style;
    Pbrt.Pp.pp_record_field ~first:false "vars" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.vars;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_hints_induct fmt (v:hints_induct) =
  match v with
  | Default  -> Format.fprintf fmt "Default"
  | Functional x -> Format.fprintf fmt "@[<hv2>Functional(@,%a)@]" pp_hints_induct_functional x
  | Structural x -> Format.fprintf fmt "@[<hv2>Structural(@,%a)@]" pp_hints_induct_structural x

let rec pp_hints fmt (v:hints) =
  match v with
  | Auto  -> Format.fprintf fmt "Auto"
  | Unroll x -> Format.fprintf fmt "@[<hv2>Unroll(@,%a)@]" pp_hints_unroll x
  | Induct x -> Format.fprintf fmt "@[<hv2>Induct(@,%a)@]" pp_hints_induct x

let rec pp_verify_src_req fmt (v:verify_src_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~first:false "src" Pbrt.Pp.pp_string fmt v.src;
    Pbrt.Pp.pp_record_field ~first:false "hints" (Pbrt.Pp.pp_option pp_hints) fmt v.hints;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_verify_name_req fmt (v:verify_name_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~first:false "name" Pbrt.Pp.pp_string fmt v.name;
    Pbrt.Pp.pp_record_field ~first:false "hints" (Pbrt.Pp.pp_option pp_hints) fmt v.hints;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_instance_src_req fmt (v:instance_src_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~first:false "src" Pbrt.Pp.pp_string fmt v.src;
    Pbrt.Pp.pp_record_field ~first:false "hints" (Pbrt.Pp.pp_option pp_hints) fmt v.hints;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_instance_name_req fmt (v:instance_name_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~first:false "name" Pbrt.Pp.pp_string fmt v.name;
    Pbrt.Pp.pp_record_field ~first:false "hints" (Pbrt.Pp.pp_option pp_hints) fmt v.hints;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_proved fmt (v:proved) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "proof_pp" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.proof_pp;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_unsat fmt (v:unsat) = 
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
  ()

let rec encode_pb_hints_unroll (v:hints_unroll) encoder = 
  begin match v.smt_solver with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  begin match v.max_steps with
  | Some x -> 
    Pbrt.Encoder.int32_as_varint x encoder;
    Pbrt.Encoder.key 11 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_hints_induct_functional (v:hints_induct_functional) encoder = 
  Pbrt.Encoder.string v.f_name encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ()

let rec encode_pb_hints_induct_structural_style (v:hints_induct_structural_style) encoder =
  match v with
  | Additive -> Pbrt.Encoder.int_as_varint (0) encoder
  | Multiplicative -> Pbrt.Encoder.int_as_varint 1 encoder

let rec encode_pb_hints_induct_structural (v:hints_induct_structural) encoder = 
  encode_pb_hints_induct_structural_style v.style encoder;
  Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  ) v.vars encoder;
  ()

let rec encode_pb_hints_induct (v:hints_induct) encoder = 
  begin match v with
  | Default ->
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
    Pbrt.Encoder.empty_nested encoder
  | Functional x ->
    Pbrt.Encoder.nested encode_pb_hints_induct_functional x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | Structural x ->
    Pbrt.Encoder.nested encode_pb_hints_induct_structural x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  end

let rec encode_pb_hints (v:hints) encoder = 
  begin match v with
  | Auto ->
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
    Pbrt.Encoder.empty_nested encoder
  | Unroll x ->
    Pbrt.Encoder.nested encode_pb_hints_unroll x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | Induct x ->
    Pbrt.Encoder.nested encode_pb_hints_induct x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  end

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
    Pbrt.Encoder.nested encode_pb_hints x encoder;
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
    Pbrt.Encoder.nested encode_pb_hints x encoder;
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
    Pbrt.Encoder.nested encode_pb_hints x encoder;
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
    Pbrt.Encoder.nested encode_pb_hints x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_proved (v:proved) encoder = 
  begin match v.proof_pp with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
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
  } : decompose_req)

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
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    session = v.session;
    src = v.src;
  } : eval_src_req)

let rec decode_pb_eval_res d =
  let v = default_eval_res_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
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
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    success = v.success;
    messages = v.messages;
    errors = v.errors;
    tasks = v.tasks;
  } : eval_res)

let rec decode_pb_hints_unroll d =
  let v = default_hints_unroll_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (10, Pbrt.Bytes) -> begin
      v.smt_solver <- Some (Pbrt.Decoder.string d);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(hints_unroll), field(10)" pk
    | Some (11, Pbrt.Varint) -> begin
      v.max_steps <- Some (Pbrt.Decoder.int32_as_varint d);
    end
    | Some (11, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(hints_unroll), field(11)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    smt_solver = v.smt_solver;
    max_steps = v.max_steps;
  } : hints_unroll)

let rec decode_pb_hints_induct_functional d =
  let v = default_hints_induct_functional_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.f_name <- Pbrt.Decoder.string d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(hints_induct_functional), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    f_name = v.f_name;
  } : hints_induct_functional)

let rec decode_pb_hints_induct_structural_style d = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> (Additive:hints_induct_structural_style)
  | 1 -> (Multiplicative:hints_induct_structural_style)
  | _ -> Pbrt.Decoder.malformed_variant "hints_induct_structural_style"

let rec decode_pb_hints_induct_structural d =
  let v = default_hints_induct_structural_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.vars <- List.rev v.vars;
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.style <- decode_pb_hints_induct_structural_style d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(hints_induct_structural), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.vars <- (Pbrt.Decoder.string d) :: v.vars;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(hints_induct_structural), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    style = v.style;
    vars = v.vars;
  } : hints_induct_structural)

let rec decode_pb_hints_induct d = 
  let rec loop () = 
    let ret:hints_induct = match Pbrt.Decoder.key d with
      | None -> Pbrt.Decoder.malformed_variant "hints_induct"
      | Some (1, _) -> begin 
        Pbrt.Decoder.empty_nested d ;
        (Default : hints_induct)
      end
      | Some (2, _) -> (Functional (decode_pb_hints_induct_functional (Pbrt.Decoder.nested d)) : hints_induct) 
      | Some (3, _) -> (Structural (decode_pb_hints_induct_structural (Pbrt.Decoder.nested d)) : hints_induct) 
      | Some (n, payload_kind) -> (
        Pbrt.Decoder.skip d payload_kind; 
        loop () 
      )
    in
    ret
  in
  loop ()

let rec decode_pb_hints d = 
  let rec loop () = 
    let ret:hints = match Pbrt.Decoder.key d with
      | None -> Pbrt.Decoder.malformed_variant "hints"
      | Some (1, _) -> begin 
        Pbrt.Decoder.empty_nested d ;
        (Auto : hints)
      end
      | Some (2, _) -> (Unroll (decode_pb_hints_unroll (Pbrt.Decoder.nested d)) : hints) 
      | Some (3, _) -> (Induct (decode_pb_hints_induct (Pbrt.Decoder.nested d)) : hints) 
      | Some (n, payload_kind) -> (
        Pbrt.Decoder.skip d payload_kind; 
        loop () 
      )
    in
    ret
  in
  loop ()

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
      v.hints <- Some (decode_pb_hints (Pbrt.Decoder.nested d));
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
      v.hints <- Some (decode_pb_hints (Pbrt.Decoder.nested d));
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
      v.hints <- Some (decode_pb_hints (Pbrt.Decoder.nested d));
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
      v.hints <- Some (decode_pb_hints (Pbrt.Decoder.nested d));
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
  `Assoc assoc

let rec encode_json_hints_unroll (v:hints_unroll) = 
  let assoc = [] in 
  let assoc = match v.smt_solver with
    | None -> assoc
    | Some v -> ("smtSolver", Pbrt_yojson.make_string v) :: assoc
  in
  let assoc = match v.max_steps with
    | None -> assoc
    | Some v -> ("maxSteps", Pbrt_yojson.make_int (Int32.to_int v)) :: assoc
  in
  `Assoc assoc

let rec encode_json_hints_induct_functional (v:hints_induct_functional) = 
  let assoc = [] in 
  let assoc = ("fName", Pbrt_yojson.make_string v.f_name) :: assoc in
  `Assoc assoc

let rec encode_json_hints_induct_structural_style (v:hints_induct_structural_style) = 
  match v with
  | Additive -> `String "Additive"
  | Multiplicative -> `String "Multiplicative"

let rec encode_json_hints_induct_structural (v:hints_induct_structural) = 
  let assoc = [] in 
  let assoc = ("style", encode_json_hints_induct_structural_style v.style) :: assoc in
  let assoc =
    let l = v.vars |> List.map Pbrt_yojson.make_string in
    ("vars", `List l) :: assoc 
  in
  `Assoc assoc

let rec encode_json_hints_induct (v:hints_induct) = 
  begin match v with
  | Default -> `Assoc [("default", `Null)]
  | Functional v -> `Assoc [("functional", encode_json_hints_induct_functional v)]
  | Structural v -> `Assoc [("structural", encode_json_hints_induct_structural v)]
  end

let rec encode_json_hints (v:hints) = 
  begin match v with
  | Auto -> `Assoc [("auto", `Null)]
  | Unroll v -> `Assoc [("unroll", encode_json_hints_unroll v)]
  | Induct v -> `Assoc [("induct", encode_json_hints_induct v)]
  end

let rec encode_json_verify_src_req (v:verify_src_req) = 
  let assoc = [] in 
  let assoc = match v.session with
    | None -> assoc
    | Some v -> ("session", Session.encode_json_session v) :: assoc
  in
  let assoc = ("src", Pbrt_yojson.make_string v.src) :: assoc in
  let assoc = match v.hints with
    | None -> assoc
    | Some v -> ("hints", encode_json_hints v) :: assoc
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
    | Some v -> ("hints", encode_json_hints v) :: assoc
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
    | Some v -> ("hints", encode_json_hints v) :: assoc
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
    | Some v -> ("hints", encode_json_hints v) :: assoc
  in
  `Assoc assoc

let rec encode_json_proved (v:proved) = 
  let assoc = [] in 
  let assoc = match v.proof_pp with
    | None -> assoc
    | Some v -> ("proofPp", Pbrt_yojson.make_string v) :: assoc
  in
  `Assoc assoc

let rec encode_json_unsat (v:unsat) = 
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
  end

and encode_json_verify_res (v:verify_res) = 
  let assoc = [] in 
  let assoc = match v.res with
      | Unknown v -> ("unknown", Utils.encode_json_string_msg v) :: assoc
      | Err -> ("err", `Null) :: assoc
      | Proved v -> ("proved", encode_json_proved v) :: assoc
      | Refuted v -> ("refuted", encode_json_refuted v) :: assoc
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
  } : decompose_req)

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
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    session = v.session;
    src = v.src;
  } : eval_src_req)

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
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    success = v.success;
    messages = v.messages;
    errors = v.errors;
    tasks = v.tasks;
  } : eval_res)

let rec decode_json_hints_unroll d =
  let v = default_hints_unroll_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("smtSolver", json_value) -> 
      v.smt_solver <- Some (Pbrt_yojson.string json_value "hints_unroll" "smt_solver")
    | ("maxSteps", json_value) -> 
      v.max_steps <- Some (Pbrt_yojson.int32 json_value "hints_unroll" "max_steps")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    smt_solver = v.smt_solver;
    max_steps = v.max_steps;
  } : hints_unroll)

let rec decode_json_hints_induct_functional d =
  let v = default_hints_induct_functional_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("fName", json_value) -> 
      v.f_name <- Pbrt_yojson.string json_value "hints_induct_functional" "f_name"
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    f_name = v.f_name;
  } : hints_induct_functional)

let rec decode_json_hints_induct_structural_style json =
  match json with
  | `String "Additive" -> (Additive : hints_induct_structural_style)
  | `String "Multiplicative" -> (Multiplicative : hints_induct_structural_style)
  | _ -> Pbrt_yojson.E.malformed_variant "hints_induct_structural_style"

let rec decode_json_hints_induct_structural d =
  let v = default_hints_induct_structural_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("style", json_value) -> 
      v.style <- (decode_json_hints_induct_structural_style json_value)
    | ("vars", `List l) -> begin
      v.vars <- List.map (function
        | json_value -> Pbrt_yojson.string json_value "hints_induct_structural" "vars"
      ) l;
    end
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    style = v.style;
    vars = v.vars;
  } : hints_induct_structural)

let rec decode_json_hints_induct json =
  let assoc = match json with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  let rec loop = function
    | [] -> Pbrt_yojson.E.malformed_variant "hints_induct"
    | ("default", _)::_-> (Default : hints_induct)
    | ("functional", json_value)::_ -> 
      (Functional ((decode_json_hints_induct_functional json_value)) : hints_induct)
    | ("structural", json_value)::_ -> 
      (Structural ((decode_json_hints_induct_structural json_value)) : hints_induct)
    
    | _ :: tl -> loop tl
  in
  loop assoc

let rec decode_json_hints json =
  let assoc = match json with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  let rec loop = function
    | [] -> Pbrt_yojson.E.malformed_variant "hints"
    | ("auto", _)::_-> (Auto : hints)
    | ("unroll", json_value)::_ -> 
      (Unroll ((decode_json_hints_unroll json_value)) : hints)
    | ("induct", json_value)::_ -> 
      (Induct ((decode_json_hints_induct json_value)) : hints)
    
    | _ :: tl -> loop tl
  in
  loop assoc

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
      v.hints <- Some ((decode_json_hints json_value))
    
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
      v.hints <- Some ((decode_json_hints json_value))
    
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
      v.hints <- Some ((decode_json_hints json_value))
    
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
      v.hints <- Some ((decode_json_hints json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    session = v.session;
    name = v.name;
    hints = v.hints;
  } : instance_name_req)

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
    
    let decompose : (decompose_req,unary,decompose_res,unary) Server.rpc = 
      (Server.mk_rpc ~name:"decompose"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_decompose_res
        ~encode_pb_res:encode_pb_decompose_res
        ~decode_json_req:decode_json_decompose_req
        ~decode_pb_req:decode_pb_decompose_req
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
    
    let make
      ~status:__handler__status
      ~shutdown:__handler__shutdown
      ~decompose:__handler__decompose
      ~create_session:__handler__create_session
      ~eval_src:__handler__eval_src
      ~verify_src:__handler__verify_src
      ~verify_name:__handler__verify_name
      ~instance_src:__handler__instance_src
      ~instance_name:__handler__instance_name
      () : _ Server.t =
      { Server.
        service_name="Simple";
        package=["imandrax";"simple"];
        handlers=[
           (__handler__status status);
           (__handler__shutdown shutdown);
           (__handler__decompose decompose);
           (__handler__create_session create_session);
           (__handler__eval_src eval_src);
           (__handler__verify_src verify_src);
           (__handler__verify_name verify_name);
           (__handler__instance_src instance_src);
           (__handler__instance_name instance_name);
        ];
      }
  end
  
end
