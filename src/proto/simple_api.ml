[@@@ocaml.warning "-23-27-30-39-44"]

type session_create_req = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable api_version : string;
}

type lift_bool =
  | Default 
  | Nested_equalities 
  | Equalities 
  | All 

type decompose_req = {
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

type decompose_req_full_by_name = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 5 fields *)
  mutable name : string;
  mutable assuming : string;
  mutable basis : string list;
  mutable rule_specs : string list;
  mutable prune : bool;
  mutable ctx_simp : bool;
  mutable lift_bool : lift_bool;
}

type decompose_req_full_local_var_get = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable name : string;
}

type decompose_req_full_prune = {
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

and decompose_req_full_merge = {
  mutable d1 : decompose_req_full_decomp option;
  mutable d2 : decompose_req_full_decomp option;
}

and decompose_req_full_compound_merge = {
  mutable d1 : decompose_req_full_decomp option;
  mutable d2 : decompose_req_full_decomp option;
}

and decompose_req_full_combine = {
  mutable d : decompose_req_full_decomp option;
}

and decompose_req_full_local_var_let = {
  mutable bindings : decompose_req_full_local_var_binding list;
  mutable and_then : decompose_req_full_decomp option;
}

and decompose_req_full_local_var_binding = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable name : string;
  mutable d : decompose_req_full_decomp option;
}

type decompose_req_full = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable session : Session.session option;
  mutable decomp : decompose_req_full_decomp option;
  mutable str : bool;
  mutable timeout : int32;
}

type decompose_res_res =
  | Artifact of Artmsg.art
  | Err

and decompose_res = {
  mutable res : decompose_res_res option;
  mutable errors : Error.error list;
  mutable task : Task.task option;
}

type eval_src_req = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable session : Session.session option;
  mutable src : string;
  mutable async_only : bool;
}

type eval_output = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable success : bool;
  mutable value_as_ocaml : string;
  mutable errors : Error.error list;
}

type proved = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable proof_pp : string;
}

type model_type =
  | Counter_example 
  | Instance 

type model = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable m_type : model_type;
  mutable src : string;
  mutable artifact : Artmsg.art option;
}

type counter_sat = {
  mutable model : model option;
}

type verified_upto = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable msg : string;
}

type po_res_res =
  | Unknown of Utils.string_msg
  | Err
  | Proof of proved
  | Instance of counter_sat
  | Verified_upto of verified_upto

and po_res = {
  mutable res : po_res_res option;
  mutable errors : Error.error list;
  mutable task : Task.task option;
  mutable origin : Task.origin option;
}

type eval_res = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable success : bool;
  mutable messages : string list;
  mutable errors : Error.error list;
  mutable tasks : Task.task list;
  mutable po_results : po_res list;
  mutable eval_results : eval_output list;
  mutable decomp_results : decompose_res list;
}

type verify_src_req = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable session : Session.session option;
  mutable src : string;
  mutable hints : string;
}

type verify_name_req = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable session : Session.session option;
  mutable name : string;
  mutable hints : string;
}

type instance_src_req = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable session : Session.session option;
  mutable src : string;
  mutable hints : string;
}

type instance_name_req = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable session : Session.session option;
  mutable name : string;
  mutable hints : string;
}

type unsat = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable proof_pp : string;
}

type refuted = {
  mutable model : model option;
}

type sat = {
  mutable model : model option;
}

type verify_res_res =
  | Unknown of Utils.string_msg
  | Err
  | Proved of proved
  | Refuted of refuted
  | Verified_upto of verified_upto

and verify_res = {
  mutable res : verify_res_res option;
  mutable errors : Error.error list;
  mutable task : Task.task option;
}

type instance_res_res =
  | Unknown of Utils.string_msg
  | Err
  | Unsat of unsat
  | Sat of sat

and instance_res = {
  mutable res : instance_res_res option;
  mutable errors : Error.error list;
  mutable task : Task.task option;
}

type typecheck_req = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable session : Session.session option;
  mutable src : string;
}

type typecheck_res = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable success : bool;
  mutable types : string;
  mutable errors : Error.error list;
}

type oneshot_req = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable input : string;
  mutable timeout : float;
}

type oneshot_res_stats = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable time : float;
}

type oneshot_res = {
  mutable results : string list;
  mutable errors : string list;
  mutable stats : oneshot_res_stats option;
  mutable detailed_results : string list;
}

let default_session_create_req (): session_create_req =
{
  _presence=Pbrt.Bitfield.empty;
  api_version="";
}

let default_lift_bool () = (Default:lift_bool)

let default_decompose_req (): decompose_req =
{
  _presence=Pbrt.Bitfield.empty;
  session=None;
  name="";
  assuming="";
  basis=[];
  rule_specs=[];
  prune=false;
  ctx_simp=false;
  lift_bool=default_lift_bool ();
  str=false;
  timeout=0l;
}

let default_decompose_req_full_by_name (): decompose_req_full_by_name =
{
  _presence=Pbrt.Bitfield.empty;
  name="";
  assuming="";
  basis=[];
  rule_specs=[];
  prune=false;
  ctx_simp=false;
  lift_bool=default_lift_bool ();
}

let default_decompose_req_full_local_var_get (): decompose_req_full_local_var_get =
{
  _presence=Pbrt.Bitfield.empty;
  name="";
}

let default_decompose_req_full_prune (): decompose_req_full_prune =
{
  d=None;
}

let default_decompose_req_full_decomp (): decompose_req_full_decomp = From_artifact (Artmsg.default_art ())

let default_decompose_req_full_merge (): decompose_req_full_merge =
{
  d1=None;
  d2=None;
}

let default_decompose_req_full_compound_merge (): decompose_req_full_compound_merge =
{
  d1=None;
  d2=None;
}

let default_decompose_req_full_combine (): decompose_req_full_combine =
{
  d=None;
}

let default_decompose_req_full_local_var_let (): decompose_req_full_local_var_let =
{
  bindings=[];
  and_then=None;
}

let default_decompose_req_full_local_var_binding (): decompose_req_full_local_var_binding =
{
  _presence=Pbrt.Bitfield.empty;
  name="";
  d=None;
}

let default_decompose_req_full (): decompose_req_full =
{
  _presence=Pbrt.Bitfield.empty;
  session=None;
  decomp=None;
  str=false;
  timeout=0l;
}

let default_decompose_res_res (): decompose_res_res = Artifact (Artmsg.default_art ())

let default_decompose_res (): decompose_res =
{
  res=None;
  errors=[];
  task=None;
}

let default_eval_src_req (): eval_src_req =
{
  _presence=Pbrt.Bitfield.empty;
  session=None;
  src="";
  async_only=false;
}

let default_eval_output (): eval_output =
{
  _presence=Pbrt.Bitfield.empty;
  success=false;
  value_as_ocaml="";
  errors=[];
}

let default_proved (): proved =
{
  _presence=Pbrt.Bitfield.empty;
  proof_pp="";
}

let default_model_type () = (Counter_example:model_type)

let default_model (): model =
{
  _presence=Pbrt.Bitfield.empty;
  m_type=default_model_type ();
  src="";
  artifact=None;
}

let default_counter_sat (): counter_sat =
{
  model=None;
}

let default_verified_upto (): verified_upto =
{
  _presence=Pbrt.Bitfield.empty;
  msg="";
}

let default_po_res_res (): po_res_res = Unknown (Utils.default_string_msg ())

let default_po_res (): po_res =
{
  res=None;
  errors=[];
  task=None;
  origin=None;
}

let default_eval_res (): eval_res =
{
  _presence=Pbrt.Bitfield.empty;
  success=false;
  messages=[];
  errors=[];
  tasks=[];
  po_results=[];
  eval_results=[];
  decomp_results=[];
}

let default_verify_src_req (): verify_src_req =
{
  _presence=Pbrt.Bitfield.empty;
  session=None;
  src="";
  hints="";
}

let default_verify_name_req (): verify_name_req =
{
  _presence=Pbrt.Bitfield.empty;
  session=None;
  name="";
  hints="";
}

let default_instance_src_req (): instance_src_req =
{
  _presence=Pbrt.Bitfield.empty;
  session=None;
  src="";
  hints="";
}

let default_instance_name_req (): instance_name_req =
{
  _presence=Pbrt.Bitfield.empty;
  session=None;
  name="";
  hints="";
}

let default_unsat (): unsat =
{
  _presence=Pbrt.Bitfield.empty;
  proof_pp="";
}

let default_refuted (): refuted =
{
  model=None;
}

let default_sat (): sat =
{
  model=None;
}

let default_verify_res_res (): verify_res_res = Unknown (Utils.default_string_msg ())

let default_verify_res (): verify_res =
{
  res=None;
  errors=[];
  task=None;
}

let default_instance_res_res (): instance_res_res = Unknown (Utils.default_string_msg ())

let default_instance_res (): instance_res =
{
  res=None;
  errors=[];
  task=None;
}

let default_typecheck_req (): typecheck_req =
{
  _presence=Pbrt.Bitfield.empty;
  session=None;
  src="";
}

let default_typecheck_res (): typecheck_res =
{
  _presence=Pbrt.Bitfield.empty;
  success=false;
  types="";
  errors=[];
}

let default_oneshot_req (): oneshot_req =
{
  _presence=Pbrt.Bitfield.empty;
  input="";
  timeout=0.;
}

let default_oneshot_res_stats (): oneshot_res_stats =
{
  _presence=Pbrt.Bitfield.empty;
  time=0.;
}

let default_oneshot_res (): oneshot_res =
{
  results=[];
  errors=[];
  stats=None;
  detailed_results=[];
}


(** {2 Make functions} *)

let[@inline] session_create_req_has_api_version (self:session_create_req) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] session_create_req_set_api_version (self:session_create_req) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.api_version <- x

let copy_session_create_req (self:session_create_req) : session_create_req =
  { self with api_version = self.api_version }

let make_session_create_req 
  ?(api_version:string option)
  () : session_create_req  =
  let _res = default_session_create_req () in
  (match api_version with
  | None -> ()
  | Some v -> session_create_req_set_api_version _res v);
  _res

let[@inline] decompose_req_has_name (self:decompose_req) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] decompose_req_has_assuming (self:decompose_req) : bool = (Pbrt.Bitfield.get self._presence 1)
let[@inline] decompose_req_has_prune (self:decompose_req) : bool = (Pbrt.Bitfield.get self._presence 2)
let[@inline] decompose_req_has_ctx_simp (self:decompose_req) : bool = (Pbrt.Bitfield.get self._presence 3)
let[@inline] decompose_req_has_lift_bool (self:decompose_req) : bool = (Pbrt.Bitfield.get self._presence 4)
let[@inline] decompose_req_has_str (self:decompose_req) : bool = (Pbrt.Bitfield.get self._presence 5)
let[@inline] decompose_req_has_timeout (self:decompose_req) : bool = (Pbrt.Bitfield.get self._presence 6)

let[@inline] decompose_req_set_session (self:decompose_req) (x:Session.session) : unit =
  self.session <- Some x
let[@inline] decompose_req_set_name (self:decompose_req) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.name <- x
let[@inline] decompose_req_set_assuming (self:decompose_req) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.assuming <- x
let[@inline] decompose_req_set_basis (self:decompose_req) (x:string list) : unit =
  self.basis <- x
let[@inline] decompose_req_set_rule_specs (self:decompose_req) (x:string list) : unit =
  self.rule_specs <- x
let[@inline] decompose_req_set_prune (self:decompose_req) (x:bool) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 2); self.prune <- x
let[@inline] decompose_req_set_ctx_simp (self:decompose_req) (x:bool) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 3); self.ctx_simp <- x
let[@inline] decompose_req_set_lift_bool (self:decompose_req) (x:lift_bool) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 4); self.lift_bool <- x
let[@inline] decompose_req_set_str (self:decompose_req) (x:bool) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 5); self.str <- x
let[@inline] decompose_req_set_timeout (self:decompose_req) (x:int32) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 6); self.timeout <- x

let copy_decompose_req (self:decompose_req) : decompose_req =
  { self with session = self.session }

let make_decompose_req 
  ?(session:Session.session option)
  ?(name:string option)
  ?(assuming:string option)
  ?(basis=[])
  ?(rule_specs=[])
  ?(prune:bool option)
  ?(ctx_simp:bool option)
  ?(lift_bool:lift_bool option)
  ?(str:bool option)
  ?(timeout:int32 option)
  () : decompose_req  =
  let _res = default_decompose_req () in
  (match session with
  | None -> ()
  | Some v -> decompose_req_set_session _res v);
  (match name with
  | None -> ()
  | Some v -> decompose_req_set_name _res v);
  (match assuming with
  | None -> ()
  | Some v -> decompose_req_set_assuming _res v);
  decompose_req_set_basis _res basis;
  decompose_req_set_rule_specs _res rule_specs;
  (match prune with
  | None -> ()
  | Some v -> decompose_req_set_prune _res v);
  (match ctx_simp with
  | None -> ()
  | Some v -> decompose_req_set_ctx_simp _res v);
  (match lift_bool with
  | None -> ()
  | Some v -> decompose_req_set_lift_bool _res v);
  (match str with
  | None -> ()
  | Some v -> decompose_req_set_str _res v);
  (match timeout with
  | None -> ()
  | Some v -> decompose_req_set_timeout _res v);
  _res

let[@inline] decompose_req_full_by_name_has_name (self:decompose_req_full_by_name) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] decompose_req_full_by_name_has_assuming (self:decompose_req_full_by_name) : bool = (Pbrt.Bitfield.get self._presence 1)
let[@inline] decompose_req_full_by_name_has_prune (self:decompose_req_full_by_name) : bool = (Pbrt.Bitfield.get self._presence 2)
let[@inline] decompose_req_full_by_name_has_ctx_simp (self:decompose_req_full_by_name) : bool = (Pbrt.Bitfield.get self._presence 3)
let[@inline] decompose_req_full_by_name_has_lift_bool (self:decompose_req_full_by_name) : bool = (Pbrt.Bitfield.get self._presence 4)

let[@inline] decompose_req_full_by_name_set_name (self:decompose_req_full_by_name) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.name <- x
let[@inline] decompose_req_full_by_name_set_assuming (self:decompose_req_full_by_name) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.assuming <- x
let[@inline] decompose_req_full_by_name_set_basis (self:decompose_req_full_by_name) (x:string list) : unit =
  self.basis <- x
let[@inline] decompose_req_full_by_name_set_rule_specs (self:decompose_req_full_by_name) (x:string list) : unit =
  self.rule_specs <- x
let[@inline] decompose_req_full_by_name_set_prune (self:decompose_req_full_by_name) (x:bool) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 2); self.prune <- x
let[@inline] decompose_req_full_by_name_set_ctx_simp (self:decompose_req_full_by_name) (x:bool) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 3); self.ctx_simp <- x
let[@inline] decompose_req_full_by_name_set_lift_bool (self:decompose_req_full_by_name) (x:lift_bool) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 4); self.lift_bool <- x

let copy_decompose_req_full_by_name (self:decompose_req_full_by_name) : decompose_req_full_by_name =
  { self with name = self.name }

let make_decompose_req_full_by_name 
  ?(name:string option)
  ?(assuming:string option)
  ?(basis=[])
  ?(rule_specs=[])
  ?(prune:bool option)
  ?(ctx_simp:bool option)
  ?(lift_bool:lift_bool option)
  () : decompose_req_full_by_name  =
  let _res = default_decompose_req_full_by_name () in
  (match name with
  | None -> ()
  | Some v -> decompose_req_full_by_name_set_name _res v);
  (match assuming with
  | None -> ()
  | Some v -> decompose_req_full_by_name_set_assuming _res v);
  decompose_req_full_by_name_set_basis _res basis;
  decompose_req_full_by_name_set_rule_specs _res rule_specs;
  (match prune with
  | None -> ()
  | Some v -> decompose_req_full_by_name_set_prune _res v);
  (match ctx_simp with
  | None -> ()
  | Some v -> decompose_req_full_by_name_set_ctx_simp _res v);
  (match lift_bool with
  | None -> ()
  | Some v -> decompose_req_full_by_name_set_lift_bool _res v);
  _res

let[@inline] decompose_req_full_local_var_get_has_name (self:decompose_req_full_local_var_get) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] decompose_req_full_local_var_get_set_name (self:decompose_req_full_local_var_get) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.name <- x

let copy_decompose_req_full_local_var_get (self:decompose_req_full_local_var_get) : decompose_req_full_local_var_get =
  { self with name = self.name }

let make_decompose_req_full_local_var_get 
  ?(name:string option)
  () : decompose_req_full_local_var_get  =
  let _res = default_decompose_req_full_local_var_get () in
  (match name with
  | None -> ()
  | Some v -> decompose_req_full_local_var_get_set_name _res v);
  _res


let[@inline] decompose_req_full_prune_set_d (self:decompose_req_full_prune) (x:decompose_req_full_decomp) : unit =
  self.d <- Some x

let copy_decompose_req_full_prune (self:decompose_req_full_prune) : decompose_req_full_prune =
  { self with d = self.d }

let make_decompose_req_full_prune 
  ?(d:decompose_req_full_decomp option)
  () : decompose_req_full_prune  =
  let _res = default_decompose_req_full_prune () in
  (match d with
  | None -> ()
  | Some v -> decompose_req_full_prune_set_d _res v);
  _res


let[@inline] decompose_req_full_merge_set_d1 (self:decompose_req_full_merge) (x:decompose_req_full_decomp) : unit =
  self.d1 <- Some x
let[@inline] decompose_req_full_merge_set_d2 (self:decompose_req_full_merge) (x:decompose_req_full_decomp) : unit =
  self.d2 <- Some x

let copy_decompose_req_full_merge (self:decompose_req_full_merge) : decompose_req_full_merge =
  { self with d1 = self.d1 }

let make_decompose_req_full_merge 
  ?(d1:decompose_req_full_decomp option)
  ?(d2:decompose_req_full_decomp option)
  () : decompose_req_full_merge  =
  let _res = default_decompose_req_full_merge () in
  (match d1 with
  | None -> ()
  | Some v -> decompose_req_full_merge_set_d1 _res v);
  (match d2 with
  | None -> ()
  | Some v -> decompose_req_full_merge_set_d2 _res v);
  _res


let[@inline] decompose_req_full_compound_merge_set_d1 (self:decompose_req_full_compound_merge) (x:decompose_req_full_decomp) : unit =
  self.d1 <- Some x
let[@inline] decompose_req_full_compound_merge_set_d2 (self:decompose_req_full_compound_merge) (x:decompose_req_full_decomp) : unit =
  self.d2 <- Some x

let copy_decompose_req_full_compound_merge (self:decompose_req_full_compound_merge) : decompose_req_full_compound_merge =
  { self with d1 = self.d1 }

let make_decompose_req_full_compound_merge 
  ?(d1:decompose_req_full_decomp option)
  ?(d2:decompose_req_full_decomp option)
  () : decompose_req_full_compound_merge  =
  let _res = default_decompose_req_full_compound_merge () in
  (match d1 with
  | None -> ()
  | Some v -> decompose_req_full_compound_merge_set_d1 _res v);
  (match d2 with
  | None -> ()
  | Some v -> decompose_req_full_compound_merge_set_d2 _res v);
  _res


let[@inline] decompose_req_full_combine_set_d (self:decompose_req_full_combine) (x:decompose_req_full_decomp) : unit =
  self.d <- Some x

let copy_decompose_req_full_combine (self:decompose_req_full_combine) : decompose_req_full_combine =
  { self with d = self.d }

let make_decompose_req_full_combine 
  ?(d:decompose_req_full_decomp option)
  () : decompose_req_full_combine  =
  let _res = default_decompose_req_full_combine () in
  (match d with
  | None -> ()
  | Some v -> decompose_req_full_combine_set_d _res v);
  _res


let[@inline] decompose_req_full_local_var_let_set_bindings (self:decompose_req_full_local_var_let) (x:decompose_req_full_local_var_binding list) : unit =
  self.bindings <- x
let[@inline] decompose_req_full_local_var_let_set_and_then (self:decompose_req_full_local_var_let) (x:decompose_req_full_decomp) : unit =
  self.and_then <- Some x

let copy_decompose_req_full_local_var_let (self:decompose_req_full_local_var_let) : decompose_req_full_local_var_let =
  { self with bindings = self.bindings }

let make_decompose_req_full_local_var_let 
  ?(bindings=[])
  ?(and_then:decompose_req_full_decomp option)
  () : decompose_req_full_local_var_let  =
  let _res = default_decompose_req_full_local_var_let () in
  decompose_req_full_local_var_let_set_bindings _res bindings;
  (match and_then with
  | None -> ()
  | Some v -> decompose_req_full_local_var_let_set_and_then _res v);
  _res

let[@inline] decompose_req_full_local_var_binding_has_name (self:decompose_req_full_local_var_binding) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] decompose_req_full_local_var_binding_set_name (self:decompose_req_full_local_var_binding) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.name <- x
let[@inline] decompose_req_full_local_var_binding_set_d (self:decompose_req_full_local_var_binding) (x:decompose_req_full_decomp) : unit =
  self.d <- Some x

let copy_decompose_req_full_local_var_binding (self:decompose_req_full_local_var_binding) : decompose_req_full_local_var_binding =
  { self with name = self.name }

let make_decompose_req_full_local_var_binding 
  ?(name:string option)
  ?(d:decompose_req_full_decomp option)
  () : decompose_req_full_local_var_binding  =
  let _res = default_decompose_req_full_local_var_binding () in
  (match name with
  | None -> ()
  | Some v -> decompose_req_full_local_var_binding_set_name _res v);
  (match d with
  | None -> ()
  | Some v -> decompose_req_full_local_var_binding_set_d _res v);
  _res

let[@inline] decompose_req_full_has_str (self:decompose_req_full) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] decompose_req_full_has_timeout (self:decompose_req_full) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] decompose_req_full_set_session (self:decompose_req_full) (x:Session.session) : unit =
  self.session <- Some x
let[@inline] decompose_req_full_set_decomp (self:decompose_req_full) (x:decompose_req_full_decomp) : unit =
  self.decomp <- Some x
let[@inline] decompose_req_full_set_str (self:decompose_req_full) (x:bool) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.str <- x
let[@inline] decompose_req_full_set_timeout (self:decompose_req_full) (x:int32) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.timeout <- x

let copy_decompose_req_full (self:decompose_req_full) : decompose_req_full =
  { self with session = self.session }

let make_decompose_req_full 
  ?(session:Session.session option)
  ?(decomp:decompose_req_full_decomp option)
  ?(str:bool option)
  ?(timeout:int32 option)
  () : decompose_req_full  =
  let _res = default_decompose_req_full () in
  (match session with
  | None -> ()
  | Some v -> decompose_req_full_set_session _res v);
  (match decomp with
  | None -> ()
  | Some v -> decompose_req_full_set_decomp _res v);
  (match str with
  | None -> ()
  | Some v -> decompose_req_full_set_str _res v);
  (match timeout with
  | None -> ()
  | Some v -> decompose_req_full_set_timeout _res v);
  _res


let[@inline] decompose_res_set_res (self:decompose_res) (x:decompose_res_res) : unit =
  self.res <- Some x
let[@inline] decompose_res_set_errors (self:decompose_res) (x:Error.error list) : unit =
  self.errors <- x
let[@inline] decompose_res_set_task (self:decompose_res) (x:Task.task) : unit =
  self.task <- Some x

let copy_decompose_res (self:decompose_res) : decompose_res =
  { self with res = self.res }

let make_decompose_res 
  ?(res:decompose_res_res option)
  ?(errors=[])
  ?(task:Task.task option)
  () : decompose_res  =
  let _res = default_decompose_res () in
  (match res with
  | None -> ()
  | Some v -> decompose_res_set_res _res v);
  decompose_res_set_errors _res errors;
  (match task with
  | None -> ()
  | Some v -> decompose_res_set_task _res v);
  _res

let[@inline] eval_src_req_has_src (self:eval_src_req) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] eval_src_req_has_async_only (self:eval_src_req) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] eval_src_req_set_session (self:eval_src_req) (x:Session.session) : unit =
  self.session <- Some x
let[@inline] eval_src_req_set_src (self:eval_src_req) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.src <- x
let[@inline] eval_src_req_set_async_only (self:eval_src_req) (x:bool) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.async_only <- x

let copy_eval_src_req (self:eval_src_req) : eval_src_req =
  { self with session = self.session }

let make_eval_src_req 
  ?(session:Session.session option)
  ?(src:string option)
  ?(async_only:bool option)
  () : eval_src_req  =
  let _res = default_eval_src_req () in
  (match session with
  | None -> ()
  | Some v -> eval_src_req_set_session _res v);
  (match src with
  | None -> ()
  | Some v -> eval_src_req_set_src _res v);
  (match async_only with
  | None -> ()
  | Some v -> eval_src_req_set_async_only _res v);
  _res

let[@inline] eval_output_has_success (self:eval_output) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] eval_output_has_value_as_ocaml (self:eval_output) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] eval_output_set_success (self:eval_output) (x:bool) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.success <- x
let[@inline] eval_output_set_value_as_ocaml (self:eval_output) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.value_as_ocaml <- x
let[@inline] eval_output_set_errors (self:eval_output) (x:Error.error list) : unit =
  self.errors <- x

let copy_eval_output (self:eval_output) : eval_output =
  { self with success = self.success }

let make_eval_output 
  ?(success:bool option)
  ?(value_as_ocaml:string option)
  ?(errors=[])
  () : eval_output  =
  let _res = default_eval_output () in
  (match success with
  | None -> ()
  | Some v -> eval_output_set_success _res v);
  (match value_as_ocaml with
  | None -> ()
  | Some v -> eval_output_set_value_as_ocaml _res v);
  eval_output_set_errors _res errors;
  _res

let[@inline] proved_has_proof_pp (self:proved) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] proved_set_proof_pp (self:proved) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.proof_pp <- x

let copy_proved (self:proved) : proved =
  { self with proof_pp = self.proof_pp }

let make_proved 
  ?(proof_pp:string option)
  () : proved  =
  let _res = default_proved () in
  (match proof_pp with
  | None -> ()
  | Some v -> proved_set_proof_pp _res v);
  _res

let[@inline] model_has_m_type (self:model) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] model_has_src (self:model) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] model_set_m_type (self:model) (x:model_type) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.m_type <- x
let[@inline] model_set_src (self:model) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.src <- x
let[@inline] model_set_artifact (self:model) (x:Artmsg.art) : unit =
  self.artifact <- Some x

let copy_model (self:model) : model =
  { self with m_type = self.m_type }

let make_model 
  ?(m_type:model_type option)
  ?(src:string option)
  ?(artifact:Artmsg.art option)
  () : model  =
  let _res = default_model () in
  (match m_type with
  | None -> ()
  | Some v -> model_set_m_type _res v);
  (match src with
  | None -> ()
  | Some v -> model_set_src _res v);
  (match artifact with
  | None -> ()
  | Some v -> model_set_artifact _res v);
  _res


let[@inline] counter_sat_set_model (self:counter_sat) (x:model) : unit =
  self.model <- Some x

let copy_counter_sat (self:counter_sat) : counter_sat =
  { self with model = self.model }

let make_counter_sat 
  ?(model:model option)
  () : counter_sat  =
  let _res = default_counter_sat () in
  (match model with
  | None -> ()
  | Some v -> counter_sat_set_model _res v);
  _res

let[@inline] verified_upto_has_msg (self:verified_upto) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] verified_upto_set_msg (self:verified_upto) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.msg <- x

let copy_verified_upto (self:verified_upto) : verified_upto =
  { self with msg = self.msg }

let make_verified_upto 
  ?(msg:string option)
  () : verified_upto  =
  let _res = default_verified_upto () in
  (match msg with
  | None -> ()
  | Some v -> verified_upto_set_msg _res v);
  _res


let[@inline] po_res_set_res (self:po_res) (x:po_res_res) : unit =
  self.res <- Some x
let[@inline] po_res_set_errors (self:po_res) (x:Error.error list) : unit =
  self.errors <- x
let[@inline] po_res_set_task (self:po_res) (x:Task.task) : unit =
  self.task <- Some x
let[@inline] po_res_set_origin (self:po_res) (x:Task.origin) : unit =
  self.origin <- Some x

let copy_po_res (self:po_res) : po_res =
  { self with res = self.res }

let make_po_res 
  ?(res:po_res_res option)
  ?(errors=[])
  ?(task:Task.task option)
  ?(origin:Task.origin option)
  () : po_res  =
  let _res = default_po_res () in
  (match res with
  | None -> ()
  | Some v -> po_res_set_res _res v);
  po_res_set_errors _res errors;
  (match task with
  | None -> ()
  | Some v -> po_res_set_task _res v);
  (match origin with
  | None -> ()
  | Some v -> po_res_set_origin _res v);
  _res

let[@inline] eval_res_has_success (self:eval_res) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] eval_res_set_success (self:eval_res) (x:bool) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.success <- x
let[@inline] eval_res_set_messages (self:eval_res) (x:string list) : unit =
  self.messages <- x
let[@inline] eval_res_set_errors (self:eval_res) (x:Error.error list) : unit =
  self.errors <- x
let[@inline] eval_res_set_tasks (self:eval_res) (x:Task.task list) : unit =
  self.tasks <- x
let[@inline] eval_res_set_po_results (self:eval_res) (x:po_res list) : unit =
  self.po_results <- x
let[@inline] eval_res_set_eval_results (self:eval_res) (x:eval_output list) : unit =
  self.eval_results <- x
let[@inline] eval_res_set_decomp_results (self:eval_res) (x:decompose_res list) : unit =
  self.decomp_results <- x

let copy_eval_res (self:eval_res) : eval_res =
  { self with success = self.success }

let make_eval_res 
  ?(success:bool option)
  ?(messages=[])
  ?(errors=[])
  ?(tasks=[])
  ?(po_results=[])
  ?(eval_results=[])
  ?(decomp_results=[])
  () : eval_res  =
  let _res = default_eval_res () in
  (match success with
  | None -> ()
  | Some v -> eval_res_set_success _res v);
  eval_res_set_messages _res messages;
  eval_res_set_errors _res errors;
  eval_res_set_tasks _res tasks;
  eval_res_set_po_results _res po_results;
  eval_res_set_eval_results _res eval_results;
  eval_res_set_decomp_results _res decomp_results;
  _res

let[@inline] verify_src_req_has_src (self:verify_src_req) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] verify_src_req_has_hints (self:verify_src_req) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] verify_src_req_set_session (self:verify_src_req) (x:Session.session) : unit =
  self.session <- Some x
let[@inline] verify_src_req_set_src (self:verify_src_req) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.src <- x
let[@inline] verify_src_req_set_hints (self:verify_src_req) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.hints <- x

let copy_verify_src_req (self:verify_src_req) : verify_src_req =
  { self with session = self.session }

let make_verify_src_req 
  ?(session:Session.session option)
  ?(src:string option)
  ?(hints:string option)
  () : verify_src_req  =
  let _res = default_verify_src_req () in
  (match session with
  | None -> ()
  | Some v -> verify_src_req_set_session _res v);
  (match src with
  | None -> ()
  | Some v -> verify_src_req_set_src _res v);
  (match hints with
  | None -> ()
  | Some v -> verify_src_req_set_hints _res v);
  _res

let[@inline] verify_name_req_has_name (self:verify_name_req) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] verify_name_req_has_hints (self:verify_name_req) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] verify_name_req_set_session (self:verify_name_req) (x:Session.session) : unit =
  self.session <- Some x
let[@inline] verify_name_req_set_name (self:verify_name_req) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.name <- x
let[@inline] verify_name_req_set_hints (self:verify_name_req) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.hints <- x

let copy_verify_name_req (self:verify_name_req) : verify_name_req =
  { self with session = self.session }

let make_verify_name_req 
  ?(session:Session.session option)
  ?(name:string option)
  ?(hints:string option)
  () : verify_name_req  =
  let _res = default_verify_name_req () in
  (match session with
  | None -> ()
  | Some v -> verify_name_req_set_session _res v);
  (match name with
  | None -> ()
  | Some v -> verify_name_req_set_name _res v);
  (match hints with
  | None -> ()
  | Some v -> verify_name_req_set_hints _res v);
  _res

let[@inline] instance_src_req_has_src (self:instance_src_req) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] instance_src_req_has_hints (self:instance_src_req) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] instance_src_req_set_session (self:instance_src_req) (x:Session.session) : unit =
  self.session <- Some x
let[@inline] instance_src_req_set_src (self:instance_src_req) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.src <- x
let[@inline] instance_src_req_set_hints (self:instance_src_req) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.hints <- x

let copy_instance_src_req (self:instance_src_req) : instance_src_req =
  { self with session = self.session }

let make_instance_src_req 
  ?(session:Session.session option)
  ?(src:string option)
  ?(hints:string option)
  () : instance_src_req  =
  let _res = default_instance_src_req () in
  (match session with
  | None -> ()
  | Some v -> instance_src_req_set_session _res v);
  (match src with
  | None -> ()
  | Some v -> instance_src_req_set_src _res v);
  (match hints with
  | None -> ()
  | Some v -> instance_src_req_set_hints _res v);
  _res

let[@inline] instance_name_req_has_name (self:instance_name_req) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] instance_name_req_has_hints (self:instance_name_req) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] instance_name_req_set_session (self:instance_name_req) (x:Session.session) : unit =
  self.session <- Some x
let[@inline] instance_name_req_set_name (self:instance_name_req) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.name <- x
let[@inline] instance_name_req_set_hints (self:instance_name_req) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.hints <- x

let copy_instance_name_req (self:instance_name_req) : instance_name_req =
  { self with session = self.session }

let make_instance_name_req 
  ?(session:Session.session option)
  ?(name:string option)
  ?(hints:string option)
  () : instance_name_req  =
  let _res = default_instance_name_req () in
  (match session with
  | None -> ()
  | Some v -> instance_name_req_set_session _res v);
  (match name with
  | None -> ()
  | Some v -> instance_name_req_set_name _res v);
  (match hints with
  | None -> ()
  | Some v -> instance_name_req_set_hints _res v);
  _res

let[@inline] unsat_has_proof_pp (self:unsat) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] unsat_set_proof_pp (self:unsat) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.proof_pp <- x

let copy_unsat (self:unsat) : unsat =
  { self with proof_pp = self.proof_pp }

let make_unsat 
  ?(proof_pp:string option)
  () : unsat  =
  let _res = default_unsat () in
  (match proof_pp with
  | None -> ()
  | Some v -> unsat_set_proof_pp _res v);
  _res


let[@inline] refuted_set_model (self:refuted) (x:model) : unit =
  self.model <- Some x

let copy_refuted (self:refuted) : refuted =
  { self with model = self.model }

let make_refuted 
  ?(model:model option)
  () : refuted  =
  let _res = default_refuted () in
  (match model with
  | None -> ()
  | Some v -> refuted_set_model _res v);
  _res


let[@inline] sat_set_model (self:sat) (x:model) : unit =
  self.model <- Some x

let copy_sat (self:sat) : sat =
  { self with model = self.model }

let make_sat 
  ?(model:model option)
  () : sat  =
  let _res = default_sat () in
  (match model with
  | None -> ()
  | Some v -> sat_set_model _res v);
  _res


let[@inline] verify_res_set_res (self:verify_res) (x:verify_res_res) : unit =
  self.res <- Some x
let[@inline] verify_res_set_errors (self:verify_res) (x:Error.error list) : unit =
  self.errors <- x
let[@inline] verify_res_set_task (self:verify_res) (x:Task.task) : unit =
  self.task <- Some x

let copy_verify_res (self:verify_res) : verify_res =
  { self with res = self.res }

let make_verify_res 
  ?(res:verify_res_res option)
  ?(errors=[])
  ?(task:Task.task option)
  () : verify_res  =
  let _res = default_verify_res () in
  (match res with
  | None -> ()
  | Some v -> verify_res_set_res _res v);
  verify_res_set_errors _res errors;
  (match task with
  | None -> ()
  | Some v -> verify_res_set_task _res v);
  _res


let[@inline] instance_res_set_res (self:instance_res) (x:instance_res_res) : unit =
  self.res <- Some x
let[@inline] instance_res_set_errors (self:instance_res) (x:Error.error list) : unit =
  self.errors <- x
let[@inline] instance_res_set_task (self:instance_res) (x:Task.task) : unit =
  self.task <- Some x

let copy_instance_res (self:instance_res) : instance_res =
  { self with res = self.res }

let make_instance_res 
  ?(res:instance_res_res option)
  ?(errors=[])
  ?(task:Task.task option)
  () : instance_res  =
  let _res = default_instance_res () in
  (match res with
  | None -> ()
  | Some v -> instance_res_set_res _res v);
  instance_res_set_errors _res errors;
  (match task with
  | None -> ()
  | Some v -> instance_res_set_task _res v);
  _res

let[@inline] typecheck_req_has_src (self:typecheck_req) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] typecheck_req_set_session (self:typecheck_req) (x:Session.session) : unit =
  self.session <- Some x
let[@inline] typecheck_req_set_src (self:typecheck_req) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.src <- x

let copy_typecheck_req (self:typecheck_req) : typecheck_req =
  { self with session = self.session }

let make_typecheck_req 
  ?(session:Session.session option)
  ?(src:string option)
  () : typecheck_req  =
  let _res = default_typecheck_req () in
  (match session with
  | None -> ()
  | Some v -> typecheck_req_set_session _res v);
  (match src with
  | None -> ()
  | Some v -> typecheck_req_set_src _res v);
  _res

let[@inline] typecheck_res_has_success (self:typecheck_res) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] typecheck_res_has_types (self:typecheck_res) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] typecheck_res_set_success (self:typecheck_res) (x:bool) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.success <- x
let[@inline] typecheck_res_set_types (self:typecheck_res) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.types <- x
let[@inline] typecheck_res_set_errors (self:typecheck_res) (x:Error.error list) : unit =
  self.errors <- x

let copy_typecheck_res (self:typecheck_res) : typecheck_res =
  { self with success = self.success }

let make_typecheck_res 
  ?(success:bool option)
  ?(types:string option)
  ?(errors=[])
  () : typecheck_res  =
  let _res = default_typecheck_res () in
  (match success with
  | None -> ()
  | Some v -> typecheck_res_set_success _res v);
  (match types with
  | None -> ()
  | Some v -> typecheck_res_set_types _res v);
  typecheck_res_set_errors _res errors;
  _res

let[@inline] oneshot_req_has_input (self:oneshot_req) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] oneshot_req_has_timeout (self:oneshot_req) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] oneshot_req_set_input (self:oneshot_req) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.input <- x
let[@inline] oneshot_req_set_timeout (self:oneshot_req) (x:float) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.timeout <- x

let copy_oneshot_req (self:oneshot_req) : oneshot_req =
  { self with input = self.input }

let make_oneshot_req 
  ?(input:string option)
  ?(timeout:float option)
  () : oneshot_req  =
  let _res = default_oneshot_req () in
  (match input with
  | None -> ()
  | Some v -> oneshot_req_set_input _res v);
  (match timeout with
  | None -> ()
  | Some v -> oneshot_req_set_timeout _res v);
  _res

let[@inline] oneshot_res_stats_has_time (self:oneshot_res_stats) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] oneshot_res_stats_set_time (self:oneshot_res_stats) (x:float) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.time <- x

let copy_oneshot_res_stats (self:oneshot_res_stats) : oneshot_res_stats =
  { self with time = self.time }

let make_oneshot_res_stats 
  ?(time:float option)
  () : oneshot_res_stats  =
  let _res = default_oneshot_res_stats () in
  (match time with
  | None -> ()
  | Some v -> oneshot_res_stats_set_time _res v);
  _res


let[@inline] oneshot_res_set_results (self:oneshot_res) (x:string list) : unit =
  self.results <- x
let[@inline] oneshot_res_set_errors (self:oneshot_res) (x:string list) : unit =
  self.errors <- x
let[@inline] oneshot_res_set_stats (self:oneshot_res) (x:oneshot_res_stats) : unit =
  self.stats <- Some x
let[@inline] oneshot_res_set_detailed_results (self:oneshot_res) (x:string list) : unit =
  self.detailed_results <- x

let copy_oneshot_res (self:oneshot_res) : oneshot_res =
  { self with results = self.results }

let make_oneshot_res 
  ?(results=[])
  ?(errors=[])
  ?(stats:oneshot_res_stats option)
  ?(detailed_results=[])
  () : oneshot_res  =
  let _res = default_oneshot_res () in
  oneshot_res_set_results _res results;
  oneshot_res_set_errors _res errors;
  (match stats with
  | None -> ()
  | Some v -> oneshot_res_set_stats _res v);
  oneshot_res_set_detailed_results _res detailed_results;
  _res

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Formatters} *)

let rec pp_session_create_req fmt (v:session_create_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (session_create_req_has_api_version v)) ~first:true "api_version" Pbrt.Pp.pp_string fmt v.api_version;
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
    Pbrt.Pp.pp_record_field ~absent:(not (decompose_req_has_name v)) ~first:false "name" Pbrt.Pp.pp_string fmt v.name;
    Pbrt.Pp.pp_record_field ~absent:(not (decompose_req_has_assuming v)) ~first:false "assuming" Pbrt.Pp.pp_string fmt v.assuming;
    Pbrt.Pp.pp_record_field ~first:false "basis" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.basis;
    Pbrt.Pp.pp_record_field ~first:false "rule_specs" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.rule_specs;
    Pbrt.Pp.pp_record_field ~absent:(not (decompose_req_has_prune v)) ~first:false "prune" Pbrt.Pp.pp_bool fmt v.prune;
    Pbrt.Pp.pp_record_field ~absent:(not (decompose_req_has_ctx_simp v)) ~first:false "ctx_simp" Pbrt.Pp.pp_bool fmt v.ctx_simp;
    Pbrt.Pp.pp_record_field ~absent:(not (decompose_req_has_lift_bool v)) ~first:false "lift_bool" pp_lift_bool fmt v.lift_bool;
    Pbrt.Pp.pp_record_field ~absent:(not (decompose_req_has_str v)) ~first:false "str" Pbrt.Pp.pp_bool fmt v.str;
    Pbrt.Pp.pp_record_field ~absent:(not (decompose_req_has_timeout v)) ~first:false "timeout" Pbrt.Pp.pp_int32 fmt v.timeout;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_decompose_req_full_by_name fmt (v:decompose_req_full_by_name) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (decompose_req_full_by_name_has_name v)) ~first:true "name" Pbrt.Pp.pp_string fmt v.name;
    Pbrt.Pp.pp_record_field ~absent:(not (decompose_req_full_by_name_has_assuming v)) ~first:false "assuming" Pbrt.Pp.pp_string fmt v.assuming;
    Pbrt.Pp.pp_record_field ~first:false "basis" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.basis;
    Pbrt.Pp.pp_record_field ~first:false "rule_specs" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.rule_specs;
    Pbrt.Pp.pp_record_field ~absent:(not (decompose_req_full_by_name_has_prune v)) ~first:false "prune" Pbrt.Pp.pp_bool fmt v.prune;
    Pbrt.Pp.pp_record_field ~absent:(not (decompose_req_full_by_name_has_ctx_simp v)) ~first:false "ctx_simp" Pbrt.Pp.pp_bool fmt v.ctx_simp;
    Pbrt.Pp.pp_record_field ~absent:(not (decompose_req_full_by_name_has_lift_bool v)) ~first:false "lift_bool" pp_lift_bool fmt v.lift_bool;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_decompose_req_full_local_var_get fmt (v:decompose_req_full_local_var_get) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (decompose_req_full_local_var_get_has_name v)) ~first:true "name" Pbrt.Pp.pp_string fmt v.name;
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
    Pbrt.Pp.pp_record_field ~absent:(not (decompose_req_full_local_var_binding_has_name v)) ~first:true "name" Pbrt.Pp.pp_string fmt v.name;
    Pbrt.Pp.pp_record_field ~first:false "d" (Pbrt.Pp.pp_option pp_decompose_req_full_decomp) fmt v.d;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_decompose_req_full fmt (v:decompose_req_full) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~first:false "decomp" (Pbrt.Pp.pp_option pp_decompose_req_full_decomp) fmt v.decomp;
    Pbrt.Pp.pp_record_field ~absent:(not (decompose_req_full_has_str v)) ~first:false "str" Pbrt.Pp.pp_bool fmt v.str;
    Pbrt.Pp.pp_record_field ~absent:(not (decompose_req_full_has_timeout v)) ~first:false "timeout" Pbrt.Pp.pp_int32 fmt v.timeout;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_decompose_res_res fmt (v:decompose_res_res) =
  match v with
  | Artifact x -> Format.fprintf fmt "@[<hv2>Artifact(@,%a)@]" Artmsg.pp_art x
  | Err  -> Format.fprintf fmt "Err"

and pp_decompose_res fmt (v:decompose_res) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "res" (Pbrt.Pp.pp_option pp_decompose_res_res) fmt v.res;
    Pbrt.Pp.pp_record_field ~first:false "errors" (Pbrt.Pp.pp_list Error.pp_error) fmt v.errors;
    Pbrt.Pp.pp_record_field ~first:false "task" (Pbrt.Pp.pp_option Task.pp_task) fmt v.task;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_eval_src_req fmt (v:eval_src_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~absent:(not (eval_src_req_has_src v)) ~first:false "src" Pbrt.Pp.pp_string fmt v.src;
    Pbrt.Pp.pp_record_field ~absent:(not (eval_src_req_has_async_only v)) ~first:false "async_only" Pbrt.Pp.pp_bool fmt v.async_only;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_eval_output fmt (v:eval_output) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (eval_output_has_success v)) ~first:true "success" Pbrt.Pp.pp_bool fmt v.success;
    Pbrt.Pp.pp_record_field ~absent:(not (eval_output_has_value_as_ocaml v)) ~first:false "value_as_ocaml" Pbrt.Pp.pp_string fmt v.value_as_ocaml;
    Pbrt.Pp.pp_record_field ~first:false "errors" (Pbrt.Pp.pp_list Error.pp_error) fmt v.errors;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_proved fmt (v:proved) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (proved_has_proof_pp v)) ~first:true "proof_pp" Pbrt.Pp.pp_string fmt v.proof_pp;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_model_type fmt (v:model_type) =
  match v with
  | Counter_example -> Format.fprintf fmt "Counter_example"
  | Instance -> Format.fprintf fmt "Instance"

let rec pp_model fmt (v:model) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (model_has_m_type v)) ~first:true "m_type" pp_model_type fmt v.m_type;
    Pbrt.Pp.pp_record_field ~absent:(not (model_has_src v)) ~first:false "src" Pbrt.Pp.pp_string fmt v.src;
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
    Pbrt.Pp.pp_record_field ~absent:(not (verified_upto_has_msg v)) ~first:true "msg" Pbrt.Pp.pp_string fmt v.msg;
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
    Pbrt.Pp.pp_record_field ~first:true "res" (Pbrt.Pp.pp_option pp_po_res_res) fmt v.res;
    Pbrt.Pp.pp_record_field ~first:false "errors" (Pbrt.Pp.pp_list Error.pp_error) fmt v.errors;
    Pbrt.Pp.pp_record_field ~first:false "task" (Pbrt.Pp.pp_option Task.pp_task) fmt v.task;
    Pbrt.Pp.pp_record_field ~first:false "origin" (Pbrt.Pp.pp_option Task.pp_origin) fmt v.origin;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_eval_res fmt (v:eval_res) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (eval_res_has_success v)) ~first:true "success" Pbrt.Pp.pp_bool fmt v.success;
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
    Pbrt.Pp.pp_record_field ~absent:(not (verify_src_req_has_src v)) ~first:false "src" Pbrt.Pp.pp_string fmt v.src;
    Pbrt.Pp.pp_record_field ~absent:(not (verify_src_req_has_hints v)) ~first:false "hints" Pbrt.Pp.pp_string fmt v.hints;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_verify_name_req fmt (v:verify_name_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~absent:(not (verify_name_req_has_name v)) ~first:false "name" Pbrt.Pp.pp_string fmt v.name;
    Pbrt.Pp.pp_record_field ~absent:(not (verify_name_req_has_hints v)) ~first:false "hints" Pbrt.Pp.pp_string fmt v.hints;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_instance_src_req fmt (v:instance_src_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~absent:(not (instance_src_req_has_src v)) ~first:false "src" Pbrt.Pp.pp_string fmt v.src;
    Pbrt.Pp.pp_record_field ~absent:(not (instance_src_req_has_hints v)) ~first:false "hints" Pbrt.Pp.pp_string fmt v.hints;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_instance_name_req fmt (v:instance_name_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~absent:(not (instance_name_req_has_name v)) ~first:false "name" Pbrt.Pp.pp_string fmt v.name;
    Pbrt.Pp.pp_record_field ~absent:(not (instance_name_req_has_hints v)) ~first:false "hints" Pbrt.Pp.pp_string fmt v.hints;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_unsat fmt (v:unsat) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (unsat_has_proof_pp v)) ~first:true "proof_pp" Pbrt.Pp.pp_string fmt v.proof_pp;
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
    Pbrt.Pp.pp_record_field ~first:true "res" (Pbrt.Pp.pp_option pp_verify_res_res) fmt v.res;
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
    Pbrt.Pp.pp_record_field ~first:true "res" (Pbrt.Pp.pp_option pp_instance_res_res) fmt v.res;
    Pbrt.Pp.pp_record_field ~first:false "errors" (Pbrt.Pp.pp_list Error.pp_error) fmt v.errors;
    Pbrt.Pp.pp_record_field ~first:false "task" (Pbrt.Pp.pp_option Task.pp_task) fmt v.task;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_typecheck_req fmt (v:typecheck_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~absent:(not (typecheck_req_has_src v)) ~first:false "src" Pbrt.Pp.pp_string fmt v.src;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_typecheck_res fmt (v:typecheck_res) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (typecheck_res_has_success v)) ~first:true "success" Pbrt.Pp.pp_bool fmt v.success;
    Pbrt.Pp.pp_record_field ~absent:(not (typecheck_res_has_types v)) ~first:false "types" Pbrt.Pp.pp_string fmt v.types;
    Pbrt.Pp.pp_record_field ~first:false "errors" (Pbrt.Pp.pp_list Error.pp_error) fmt v.errors;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_oneshot_req fmt (v:oneshot_req) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (oneshot_req_has_input v)) ~first:true "input" Pbrt.Pp.pp_string fmt v.input;
    Pbrt.Pp.pp_record_field ~absent:(not (oneshot_req_has_timeout v)) ~first:false "timeout" Pbrt.Pp.pp_float fmt v.timeout;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_oneshot_res_stats fmt (v:oneshot_res_stats) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (oneshot_res_stats_has_time v)) ~first:true "time" Pbrt.Pp.pp_float fmt v.time;
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

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_session_create_req (v:session_create_req) encoder = 
  if session_create_req_has_api_version v then (
    Pbrt.Encoder.string v.api_version encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
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
  if decompose_req_has_name v then (
    Pbrt.Encoder.string v.name encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  if decompose_req_has_assuming v then (
    Pbrt.Encoder.string v.assuming encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  );
  Pbrt.List_util.rev_iter_with (fun x encoder ->
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  ) v.basis encoder;
  Pbrt.List_util.rev_iter_with (fun x encoder ->
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 5 Pbrt.Bytes encoder; 
  ) v.rule_specs encoder;
  if decompose_req_has_prune v then (
    Pbrt.Encoder.bool v.prune encoder;
    Pbrt.Encoder.key 6 Pbrt.Varint encoder; 
  );
  if decompose_req_has_ctx_simp v then (
    Pbrt.Encoder.bool v.ctx_simp encoder;
    Pbrt.Encoder.key 7 Pbrt.Varint encoder; 
  );
  if decompose_req_has_lift_bool v then (
    encode_pb_lift_bool v.lift_bool encoder;
    Pbrt.Encoder.key 8 Pbrt.Varint encoder; 
  );
  if decompose_req_has_str v then (
    Pbrt.Encoder.bool v.str encoder;
    Pbrt.Encoder.key 9 Pbrt.Varint encoder; 
  );
  if decompose_req_has_timeout v then (
    Pbrt.Encoder.int32_as_varint v.timeout encoder;
    Pbrt.Encoder.key 10 Pbrt.Varint encoder; 
  );
  ()

let rec encode_pb_decompose_req_full_by_name (v:decompose_req_full_by_name) encoder = 
  if decompose_req_full_by_name_has_name v then (
    Pbrt.Encoder.string v.name encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  if decompose_req_full_by_name_has_assuming v then (
    Pbrt.Encoder.string v.assuming encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  );
  Pbrt.List_util.rev_iter_with (fun x encoder ->
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  ) v.basis encoder;
  Pbrt.List_util.rev_iter_with (fun x encoder ->
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 5 Pbrt.Bytes encoder; 
  ) v.rule_specs encoder;
  if decompose_req_full_by_name_has_prune v then (
    Pbrt.Encoder.bool v.prune encoder;
    Pbrt.Encoder.key 6 Pbrt.Varint encoder; 
  );
  if decompose_req_full_by_name_has_ctx_simp v then (
    Pbrt.Encoder.bool v.ctx_simp encoder;
    Pbrt.Encoder.key 7 Pbrt.Varint encoder; 
  );
  if decompose_req_full_by_name_has_lift_bool v then (
    encode_pb_lift_bool v.lift_bool encoder;
    Pbrt.Encoder.key 8 Pbrt.Varint encoder; 
  );
  ()

let rec encode_pb_decompose_req_full_local_var_get (v:decompose_req_full_local_var_get) encoder = 
  if decompose_req_full_local_var_get_has_name v then (
    Pbrt.Encoder.string v.name encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
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
  if decompose_req_full_local_var_binding_has_name v then (
    Pbrt.Encoder.string v.name encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
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
  if decompose_req_full_has_str v then (
    Pbrt.Encoder.bool v.str encoder;
    Pbrt.Encoder.key 9 Pbrt.Varint encoder; 
  );
  if decompose_req_full_has_timeout v then (
    Pbrt.Encoder.int32_as_varint v.timeout encoder;
    Pbrt.Encoder.key 10 Pbrt.Varint encoder; 
  );
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
  | None -> ()
  | Some (Artifact x) ->
    Pbrt.Encoder.nested Artmsg.encode_pb_art x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | Some Err ->
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
  if eval_src_req_has_src v then (
    Pbrt.Encoder.string v.src encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  if eval_src_req_has_async_only v then (
    Pbrt.Encoder.bool v.async_only encoder;
    Pbrt.Encoder.key 3 Pbrt.Varint encoder; 
  );
  ()

let rec encode_pb_eval_output (v:eval_output) encoder = 
  if eval_output_has_success v then (
    Pbrt.Encoder.bool v.success encoder;
    Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  );
  if eval_output_has_value_as_ocaml v then (
    Pbrt.Encoder.string v.value_as_ocaml encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  Pbrt.List_util.rev_iter_with (fun x encoder ->
    Pbrt.Encoder.nested Error.encode_pb_error x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  ) v.errors encoder;
  ()

let rec encode_pb_proved (v:proved) encoder = 
  if proved_has_proof_pp v then (
    Pbrt.Encoder.string v.proof_pp encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
  ()

let rec encode_pb_model_type (v:model_type) encoder =
  match v with
  | Counter_example -> Pbrt.Encoder.int_as_varint (0) encoder
  | Instance -> Pbrt.Encoder.int_as_varint 1 encoder

let rec encode_pb_model (v:model) encoder = 
  if model_has_m_type v then (
    encode_pb_model_type v.m_type encoder;
    Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  );
  if model_has_src v then (
    Pbrt.Encoder.string v.src encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
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
  if verified_upto_has_msg v then (
    Pbrt.Encoder.string v.msg encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
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
  | None -> ()
  | Some (Unknown x) ->
    Pbrt.Encoder.nested Utils.encode_pb_string_msg x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | Some Err ->
    Pbrt.Encoder.empty_nested encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | Some (Proof x) ->
    Pbrt.Encoder.nested encode_pb_proved x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | Some (Instance x) ->
    Pbrt.Encoder.nested encode_pb_counter_sat x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  | Some (Verified_upto x) ->
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
  if eval_res_has_success v then (
    Pbrt.Encoder.bool v.success encoder;
    Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  );
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
  if verify_src_req_has_src v then (
    Pbrt.Encoder.string v.src encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  if verify_src_req_has_hints v then (
    Pbrt.Encoder.string v.hints encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  );
  ()

let rec encode_pb_verify_name_req (v:verify_name_req) encoder = 
  begin match v.session with
  | Some x -> 
    Pbrt.Encoder.nested Session.encode_pb_session x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  if verify_name_req_has_name v then (
    Pbrt.Encoder.string v.name encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  if verify_name_req_has_hints v then (
    Pbrt.Encoder.string v.hints encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  );
  ()

let rec encode_pb_instance_src_req (v:instance_src_req) encoder = 
  begin match v.session with
  | Some x -> 
    Pbrt.Encoder.nested Session.encode_pb_session x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  if instance_src_req_has_src v then (
    Pbrt.Encoder.string v.src encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  if instance_src_req_has_hints v then (
    Pbrt.Encoder.string v.hints encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  );
  ()

let rec encode_pb_instance_name_req (v:instance_name_req) encoder = 
  begin match v.session with
  | Some x -> 
    Pbrt.Encoder.nested Session.encode_pb_session x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  if instance_name_req_has_name v then (
    Pbrt.Encoder.string v.name encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  if instance_name_req_has_hints v then (
    Pbrt.Encoder.string v.hints encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  );
  ()

let rec encode_pb_unsat (v:unsat) encoder = 
  if unsat_has_proof_pp v then (
    Pbrt.Encoder.string v.proof_pp encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
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
  | None -> ()
  | Some (Unknown x) ->
    Pbrt.Encoder.nested Utils.encode_pb_string_msg x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | Some Err ->
    Pbrt.Encoder.empty_nested encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | Some (Proved x) ->
    Pbrt.Encoder.nested encode_pb_proved x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | Some (Refuted x) ->
    Pbrt.Encoder.nested encode_pb_refuted x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  | Some (Verified_upto x) ->
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
  | None -> ()
  | Some (Unknown x) ->
    Pbrt.Encoder.nested Utils.encode_pb_string_msg x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | Some Err ->
    Pbrt.Encoder.empty_nested encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | Some (Unsat x) ->
    Pbrt.Encoder.nested encode_pb_unsat x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | Some (Sat x) ->
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
  if typecheck_req_has_src v then (
    Pbrt.Encoder.string v.src encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  ()

let rec encode_pb_typecheck_res (v:typecheck_res) encoder = 
  if typecheck_res_has_success v then (
    Pbrt.Encoder.bool v.success encoder;
    Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  );
  if typecheck_res_has_types v then (
    Pbrt.Encoder.string v.types encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  Pbrt.List_util.rev_iter_with (fun x encoder ->
    Pbrt.Encoder.nested Error.encode_pb_error x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  ) v.errors encoder;
  ()

let rec encode_pb_oneshot_req (v:oneshot_req) encoder = 
  if oneshot_req_has_input v then (
    Pbrt.Encoder.string v.input encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
  if oneshot_req_has_timeout v then (
    Pbrt.Encoder.float_as_bits64 v.timeout encoder;
    Pbrt.Encoder.key 2 Pbrt.Bits64 encoder; 
  );
  ()

let rec encode_pb_oneshot_res_stats (v:oneshot_res_stats) encoder = 
  if oneshot_res_stats_has_time v then (
    Pbrt.Encoder.float_as_bits64 v.time encoder;
    Pbrt.Encoder.key 1 Pbrt.Bits64 encoder; 
  );
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

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_session_create_req d =
  let v = default_session_create_req () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      session_create_req_set_api_version v (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "session_create_req" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : session_create_req)

let rec decode_pb_lift_bool d : lift_bool = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> Default
  | 1 -> Nested_equalities
  | 2 -> Equalities
  | 3 -> All
  | _ -> Pbrt.Decoder.malformed_variant "lift_bool"

let rec decode_pb_decompose_req d =
  let v = default_decompose_req () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      (* put lists in the correct order *)
      decompose_req_set_rule_specs v (List.rev v.rule_specs);
      decompose_req_set_basis v (List.rev v.basis);
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      decompose_req_set_session v (Session.decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      decompose_req_set_name v (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req" 2 pk
    | Some (3, Pbrt.Bytes) -> begin
      decompose_req_set_assuming v (Pbrt.Decoder.string d);
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req" 3 pk
    | Some (4, Pbrt.Bytes) -> begin
      decompose_req_set_basis v ((Pbrt.Decoder.string d) :: v.basis);
    end
    | Some (4, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req" 4 pk
    | Some (5, Pbrt.Bytes) -> begin
      decompose_req_set_rule_specs v ((Pbrt.Decoder.string d) :: v.rule_specs);
    end
    | Some (5, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req" 5 pk
    | Some (6, Pbrt.Varint) -> begin
      decompose_req_set_prune v (Pbrt.Decoder.bool d);
    end
    | Some (6, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req" 6 pk
    | Some (7, Pbrt.Varint) -> begin
      decompose_req_set_ctx_simp v (Pbrt.Decoder.bool d);
    end
    | Some (7, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req" 7 pk
    | Some (8, Pbrt.Varint) -> begin
      decompose_req_set_lift_bool v (decode_pb_lift_bool d);
    end
    | Some (8, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req" 8 pk
    | Some (9, Pbrt.Varint) -> begin
      decompose_req_set_str v (Pbrt.Decoder.bool d);
    end
    | Some (9, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req" 9 pk
    | Some (10, Pbrt.Varint) -> begin
      decompose_req_set_timeout v (Pbrt.Decoder.int32_as_varint d);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req" 10 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : decompose_req)

let rec decode_pb_decompose_req_full_by_name d =
  let v = default_decompose_req_full_by_name () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      (* put lists in the correct order *)
      decompose_req_full_by_name_set_rule_specs v (List.rev v.rule_specs);
      decompose_req_full_by_name_set_basis v (List.rev v.basis);
    ); continue__ := false
    | Some (2, Pbrt.Bytes) -> begin
      decompose_req_full_by_name_set_name v (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_by_name" 2 pk
    | Some (3, Pbrt.Bytes) -> begin
      decompose_req_full_by_name_set_assuming v (Pbrt.Decoder.string d);
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_by_name" 3 pk
    | Some (4, Pbrt.Bytes) -> begin
      decompose_req_full_by_name_set_basis v ((Pbrt.Decoder.string d) :: v.basis);
    end
    | Some (4, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_by_name" 4 pk
    | Some (5, Pbrt.Bytes) -> begin
      decompose_req_full_by_name_set_rule_specs v ((Pbrt.Decoder.string d) :: v.rule_specs);
    end
    | Some (5, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_by_name" 5 pk
    | Some (6, Pbrt.Varint) -> begin
      decompose_req_full_by_name_set_prune v (Pbrt.Decoder.bool d);
    end
    | Some (6, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_by_name" 6 pk
    | Some (7, Pbrt.Varint) -> begin
      decompose_req_full_by_name_set_ctx_simp v (Pbrt.Decoder.bool d);
    end
    | Some (7, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_by_name" 7 pk
    | Some (8, Pbrt.Varint) -> begin
      decompose_req_full_by_name_set_lift_bool v (decode_pb_lift_bool d);
    end
    | Some (8, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_by_name" 8 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : decompose_req_full_by_name)

let rec decode_pb_decompose_req_full_local_var_get d =
  let v = default_decompose_req_full_local_var_get () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      decompose_req_full_local_var_get_set_name v (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_local_var_get" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : decompose_req_full_local_var_get)

let rec decode_pb_decompose_req_full_prune d =
  let v = default_decompose_req_full_prune () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      decompose_req_full_prune_set_d v (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_prune" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : decompose_req_full_prune)

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
  let v = default_decompose_req_full_merge () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      decompose_req_full_merge_set_d1 v (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_merge" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      decompose_req_full_merge_set_d2 v (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_merge" 2 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : decompose_req_full_merge)

and decode_pb_decompose_req_full_compound_merge d =
  let v = default_decompose_req_full_compound_merge () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      decompose_req_full_compound_merge_set_d1 v (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_compound_merge" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      decompose_req_full_compound_merge_set_d2 v (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_compound_merge" 2 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : decompose_req_full_compound_merge)

and decode_pb_decompose_req_full_combine d =
  let v = default_decompose_req_full_combine () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      decompose_req_full_combine_set_d v (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_combine" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : decompose_req_full_combine)

and decode_pb_decompose_req_full_local_var_let d =
  let v = default_decompose_req_full_local_var_let () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      (* put lists in the correct order *)
      decompose_req_full_local_var_let_set_bindings v (List.rev v.bindings);
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      decompose_req_full_local_var_let_set_bindings v ((decode_pb_decompose_req_full_local_var_binding (Pbrt.Decoder.nested d)) :: v.bindings);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_local_var_let" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      decompose_req_full_local_var_let_set_and_then v (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_local_var_let" 2 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : decompose_req_full_local_var_let)

and decode_pb_decompose_req_full_local_var_binding d =
  let v = default_decompose_req_full_local_var_binding () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      decompose_req_full_local_var_binding_set_name v (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_local_var_binding" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      decompose_req_full_local_var_binding_set_d v (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full_local_var_binding" 2 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : decompose_req_full_local_var_binding)

let rec decode_pb_decompose_req_full d =
  let v = default_decompose_req_full () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      decompose_req_full_set_session v (Session.decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      decompose_req_full_set_decomp v (decode_pb_decompose_req_full_decomp (Pbrt.Decoder.nested d));
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full" 2 pk
    | Some (9, Pbrt.Varint) -> begin
      decompose_req_full_set_str v (Pbrt.Decoder.bool d);
    end
    | Some (9, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full" 9 pk
    | Some (10, Pbrt.Varint) -> begin
      decompose_req_full_set_timeout v (Pbrt.Decoder.int32_as_varint d);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_req_full" 10 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : decompose_req_full)

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
  let v = default_decompose_res () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      (* put lists in the correct order *)
      decompose_res_set_errors v (List.rev v.errors);
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      decompose_res_set_res v (Artifact (Artmsg.decode_pb_art (Pbrt.Decoder.nested d)));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_res" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      Pbrt.Decoder.empty_nested d;
      decompose_res_set_res v Err;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_res" 2 pk
    | Some (10, Pbrt.Bytes) -> begin
      decompose_res_set_errors v ((Error.decode_pb_error (Pbrt.Decoder.nested d)) :: v.errors);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_res" 10 pk
    | Some (11, Pbrt.Bytes) -> begin
      decompose_res_set_task v (Task.decode_pb_task (Pbrt.Decoder.nested d));
    end
    | Some (11, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "decompose_res" 11 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : decompose_res)

let rec decode_pb_eval_src_req d =
  let v = default_eval_src_req () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      eval_src_req_set_session v (Session.decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "eval_src_req" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      eval_src_req_set_src v (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "eval_src_req" 2 pk
    | Some (3, Pbrt.Varint) -> begin
      eval_src_req_set_async_only v (Pbrt.Decoder.bool d);
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "eval_src_req" 3 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : eval_src_req)

let rec decode_pb_eval_output d =
  let v = default_eval_output () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      (* put lists in the correct order *)
      eval_output_set_errors v (List.rev v.errors);
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      eval_output_set_success v (Pbrt.Decoder.bool d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "eval_output" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      eval_output_set_value_as_ocaml v (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "eval_output" 2 pk
    | Some (10, Pbrt.Bytes) -> begin
      eval_output_set_errors v ((Error.decode_pb_error (Pbrt.Decoder.nested d)) :: v.errors);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "eval_output" 10 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : eval_output)

let rec decode_pb_proved d =
  let v = default_proved () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      proved_set_proof_pp v (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "proved" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : proved)

let rec decode_pb_model_type d : model_type = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> Counter_example
  | 1 -> Instance
  | _ -> Pbrt.Decoder.malformed_variant "model_type"

let rec decode_pb_model d =
  let v = default_model () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      model_set_m_type v (decode_pb_model_type d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "model" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      model_set_src v (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "model" 2 pk
    | Some (3, Pbrt.Bytes) -> begin
      model_set_artifact v (Artmsg.decode_pb_art (Pbrt.Decoder.nested d));
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "model" 3 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : model)

let rec decode_pb_counter_sat d =
  let v = default_counter_sat () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      counter_sat_set_model v (decode_pb_model (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "counter_sat" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : counter_sat)

let rec decode_pb_verified_upto d =
  let v = default_verified_upto () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      verified_upto_set_msg v (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "verified_upto" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : verified_upto)

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
  let v = default_po_res () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      (* put lists in the correct order *)
      po_res_set_errors v (List.rev v.errors);
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      po_res_set_res v (Unknown (Utils.decode_pb_string_msg (Pbrt.Decoder.nested d)));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "po_res" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      Pbrt.Decoder.empty_nested d;
      po_res_set_res v Err;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "po_res" 2 pk
    | Some (3, Pbrt.Bytes) -> begin
      po_res_set_res v (Proof (decode_pb_proved (Pbrt.Decoder.nested d)));
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "po_res" 3 pk
    | Some (4, Pbrt.Bytes) -> begin
      po_res_set_res v (Instance (decode_pb_counter_sat (Pbrt.Decoder.nested d)));
    end
    | Some (4, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "po_res" 4 pk
    | Some (5, Pbrt.Bytes) -> begin
      po_res_set_res v (Verified_upto (decode_pb_verified_upto (Pbrt.Decoder.nested d)));
    end
    | Some (5, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "po_res" 5 pk
    | Some (10, Pbrt.Bytes) -> begin
      po_res_set_errors v ((Error.decode_pb_error (Pbrt.Decoder.nested d)) :: v.errors);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "po_res" 10 pk
    | Some (11, Pbrt.Bytes) -> begin
      po_res_set_task v (Task.decode_pb_task (Pbrt.Decoder.nested d));
    end
    | Some (11, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "po_res" 11 pk
    | Some (12, Pbrt.Bytes) -> begin
      po_res_set_origin v (Task.decode_pb_origin (Pbrt.Decoder.nested d));
    end
    | Some (12, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "po_res" 12 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : po_res)

let rec decode_pb_eval_res d =
  let v = default_eval_res () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      (* put lists in the correct order *)
      eval_res_set_decomp_results v (List.rev v.decomp_results);
      eval_res_set_eval_results v (List.rev v.eval_results);
      eval_res_set_po_results v (List.rev v.po_results);
      eval_res_set_tasks v (List.rev v.tasks);
      eval_res_set_errors v (List.rev v.errors);
      eval_res_set_messages v (List.rev v.messages);
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      eval_res_set_success v (Pbrt.Decoder.bool d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "eval_res" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      eval_res_set_messages v ((Pbrt.Decoder.string d) :: v.messages);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "eval_res" 2 pk
    | Some (3, Pbrt.Bytes) -> begin
      eval_res_set_errors v ((Error.decode_pb_error (Pbrt.Decoder.nested d)) :: v.errors);
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "eval_res" 3 pk
    | Some (4, Pbrt.Bytes) -> begin
      eval_res_set_tasks v ((Task.decode_pb_task (Pbrt.Decoder.nested d)) :: v.tasks);
    end
    | Some (4, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "eval_res" 4 pk
    | Some (10, Pbrt.Bytes) -> begin
      eval_res_set_po_results v ((decode_pb_po_res (Pbrt.Decoder.nested d)) :: v.po_results);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "eval_res" 10 pk
    | Some (11, Pbrt.Bytes) -> begin
      eval_res_set_eval_results v ((decode_pb_eval_output (Pbrt.Decoder.nested d)) :: v.eval_results);
    end
    | Some (11, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "eval_res" 11 pk
    | Some (12, Pbrt.Bytes) -> begin
      eval_res_set_decomp_results v ((decode_pb_decompose_res (Pbrt.Decoder.nested d)) :: v.decomp_results);
    end
    | Some (12, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "eval_res" 12 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : eval_res)

let rec decode_pb_verify_src_req d =
  let v = default_verify_src_req () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      verify_src_req_set_session v (Session.decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "verify_src_req" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      verify_src_req_set_src v (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "verify_src_req" 2 pk
    | Some (10, Pbrt.Bytes) -> begin
      verify_src_req_set_hints v (Pbrt.Decoder.string d);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "verify_src_req" 10 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : verify_src_req)

let rec decode_pb_verify_name_req d =
  let v = default_verify_name_req () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      verify_name_req_set_session v (Session.decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "verify_name_req" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      verify_name_req_set_name v (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "verify_name_req" 2 pk
    | Some (10, Pbrt.Bytes) -> begin
      verify_name_req_set_hints v (Pbrt.Decoder.string d);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "verify_name_req" 10 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : verify_name_req)

let rec decode_pb_instance_src_req d =
  let v = default_instance_src_req () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      instance_src_req_set_session v (Session.decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "instance_src_req" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      instance_src_req_set_src v (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "instance_src_req" 2 pk
    | Some (10, Pbrt.Bytes) -> begin
      instance_src_req_set_hints v (Pbrt.Decoder.string d);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "instance_src_req" 10 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : instance_src_req)

let rec decode_pb_instance_name_req d =
  let v = default_instance_name_req () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      instance_name_req_set_session v (Session.decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "instance_name_req" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      instance_name_req_set_name v (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "instance_name_req" 2 pk
    | Some (10, Pbrt.Bytes) -> begin
      instance_name_req_set_hints v (Pbrt.Decoder.string d);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "instance_name_req" 10 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : instance_name_req)

let rec decode_pb_unsat d =
  let v = default_unsat () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      unsat_set_proof_pp v (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "unsat" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : unsat)

let rec decode_pb_refuted d =
  let v = default_refuted () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      refuted_set_model v (decode_pb_model (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "refuted" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : refuted)

let rec decode_pb_sat d =
  let v = default_sat () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      sat_set_model v (decode_pb_model (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "sat" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : sat)

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
  let v = default_verify_res () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      (* put lists in the correct order *)
      verify_res_set_errors v (List.rev v.errors);
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      verify_res_set_res v (Unknown (Utils.decode_pb_string_msg (Pbrt.Decoder.nested d)));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "verify_res" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      Pbrt.Decoder.empty_nested d;
      verify_res_set_res v Err;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "verify_res" 2 pk
    | Some (3, Pbrt.Bytes) -> begin
      verify_res_set_res v (Proved (decode_pb_proved (Pbrt.Decoder.nested d)));
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "verify_res" 3 pk
    | Some (4, Pbrt.Bytes) -> begin
      verify_res_set_res v (Refuted (decode_pb_refuted (Pbrt.Decoder.nested d)));
    end
    | Some (4, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "verify_res" 4 pk
    | Some (5, Pbrt.Bytes) -> begin
      verify_res_set_res v (Verified_upto (decode_pb_verified_upto (Pbrt.Decoder.nested d)));
    end
    | Some (5, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "verify_res" 5 pk
    | Some (10, Pbrt.Bytes) -> begin
      verify_res_set_errors v ((Error.decode_pb_error (Pbrt.Decoder.nested d)) :: v.errors);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "verify_res" 10 pk
    | Some (11, Pbrt.Bytes) -> begin
      verify_res_set_task v (Task.decode_pb_task (Pbrt.Decoder.nested d));
    end
    | Some (11, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "verify_res" 11 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : verify_res)

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
  let v = default_instance_res () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      (* put lists in the correct order *)
      instance_res_set_errors v (List.rev v.errors);
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      instance_res_set_res v (Unknown (Utils.decode_pb_string_msg (Pbrt.Decoder.nested d)));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "instance_res" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      Pbrt.Decoder.empty_nested d;
      instance_res_set_res v Err;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "instance_res" 2 pk
    | Some (3, Pbrt.Bytes) -> begin
      instance_res_set_res v (Unsat (decode_pb_unsat (Pbrt.Decoder.nested d)));
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "instance_res" 3 pk
    | Some (4, Pbrt.Bytes) -> begin
      instance_res_set_res v (Sat (decode_pb_sat (Pbrt.Decoder.nested d)));
    end
    | Some (4, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "instance_res" 4 pk
    | Some (10, Pbrt.Bytes) -> begin
      instance_res_set_errors v ((Error.decode_pb_error (Pbrt.Decoder.nested d)) :: v.errors);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "instance_res" 10 pk
    | Some (11, Pbrt.Bytes) -> begin
      instance_res_set_task v (Task.decode_pb_task (Pbrt.Decoder.nested d));
    end
    | Some (11, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "instance_res" 11 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : instance_res)

let rec decode_pb_typecheck_req d =
  let v = default_typecheck_req () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      typecheck_req_set_session v (Session.decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "typecheck_req" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      typecheck_req_set_src v (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "typecheck_req" 2 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : typecheck_req)

let rec decode_pb_typecheck_res d =
  let v = default_typecheck_res () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      (* put lists in the correct order *)
      typecheck_res_set_errors v (List.rev v.errors);
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      typecheck_res_set_success v (Pbrt.Decoder.bool d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "typecheck_res" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      typecheck_res_set_types v (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "typecheck_res" 2 pk
    | Some (3, Pbrt.Bytes) -> begin
      typecheck_res_set_errors v ((Error.decode_pb_error (Pbrt.Decoder.nested d)) :: v.errors);
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "typecheck_res" 3 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : typecheck_res)

let rec decode_pb_oneshot_req d =
  let v = default_oneshot_req () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      oneshot_req_set_input v (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "oneshot_req" 1 pk
    | Some (2, Pbrt.Bits64) -> begin
      oneshot_req_set_timeout v (Pbrt.Decoder.float_as_bits64 d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "oneshot_req" 2 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : oneshot_req)

let rec decode_pb_oneshot_res_stats d =
  let v = default_oneshot_res_stats () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bits64) -> begin
      oneshot_res_stats_set_time v (Pbrt.Decoder.float_as_bits64 d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "oneshot_res_stats" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : oneshot_res_stats)

let rec decode_pb_oneshot_res d =
  let v = default_oneshot_res () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      (* put lists in the correct order *)
      oneshot_res_set_detailed_results v (List.rev v.detailed_results);
      oneshot_res_set_errors v (List.rev v.errors);
      oneshot_res_set_results v (List.rev v.results);
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      oneshot_res_set_results v ((Pbrt.Decoder.string d) :: v.results);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "oneshot_res" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      oneshot_res_set_errors v ((Pbrt.Decoder.string d) :: v.errors);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "oneshot_res" 2 pk
    | Some (3, Pbrt.Bytes) -> begin
      oneshot_res_set_stats v (decode_pb_oneshot_res_stats (Pbrt.Decoder.nested d));
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "oneshot_res" 3 pk
    | Some (10, Pbrt.Bytes) -> begin
      oneshot_res_set_detailed_results v ((Pbrt.Decoder.string d) :: v.detailed_results);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "oneshot_res" 10 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : oneshot_res)

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_session_create_req (v:session_create_req) = 
  let assoc = ref [] in
  if session_create_req_has_api_version v then (
    assoc := ("apiVersion", Pbrt_yojson.make_string v.api_version) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_lift_bool (v:lift_bool) = 
  match v with
  | Default -> `String "Default"
  | Nested_equalities -> `String "NestedEqualities"
  | Equalities -> `String "Equalities"
  | All -> `String "All"

let rec encode_json_decompose_req (v:decompose_req) = 
  let assoc = ref [] in
  assoc := (match v.session with
    | None -> !assoc
    | Some v -> ("session", Session.encode_json_session v) :: !assoc);
  if decompose_req_has_name v then (
    assoc := ("name", Pbrt_yojson.make_string v.name) :: !assoc;
  );
  if decompose_req_has_assuming v then (
    assoc := ("assuming", Pbrt_yojson.make_string v.assuming) :: !assoc;
  );
  assoc := (
    let l = v.basis |> List.map Pbrt_yojson.make_string in
    ("basis", `List l) :: !assoc 
  );
  assoc := (
    let l = v.rule_specs |> List.map Pbrt_yojson.make_string in
    ("ruleSpecs", `List l) :: !assoc 
  );
  if decompose_req_has_prune v then (
    assoc := ("prune", Pbrt_yojson.make_bool v.prune) :: !assoc;
  );
  if decompose_req_has_ctx_simp v then (
    assoc := ("ctxSimp", Pbrt_yojson.make_bool v.ctx_simp) :: !assoc;
  );
  if decompose_req_has_lift_bool v then (
    assoc := ("liftBool", encode_json_lift_bool v.lift_bool) :: !assoc;
  );
  if decompose_req_has_str v then (
    assoc := ("str", Pbrt_yojson.make_bool v.str) :: !assoc;
  );
  if decompose_req_has_timeout v then (
    assoc := ("timeout", Pbrt_yojson.make_int (Int32.to_int v.timeout)) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_decompose_req_full_by_name (v:decompose_req_full_by_name) = 
  let assoc = ref [] in
  if decompose_req_full_by_name_has_name v then (
    assoc := ("name", Pbrt_yojson.make_string v.name) :: !assoc;
  );
  if decompose_req_full_by_name_has_assuming v then (
    assoc := ("assuming", Pbrt_yojson.make_string v.assuming) :: !assoc;
  );
  assoc := (
    let l = v.basis |> List.map Pbrt_yojson.make_string in
    ("basis", `List l) :: !assoc 
  );
  assoc := (
    let l = v.rule_specs |> List.map Pbrt_yojson.make_string in
    ("ruleSpecs", `List l) :: !assoc 
  );
  if decompose_req_full_by_name_has_prune v then (
    assoc := ("prune", Pbrt_yojson.make_bool v.prune) :: !assoc;
  );
  if decompose_req_full_by_name_has_ctx_simp v then (
    assoc := ("ctxSimp", Pbrt_yojson.make_bool v.ctx_simp) :: !assoc;
  );
  if decompose_req_full_by_name_has_lift_bool v then (
    assoc := ("liftBool", encode_json_lift_bool v.lift_bool) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_decompose_req_full_local_var_get (v:decompose_req_full_local_var_get) = 
  let assoc = ref [] in
  if decompose_req_full_local_var_get_has_name v then (
    assoc := ("name", Pbrt_yojson.make_string v.name) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_decompose_req_full_prune (v:decompose_req_full_prune) = 
  let assoc = ref [] in
  assoc := (match v.d with
    | None -> !assoc
    | Some v -> ("d", encode_json_decompose_req_full_decomp v) :: !assoc);
  `Assoc !assoc

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
  let assoc = ref [] in
  assoc := (match v.d1 with
    | None -> !assoc
    | Some v -> ("d1", encode_json_decompose_req_full_decomp v) :: !assoc);
  assoc := (match v.d2 with
    | None -> !assoc
    | Some v -> ("d2", encode_json_decompose_req_full_decomp v) :: !assoc);
  `Assoc !assoc

and encode_json_decompose_req_full_compound_merge (v:decompose_req_full_compound_merge) = 
  let assoc = ref [] in
  assoc := (match v.d1 with
    | None -> !assoc
    | Some v -> ("d1", encode_json_decompose_req_full_decomp v) :: !assoc);
  assoc := (match v.d2 with
    | None -> !assoc
    | Some v -> ("d2", encode_json_decompose_req_full_decomp v) :: !assoc);
  `Assoc !assoc

and encode_json_decompose_req_full_combine (v:decompose_req_full_combine) = 
  let assoc = ref [] in
  assoc := (match v.d with
    | None -> !assoc
    | Some v -> ("d", encode_json_decompose_req_full_decomp v) :: !assoc);
  `Assoc !assoc

and encode_json_decompose_req_full_local_var_let (v:decompose_req_full_local_var_let) = 
  let assoc = ref [] in
  assoc := (
    let l = v.bindings |> List.map encode_json_decompose_req_full_local_var_binding in
    ("bindings", `List l) :: !assoc 
  );
  assoc := (match v.and_then with
    | None -> !assoc
    | Some v -> ("andThen", encode_json_decompose_req_full_decomp v) :: !assoc);
  `Assoc !assoc

and encode_json_decompose_req_full_local_var_binding (v:decompose_req_full_local_var_binding) = 
  let assoc = ref [] in
  if decompose_req_full_local_var_binding_has_name v then (
    assoc := ("name", Pbrt_yojson.make_string v.name) :: !assoc;
  );
  assoc := (match v.d with
    | None -> !assoc
    | Some v -> ("d", encode_json_decompose_req_full_decomp v) :: !assoc);
  `Assoc !assoc

let rec encode_json_decompose_req_full (v:decompose_req_full) = 
  let assoc = ref [] in
  assoc := (match v.session with
    | None -> !assoc
    | Some v -> ("session", Session.encode_json_session v) :: !assoc);
  assoc := (match v.decomp with
    | None -> !assoc
    | Some v -> ("decomp", encode_json_decompose_req_full_decomp v) :: !assoc);
  if decompose_req_full_has_str v then (
    assoc := ("str", Pbrt_yojson.make_bool v.str) :: !assoc;
  );
  if decompose_req_full_has_timeout v then (
    assoc := ("timeout", Pbrt_yojson.make_int (Int32.to_int v.timeout)) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_decompose_res_res (v:decompose_res_res) = 
  begin match v with
  | Artifact v -> `Assoc [("artifact", Artmsg.encode_json_art v)]
  | Err -> `Assoc [("err", `Null)]
  end

and encode_json_decompose_res (v:decompose_res) = 
  let assoc = ref [] in
  assoc := (match v.res with
      | None -> !assoc
      | Some (Artifact v) -> ("artifact", Artmsg.encode_json_art v) :: !assoc
      | Some Err -> ("err", `Null) :: !assoc
  ); (* match v.res *)
  assoc := (
    let l = v.errors |> List.map Error.encode_json_error in
    ("errors", `List l) :: !assoc 
  );
  assoc := (match v.task with
    | None -> !assoc
    | Some v -> ("task", Task.encode_json_task v) :: !assoc);
  `Assoc !assoc

let rec encode_json_eval_src_req (v:eval_src_req) = 
  let assoc = ref [] in
  assoc := (match v.session with
    | None -> !assoc
    | Some v -> ("session", Session.encode_json_session v) :: !assoc);
  if eval_src_req_has_src v then (
    assoc := ("src", Pbrt_yojson.make_string v.src) :: !assoc;
  );
  if eval_src_req_has_async_only v then (
    assoc := ("asyncOnly", Pbrt_yojson.make_bool v.async_only) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_eval_output (v:eval_output) = 
  let assoc = ref [] in
  if eval_output_has_success v then (
    assoc := ("success", Pbrt_yojson.make_bool v.success) :: !assoc;
  );
  if eval_output_has_value_as_ocaml v then (
    assoc := ("valueAsOcaml", Pbrt_yojson.make_string v.value_as_ocaml) :: !assoc;
  );
  assoc := (
    let l = v.errors |> List.map Error.encode_json_error in
    ("errors", `List l) :: !assoc 
  );
  `Assoc !assoc

let rec encode_json_proved (v:proved) = 
  let assoc = ref [] in
  if proved_has_proof_pp v then (
    assoc := ("proofPp", Pbrt_yojson.make_string v.proof_pp) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_model_type (v:model_type) = 
  match v with
  | Counter_example -> `String "Counter_example"
  | Instance -> `String "Instance"

let rec encode_json_model (v:model) = 
  let assoc = ref [] in
  if model_has_m_type v then (
    assoc := ("mType", encode_json_model_type v.m_type) :: !assoc;
  );
  if model_has_src v then (
    assoc := ("src", Pbrt_yojson.make_string v.src) :: !assoc;
  );
  assoc := (match v.artifact with
    | None -> !assoc
    | Some v -> ("artifact", Artmsg.encode_json_art v) :: !assoc);
  `Assoc !assoc

let rec encode_json_counter_sat (v:counter_sat) = 
  let assoc = ref [] in
  assoc := (match v.model with
    | None -> !assoc
    | Some v -> ("model", encode_json_model v) :: !assoc);
  `Assoc !assoc

let rec encode_json_verified_upto (v:verified_upto) = 
  let assoc = ref [] in
  if verified_upto_has_msg v then (
    assoc := ("msg", Pbrt_yojson.make_string v.msg) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_po_res_res (v:po_res_res) = 
  begin match v with
  | Unknown v -> `Assoc [("unknown", Utils.encode_json_string_msg v)]
  | Err -> `Assoc [("err", `Null)]
  | Proof v -> `Assoc [("proof", encode_json_proved v)]
  | Instance v -> `Assoc [("instance", encode_json_counter_sat v)]
  | Verified_upto v -> `Assoc [("verifiedUpto", encode_json_verified_upto v)]
  end

and encode_json_po_res (v:po_res) = 
  let assoc = ref [] in
  assoc := (match v.res with
      | None -> !assoc
      | Some (Unknown v) -> ("unknown", Utils.encode_json_string_msg v) :: !assoc
      | Some Err -> ("err", `Null) :: !assoc
      | Some (Proof v) -> ("proof", encode_json_proved v) :: !assoc
      | Some (Instance v) -> ("instance", encode_json_counter_sat v) :: !assoc
      | Some (Verified_upto v) -> ("verifiedUpto", encode_json_verified_upto v) :: !assoc
  ); (* match v.res *)
  assoc := (
    let l = v.errors |> List.map Error.encode_json_error in
    ("errors", `List l) :: !assoc 
  );
  assoc := (match v.task with
    | None -> !assoc
    | Some v -> ("task", Task.encode_json_task v) :: !assoc);
  assoc := (match v.origin with
    | None -> !assoc
    | Some v -> ("origin", Task.encode_json_origin v) :: !assoc);
  `Assoc !assoc

let rec encode_json_eval_res (v:eval_res) = 
  let assoc = ref [] in
  if eval_res_has_success v then (
    assoc := ("success", Pbrt_yojson.make_bool v.success) :: !assoc;
  );
  assoc := (
    let l = v.messages |> List.map Pbrt_yojson.make_string in
    ("messages", `List l) :: !assoc 
  );
  assoc := (
    let l = v.errors |> List.map Error.encode_json_error in
    ("errors", `List l) :: !assoc 
  );
  assoc := (
    let l = v.tasks |> List.map Task.encode_json_task in
    ("tasks", `List l) :: !assoc 
  );
  assoc := (
    let l = v.po_results |> List.map encode_json_po_res in
    ("poResults", `List l) :: !assoc 
  );
  assoc := (
    let l = v.eval_results |> List.map encode_json_eval_output in
    ("evalResults", `List l) :: !assoc 
  );
  assoc := (
    let l = v.decomp_results |> List.map encode_json_decompose_res in
    ("decompResults", `List l) :: !assoc 
  );
  `Assoc !assoc

let rec encode_json_verify_src_req (v:verify_src_req) = 
  let assoc = ref [] in
  assoc := (match v.session with
    | None -> !assoc
    | Some v -> ("session", Session.encode_json_session v) :: !assoc);
  if verify_src_req_has_src v then (
    assoc := ("src", Pbrt_yojson.make_string v.src) :: !assoc;
  );
  if verify_src_req_has_hints v then (
    assoc := ("hints", Pbrt_yojson.make_string v.hints) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_verify_name_req (v:verify_name_req) = 
  let assoc = ref [] in
  assoc := (match v.session with
    | None -> !assoc
    | Some v -> ("session", Session.encode_json_session v) :: !assoc);
  if verify_name_req_has_name v then (
    assoc := ("name", Pbrt_yojson.make_string v.name) :: !assoc;
  );
  if verify_name_req_has_hints v then (
    assoc := ("hints", Pbrt_yojson.make_string v.hints) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_instance_src_req (v:instance_src_req) = 
  let assoc = ref [] in
  assoc := (match v.session with
    | None -> !assoc
    | Some v -> ("session", Session.encode_json_session v) :: !assoc);
  if instance_src_req_has_src v then (
    assoc := ("src", Pbrt_yojson.make_string v.src) :: !assoc;
  );
  if instance_src_req_has_hints v then (
    assoc := ("hints", Pbrt_yojson.make_string v.hints) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_instance_name_req (v:instance_name_req) = 
  let assoc = ref [] in
  assoc := (match v.session with
    | None -> !assoc
    | Some v -> ("session", Session.encode_json_session v) :: !assoc);
  if instance_name_req_has_name v then (
    assoc := ("name", Pbrt_yojson.make_string v.name) :: !assoc;
  );
  if instance_name_req_has_hints v then (
    assoc := ("hints", Pbrt_yojson.make_string v.hints) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_unsat (v:unsat) = 
  let assoc = ref [] in
  if unsat_has_proof_pp v then (
    assoc := ("proofPp", Pbrt_yojson.make_string v.proof_pp) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_refuted (v:refuted) = 
  let assoc = ref [] in
  assoc := (match v.model with
    | None -> !assoc
    | Some v -> ("model", encode_json_model v) :: !assoc);
  `Assoc !assoc

let rec encode_json_sat (v:sat) = 
  let assoc = ref [] in
  assoc := (match v.model with
    | None -> !assoc
    | Some v -> ("model", encode_json_model v) :: !assoc);
  `Assoc !assoc

let rec encode_json_verify_res_res (v:verify_res_res) = 
  begin match v with
  | Unknown v -> `Assoc [("unknown", Utils.encode_json_string_msg v)]
  | Err -> `Assoc [("err", `Null)]
  | Proved v -> `Assoc [("proved", encode_json_proved v)]
  | Refuted v -> `Assoc [("refuted", encode_json_refuted v)]
  | Verified_upto v -> `Assoc [("verifiedUpto", encode_json_verified_upto v)]
  end

and encode_json_verify_res (v:verify_res) = 
  let assoc = ref [] in
  assoc := (match v.res with
      | None -> !assoc
      | Some (Unknown v) -> ("unknown", Utils.encode_json_string_msg v) :: !assoc
      | Some Err -> ("err", `Null) :: !assoc
      | Some (Proved v) -> ("proved", encode_json_proved v) :: !assoc
      | Some (Refuted v) -> ("refuted", encode_json_refuted v) :: !assoc
      | Some (Verified_upto v) -> ("verifiedUpto", encode_json_verified_upto v) :: !assoc
  ); (* match v.res *)
  assoc := (
    let l = v.errors |> List.map Error.encode_json_error in
    ("errors", `List l) :: !assoc 
  );
  assoc := (match v.task with
    | None -> !assoc
    | Some v -> ("task", Task.encode_json_task v) :: !assoc);
  `Assoc !assoc

let rec encode_json_instance_res_res (v:instance_res_res) = 
  begin match v with
  | Unknown v -> `Assoc [("unknown", Utils.encode_json_string_msg v)]
  | Err -> `Assoc [("err", `Null)]
  | Unsat v -> `Assoc [("unsat", encode_json_unsat v)]
  | Sat v -> `Assoc [("sat", encode_json_sat v)]
  end

and encode_json_instance_res (v:instance_res) = 
  let assoc = ref [] in
  assoc := (match v.res with
      | None -> !assoc
      | Some (Unknown v) -> ("unknown", Utils.encode_json_string_msg v) :: !assoc
      | Some Err -> ("err", `Null) :: !assoc
      | Some (Unsat v) -> ("unsat", encode_json_unsat v) :: !assoc
      | Some (Sat v) -> ("sat", encode_json_sat v) :: !assoc
  ); (* match v.res *)
  assoc := (
    let l = v.errors |> List.map Error.encode_json_error in
    ("errors", `List l) :: !assoc 
  );
  assoc := (match v.task with
    | None -> !assoc
    | Some v -> ("task", Task.encode_json_task v) :: !assoc);
  `Assoc !assoc

let rec encode_json_typecheck_req (v:typecheck_req) = 
  let assoc = ref [] in
  assoc := (match v.session with
    | None -> !assoc
    | Some v -> ("session", Session.encode_json_session v) :: !assoc);
  if typecheck_req_has_src v then (
    assoc := ("src", Pbrt_yojson.make_string v.src) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_typecheck_res (v:typecheck_res) = 
  let assoc = ref [] in
  if typecheck_res_has_success v then (
    assoc := ("success", Pbrt_yojson.make_bool v.success) :: !assoc;
  );
  if typecheck_res_has_types v then (
    assoc := ("types", Pbrt_yojson.make_string v.types) :: !assoc;
  );
  assoc := (
    let l = v.errors |> List.map Error.encode_json_error in
    ("errors", `List l) :: !assoc 
  );
  `Assoc !assoc

let rec encode_json_oneshot_req (v:oneshot_req) = 
  let assoc = ref [] in
  if oneshot_req_has_input v then (
    assoc := ("input", Pbrt_yojson.make_string v.input) :: !assoc;
  );
  if oneshot_req_has_timeout v then (
    assoc := ("timeout", Pbrt_yojson.make_string (string_of_float v.timeout)) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_oneshot_res_stats (v:oneshot_res_stats) = 
  let assoc = ref [] in
  if oneshot_res_stats_has_time v then (
    assoc := ("time", Pbrt_yojson.make_string (string_of_float v.time)) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_oneshot_res (v:oneshot_res) = 
  let assoc = ref [] in
  assoc := (
    let l = v.results |> List.map Pbrt_yojson.make_string in
    ("results", `List l) :: !assoc 
  );
  assoc := (
    let l = v.errors |> List.map Pbrt_yojson.make_string in
    ("errors", `List l) :: !assoc 
  );
  assoc := (match v.stats with
    | None -> !assoc
    | Some v -> ("stats", encode_json_oneshot_res_stats v) :: !assoc);
  assoc := (
    let l = v.detailed_results |> List.map Pbrt_yojson.make_string in
    ("detailedResults", `List l) :: !assoc 
  );
  `Assoc !assoc

[@@@ocaml.warning "-23-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_session_create_req d =
  let v = default_session_create_req () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("apiVersion", json_value) -> 
      session_create_req_set_api_version v (Pbrt_yojson.string json_value "session_create_req" "api_version")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
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
  let v = default_decompose_req () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      decompose_req_set_session v (Session.decode_json_session json_value)
    | ("name", json_value) -> 
      decompose_req_set_name v (Pbrt_yojson.string json_value "decompose_req" "name")
    | ("assuming", json_value) -> 
      decompose_req_set_assuming v (Pbrt_yojson.string json_value "decompose_req" "assuming")
    | ("basis", `List l) -> begin
      decompose_req_set_basis v @@ List.map (function
        | json_value -> Pbrt_yojson.string json_value "decompose_req" "basis"
      ) l;
    end
    | ("ruleSpecs", `List l) -> begin
      decompose_req_set_rule_specs v @@ List.map (function
        | json_value -> Pbrt_yojson.string json_value "decompose_req" "rule_specs"
      ) l;
    end
    | ("prune", json_value) -> 
      decompose_req_set_prune v (Pbrt_yojson.bool json_value "decompose_req" "prune")
    | ("ctxSimp", json_value) -> 
      decompose_req_set_ctx_simp v (Pbrt_yojson.bool json_value "decompose_req" "ctx_simp")
    | ("liftBool", json_value) -> 
      decompose_req_set_lift_bool v ((decode_json_lift_bool json_value))
    | ("str", json_value) -> 
      decompose_req_set_str v (Pbrt_yojson.bool json_value "decompose_req" "str")
    | ("timeout", json_value) -> 
      decompose_req_set_timeout v (Pbrt_yojson.int32 json_value "decompose_req" "timeout")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
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
  let v = default_decompose_req_full_by_name () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("name", json_value) -> 
      decompose_req_full_by_name_set_name v (Pbrt_yojson.string json_value "decompose_req_full_by_name" "name")
    | ("assuming", json_value) -> 
      decompose_req_full_by_name_set_assuming v (Pbrt_yojson.string json_value "decompose_req_full_by_name" "assuming")
    | ("basis", `List l) -> begin
      decompose_req_full_by_name_set_basis v @@ List.map (function
        | json_value -> Pbrt_yojson.string json_value "decompose_req_full_by_name" "basis"
      ) l;
    end
    | ("ruleSpecs", `List l) -> begin
      decompose_req_full_by_name_set_rule_specs v @@ List.map (function
        | json_value -> Pbrt_yojson.string json_value "decompose_req_full_by_name" "rule_specs"
      ) l;
    end
    | ("prune", json_value) -> 
      decompose_req_full_by_name_set_prune v (Pbrt_yojson.bool json_value "decompose_req_full_by_name" "prune")
    | ("ctxSimp", json_value) -> 
      decompose_req_full_by_name_set_ctx_simp v (Pbrt_yojson.bool json_value "decompose_req_full_by_name" "ctx_simp")
    | ("liftBool", json_value) -> 
      decompose_req_full_by_name_set_lift_bool v ((decode_json_lift_bool json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    name = v.name;
    assuming = v.assuming;
    basis = v.basis;
    rule_specs = v.rule_specs;
    prune = v.prune;
    ctx_simp = v.ctx_simp;
    lift_bool = v.lift_bool;
  } : decompose_req_full_by_name)

let rec decode_json_decompose_req_full_local_var_get d =
  let v = default_decompose_req_full_local_var_get () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("name", json_value) -> 
      decompose_req_full_local_var_get_set_name v (Pbrt_yojson.string json_value "decompose_req_full_local_var_get" "name")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    name = v.name;
  } : decompose_req_full_local_var_get)

let rec decode_json_decompose_req_full_prune d =
  let v = default_decompose_req_full_prune () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("d", json_value) -> 
      decompose_req_full_prune_set_d v (decode_json_decompose_req_full_decomp json_value)
    
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
  let v = default_decompose_req_full_merge () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("d1", json_value) -> 
      decompose_req_full_merge_set_d1 v (decode_json_decompose_req_full_decomp json_value)
    | ("d2", json_value) -> 
      decompose_req_full_merge_set_d2 v (decode_json_decompose_req_full_decomp json_value)
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    d1 = v.d1;
    d2 = v.d2;
  } : decompose_req_full_merge)

and decode_json_decompose_req_full_compound_merge d =
  let v = default_decompose_req_full_compound_merge () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("d1", json_value) -> 
      decompose_req_full_compound_merge_set_d1 v (decode_json_decompose_req_full_decomp json_value)
    | ("d2", json_value) -> 
      decompose_req_full_compound_merge_set_d2 v (decode_json_decompose_req_full_decomp json_value)
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    d1 = v.d1;
    d2 = v.d2;
  } : decompose_req_full_compound_merge)

and decode_json_decompose_req_full_combine d =
  let v = default_decompose_req_full_combine () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("d", json_value) -> 
      decompose_req_full_combine_set_d v (decode_json_decompose_req_full_decomp json_value)
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    d = v.d;
  } : decompose_req_full_combine)

and decode_json_decompose_req_full_local_var_let d =
  let v = default_decompose_req_full_local_var_let () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("bindings", `List l) -> begin
      decompose_req_full_local_var_let_set_bindings v @@ List.map (function
        | json_value -> (decode_json_decompose_req_full_local_var_binding json_value)
      ) l;
    end
    | ("andThen", json_value) -> 
      decompose_req_full_local_var_let_set_and_then v (decode_json_decompose_req_full_decomp json_value)
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    bindings = v.bindings;
    and_then = v.and_then;
  } : decompose_req_full_local_var_let)

and decode_json_decompose_req_full_local_var_binding d =
  let v = default_decompose_req_full_local_var_binding () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("name", json_value) -> 
      decompose_req_full_local_var_binding_set_name v (Pbrt_yojson.string json_value "decompose_req_full_local_var_binding" "name")
    | ("d", json_value) -> 
      decompose_req_full_local_var_binding_set_d v (decode_json_decompose_req_full_decomp json_value)
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    name = v.name;
    d = v.d;
  } : decompose_req_full_local_var_binding)

let rec decode_json_decompose_req_full d =
  let v = default_decompose_req_full () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      decompose_req_full_set_session v (Session.decode_json_session json_value)
    | ("decomp", json_value) -> 
      decompose_req_full_set_decomp v (decode_json_decompose_req_full_decomp json_value)
    | ("str", json_value) -> 
      decompose_req_full_set_str v (Pbrt_yojson.bool json_value "decompose_req_full" "str")
    | ("timeout", json_value) -> 
      decompose_req_full_set_timeout v (Pbrt_yojson.int32 json_value "decompose_req_full" "timeout")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
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
  let v = default_decompose_res () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("artifact", json_value) -> 
      decompose_res_set_res v (Artifact ((Artmsg.decode_json_art json_value)))
    | ("err", _) -> decompose_res_set_res v Err
    | ("errors", `List l) -> begin
      decompose_res_set_errors v @@ List.map (function
        | json_value -> (Error.decode_json_error json_value)
      ) l;
    end
    | ("task", json_value) -> 
      decompose_res_set_task v (Task.decode_json_task json_value)
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    res = v.res;
    errors = v.errors;
    task = v.task;
  } : decompose_res)

let rec decode_json_eval_src_req d =
  let v = default_eval_src_req () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      eval_src_req_set_session v (Session.decode_json_session json_value)
    | ("src", json_value) -> 
      eval_src_req_set_src v (Pbrt_yojson.string json_value "eval_src_req" "src")
    | ("asyncOnly", json_value) -> 
      eval_src_req_set_async_only v (Pbrt_yojson.bool json_value "eval_src_req" "async_only")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    session = v.session;
    src = v.src;
    async_only = v.async_only;
  } : eval_src_req)

let rec decode_json_eval_output d =
  let v = default_eval_output () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("success", json_value) -> 
      eval_output_set_success v (Pbrt_yojson.bool json_value "eval_output" "success")
    | ("valueAsOcaml", json_value) -> 
      eval_output_set_value_as_ocaml v (Pbrt_yojson.string json_value "eval_output" "value_as_ocaml")
    | ("errors", `List l) -> begin
      eval_output_set_errors v @@ List.map (function
        | json_value -> (Error.decode_json_error json_value)
      ) l;
    end
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    success = v.success;
    value_as_ocaml = v.value_as_ocaml;
    errors = v.errors;
  } : eval_output)

let rec decode_json_proved d =
  let v = default_proved () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("proofPp", json_value) -> 
      proved_set_proof_pp v (Pbrt_yojson.string json_value "proved" "proof_pp")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    proof_pp = v.proof_pp;
  } : proved)

let rec decode_json_model_type json =
  match json with
  | `String "Counter_example" -> (Counter_example : model_type)
  | `String "Instance" -> (Instance : model_type)
  | _ -> Pbrt_yojson.E.malformed_variant "model_type"

let rec decode_json_model d =
  let v = default_model () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("mType", json_value) -> 
      model_set_m_type v ((decode_json_model_type json_value))
    | ("src", json_value) -> 
      model_set_src v (Pbrt_yojson.string json_value "model" "src")
    | ("artifact", json_value) -> 
      model_set_artifact v (Artmsg.decode_json_art json_value)
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    m_type = v.m_type;
    src = v.src;
    artifact = v.artifact;
  } : model)

let rec decode_json_counter_sat d =
  let v = default_counter_sat () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("model", json_value) -> 
      counter_sat_set_model v (decode_json_model json_value)
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    model = v.model;
  } : counter_sat)

let rec decode_json_verified_upto d =
  let v = default_verified_upto () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("msg", json_value) -> 
      verified_upto_set_msg v (Pbrt_yojson.string json_value "verified_upto" "msg")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
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
  let v = default_po_res () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("unknown", json_value) -> 
      po_res_set_res v (Unknown ((Utils.decode_json_string_msg json_value)))
    | ("err", _) -> po_res_set_res v Err
    | ("proof", json_value) -> 
      po_res_set_res v (Proof ((decode_json_proved json_value)))
    | ("instance", json_value) -> 
      po_res_set_res v (Instance ((decode_json_counter_sat json_value)))
    | ("verifiedUpto", json_value) -> 
      po_res_set_res v (Verified_upto ((decode_json_verified_upto json_value)))
    | ("errors", `List l) -> begin
      po_res_set_errors v @@ List.map (function
        | json_value -> (Error.decode_json_error json_value)
      ) l;
    end
    | ("task", json_value) -> 
      po_res_set_task v (Task.decode_json_task json_value)
    | ("origin", json_value) -> 
      po_res_set_origin v (Task.decode_json_origin json_value)
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    res = v.res;
    errors = v.errors;
    task = v.task;
    origin = v.origin;
  } : po_res)

let rec decode_json_eval_res d =
  let v = default_eval_res () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("success", json_value) -> 
      eval_res_set_success v (Pbrt_yojson.bool json_value "eval_res" "success")
    | ("messages", `List l) -> begin
      eval_res_set_messages v @@ List.map (function
        | json_value -> Pbrt_yojson.string json_value "eval_res" "messages"
      ) l;
    end
    | ("errors", `List l) -> begin
      eval_res_set_errors v @@ List.map (function
        | json_value -> (Error.decode_json_error json_value)
      ) l;
    end
    | ("tasks", `List l) -> begin
      eval_res_set_tasks v @@ List.map (function
        | json_value -> (Task.decode_json_task json_value)
      ) l;
    end
    | ("poResults", `List l) -> begin
      eval_res_set_po_results v @@ List.map (function
        | json_value -> (decode_json_po_res json_value)
      ) l;
    end
    | ("evalResults", `List l) -> begin
      eval_res_set_eval_results v @@ List.map (function
        | json_value -> (decode_json_eval_output json_value)
      ) l;
    end
    | ("decompResults", `List l) -> begin
      eval_res_set_decomp_results v @@ List.map (function
        | json_value -> (decode_json_decompose_res json_value)
      ) l;
    end
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    success = v.success;
    messages = v.messages;
    errors = v.errors;
    tasks = v.tasks;
    po_results = v.po_results;
    eval_results = v.eval_results;
    decomp_results = v.decomp_results;
  } : eval_res)

let rec decode_json_verify_src_req d =
  let v = default_verify_src_req () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      verify_src_req_set_session v (Session.decode_json_session json_value)
    | ("src", json_value) -> 
      verify_src_req_set_src v (Pbrt_yojson.string json_value "verify_src_req" "src")
    | ("hints", json_value) -> 
      verify_src_req_set_hints v (Pbrt_yojson.string json_value "verify_src_req" "hints")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    session = v.session;
    src = v.src;
    hints = v.hints;
  } : verify_src_req)

let rec decode_json_verify_name_req d =
  let v = default_verify_name_req () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      verify_name_req_set_session v (Session.decode_json_session json_value)
    | ("name", json_value) -> 
      verify_name_req_set_name v (Pbrt_yojson.string json_value "verify_name_req" "name")
    | ("hints", json_value) -> 
      verify_name_req_set_hints v (Pbrt_yojson.string json_value "verify_name_req" "hints")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    session = v.session;
    name = v.name;
    hints = v.hints;
  } : verify_name_req)

let rec decode_json_instance_src_req d =
  let v = default_instance_src_req () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      instance_src_req_set_session v (Session.decode_json_session json_value)
    | ("src", json_value) -> 
      instance_src_req_set_src v (Pbrt_yojson.string json_value "instance_src_req" "src")
    | ("hints", json_value) -> 
      instance_src_req_set_hints v (Pbrt_yojson.string json_value "instance_src_req" "hints")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    session = v.session;
    src = v.src;
    hints = v.hints;
  } : instance_src_req)

let rec decode_json_instance_name_req d =
  let v = default_instance_name_req () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      instance_name_req_set_session v (Session.decode_json_session json_value)
    | ("name", json_value) -> 
      instance_name_req_set_name v (Pbrt_yojson.string json_value "instance_name_req" "name")
    | ("hints", json_value) -> 
      instance_name_req_set_hints v (Pbrt_yojson.string json_value "instance_name_req" "hints")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    session = v.session;
    name = v.name;
    hints = v.hints;
  } : instance_name_req)

let rec decode_json_unsat d =
  let v = default_unsat () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("proofPp", json_value) -> 
      unsat_set_proof_pp v (Pbrt_yojson.string json_value "unsat" "proof_pp")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    proof_pp = v.proof_pp;
  } : unsat)

let rec decode_json_refuted d =
  let v = default_refuted () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("model", json_value) -> 
      refuted_set_model v (decode_json_model json_value)
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    model = v.model;
  } : refuted)

let rec decode_json_sat d =
  let v = default_sat () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("model", json_value) -> 
      sat_set_model v (decode_json_model json_value)
    
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
  let v = default_verify_res () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("unknown", json_value) -> 
      verify_res_set_res v (Unknown ((Utils.decode_json_string_msg json_value)))
    | ("err", _) -> verify_res_set_res v Err
    | ("proved", json_value) -> 
      verify_res_set_res v (Proved ((decode_json_proved json_value)))
    | ("refuted", json_value) -> 
      verify_res_set_res v (Refuted ((decode_json_refuted json_value)))
    | ("verifiedUpto", json_value) -> 
      verify_res_set_res v (Verified_upto ((decode_json_verified_upto json_value)))
    | ("errors", `List l) -> begin
      verify_res_set_errors v @@ List.map (function
        | json_value -> (Error.decode_json_error json_value)
      ) l;
    end
    | ("task", json_value) -> 
      verify_res_set_task v (Task.decode_json_task json_value)
    
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
  let v = default_instance_res () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("unknown", json_value) -> 
      instance_res_set_res v (Unknown ((Utils.decode_json_string_msg json_value)))
    | ("err", _) -> instance_res_set_res v Err
    | ("unsat", json_value) -> 
      instance_res_set_res v (Unsat ((decode_json_unsat json_value)))
    | ("sat", json_value) -> 
      instance_res_set_res v (Sat ((decode_json_sat json_value)))
    | ("errors", `List l) -> begin
      instance_res_set_errors v @@ List.map (function
        | json_value -> (Error.decode_json_error json_value)
      ) l;
    end
    | ("task", json_value) -> 
      instance_res_set_task v (Task.decode_json_task json_value)
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    res = v.res;
    errors = v.errors;
    task = v.task;
  } : instance_res)

let rec decode_json_typecheck_req d =
  let v = default_typecheck_req () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      typecheck_req_set_session v (Session.decode_json_session json_value)
    | ("src", json_value) -> 
      typecheck_req_set_src v (Pbrt_yojson.string json_value "typecheck_req" "src")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    session = v.session;
    src = v.src;
  } : typecheck_req)

let rec decode_json_typecheck_res d =
  let v = default_typecheck_res () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("success", json_value) -> 
      typecheck_res_set_success v (Pbrt_yojson.bool json_value "typecheck_res" "success")
    | ("types", json_value) -> 
      typecheck_res_set_types v (Pbrt_yojson.string json_value "typecheck_res" "types")
    | ("errors", `List l) -> begin
      typecheck_res_set_errors v @@ List.map (function
        | json_value -> (Error.decode_json_error json_value)
      ) l;
    end
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    success = v.success;
    types = v.types;
    errors = v.errors;
  } : typecheck_res)

let rec decode_json_oneshot_req d =
  let v = default_oneshot_req () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("input", json_value) -> 
      oneshot_req_set_input v (Pbrt_yojson.string json_value "oneshot_req" "input")
    | ("timeout", json_value) -> 
      oneshot_req_set_timeout v (Pbrt_yojson.float json_value "oneshot_req" "timeout")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    input = v.input;
    timeout = v.timeout;
  } : oneshot_req)

let rec decode_json_oneshot_res_stats d =
  let v = default_oneshot_res_stats () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("time", json_value) -> 
      oneshot_res_stats_set_time v (Pbrt_yojson.float json_value "oneshot_res_stats" "time")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    time = v.time;
  } : oneshot_res_stats)

let rec decode_json_oneshot_res d =
  let v = default_oneshot_res () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("results", `List l) -> begin
      oneshot_res_set_results v @@ List.map (function
        | json_value -> Pbrt_yojson.string json_value "oneshot_res" "results"
      ) l;
    end
    | ("errors", `List l) -> begin
      oneshot_res_set_errors v @@ List.map (function
        | json_value -> Pbrt_yojson.string json_value "oneshot_res" "errors"
      ) l;
    end
    | ("stats", json_value) -> 
      oneshot_res_set_stats v (decode_json_oneshot_res_stats json_value)
    | ("detailedResults", `List l) -> begin
      oneshot_res_set_detailed_results v @@ List.map (function
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
