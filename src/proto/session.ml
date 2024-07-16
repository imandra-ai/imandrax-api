[@@@ocaml.warning "-27-30-39-44"]

type session = {
  id : string;
}

type session_create = {
  po_check : bool option;
}

type session_open = {
  id : session option;
}

let rec default_session 
  ?id:((id:string) = "")
  () : session  = {
  id;
}

let rec default_session_create 
  ?po_check:((po_check:bool option) = None)
  () : session_create  = {
  po_check;
}

let rec default_session_open 
  ?id:((id:session option) = None)
  () : session_open  = {
  id;
}

type session_mutable = {
  mutable id : string;
}

let default_session_mutable () : session_mutable = {
  id = "";
}

type session_create_mutable = {
  mutable po_check : bool option;
}

let default_session_create_mutable () : session_create_mutable = {
  po_check = None;
}

type session_open_mutable = {
  mutable id : session option;
}

let default_session_open_mutable () : session_open_mutable = {
  id = None;
}


(** {2 Make functions} *)

let rec make_session 
  ~(id:string)
  () : session  = {
  id;
}

let rec make_session_create 
  ?po_check:((po_check:bool option) = None)
  () : session_create  = {
  po_check;
}

let rec make_session_open 
  ?id:((id:session option) = None)
  () : session_open  = {
  id;
}

[@@@ocaml.warning "-27-30-39"]

(** {2 Formatters} *)

let rec pp_session fmt (v:session) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "id" Pbrt.Pp.pp_string fmt v.id;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_session_create fmt (v:session_create) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "po_check" (Pbrt.Pp.pp_option Pbrt.Pp.pp_bool) fmt v.po_check;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_session_open fmt (v:session_open) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "id" (Pbrt.Pp.pp_option pp_session) fmt v.id;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_session (v:session) encoder = 
  Pbrt.Encoder.string v.id encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ()

let rec encode_pb_session_create (v:session_create) encoder = 
  begin match v.po_check with
  | Some x -> 
    Pbrt.Encoder.bool x encoder;
    Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_session_open (v:session_open) encoder = 
  begin match v.id with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_session x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_session d =
  let v = default_session_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.id <- Pbrt.Decoder.string d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(session), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    id = v.id;
  } : session)

let rec decode_pb_session_create d =
  let v = default_session_create_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.po_check <- Some (Pbrt.Decoder.bool d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(session_create), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    po_check = v.po_check;
  } : session_create)

let rec decode_pb_session_open d =
  let v = default_session_open_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.id <- Some (decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(session_open), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    id = v.id;
  } : session_open)

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_session (v:session) = 
  let assoc = [] in 
  let assoc = ("id", Pbrt_yojson.make_string v.id) :: assoc in
  `Assoc assoc

let rec encode_json_session_create (v:session_create) = 
  let assoc = [] in 
  let assoc = match v.po_check with
    | None -> assoc
    | Some v -> ("poCheck", Pbrt_yojson.make_bool v) :: assoc
  in
  `Assoc assoc

let rec encode_json_session_open (v:session_open) = 
  let assoc = [] in 
  let assoc = match v.id with
    | None -> assoc
    | Some v -> ("id", encode_json_session v) :: assoc
  in
  `Assoc assoc

[@@@ocaml.warning "-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_session d =
  let v = default_session_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("id", json_value) -> 
      v.id <- Pbrt_yojson.string json_value "session" "id"
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    id = v.id;
  } : session)

let rec decode_json_session_create d =
  let v = default_session_create_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("poCheck", json_value) -> 
      v.po_check <- Some (Pbrt_yojson.bool json_value "session_create" "po_check")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    po_check = v.po_check;
  } : session_create)

let rec decode_json_session_open d =
  let v = default_session_open_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("id", json_value) -> 
      v.id <- Some ((decode_json_session json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    id = v.id;
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
      ~keep_session_alive:__handler__keep_session_alive
      () : _ Server.t =
      { Server.
        service_name="SessionManager";
        package=["imandrax";"session"];
        handlers=[
           (__handler__create_session create_session);
           (__handler__open_session open_session);
           (__handler__keep_session_alive keep_session_alive);
        ];
      }
  end
  
end
