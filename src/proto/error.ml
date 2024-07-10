[@@@ocaml.warning "-27-30-39-44"]

type error_message = {
  msg : string;
  locs : Locs.location list;
  backtrace : string option;
}

type error = {
  msg : error_message option;
  kind : string;
  stack : error_message list;
  process : string option;
}

let rec default_error_message 
  ?msg:((msg:string) = "")
  ?locs:((locs:Locs.location list) = [])
  ?backtrace:((backtrace:string option) = None)
  () : error_message  = {
  msg;
  locs;
  backtrace;
}

let rec default_error 
  ?msg:((msg:error_message option) = None)
  ?kind:((kind:string) = "")
  ?stack:((stack:error_message list) = [])
  ?process:((process:string option) = None)
  () : error  = {
  msg;
  kind;
  stack;
  process;
}

type error_message_mutable = {
  mutable msg : string;
  mutable locs : Locs.location list;
  mutable backtrace : string option;
}

let default_error_message_mutable () : error_message_mutable = {
  msg = "";
  locs = [];
  backtrace = None;
}

type error_mutable = {
  mutable msg : error_message option;
  mutable kind : string;
  mutable stack : error_message list;
  mutable process : string option;
}

let default_error_mutable () : error_mutable = {
  msg = None;
  kind = "";
  stack = [];
  process = None;
}


(** {2 Make functions} *)

let rec make_error_message 
  ~(msg:string)
  ~(locs:Locs.location list)
  ?backtrace:((backtrace:string option) = None)
  () : error_message  = {
  msg;
  locs;
  backtrace;
}

let rec make_error 
  ?msg:((msg:error_message option) = None)
  ~(kind:string)
  ~(stack:error_message list)
  ?process:((process:string option) = None)
  () : error  = {
  msg;
  kind;
  stack;
  process;
}

[@@@ocaml.warning "-27-30-39"]

(** {2 Formatters} *)

let rec pp_error_message fmt (v:error_message) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "msg" Pbrt.Pp.pp_string fmt v.msg;
    Pbrt.Pp.pp_record_field ~first:false "locs" (Pbrt.Pp.pp_list Locs.pp_location) fmt v.locs;
    Pbrt.Pp.pp_record_field ~first:false "backtrace" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.backtrace;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_error fmt (v:error) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "msg" (Pbrt.Pp.pp_option pp_error_message) fmt v.msg;
    Pbrt.Pp.pp_record_field ~first:false "kind" Pbrt.Pp.pp_string fmt v.kind;
    Pbrt.Pp.pp_record_field ~first:false "stack" (Pbrt.Pp.pp_list pp_error_message) fmt v.stack;
    Pbrt.Pp.pp_record_field ~first:false "process" (Pbrt.Pp.pp_option Pbrt.Pp.pp_string) fmt v.process;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_error_message (v:error_message) encoder = 
  Pbrt.Encoder.string v.msg encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested Locs.encode_pb_location x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  ) v.locs encoder;
  begin match v.backtrace with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_error (v:error) encoder = 
  begin match v.msg with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_error_message x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  Pbrt.Encoder.string v.kind encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested encode_pb_error_message x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  ) v.stack encoder;
  begin match v.process with
  | Some x -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_error_message d =
  let v = default_error_message_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.locs <- List.rev v.locs;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.msg <- Pbrt.Decoder.string d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(error_message), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.locs <- (Locs.decode_pb_location (Pbrt.Decoder.nested d)) :: v.locs;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(error_message), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.backtrace <- Some (Pbrt.Decoder.string d);
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(error_message), field(3)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    msg = v.msg;
    locs = v.locs;
    backtrace = v.backtrace;
  } : error_message)

let rec decode_pb_error d =
  let v = default_error_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.stack <- List.rev v.stack;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.msg <- Some (decode_pb_error_message (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(error), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.kind <- Pbrt.Decoder.string d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(error), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.stack <- (decode_pb_error_message (Pbrt.Decoder.nested d)) :: v.stack;
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(error), field(3)" pk
    | Some (4, Pbrt.Bytes) -> begin
      v.process <- Some (Pbrt.Decoder.string d);
    end
    | Some (4, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(error), field(4)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    msg = v.msg;
    kind = v.kind;
    stack = v.stack;
    process = v.process;
  } : error)

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_error_message (v:error_message) = 
  let assoc = [] in 
  let assoc = ("msg", Pbrt_yojson.make_string v.msg) :: assoc in
  let assoc =
    let l = v.locs |> List.map Locs.encode_json_location in
    ("locs", `List l) :: assoc 
  in
  let assoc = match v.backtrace with
    | None -> assoc
    | Some v -> ("backtrace", Pbrt_yojson.make_string v) :: assoc
  in
  `Assoc assoc

let rec encode_json_error (v:error) = 
  let assoc = [] in 
  let assoc = match v.msg with
    | None -> assoc
    | Some v -> ("msg", encode_json_error_message v) :: assoc
  in
  let assoc = ("kind", Pbrt_yojson.make_string v.kind) :: assoc in
  let assoc =
    let l = v.stack |> List.map encode_json_error_message in
    ("stack", `List l) :: assoc 
  in
  let assoc = match v.process with
    | None -> assoc
    | Some v -> ("process", Pbrt_yojson.make_string v) :: assoc
  in
  `Assoc assoc

[@@@ocaml.warning "-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_error_message d =
  let v = default_error_message_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("msg", json_value) -> 
      v.msg <- Pbrt_yojson.string json_value "error_message" "msg"
    | ("locs", `List l) -> begin
      v.locs <- List.map (function
        | json_value -> (Locs.decode_json_location json_value)
      ) l;
    end
    | ("backtrace", json_value) -> 
      v.backtrace <- Some (Pbrt_yojson.string json_value "error_message" "backtrace")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    msg = v.msg;
    locs = v.locs;
    backtrace = v.backtrace;
  } : error_message)

let rec decode_json_error d =
  let v = default_error_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("msg", json_value) -> 
      v.msg <- Some ((decode_json_error_message json_value))
    | ("kind", json_value) -> 
      v.kind <- Pbrt_yojson.string json_value "error" "kind"
    | ("stack", `List l) -> begin
      v.stack <- List.map (function
        | json_value -> (decode_json_error_message json_value)
      ) l;
    end
    | ("process", json_value) -> 
      v.process <- Some (Pbrt_yojson.string json_value "error" "process")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    msg = v.msg;
    kind = v.kind;
    stack = v.stack;
    process = v.process;
  } : error)
