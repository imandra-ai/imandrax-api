[@@@ocaml.warning "-23-27-30-39-44"]

type session = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable id : string;
}

type session_create = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable po_check : bool;
  mutable api_version : string;
}

type session_open = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable id : session option;
  mutable api_version : string;
}

let default_session (): session =
{
  _presence=Pbrt.Bitfield.empty;
  id="";
}

let default_session_create (): session_create =
{
  _presence=Pbrt.Bitfield.empty;
  po_check=false;
  api_version="";
}

let default_session_open (): session_open =
{
  _presence=Pbrt.Bitfield.empty;
  id=None;
  api_version="";
}


(** {2 Make functions} *)

let[@inline] session_has_id (self:session) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] session_set_id (self:session) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.id <- x

let copy_session (self:session) : session =
  { self with id = self.id }

let make_session 
  ?(id:string option)
  () : session  =
  let _res = default_session () in
  (match id with
  | None -> ()
  | Some v -> session_set_id _res v);
  _res

let[@inline] session_create_has_po_check (self:session_create) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] session_create_has_api_version (self:session_create) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] session_create_set_po_check (self:session_create) (x:bool) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.po_check <- x
let[@inline] session_create_set_api_version (self:session_create) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.api_version <- x

let copy_session_create (self:session_create) : session_create =
  { self with po_check = self.po_check }

let make_session_create 
  ?(po_check:bool option)
  ?(api_version:string option)
  () : session_create  =
  let _res = default_session_create () in
  (match po_check with
  | None -> ()
  | Some v -> session_create_set_po_check _res v);
  (match api_version with
  | None -> ()
  | Some v -> session_create_set_api_version _res v);
  _res

let[@inline] session_open_has_api_version (self:session_open) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] session_open_set_id (self:session_open) (x:session) : unit =
  self.id <- Some x
let[@inline] session_open_set_api_version (self:session_open) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.api_version <- x

let copy_session_open (self:session_open) : session_open =
  { self with id = self.id }

let make_session_open 
  ?(id:session option)
  ?(api_version:string option)
  () : session_open  =
  let _res = default_session_open () in
  (match id with
  | None -> ()
  | Some v -> session_open_set_id _res v);
  (match api_version with
  | None -> ()
  | Some v -> session_open_set_api_version _res v);
  _res

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Formatters} *)

let rec pp_session fmt (v:session) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (session_has_id v)) ~first:true "id" Pbrt.Pp.pp_string fmt v.id;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_session_create fmt (v:session_create) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (session_create_has_po_check v)) ~first:true "po_check" Pbrt.Pp.pp_bool fmt v.po_check;
    Pbrt.Pp.pp_record_field ~absent:(not (session_create_has_api_version v)) ~first:false "api_version" Pbrt.Pp.pp_string fmt v.api_version;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_session_open fmt (v:session_open) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "id" (Pbrt.Pp.pp_option pp_session) fmt v.id;
    Pbrt.Pp.pp_record_field ~absent:(not (session_open_has_api_version v)) ~first:false "api_version" Pbrt.Pp.pp_string fmt v.api_version;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_session (v:session) encoder = 
  if session_has_id v then (
    Pbrt.Encoder.string v.id encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
  ()

let rec encode_pb_session_create (v:session_create) encoder = 
  if session_create_has_po_check v then (
    Pbrt.Encoder.bool v.po_check encoder;
    Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  );
  if session_create_has_api_version v then (
    Pbrt.Encoder.string v.api_version encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  ()

let rec encode_pb_session_open (v:session_open) encoder = 
  begin match v.id with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_session x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  if session_open_has_api_version v then (
    Pbrt.Encoder.string v.api_version encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  ()

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_session d =
  let v = default_session () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      session_set_id v (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "session" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : session)

let rec decode_pb_session_create d =
  let v = default_session_create () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      session_create_set_po_check v (Pbrt.Decoder.bool d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "session_create" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      session_create_set_api_version v (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "session_create" 2 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : session_create)

let rec decode_pb_session_open d =
  let v = default_session_open () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      session_open_set_id v (decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "session_open" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      session_open_set_api_version v (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "session_open" 2 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : session_open)

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_session (v:session) = 
  let assoc = ref [] in
  if session_has_id v then (
    assoc := ("id", Pbrt_yojson.make_string v.id) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_session_create (v:session_create) = 
  let assoc = ref [] in
  if session_create_has_po_check v then (
    assoc := ("poCheck", Pbrt_yojson.make_bool v.po_check) :: !assoc;
  );
  if session_create_has_api_version v then (
    assoc := ("apiVersion", Pbrt_yojson.make_string v.api_version) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_session_open (v:session_open) = 
  let assoc = ref [] in
  assoc := (match v.id with
    | None -> !assoc
    | Some v -> ("id", encode_json_session v) :: !assoc);
  if session_open_has_api_version v then (
    assoc := ("apiVersion", Pbrt_yojson.make_string v.api_version) :: !assoc;
  );
  `Assoc !assoc

[@@@ocaml.warning "-23-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_session d =
  let v = default_session () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("id", json_value) -> 
      session_set_id v (Pbrt_yojson.string json_value "session" "id")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    id = v.id;
  } : session)

let rec decode_json_session_create d =
  let v = default_session_create () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("poCheck", json_value) -> 
      session_create_set_po_check v (Pbrt_yojson.bool json_value "session_create" "po_check")
    | ("apiVersion", json_value) -> 
      session_create_set_api_version v (Pbrt_yojson.string json_value "session_create" "api_version")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    po_check = v.po_check;
    api_version = v.api_version;
  } : session_create)

let rec decode_json_session_open d =
  let v = default_session_open () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("id", json_value) -> 
      session_open_set_id v (decode_json_session json_value)
    | ("apiVersion", json_value) -> 
      session_open_set_api_version v (Pbrt_yojson.string json_value "session_open" "api_version")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    id = v.id;
    api_version = v.api_version;
  } : session_open)

module SessionManager = struct
  open Pbrt_services.Value_mode
  module Client = struct
    open Pbrt_services
    
    let create_session : (session_create, unary, session, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"session"]
        ~service_name:"SessionManager" ~rpc_name:"create_session"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_session_create
        ~encode_pb_req:encode_pb_session_create
        ~decode_json_res:decode_json_session
        ~decode_pb_res:decode_pb_session
        () : (session_create, unary, session, unary) Client.rpc)
    open Pbrt_services
    
    let open_session : (session_open, unary, Utils.empty, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"session"]
        ~service_name:"SessionManager" ~rpc_name:"open_session"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_session_open
        ~encode_pb_req:encode_pb_session_open
        ~decode_json_res:Utils.decode_json_empty
        ~decode_pb_res:Utils.decode_pb_empty
        () : (session_open, unary, Utils.empty, unary) Client.rpc)
    open Pbrt_services
    
    let end_session : (session, unary, Utils.empty, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"session"]
        ~service_name:"SessionManager" ~rpc_name:"end_session"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_session
        ~encode_pb_req:encode_pb_session
        ~decode_json_res:Utils.decode_json_empty
        ~decode_pb_res:Utils.decode_pb_empty
        () : (session, unary, Utils.empty, unary) Client.rpc)
    open Pbrt_services
    
    let keep_session_alive : (session, unary, Utils.empty, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"session"]
        ~service_name:"SessionManager" ~rpc_name:"keep_session_alive"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_session
        ~encode_pb_req:encode_pb_session
        ~decode_json_res:Utils.decode_json_empty
        ~decode_pb_res:Utils.decode_pb_empty
        () : (session, unary, Utils.empty, unary) Client.rpc)
  end
  
  module Server = struct
    open Pbrt_services
    
    let create_session : (session_create,unary,session,unary) Server.rpc = 
      (Server.mk_rpc ~name:"create_session"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_session
        ~encode_pb_res:encode_pb_session
        ~decode_json_req:decode_json_session_create
        ~decode_pb_req:decode_pb_session_create
        () : _ Server.rpc)
    
    let open_session : (session_open,unary,Utils.empty,unary) Server.rpc = 
      (Server.mk_rpc ~name:"open_session"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:Utils.encode_json_empty
        ~encode_pb_res:Utils.encode_pb_empty
        ~decode_json_req:decode_json_session_open
        ~decode_pb_req:decode_pb_session_open
        () : _ Server.rpc)
    
    let end_session : (session,unary,Utils.empty,unary) Server.rpc = 
      (Server.mk_rpc ~name:"end_session"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:Utils.encode_json_empty
        ~encode_pb_res:Utils.encode_pb_empty
        ~decode_json_req:decode_json_session
        ~decode_pb_req:decode_pb_session
        () : _ Server.rpc)
    
    let keep_session_alive : (session,unary,Utils.empty,unary) Server.rpc = 
      (Server.mk_rpc ~name:"keep_session_alive"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:Utils.encode_json_empty
        ~encode_pb_res:Utils.encode_pb_empty
        ~decode_json_req:decode_json_session
        ~decode_pb_req:decode_pb_session
        () : _ Server.rpc)
    
    let make
      ~create_session:__handler__create_session
      ~open_session:__handler__open_session
      ~end_session:__handler__end_session
      ~keep_session_alive:__handler__keep_session_alive
      () : _ Server.t =
      { Server.
        service_name="SessionManager";
        package=["imandrax";"session"];
        handlers=[
           (__handler__create_session create_session);
           (__handler__open_session open_session);
           (__handler__end_session end_session);
           (__handler__keep_session_alive keep_session_alive);
        ];
      }
  end
  
end
