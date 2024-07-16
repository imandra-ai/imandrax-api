[@@@ocaml.warning "-27-30-39-44"]

type gc_stats = {
  heap_size_b : int64;
  major_collections : int64;
  minor_collections : int64;
}

type version_response = {
  version : string;
  git_version : string option;
}

let rec default_gc_stats 
  ?heap_size_b:((heap_size_b:int64) = 0L)
  ?major_collections:((major_collections:int64) = 0L)
  ?minor_collections:((minor_collections:int64) = 0L)
  () : gc_stats  = {
  heap_size_b;
  major_collections;
  minor_collections;
}

let rec default_version_response 
  ?version:((version:string) = "")
  ?git_version:((git_version:string option) = None)
  () : version_response  = {
  version;
  git_version;
}

type gc_stats_mutable = {
  mutable heap_size_b : int64;
  mutable major_collections : int64;
  mutable minor_collections : int64;
}

let default_gc_stats_mutable () : gc_stats_mutable = {
  heap_size_b = 0L;
  major_collections = 0L;
  minor_collections = 0L;
}

type version_response_mutable = {
  mutable version : string;
  mutable git_version : string option;
}

let default_version_response_mutable () : version_response_mutable = {
  version = "";
  git_version = None;
}


(** {2 Make functions} *)

let rec make_gc_stats 
  ~(heap_size_b:int64)
  ~(major_collections:int64)
  ~(minor_collections:int64)
  () : gc_stats  = {
  heap_size_b;
  major_collections;
  minor_collections;
}

let rec make_version_response 
  ~(version:string)
  ?git_version:((git_version:string option) = None)
  () : version_response  = {
  version;
  git_version;
}

[@@@ocaml.warning "-27-30-39"]

(** {2 Formatters} *)

let rec pp_gc_stats fmt (v:gc_stats) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "heap_size_b" Pbrt.Pp.pp_int64 fmt v.heap_size_b;
    Pbrt.Pp.pp_record_field ~first:false "major_collections" Pbrt.Pp.pp_int64 fmt v.major_collections;
    Pbrt.Pp.pp_record_field ~first:false "minor_collections" Pbrt.Pp.pp_int64 fmt v.minor_collections;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_version_response fmt (v:version_response) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "version" Pbrt.Pp.pp_string fmt v.version;
    Pbrt.Pp.pp_record_field ~first:false "git_version" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.git_version;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_gc_stats (v:gc_stats) encoder = 
  Pbrt.Encoder.int64_as_varint v.heap_size_b encoder;
  Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  Pbrt.Encoder.int64_as_varint v.major_collections encoder;
  Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  Pbrt.Encoder.int64_as_varint v.minor_collections encoder;
  Pbrt.Encoder.key 3 Pbrt.Varint encoder; 
  ()

let rec encode_pb_version_response (v:version_response) encoder = 
  Pbrt.Encoder.string v.version encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  begin match v.git_version with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_gc_stats d =
  let v = default_gc_stats_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.heap_size_b <- Pbrt.Decoder.int64_as_varint d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(gc_stats), field(1)" pk
    | Some (2, Pbrt.Varint) -> begin
      v.major_collections <- Pbrt.Decoder.int64_as_varint d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(gc_stats), field(2)" pk
    | Some (3, Pbrt.Varint) -> begin
      v.minor_collections <- Pbrt.Decoder.int64_as_varint d;
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(gc_stats), field(3)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    heap_size_b = v.heap_size_b;
    major_collections = v.major_collections;
    minor_collections = v.minor_collections;
  } : gc_stats)

let rec decode_pb_version_response d =
  let v = default_version_response_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.version <- Pbrt.Decoder.string d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(version_response), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.git_version <- Some (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(version_response), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    version = v.version;
    git_version = v.git_version;
  } : version_response)

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_gc_stats (v:gc_stats) = 
  let assoc = [] in 
  let assoc = ("heapSizeB", Pbrt_yojson.make_string (Int64.to_string v.heap_size_b)) :: assoc in
  let assoc = ("majorCollections", Pbrt_yojson.make_string (Int64.to_string v.major_collections)) :: assoc in
  let assoc = ("minorCollections", Pbrt_yojson.make_string (Int64.to_string v.minor_collections)) :: assoc in
  `Assoc assoc

let rec encode_json_version_response (v:version_response) = 
  let assoc = [] in 
  let assoc = ("version", Pbrt_yojson.make_string v.version) :: assoc in
  let assoc = match v.git_version with
    | None -> assoc
    | Some v -> ("gitVersion", Pbrt_yojson.make_string v) :: assoc
  in
  `Assoc assoc

[@@@ocaml.warning "-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_gc_stats d =
  let v = default_gc_stats_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("heapSizeB", json_value) -> 
      v.heap_size_b <- Pbrt_yojson.int64 json_value "gc_stats" "heap_size_b"
    | ("majorCollections", json_value) -> 
      v.major_collections <- Pbrt_yojson.int64 json_value "gc_stats" "major_collections"
    | ("minorCollections", json_value) -> 
      v.minor_collections <- Pbrt_yojson.int64 json_value "gc_stats" "minor_collections"
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    heap_size_b = v.heap_size_b;
    major_collections = v.major_collections;
    minor_collections = v.minor_collections;
  } : gc_stats)

let rec decode_json_version_response d =
  let v = default_version_response_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("version", json_value) -> 
      v.version <- Pbrt_yojson.string json_value "version_response" "version"
    | ("gitVersion", json_value) -> 
      v.git_version <- Some (Pbrt_yojson.string json_value "version_response" "git_version")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
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
