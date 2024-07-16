[@@@ocaml.warning "-27-30-39-44"]

type position = {
  line : int32;
  col : int32;
}

type location = {
  file : string option;
  start : position option;
  stop : position option;
}

let rec default_position 
  ?line:((line:int32) = 0l)
  ?col:((col:int32) = 0l)
  () : position  = {
  line;
  col;
}

let rec default_location 
  ?file:((file:string option) = None)
  ?start:((start:position option) = None)
  ?stop:((stop:position option) = None)
  () : location  = {
  file;
  start;
  stop;
}

type position_mutable = {
  mutable line : int32;
  mutable col : int32;
}

let default_position_mutable () : position_mutable = {
  line = 0l;
  col = 0l;
}

type location_mutable = {
  mutable file : string option;
  mutable start : position option;
  mutable stop : position option;
}

let default_location_mutable () : location_mutable = {
  file = None;
  start = None;
  stop = None;
}


(** {2 Make functions} *)

let rec make_position 
  ~(line:int32)
  ~(col:int32)
  () : position  = {
  line;
  col;
}

let rec make_location 
  ?file:((file:string option) = None)
  ?start:((start:position option) = None)
  ?stop:((stop:position option) = None)
  () : location  = {
  file;
  start;
  stop;
}

[@@@ocaml.warning "-27-30-39"]

(** {2 Formatters} *)

let rec pp_position fmt (v:position) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "line" Pbrt.Pp.pp_int32 fmt v.line;
    Pbrt.Pp.pp_record_field ~first:false "col" Pbrt.Pp.pp_int32 fmt v.col;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_location fmt (v:location) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "file" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.file;
    Pbrt.Pp.pp_record_field ~first:false "start" (Pbrt.Pp.pp_option pp_position) fmt v.start;
    Pbrt.Pp.pp_record_field ~first:false "stop" (Pbrt.Pp.pp_option pp_position) fmt v.stop;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_position (v:position) encoder = 
  Pbrt.Encoder.int32_as_varint v.line encoder;
  Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  Pbrt.Encoder.int32_as_varint v.col encoder;
  Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  ()

let rec encode_pb_location (v:location) encoder = 
  begin match v.file with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  begin match v.start with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_position x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  begin match v.stop with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_position x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_position d =
  let v = default_position_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.line <- Pbrt.Decoder.int32_as_varint d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(position), field(1)" pk
    | Some (2, Pbrt.Varint) -> begin
      v.col <- Pbrt.Decoder.int32_as_varint d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(position), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    line = v.line;
    col = v.col;
  } : position)

let rec decode_pb_location d =
  let v = default_location_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.file <- Some (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(location), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.start <- Some (decode_pb_position (Pbrt.Decoder.nested d));
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(location), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.stop <- Some (decode_pb_position (Pbrt.Decoder.nested d));
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(location), field(3)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    file = v.file;
    start = v.start;
    stop = v.stop;
  } : location)

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_position (v:position) = 
  let assoc = [] in 
  let assoc = ("line", Pbrt_yojson.make_int (Int32.to_int v.line)) :: assoc in
  let assoc = ("col", Pbrt_yojson.make_int (Int32.to_int v.col)) :: assoc in
  `Assoc assoc

let rec encode_json_location (v:location) = 
  let assoc = [] in 
  let assoc = match v.file with
    | None -> assoc
    | Some v -> ("file", Pbrt_yojson.make_string v) :: assoc
  in
  let assoc = match v.start with
    | None -> assoc
    | Some v -> ("start", encode_json_position v) :: assoc
  in
  let assoc = match v.stop with
    | None -> assoc
    | Some v -> ("stop", encode_json_position v) :: assoc
  in
  `Assoc assoc

[@@@ocaml.warning "-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_position d =
  let v = default_position_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("line", json_value) -> 
      v.line <- Pbrt_yojson.int32 json_value "position" "line"
    | ("col", json_value) -> 
      v.col <- Pbrt_yojson.int32 json_value "position" "col"
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    line = v.line;
    col = v.col;
  } : position)

let rec decode_json_location d =
  let v = default_location_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("file", json_value) -> 
      v.file <- Some (Pbrt_yojson.string json_value "location" "file")
    | ("start", json_value) -> 
      v.start <- Some ((decode_json_position json_value))
    | ("stop", json_value) -> 
      v.stop <- Some ((decode_json_position json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    file = v.file;
    start = v.start;
    stop = v.stop;
  } : location)
