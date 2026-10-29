(* Builders for the values of the golden cases *)

open Imandrax_api
module Mir = Imandrax_api_mir
module A = Imandrax_api_artifact.Artifact
module Ca_ptr = Imandrax_api_ca_store.Ca_ptr
module Key = Imandrax_api_ca_store.Key

type case =
  | Case : {
      name: string;
      kind: 'a A.kind;
      data: 'a;
      storage: A.storage;
    }
      -> case

let case ?(storage : A.storage = []) (name : string) (kind : 'a A.kind)
    (data : 'a) : case =
  Case { name; kind; data; storage }

(* Uids
   ==== *)

let uid (name : string) : Uid.t = Uid.Private_.make name Uid.Persistent

let local_uid (name : string) (id : int) : Uid.t =
  Uid.Private_.make name (Uid.Generative { id; gen_kind = Uid.Local })

let chash (s : string) : Chash.t = Chash.(make string s)

let cname (name : string) : Cname.t =
  { name; chash = chash name; is_key = true }

let cname_uid (name : string) : Uid.t =
  Uid.Private_.make name (Uid.Cname { cname = cname name })

let builtin_kind (name : string) : Builtin_data.kind =
  Logic_core { logic_core_name = name }

let builtin_uid (name : string) : Uid.t =
  Uid.Private_.make name (Uid.Builtin { kind = builtin_kind name })

(* Types
   ===== *)

let ty (v : (unit, Mir.Type.var, Mir.Type.t) Ty_view.view) : Mir.Type.t =
  Mir.Type.make Mir.Type.State.non_hashconsing v

let constr (name : string) (args : Mir.Type.t list) : Mir.Type.t =
  ty (Ty_view.Constr (uid name, args))

let arrow (a : Mir.Type.t) (b : Mir.Type.t) : Mir.Type.t =
  ty (Ty_view.Arrow ((), a, b))

let int_ty : Mir.Type.t = constr "int" []
let bool_ty : Mir.Type.t = constr "bool" []
let alpha : Uid.t = local_uid "a" 1
let alpha_ty : Mir.Type.t = ty (Ty_view.Var alpha)

(* Terms
   ===== *)

let term (v : (Mir.Term.t, Mir.Type.t) Mir.Term.view) (ty : Mir.Type.t) :
    Mir.Term.t =
  Mir.Term.make Mir.Term.State.non_hashconsing v ty

let int (n : int) : Mir.Term.t =
  term (Mir.Term.Const (Const.Const_z (Z.of_int n))) int_ty

let bool (b : bool) : Mir.Term.t =
  term (Mir.Term.Const (Const.Const_bool b)) bool_ty

(* [ty] is the symbol's type schema; [inst] its type once [params] are instantiated with [args] *)
let sym ?(params : Uid.t list = []) ?(args : Mir.Type.t list = [])
    ?(inst : Mir.Type.t option) (name : string) (ty : Mir.Type.t) :
    Mir.Applied_symbol.t =
  {
    sym = { id = uid name; ty = { params; ty } };
    args;
    ty = Option.value inst ~default:ty;
  }

let var (name : string) (id : int) (ty : Mir.Type.t) : Mir.Var.t =
  { id = local_uid name id; ty }

let var_term (v : Mir.Var.t) : Mir.Term.t = term (Mir.Term.Var v) v.ty

let sym_term (s : Mir.Applied_symbol.t) : Mir.Term.t =
  term (Mir.Term.Sym s) s.ty

let x : Mir.Var.t = var "x" 2 int_ty
let x_t : Mir.Term.t = var_term x
let succ : Mir.Applied_symbol.t = sym "succ" (arrow int_ty int_ty)

let apply (f : Mir.Applied_symbol.t) (l : Mir.Term.t list) (ty : Mir.Type.t) :
    Mir.Term.t =
  term (Mir.Term.Apply { f = sym_term f; l }) ty

(* [x > 0] *)
let x_pos : Mir.Term.t =
  let gt = sym "gt" (arrow int_ty (arrow int_ty bool_ty)) in
  apply gt [ x_t; int 0 ] bool_ty

let sequent ?(hyps : (string option * Mir.Term.t) list = [])
    (concls : (string option * Mir.Term.t) list) : Mir.Sequent.t =
  { hyps; concls }

(* Errors, anchors, statistics
   =========================== *)

let error ?(stack : string list = []) ?(bt : string option) (msg : string) :
    Imandrakit_error.Error_core.t =
  let message ?bt msg : Imandrakit_error.Error_core.message =
    { msg; data = Imandrakit_error.Data.empty; bt }
  in
  {
    process = "golden_0001";
    kind = Imandrakit_error.Kind.make ~name:"GoldenError0002" ();
    msg = message ?bt msg;
    stack = List.map message stack;
  }

let anchor : Anchor.t = Eval 0

let stats : Statistics.t =
  { time_s = 1003.5; tactic = Some [ "steps_0004", "1005" ] }

(* Storage
   ======= *)

let ca_ptr_of_key (key : Key.t) : 'a Ca_ptr.t =
  Ca_ptr.Private_.(unsafe_of_raw (raw_of_key key))

(* A pointer to nothing in the storage *)
let ca_ptr (ty : string) : 'a Ca_ptr.t =
  ca_ptr_of_key (Key.chash ~ty (chash ty))

(* [x] stored like [Ca_ptr.store] stores it: its pointer, and the entry for the
   artifact's storage. [ty] is the type part of the key. *)
let store ~(ty : string) (enc : 'a Imandrakit_twine.Encode.encoder) (x : 'a) :
    'a Ca_ptr.t * (Key.t * string) =
  let data = Imandrakit_twine.Encode.encode_to_string enc x in
  let key = Key.chash ~ty (chash data) in
  ca_ptr_of_key key, (key, data)
