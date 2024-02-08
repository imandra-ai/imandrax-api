[@@@ocaml.warning "-27-30-39"]

type empty = unit

type gc_stats = {
  heap_size_b : int32;
  major_collections : int32;
  minor_collections : int32;
}

let rec default_empty = ()

let rec default_gc_stats 
  ?heap_size_b:((heap_size_b:int32) = 0l)
  ?major_collections:((major_collections:int32) = 0l)
  ?minor_collections:((minor_collections:int32) = 0l)
  () : gc_stats  = {
  heap_size_b;
  major_collections;
  minor_collections;
}

type gc_stats_mutable = {
  mutable heap_size_b : int32;
  mutable major_collections : int32;
  mutable minor_collections : int32;
}

let default_gc_stats_mutable () : gc_stats_mutable = {
  heap_size_b = 0l;
  major_collections = 0l;
  minor_collections = 0l;
}


(** {2 Make functions} *)


let rec make_gc_stats 
  ~(heap_size_b:int32)
  ~(major_collections:int32)
  ~(minor_collections:int32)
  () : gc_stats  = {
  heap_size_b;
  major_collections;
  minor_collections;
}

[@@@ocaml.warning "-27-30-39"]

(** {2 Formatters} *)

let rec pp_empty fmt (v:empty) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_unit fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_gc_stats fmt (v:gc_stats) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "heap_size_b" Pbrt.Pp.pp_int32 fmt v.heap_size_b;
    Pbrt.Pp.pp_record_field ~first:false "major_collections" Pbrt.Pp.pp_int32 fmt v.major_collections;
    Pbrt.Pp.pp_record_field ~first:false "minor_collections" Pbrt.Pp.pp_int32 fmt v.minor_collections;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_empty (v:empty) encoder = 
()

let rec encode_pb_gc_stats (v:gc_stats) encoder = 
  Pbrt.Encoder.int32_as_varint v.heap_size_b encoder;
  Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  Pbrt.Encoder.int32_as_varint v.major_collections encoder;
  Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  Pbrt.Encoder.int32_as_varint v.minor_collections encoder;
  Pbrt.Encoder.key 3 Pbrt.Varint encoder; 
  ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_empty d =
  match Pbrt.Decoder.key d with
  | None -> ();
  | Some (_, pk) -> 
    Pbrt.Decoder.unexpected_payload "Unexpected fields in empty message(empty)" pk

let rec decode_pb_gc_stats d =
  let v = default_gc_stats_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.heap_size_b <- Pbrt.Decoder.int32_as_varint d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(gc_stats), field(1)" pk
    | Some (2, Pbrt.Varint) -> begin
      v.major_collections <- Pbrt.Decoder.int32_as_varint d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(gc_stats), field(2)" pk
    | Some (3, Pbrt.Varint) -> begin
      v.minor_collections <- Pbrt.Decoder.int32_as_varint d;
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

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_empty (v:empty) = 
Pbrt_yojson.make_unit v

let rec encode_json_gc_stats (v:gc_stats) = 
  let assoc = [] in 
  let assoc = ("heapSizeB", Pbrt_yojson.make_int (Int32.to_int v.heap_size_b)) :: assoc in
  let assoc = ("majorCollections", Pbrt_yojson.make_int (Int32.to_int v.major_collections)) :: assoc in
  let assoc = ("minorCollections", Pbrt_yojson.make_int (Int32.to_int v.minor_collections)) :: assoc in
  `Assoc assoc

[@@@ocaml.warning "-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_empty d =
Pbrt_yojson.unit d "empty" "empty record"

let rec decode_json_gc_stats d =
  let v = default_gc_stats_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("heapSizeB", json_value) -> 
      v.heap_size_b <- Pbrt_yojson.int32 json_value "gc_stats" "heap_size_b"
    | ("majorCollections", json_value) -> 
      v.major_collections <- Pbrt_yojson.int32 json_value "gc_stats" "major_collections"
    | ("minorCollections", json_value) -> 
      v.minor_collections <- Pbrt_yojson.int32 json_value "gc_stats" "minor_collections"
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    heap_size_b = v.heap_size_b;
    major_collections = v.major_collections;
    minor_collections = v.minor_collections;
  } : gc_stats)

module Gc_service = struct
  open Pbrt_services.Value_mode
  module Client = struct
    open Pbrt_services
    
    let get_stats : (unit, unary, gc_stats, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:[]
        ~service_name:"Gc_service" ~rpc_name:"get_stats"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:(fun () -> `Assoc [])
        ~encode_pb_req:(fun () enc -> Pbrt.Encoder.empty_nested enc)
        ~decode_json_res:decode_json_gc_stats
        ~decode_pb_res:decode_pb_gc_stats
        () : (unit, unary, gc_stats, unary) Client.rpc)
  end
  
  module Server = struct
    open Pbrt_services
    
    let _rpc_get_stats : (unit,unary,gc_stats,unary) Server.rpc = 
      (Server.mk_rpc ~name:"get_stats"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_gc_stats
        ~encode_pb_res:encode_pb_gc_stats
        ~decode_json_req:(fun _ -> ())
        ~decode_pb_req:(fun d -> Pbrt.Decoder.empty_nested d)
        () : _ Server.rpc)
    
    let make
      ~get_stats
      () : _ Server.t =
      { Server.
        service_name="Gc_service";
        package=[];
        handlers=[
           (get_stats _rpc_get_stats);
        ];
      }
  end
  
end
