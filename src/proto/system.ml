[@@@ocaml.warning "-23-27-30-39-44"]

type gc_stats = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 3 fields *)
  mutable heap_size_b : int64;
  mutable major_collections : int64;
  mutable minor_collections : int64;
}

type version_response = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable version : string;
  mutable git_version : string;
}

let default_gc_stats (): gc_stats =
{
  _presence=Pbrt.Bitfield.empty;
  heap_size_b=0L;
  major_collections=0L;
  minor_collections=0L;
}

let default_version_response (): version_response =
{
  _presence=Pbrt.Bitfield.empty;
  version="";
  git_version="";
}


(** {2 Make functions} *)

let[@inline] gc_stats_has_heap_size_b (self:gc_stats) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] gc_stats_has_major_collections (self:gc_stats) : bool = (Pbrt.Bitfield.get self._presence 1)
let[@inline] gc_stats_has_minor_collections (self:gc_stats) : bool = (Pbrt.Bitfield.get self._presence 2)

let[@inline] gc_stats_set_heap_size_b (self:gc_stats) (x:int64) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.heap_size_b <- x
let[@inline] gc_stats_set_major_collections (self:gc_stats) (x:int64) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.major_collections <- x
let[@inline] gc_stats_set_minor_collections (self:gc_stats) (x:int64) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 2); self.minor_collections <- x

let copy_gc_stats (self:gc_stats) : gc_stats =
  { self with heap_size_b = self.heap_size_b }

let make_gc_stats 
  ?(heap_size_b:int64 option)
  ?(major_collections:int64 option)
  ?(minor_collections:int64 option)
  () : gc_stats  =
  let _res = default_gc_stats () in
  (match heap_size_b with
  | None -> ()
  | Some v -> gc_stats_set_heap_size_b _res v);
  (match major_collections with
  | None -> ()
  | Some v -> gc_stats_set_major_collections _res v);
  (match minor_collections with
  | None -> ()
  | Some v -> gc_stats_set_minor_collections _res v);
  _res

let[@inline] version_response_has_version (self:version_response) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] version_response_has_git_version (self:version_response) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] version_response_set_version (self:version_response) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.version <- x
let[@inline] version_response_set_git_version (self:version_response) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.git_version <- x

let copy_version_response (self:version_response) : version_response =
  { self with version = self.version }

let make_version_response 
  ?(version:string option)
  ?(git_version:string option)
  () : version_response  =
  let _res = default_version_response () in
  (match version with
  | None -> ()
  | Some v -> version_response_set_version _res v);
  (match git_version with
  | None -> ()
  | Some v -> version_response_set_git_version _res v);
  _res

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Formatters} *)

let rec pp_gc_stats fmt (v:gc_stats) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (gc_stats_has_heap_size_b v)) ~first:true "heap_size_b" Pbrt.Pp.pp_int64 fmt v.heap_size_b;
    Pbrt.Pp.pp_record_field ~absent:(not (gc_stats_has_major_collections v)) ~first:false "major_collections" Pbrt.Pp.pp_int64 fmt v.major_collections;
    Pbrt.Pp.pp_record_field ~absent:(not (gc_stats_has_minor_collections v)) ~first:false "minor_collections" Pbrt.Pp.pp_int64 fmt v.minor_collections;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_version_response fmt (v:version_response) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (version_response_has_version v)) ~first:true "version" Pbrt.Pp.pp_string fmt v.version;
    Pbrt.Pp.pp_record_field ~absent:(not (version_response_has_git_version v)) ~first:false "git_version" Pbrt.Pp.pp_string fmt v.git_version;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_gc_stats (v:gc_stats) encoder = 
  if gc_stats_has_heap_size_b v then (
    Pbrt.Encoder.int64_as_varint v.heap_size_b encoder;
    Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  );
  if gc_stats_has_major_collections v then (
    Pbrt.Encoder.int64_as_varint v.major_collections encoder;
    Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  );
  if gc_stats_has_minor_collections v then (
    Pbrt.Encoder.int64_as_varint v.minor_collections encoder;
    Pbrt.Encoder.key 3 Pbrt.Varint encoder; 
  );
  ()

let rec encode_pb_version_response (v:version_response) encoder = 
  if version_response_has_version v then (
    Pbrt.Encoder.string v.version encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
  if version_response_has_git_version v then (
    Pbrt.Encoder.string v.git_version encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  ()

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_gc_stats d =
  let v = default_gc_stats () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      gc_stats_set_heap_size_b v (Pbrt.Decoder.int64_as_varint d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "gc_stats" 1 pk
    | Some (2, Pbrt.Varint) -> begin
      gc_stats_set_major_collections v (Pbrt.Decoder.int64_as_varint d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "gc_stats" 2 pk
    | Some (3, Pbrt.Varint) -> begin
      gc_stats_set_minor_collections v (Pbrt.Decoder.int64_as_varint d);
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "gc_stats" 3 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : gc_stats)

let rec decode_pb_version_response d =
  let v = default_version_response () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      version_response_set_version v (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "version_response" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      version_response_set_git_version v (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "version_response" 2 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : version_response)

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_gc_stats (v:gc_stats) = 
  let assoc = ref [] in
  if gc_stats_has_heap_size_b v then (
    assoc := ("heapSizeB", Pbrt_yojson.make_string (Int64.to_string v.heap_size_b)) :: !assoc;
  );
  if gc_stats_has_major_collections v then (
    assoc := ("majorCollections", Pbrt_yojson.make_string (Int64.to_string v.major_collections)) :: !assoc;
  );
  if gc_stats_has_minor_collections v then (
    assoc := ("minorCollections", Pbrt_yojson.make_string (Int64.to_string v.minor_collections)) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_version_response (v:version_response) = 
  let assoc = ref [] in
  if version_response_has_version v then (
    assoc := ("version", Pbrt_yojson.make_string v.version) :: !assoc;
  );
  if version_response_has_git_version v then (
    assoc := ("gitVersion", Pbrt_yojson.make_string v.git_version) :: !assoc;
  );
  `Assoc !assoc

[@@@ocaml.warning "-23-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_gc_stats d =
  let v = default_gc_stats () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("heapSizeB", json_value) -> 
      gc_stats_set_heap_size_b v (Pbrt_yojson.int64 json_value "gc_stats" "heap_size_b")
    | ("majorCollections", json_value) -> 
      gc_stats_set_major_collections v (Pbrt_yojson.int64 json_value "gc_stats" "major_collections")
    | ("minorCollections", json_value) -> 
      gc_stats_set_minor_collections v (Pbrt_yojson.int64 json_value "gc_stats" "minor_collections")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    heap_size_b = v.heap_size_b;
    major_collections = v.major_collections;
    minor_collections = v.minor_collections;
  } : gc_stats)

let rec decode_json_version_response d =
  let v = default_version_response () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("version", json_value) -> 
      version_response_set_version v (Pbrt_yojson.string json_value "version_response" "version")
    | ("gitVersion", json_value) -> 
      version_response_set_git_version v (Pbrt_yojson.string json_value "version_response" "git_version")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    version = v.version;
    git_version = v.git_version;
  } : version_response)

module System = struct
  open Pbrt_services.Value_mode
  module Client = struct
    open Pbrt_services
    
    let version : (Utils.empty, unary, version_response, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"system"]
        ~service_name:"System" ~rpc_name:"version"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:Utils.encode_json_empty
        ~encode_pb_req:Utils.encode_pb_empty
        ~decode_json_res:decode_json_version_response
        ~decode_pb_res:decode_pb_version_response
        () : (Utils.empty, unary, version_response, unary) Client.rpc)
    open Pbrt_services
    
    let gc_stats : (Utils.empty, unary, gc_stats, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"system"]
        ~service_name:"System" ~rpc_name:"gc_stats"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:Utils.encode_json_empty
        ~encode_pb_req:Utils.encode_pb_empty
        ~decode_json_res:decode_json_gc_stats
        ~decode_pb_res:decode_pb_gc_stats
        () : (Utils.empty, unary, gc_stats, unary) Client.rpc)
    open Pbrt_services
    
    let release_memory : (Utils.empty, unary, gc_stats, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"system"]
        ~service_name:"System" ~rpc_name:"release_memory"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:Utils.encode_json_empty
        ~encode_pb_req:Utils.encode_pb_empty
        ~decode_json_res:decode_json_gc_stats
        ~decode_pb_res:decode_pb_gc_stats
        () : (Utils.empty, unary, gc_stats, unary) Client.rpc)
  end
  
  module Server = struct
    open Pbrt_services
    
    let version : (Utils.empty,unary,version_response,unary) Server.rpc = 
      (Server.mk_rpc ~name:"version"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_version_response
        ~encode_pb_res:encode_pb_version_response
        ~decode_json_req:Utils.decode_json_empty
        ~decode_pb_req:Utils.decode_pb_empty
        () : _ Server.rpc)
    
    let gc_stats : (Utils.empty,unary,gc_stats,unary) Server.rpc = 
      (Server.mk_rpc ~name:"gc_stats"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_gc_stats
        ~encode_pb_res:encode_pb_gc_stats
        ~decode_json_req:Utils.decode_json_empty
        ~decode_pb_req:Utils.decode_pb_empty
        () : _ Server.rpc)
    
    let release_memory : (Utils.empty,unary,gc_stats,unary) Server.rpc = 
      (Server.mk_rpc ~name:"release_memory"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_gc_stats
        ~encode_pb_res:encode_pb_gc_stats
        ~decode_json_req:Utils.decode_json_empty
        ~decode_pb_req:Utils.decode_pb_empty
        () : _ Server.rpc)
    
    let make
      ~version:__handler__version
      ~gc_stats:__handler__gc_stats
      ~release_memory:__handler__release_memory
      () : _ Server.t =
      { Server.
        service_name="System";
        package=["imandrax";"system"];
        handlers=[
           (__handler__version version);
           (__handler__gc_stats gc_stats);
           (__handler__release_memory release_memory);
        ];
      }
  end
  
end
