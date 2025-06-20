[@@@ocaml.warning "-27-30-39-44"]

type task_kind =
  | Task_unspecified 
  | Task_eval 
  | Task_check_po 
  | Task_proof_check 
  | Task_decomp 

type task_id = {
  id : string;
}

type task = {
  id : task_id option;
  kind : task_kind;
}

type origin = {
  from_sym : string;
  count : int32;
}

let rec default_task_kind () = (Task_unspecified:task_kind)

let rec default_task_id 
  ?id:((id:string) = "")
  () : task_id  = {
  id;
}

let rec default_task 
  ?id:((id:task_id option) = None)
  ?kind:((kind:task_kind) = default_task_kind ())
  () : task  = {
  id;
  kind;
}

let rec default_origin 
  ?from_sym:((from_sym:string) = "")
  ?count:((count:int32) = 0l)
  () : origin  = {
  from_sym;
  count;
}

type task_id_mutable = {
  mutable id : string;
}

let default_task_id_mutable () : task_id_mutable = {
  id = "";
}

type task_mutable = {
  mutable id : task_id option;
  mutable kind : task_kind;
}

let default_task_mutable () : task_mutable = {
  id = None;
  kind = default_task_kind ();
}

type origin_mutable = {
  mutable from_sym : string;
  mutable count : int32;
}

let default_origin_mutable () : origin_mutable = {
  from_sym = "";
  count = 0l;
}


(** {2 Make functions} *)


let rec make_task_id 
  ~(id:string)
  () : task_id  = {
  id;
}

let rec make_task 
  ?id:((id:task_id option) = None)
  ~(kind:task_kind)
  () : task  = {
  id;
  kind;
}

let rec make_origin 
  ~(from_sym:string)
  ~(count:int32)
  () : origin  = {
  from_sym;
  count;
}

[@@@ocaml.warning "-27-30-39"]

(** {2 Formatters} *)

let rec pp_task_kind fmt (v:task_kind) =
  match v with
  | Task_unspecified -> Format.fprintf fmt "Task_unspecified"
  | Task_eval -> Format.fprintf fmt "Task_eval"
  | Task_check_po -> Format.fprintf fmt "Task_check_po"
  | Task_proof_check -> Format.fprintf fmt "Task_proof_check"
  | Task_decomp -> Format.fprintf fmt "Task_decomp"

let rec pp_task_id fmt (v:task_id) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "id" Pbrt.Pp.pp_string fmt v.id;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_task fmt (v:task) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "id" (Pbrt.Pp.pp_option pp_task_id) fmt v.id;
    Pbrt.Pp.pp_record_field ~first:false "kind" pp_task_kind fmt v.kind;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_origin fmt (v:origin) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "from_sym" Pbrt.Pp.pp_string fmt v.from_sym;
    Pbrt.Pp.pp_record_field ~first:false "count" Pbrt.Pp.pp_int32 fmt v.count;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_task_kind (v:task_kind) encoder =
  match v with
  | Task_unspecified -> Pbrt.Encoder.int_as_varint (0) encoder
  | Task_eval -> Pbrt.Encoder.int_as_varint 1 encoder
  | Task_check_po -> Pbrt.Encoder.int_as_varint 2 encoder
  | Task_proof_check -> Pbrt.Encoder.int_as_varint 3 encoder
  | Task_decomp -> Pbrt.Encoder.int_as_varint 4 encoder

let rec encode_pb_task_id (v:task_id) encoder = 
  Pbrt.Encoder.string v.id encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ()

let rec encode_pb_task (v:task) encoder = 
  begin match v.id with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_task_id x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  encode_pb_task_kind v.kind encoder;
  Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  ()

let rec encode_pb_origin (v:origin) encoder = 
  Pbrt.Encoder.string v.from_sym encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  Pbrt.Encoder.int32_as_varint v.count encoder;
  Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_task_kind d = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> (Task_unspecified:task_kind)
  | 1 -> (Task_eval:task_kind)
  | 2 -> (Task_check_po:task_kind)
  | 3 -> (Task_proof_check:task_kind)
  | 4 -> (Task_decomp:task_kind)
  | _ -> Pbrt.Decoder.malformed_variant "task_kind"

let rec decode_pb_task_id d =
  let v = default_task_id_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.id <- Pbrt.Decoder.string d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(task_id), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    id = v.id;
  } : task_id)

let rec decode_pb_task d =
  let v = default_task_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.id <- Some (decode_pb_task_id (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(task), field(1)" pk
    | Some (2, Pbrt.Varint) -> begin
      v.kind <- decode_pb_task_kind d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(task), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    id = v.id;
    kind = v.kind;
  } : task)

let rec decode_pb_origin d =
  let v = default_origin_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.from_sym <- Pbrt.Decoder.string d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(origin), field(1)" pk
    | Some (2, Pbrt.Varint) -> begin
      v.count <- Pbrt.Decoder.int32_as_varint d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(origin), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    from_sym = v.from_sym;
    count = v.count;
  } : origin)

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_task_kind (v:task_kind) = 
  match v with
  | Task_unspecified -> `String "TASK_UNSPECIFIED"
  | Task_eval -> `String "TASK_EVAL"
  | Task_check_po -> `String "TASK_CHECK_PO"
  | Task_proof_check -> `String "TASK_PROOF_CHECK"
  | Task_decomp -> `String "TASK_DECOMP"

let rec encode_json_task_id (v:task_id) = 
  let assoc = [] in 
  let assoc = ("id", Pbrt_yojson.make_string v.id) :: assoc in
  `Assoc assoc

let rec encode_json_task (v:task) = 
  let assoc = [] in 
  let assoc = match v.id with
    | None -> assoc
    | Some v -> ("id", encode_json_task_id v) :: assoc
  in
  let assoc = ("kind", encode_json_task_kind v.kind) :: assoc in
  `Assoc assoc

let rec encode_json_origin (v:origin) = 
  let assoc = [] in 
  let assoc = ("fromSym", Pbrt_yojson.make_string v.from_sym) :: assoc in
  let assoc = ("count", Pbrt_yojson.make_int (Int32.to_int v.count)) :: assoc in
  `Assoc assoc

[@@@ocaml.warning "-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_task_kind json =
  match json with
  | `String "TASK_UNSPECIFIED" -> (Task_unspecified : task_kind)
  | `String "TASK_EVAL" -> (Task_eval : task_kind)
  | `String "TASK_CHECK_PO" -> (Task_check_po : task_kind)
  | `String "TASK_PROOF_CHECK" -> (Task_proof_check : task_kind)
  | `String "TASK_DECOMP" -> (Task_decomp : task_kind)
  | _ -> Pbrt_yojson.E.malformed_variant "task_kind"

let rec decode_json_task_id d =
  let v = default_task_id_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("id", json_value) -> 
      v.id <- Pbrt_yojson.string json_value "task_id" "id"
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    id = v.id;
  } : task_id)

let rec decode_json_task d =
  let v = default_task_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("id", json_value) -> 
      v.id <- Some ((decode_json_task_id json_value))
    | ("kind", json_value) -> 
      v.kind <- (decode_json_task_kind json_value)
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    id = v.id;
    kind = v.kind;
  } : task)

let rec decode_json_origin d =
  let v = default_origin_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("fromSym", json_value) -> 
      v.from_sym <- Pbrt_yojson.string json_value "origin" "from_sym"
    | ("count", json_value) -> 
      v.count <- Pbrt_yojson.int32 json_value "origin" "count"
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    from_sym = v.from_sym;
    count = v.count;
  } : origin)
