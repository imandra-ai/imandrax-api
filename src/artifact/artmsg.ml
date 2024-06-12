[@@@ocaml.warning "-27-30-39"]

type art = {
  kind : string;
  data : bytes;
  api_version : string;
}

let rec default_art 
  ?kind:((kind:string) = "")
  ?data:((data:bytes) = Bytes.create 0)
  ?api_version:((api_version:string) = "")
  () : art  = {
  kind;
  data;
  api_version;
}

type art_mutable = {
  mutable kind : string;
  mutable data : bytes;
  mutable api_version : string;
}

let default_art_mutable () : art_mutable = {
  kind = "";
  data = Bytes.create 0;
  api_version = "";
}


(** {2 Make functions} *)

let rec make_art 
  ~(kind:string)
  ~(data:bytes)
  ~(api_version:string)
  () : art  = {
  kind;
  data;
  api_version;
}

[@@@ocaml.warning "-27-30-39"]

(** {2 Formatters} *)

let rec pp_art fmt (v:art) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "kind" Pbrt.Pp.pp_string fmt v.kind;
    Pbrt.Pp.pp_record_field ~first:false "data" Pbrt.Pp.pp_bytes fmt v.data;
    Pbrt.Pp.pp_record_field ~first:false "api_version" Pbrt.Pp.pp_string fmt v.api_version;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_art (v:art) encoder = 
  Pbrt.Encoder.string v.kind encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  Pbrt.Encoder.bytes v.data encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  Pbrt.Encoder.string v.api_version encoder;
  Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_art d =
  let v = default_art_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
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
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    kind = v.kind;
    data = v.data;
    api_version = v.api_version;
  } : art)

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_art (v:art) = 
  let assoc = [] in 
  let assoc = ("kind", Pbrt_yojson.make_string v.kind) :: assoc in
  let assoc = ("data", Pbrt_yojson.make_bytes v.data) :: assoc in
  let assoc = ("apiVersion", Pbrt_yojson.make_string v.api_version) :: assoc in
  `Assoc assoc

[@@@ocaml.warning "-27-30-39"]

(** {2 JSON Decoding} *)

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
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    kind = v.kind;
    data = v.data;
    api_version = v.api_version;
  } : art)
