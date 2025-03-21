[@@@ocaml.warning "-27-30-39-44"]

type storage_entry = {
  key : string;
  value : bytes;
}

type art = {
  kind : string;
  data : bytes;
  api_version : string;
  storage : storage_entry list;
}

let rec default_storage_entry 
  ?key:((key:string) = "")
  ?value:((value:bytes) = Bytes.create 0)
  () : storage_entry  = {
  key;
  value;
}

let rec default_art 
  ?kind:((kind:string) = "")
  ?data:((data:bytes) = Bytes.create 0)
  ?api_version:((api_version:string) = "")
  ?storage:((storage:storage_entry list) = [])
  () : art  = {
  kind;
  data;
  api_version;
  storage;
}

type storage_entry_mutable = {
  mutable key : string;
  mutable value : bytes;
}

let default_storage_entry_mutable () : storage_entry_mutable = {
  key = "";
  value = Bytes.create 0;
}

type art_mutable = {
  mutable kind : string;
  mutable data : bytes;
  mutable api_version : string;
  mutable storage : storage_entry list;
}

let default_art_mutable () : art_mutable = {
  kind = "";
  data = Bytes.create 0;
  api_version = "";
  storage = [];
}


(** {2 Make functions} *)

let rec make_storage_entry 
  ~(key:string)
  ~(value:bytes)
  () : storage_entry  = {
  key;
  value;
}

let rec make_art 
  ~(kind:string)
  ~(data:bytes)
  ~(api_version:string)
  ~(storage:storage_entry list)
  () : art  = {
  kind;
  data;
  api_version;
  storage;
}

[@@@ocaml.warning "-27-30-39"]

(** {2 Formatters} *)

let rec pp_storage_entry fmt (v:storage_entry) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "key" Pbrt.Pp.pp_string fmt v.key;
    Pbrt.Pp.pp_record_field ~first:false "value" Pbrt.Pp.pp_bytes fmt v.value;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_art fmt (v:art) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "kind" Pbrt.Pp.pp_string fmt v.kind;
    Pbrt.Pp.pp_record_field ~first:false "data" Pbrt.Pp.pp_bytes fmt v.data;
    Pbrt.Pp.pp_record_field ~first:false "api_version" Pbrt.Pp.pp_string fmt v.api_version;
    Pbrt.Pp.pp_record_field ~first:false "storage" (Pbrt.Pp.pp_list pp_storage_entry) fmt v.storage;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_storage_entry (v:storage_entry) encoder = 
  Pbrt.Encoder.string v.key encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  Pbrt.Encoder.bytes v.value encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  ()

let rec encode_pb_art (v:art) encoder = 
  Pbrt.Encoder.string v.kind encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  Pbrt.Encoder.bytes v.data encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  Pbrt.Encoder.string v.api_version encoder;
  Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested encode_pb_storage_entry x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  ) v.storage encoder;
  ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_storage_entry d =
  let v = default_storage_entry_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.key <- Pbrt.Decoder.string d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(storage_entry), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.value <- Pbrt.Decoder.bytes d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(storage_entry), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    key = v.key;
    value = v.value;
  } : storage_entry)

let rec decode_pb_art d =
  let v = default_art_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.storage <- List.rev v.storage;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.kind <- Pbrt.Decoder.string d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(art), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.data <- Pbrt.Decoder.bytes d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(art), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.api_version <- Pbrt.Decoder.string d;
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(art), field(3)" pk
    | Some (4, Pbrt.Bytes) -> begin
      v.storage <- (decode_pb_storage_entry (Pbrt.Decoder.nested d)) :: v.storage;
    end
    | Some (4, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(art), field(4)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    kind = v.kind;
    data = v.data;
    api_version = v.api_version;
    storage = v.storage;
  } : art)

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_storage_entry (v:storage_entry) = 
  let assoc = [] in 
  let assoc = ("key", Pbrt_yojson.make_string v.key) :: assoc in
  let assoc = ("value", Pbrt_yojson.make_bytes v.value) :: assoc in
  `Assoc assoc

let rec encode_json_art (v:art) = 
  let assoc = [] in 
  let assoc = ("kind", Pbrt_yojson.make_string v.kind) :: assoc in
  let assoc = ("data", Pbrt_yojson.make_bytes v.data) :: assoc in
  let assoc = ("apiVersion", Pbrt_yojson.make_string v.api_version) :: assoc in
  let assoc =
    let l = v.storage |> List.map encode_json_storage_entry in
    ("storage", `List l) :: assoc 
  in
  `Assoc assoc

[@@@ocaml.warning "-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_storage_entry d =
  let v = default_storage_entry_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("key", json_value) -> 
      v.key <- Pbrt_yojson.string json_value "storage_entry" "key"
    | ("value", json_value) -> 
      v.value <- Pbrt_yojson.bytes json_value "storage_entry" "value"
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    key = v.key;
    value = v.value;
  } : storage_entry)

let rec decode_json_art d =
  let v = default_art_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("kind", json_value) -> 
      v.kind <- Pbrt_yojson.string json_value "art" "kind"
    | ("data", json_value) -> 
      v.data <- Pbrt_yojson.bytes json_value "art" "data"
    | ("apiVersion", json_value) -> 
      v.api_version <- Pbrt_yojson.string json_value "art" "api_version"
    | ("storage", `List l) -> begin
      v.storage <- List.map (function
        | json_value -> (decode_json_storage_entry json_value)
      ) l;
    end
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    kind = v.kind;
    data = v.data;
    api_version = v.api_version;
    storage = v.storage;
  } : art)
