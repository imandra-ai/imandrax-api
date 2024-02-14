[@@@ocaml.warning "-27-30-39"]

type empty = unit

type position = {
  line : int32;
  col : int32;
}

type location = {
  file : string;
  start : position option;
  stop : position option;
}

type error = {
  msg : string;
  kind : string;
  locs : location list;
}

type task_id = {
  id : bytes;
}

type session = {
  id : bytes;
}

type session_create = {
  po_check : bool option;
}

type code_snippet = {
  session : session option;
  code : string;
}

type eval_result =
  | Eval_ok 
  | Eval_errors 

type code_snippet_eval_result = {
  res : eval_result;
  duration_s : float;
  tasks : task_id list;
  errors : error list;
}

type gc_stats = {
  heap_size_b : int64;
  major_collections : int64;
  minor_collections : int64;
}

type version_response = {
  version : string;
  git_version : string option;
}

let rec default_empty = ()

let rec default_position 
  ?line:((line:int32) = 0l)
  ?col:((col:int32) = 0l)
  () : position  = {
  line;
  col;
}

let rec default_location 
  ?file:((file:string) = "")
  ?start:((start:position option) = None)
  ?stop:((stop:position option) = None)
  () : location  = {
  file;
  start;
  stop;
}

let rec default_error 
  ?msg:((msg:string) = "")
  ?kind:((kind:string) = "")
  ?locs:((locs:location list) = [])
  () : error  = {
  msg;
  kind;
  locs;
}

let rec default_task_id 
  ?id:((id:bytes) = Bytes.create 0)
  () : task_id  = {
  id;
}

let rec default_session 
  ?id:((id:bytes) = Bytes.create 0)
  () : session  = {
  id;
}

let rec default_session_create 
  ?po_check:((po_check:bool option) = None)
  () : session_create  = {
  po_check;
}

let rec default_code_snippet 
  ?session:((session:session option) = None)
  ?code:((code:string) = "")
  () : code_snippet  = {
  session;
  code;
}

let rec default_eval_result () = (Eval_ok:eval_result)

let rec default_code_snippet_eval_result 
  ?res:((res:eval_result) = default_eval_result ())
  ?duration_s:((duration_s:float) = 0.)
  ?tasks:((tasks:task_id list) = [])
  ?errors:((errors:error list) = [])
  () : code_snippet_eval_result  = {
  res;
  duration_s;
  tasks;
  errors;
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

type position_mutable = {
  mutable line : int32;
  mutable col : int32;
}

let default_position_mutable () : position_mutable = {
  line = 0l;
  col = 0l;
}

type location_mutable = {
  mutable file : string;
  mutable start : position option;
  mutable stop : position option;
}

let default_location_mutable () : location_mutable = {
  file = "";
  start = None;
  stop = None;
}

type error_mutable = {
  mutable msg : string;
  mutable kind : string;
  mutable locs : location list;
}

let default_error_mutable () : error_mutable = {
  msg = "";
  kind = "";
  locs = [];
}

type task_id_mutable = {
  mutable id : bytes;
}

let default_task_id_mutable () : task_id_mutable = {
  id = Bytes.create 0;
}

type session_mutable = {
  mutable id : bytes;
}

let default_session_mutable () : session_mutable = {
  id = Bytes.create 0;
}

type session_create_mutable = {
  mutable po_check : bool option;
}

let default_session_create_mutable () : session_create_mutable = {
  po_check = None;
}

type code_snippet_mutable = {
  mutable session : session option;
  mutable code : string;
}

let default_code_snippet_mutable () : code_snippet_mutable = {
  session = None;
  code = "";
}

type code_snippet_eval_result_mutable = {
  mutable res : eval_result;
  mutable duration_s : float;
  mutable tasks : task_id list;
  mutable errors : error list;
}

let default_code_snippet_eval_result_mutable () : code_snippet_eval_result_mutable = {
  res = default_eval_result ();
  duration_s = 0.;
  tasks = [];
  errors = [];
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


let rec make_position 
  ~(line:int32)
  ~(col:int32)
  () : position  = {
  line;
  col;
}

let rec make_location 
  ~(file:string)
  ?start:((start:position option) = None)
  ?stop:((stop:position option) = None)
  () : location  = {
  file;
  start;
  stop;
}

let rec make_error 
  ~(msg:string)
  ~(kind:string)
  ~(locs:location list)
  () : error  = {
  msg;
  kind;
  locs;
}

let rec make_task_id 
  ~(id:bytes)
  () : task_id  = {
  id;
}

let rec make_session 
  ~(id:bytes)
  () : session  = {
  id;
}

let rec make_session_create 
  ?po_check:((po_check:bool option) = None)
  () : session_create  = {
  po_check;
}

let rec make_code_snippet 
  ?session:((session:session option) = None)
  ~(code:string)
  () : code_snippet  = {
  session;
  code;
}


let rec make_code_snippet_eval_result 
  ~(res:eval_result)
  ~(duration_s:float)
  ~(tasks:task_id list)
  ~(errors:error list)
  () : code_snippet_eval_result  = {
  res;
  duration_s;
  tasks;
  errors;
}

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

let rec pp_empty fmt (v:empty) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_unit fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_position fmt (v:position) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "line" Pbrt.Pp.pp_int32 fmt v.line;
    Pbrt.Pp.pp_record_field ~first:false "col" Pbrt.Pp.pp_int32 fmt v.col;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_location fmt (v:location) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "file" Pbrt.Pp.pp_string fmt v.file;
    Pbrt.Pp.pp_record_field ~first:false "start" (Pbrt.Pp.pp_option pp_position) fmt v.start;
    Pbrt.Pp.pp_record_field ~first:false "stop" (Pbrt.Pp.pp_option pp_position) fmt v.stop;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_error fmt (v:error) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "msg" Pbrt.Pp.pp_string fmt v.msg;
    Pbrt.Pp.pp_record_field ~first:false "kind" Pbrt.Pp.pp_string fmt v.kind;
    Pbrt.Pp.pp_record_field ~first:false "locs" (Pbrt.Pp.pp_list pp_location) fmt v.locs;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_task_id fmt (v:task_id) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "id" Pbrt.Pp.pp_bytes fmt v.id;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_session fmt (v:session) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "id" Pbrt.Pp.pp_bytes fmt v.id;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_session_create fmt (v:session_create) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "po_check" (Pbrt.Pp.pp_option Pbrt.Pp.pp_bool) fmt v.po_check;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_code_snippet fmt (v:code_snippet) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~first:false "code" Pbrt.Pp.pp_string fmt v.code;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_eval_result fmt (v:eval_result) =
  match v with
  | Eval_ok -> Format.fprintf fmt "Eval_ok"
  | Eval_errors -> Format.fprintf fmt "Eval_errors"

let rec pp_code_snippet_eval_result fmt (v:code_snippet_eval_result) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "res" pp_eval_result fmt v.res;
    Pbrt.Pp.pp_record_field ~first:false "duration_s" Pbrt.Pp.pp_float fmt v.duration_s;
    Pbrt.Pp.pp_record_field ~first:false "tasks" (Pbrt.Pp.pp_list pp_task_id) fmt v.tasks;
    Pbrt.Pp.pp_record_field ~first:false "errors" (Pbrt.Pp.pp_list pp_error) fmt v.errors;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

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

let rec encode_pb_empty (v:empty) encoder = 
()

let rec encode_pb_position (v:position) encoder = 
  Pbrt.Encoder.int32_as_varint v.line encoder;
  Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  Pbrt.Encoder.int32_as_varint v.col encoder;
  Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  ()

let rec encode_pb_location (v:location) encoder = 
  Pbrt.Encoder.string v.file encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
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

let rec encode_pb_error (v:error) encoder = 
  Pbrt.Encoder.string v.msg encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  Pbrt.Encoder.string v.kind encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested encode_pb_location x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  ) v.locs encoder;
  ()

let rec encode_pb_task_id (v:task_id) encoder = 
  Pbrt.Encoder.bytes v.id encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ()

let rec encode_pb_session (v:session) encoder = 
  Pbrt.Encoder.bytes v.id encoder;
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

let rec encode_pb_code_snippet (v:code_snippet) encoder = 
  begin match v.session with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_session x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  Pbrt.Encoder.string v.code encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  ()

let rec encode_pb_eval_result (v:eval_result) encoder =
  match v with
  | Eval_ok -> Pbrt.Encoder.int_as_varint (0) encoder
  | Eval_errors -> Pbrt.Encoder.int_as_varint 1 encoder

let rec encode_pb_code_snippet_eval_result (v:code_snippet_eval_result) encoder = 
  encode_pb_eval_result v.res encoder;
  Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  Pbrt.Encoder.float_as_bits32 v.duration_s encoder;
  Pbrt.Encoder.key 3 Pbrt.Bits32 encoder; 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested encode_pb_task_id x encoder;
    Pbrt.Encoder.key 9 Pbrt.Bytes encoder; 
  ) v.tasks encoder;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested encode_pb_error x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  ) v.errors encoder;
  ()

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

let rec decode_pb_empty d =
  match Pbrt.Decoder.key d with
  | None -> ();
  | Some (_, pk) -> 
    Pbrt.Decoder.unexpected_payload "Unexpected fields in empty message(empty)" pk

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
      v.file <- Pbrt.Decoder.string d;
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

let rec decode_pb_error d =
  let v = default_error_mutable () in
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
      Pbrt.Decoder.unexpected_payload "Message(error), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.kind <- Pbrt.Decoder.string d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(error), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.locs <- (decode_pb_location (Pbrt.Decoder.nested d)) :: v.locs;
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(error), field(3)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    msg = v.msg;
    kind = v.kind;
    locs = v.locs;
  } : error)

let rec decode_pb_task_id d =
  let v = default_task_id_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.id <- Pbrt.Decoder.bytes d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(task_id), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    id = v.id;
  } : task_id)

let rec decode_pb_session d =
  let v = default_session_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.id <- Pbrt.Decoder.bytes d;
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

let rec decode_pb_code_snippet d =
  let v = default_code_snippet_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.session <- Some (decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(code_snippet), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.code <- Pbrt.Decoder.string d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(code_snippet), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    session = v.session;
    code = v.code;
  } : code_snippet)

let rec decode_pb_eval_result d = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> (Eval_ok:eval_result)
  | 1 -> (Eval_errors:eval_result)
  | _ -> Pbrt.Decoder.malformed_variant "eval_result"

let rec decode_pb_code_snippet_eval_result d =
  let v = default_code_snippet_eval_result_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.errors <- List.rev v.errors;
      v.tasks <- List.rev v.tasks;
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.res <- decode_pb_eval_result d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(code_snippet_eval_result), field(1)" pk
    | Some (3, Pbrt.Bits32) -> begin
      v.duration_s <- Pbrt.Decoder.float_as_bits32 d;
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(code_snippet_eval_result), field(3)" pk
    | Some (9, Pbrt.Bytes) -> begin
      v.tasks <- (decode_pb_task_id (Pbrt.Decoder.nested d)) :: v.tasks;
    end
    | Some (9, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(code_snippet_eval_result), field(9)" pk
    | Some (10, Pbrt.Bytes) -> begin
      v.errors <- (decode_pb_error (Pbrt.Decoder.nested d)) :: v.errors;
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(code_snippet_eval_result), field(10)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    res = v.res;
    duration_s = v.duration_s;
    tasks = v.tasks;
    errors = v.errors;
  } : code_snippet_eval_result)

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

let rec encode_json_empty (v:empty) = 
Pbrt_yojson.make_unit v

let rec encode_json_position (v:position) = 
  let assoc = [] in 
  let assoc = ("line", Pbrt_yojson.make_int (Int32.to_int v.line)) :: assoc in
  let assoc = ("col", Pbrt_yojson.make_int (Int32.to_int v.col)) :: assoc in
  `Assoc assoc

let rec encode_json_location (v:location) = 
  let assoc = [] in 
  let assoc = ("file", Pbrt_yojson.make_string v.file) :: assoc in
  let assoc = match v.start with
    | None -> assoc
    | Some v -> ("start", encode_json_position v) :: assoc
  in
  let assoc = match v.stop with
    | None -> assoc
    | Some v -> ("stop", encode_json_position v) :: assoc
  in
  `Assoc assoc

let rec encode_json_error (v:error) = 
  let assoc = [] in 
  let assoc = ("msg", Pbrt_yojson.make_string v.msg) :: assoc in
  let assoc = ("kind", Pbrt_yojson.make_string v.kind) :: assoc in
  let assoc =
    let l = v.locs |> List.map encode_json_location in
    ("locs", `List l) :: assoc 
  in
  `Assoc assoc

let rec encode_json_task_id (v:task_id) = 
  let assoc = [] in 
  let assoc = ("id", Pbrt_yojson.make_bytes v.id) :: assoc in
  `Assoc assoc

let rec encode_json_session (v:session) = 
  let assoc = [] in 
  let assoc = ("id", Pbrt_yojson.make_bytes v.id) :: assoc in
  `Assoc assoc

let rec encode_json_session_create (v:session_create) = 
  let assoc = [] in 
  let assoc = match v.po_check with
    | None -> assoc
    | Some v -> ("poCheck", Pbrt_yojson.make_bool v) :: assoc
  in
  `Assoc assoc

let rec encode_json_code_snippet (v:code_snippet) = 
  let assoc = [] in 
  let assoc = match v.session with
    | None -> assoc
    | Some v -> ("session", encode_json_session v) :: assoc
  in
  let assoc = ("code", Pbrt_yojson.make_string v.code) :: assoc in
  `Assoc assoc

let rec encode_json_eval_result (v:eval_result) = 
  match v with
  | Eval_ok -> `String "EVAL_OK"
  | Eval_errors -> `String "EVAL_ERRORS"

let rec encode_json_code_snippet_eval_result (v:code_snippet_eval_result) = 
  let assoc = [] in 
  let assoc = ("res", encode_json_eval_result v.res) :: assoc in
  let assoc = ("durationS", Pbrt_yojson.make_float v.duration_s) :: assoc in
  let assoc =
    let l = v.tasks |> List.map encode_json_task_id in
    ("tasks", `List l) :: assoc 
  in
  let assoc =
    let l = v.errors |> List.map encode_json_error in
    ("errors", `List l) :: assoc 
  in
  `Assoc assoc

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

let rec decode_json_empty d =
Pbrt_yojson.unit d "empty" "empty record"

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
      v.file <- Pbrt_yojson.string json_value "location" "file"
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

let rec decode_json_error d =
  let v = default_error_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("msg", json_value) -> 
      v.msg <- Pbrt_yojson.string json_value "error" "msg"
    | ("kind", json_value) -> 
      v.kind <- Pbrt_yojson.string json_value "error" "kind"
    | ("locs", `List l) -> begin
      v.locs <- List.map (function
        | json_value -> (decode_json_location json_value)
      ) l;
    end
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    msg = v.msg;
    kind = v.kind;
    locs = v.locs;
  } : error)

let rec decode_json_task_id d =
  let v = default_task_id_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("id", json_value) -> 
      v.id <- Pbrt_yojson.bytes json_value "task_id" "id"
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    id = v.id;
  } : task_id)

let rec decode_json_session d =
  let v = default_session_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("id", json_value) -> 
      v.id <- Pbrt_yojson.bytes json_value "session" "id"
    
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

let rec decode_json_code_snippet d =
  let v = default_code_snippet_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      v.session <- Some ((decode_json_session json_value))
    | ("code", json_value) -> 
      v.code <- Pbrt_yojson.string json_value "code_snippet" "code"
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    session = v.session;
    code = v.code;
  } : code_snippet)

let rec decode_json_eval_result json =
  match json with
  | `String "EVAL_OK" -> (Eval_ok : eval_result)
  | `String "EVAL_ERRORS" -> (Eval_errors : eval_result)
  | _ -> Pbrt_yojson.E.malformed_variant "eval_result"

let rec decode_json_code_snippet_eval_result d =
  let v = default_code_snippet_eval_result_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("res", json_value) -> 
      v.res <- (decode_json_eval_result json_value)
    | ("durationS", json_value) -> 
      v.duration_s <- Pbrt_yojson.float json_value "code_snippet_eval_result" "duration_s"
    | ("tasks", `List l) -> begin
      v.tasks <- List.map (function
        | json_value -> (decode_json_task_id json_value)
      ) l;
    end
    | ("errors", `List l) -> begin
      v.errors <- List.map (function
        | json_value -> (decode_json_error json_value)
      ) l;
    end
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    res = v.res;
    duration_s = v.duration_s;
    tasks = v.tasks;
    errors = v.errors;
  } : code_snippet_eval_result)

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

module SessionManager = struct
  open Pbrt_services.Value_mode
  module Client = struct
    open Pbrt_services
    
    let create_session : (session_create, unary, session, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:[]
        ~service_name:"SessionManager" ~rpc_name:"create_session"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_session_create
        ~encode_pb_req:encode_pb_session_create
        ~decode_json_res:decode_json_session
        ~decode_pb_res:decode_pb_session
        () : (session_create, unary, session, unary) Client.rpc)
  end
  
  module Server = struct
    open Pbrt_services
    
    let _rpc_create_session : (session_create,unary,session,unary) Server.rpc = 
      (Server.mk_rpc ~name:"create_session"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_session
        ~encode_pb_res:encode_pb_session
        ~decode_json_req:decode_json_session_create
        ~decode_pb_req:decode_pb_session_create
        () : _ Server.rpc)
    
    let make
      ~create_session
      () : _ Server.t =
      { Server.
        service_name="SessionManager";
        package=[];
        handlers=[
           (create_session _rpc_create_session);
        ];
      }
  end
  
end

module Eval = struct
  open Pbrt_services.Value_mode
  module Client = struct
    open Pbrt_services
    
    let eval_code_snippet : (code_snippet, unary, code_snippet_eval_result, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:[]
        ~service_name:"Eval" ~rpc_name:"eval_code_snippet"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_code_snippet
        ~encode_pb_req:encode_pb_code_snippet
        ~decode_json_res:decode_json_code_snippet_eval_result
        ~decode_pb_res:decode_pb_code_snippet_eval_result
        () : (code_snippet, unary, code_snippet_eval_result, unary) Client.rpc)
  end
  
  module Server = struct
    open Pbrt_services
    
    let _rpc_eval_code_snippet : (code_snippet,unary,code_snippet_eval_result,unary) Server.rpc = 
      (Server.mk_rpc ~name:"eval_code_snippet"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_code_snippet_eval_result
        ~encode_pb_res:encode_pb_code_snippet_eval_result
        ~decode_json_req:decode_json_code_snippet
        ~decode_pb_req:decode_pb_code_snippet
        () : _ Server.rpc)
    
    let make
      ~eval_code_snippet
      () : _ Server.t =
      { Server.
        service_name="Eval";
        package=[];
        handlers=[
           (eval_code_snippet _rpc_eval_code_snippet);
        ];
      }
  end
  
end

module System = struct
  open Pbrt_services.Value_mode
  module Client = struct
    open Pbrt_services
    
    let version : (unit, unary, version_response, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:[]
        ~service_name:"System" ~rpc_name:"version"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:(fun () -> `Assoc [])
        ~encode_pb_req:(fun () enc -> Pbrt.Encoder.empty_nested enc)
        ~decode_json_res:decode_json_version_response
        ~decode_pb_res:decode_pb_version_response
        () : (unit, unary, version_response, unary) Client.rpc)
    open Pbrt_services
    
    let gc_stats : (unit, unary, gc_stats, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:[]
        ~service_name:"System" ~rpc_name:"gc_stats"
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
    
    let _rpc_version : (unit,unary,version_response,unary) Server.rpc = 
      (Server.mk_rpc ~name:"version"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_version_response
        ~encode_pb_res:encode_pb_version_response
        ~decode_json_req:(fun _ -> ())
        ~decode_pb_req:(fun d -> Pbrt.Decoder.empty_nested d)
        () : _ Server.rpc)
    
    let _rpc_gc_stats : (unit,unary,gc_stats,unary) Server.rpc = 
      (Server.mk_rpc ~name:"gc_stats"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_gc_stats
        ~encode_pb_res:encode_pb_gc_stats
        ~decode_json_req:(fun _ -> ())
        ~decode_pb_req:(fun d -> Pbrt.Decoder.empty_nested d)
        () : _ Server.rpc)
    
    let make
      ~version
      ~gc_stats
      () : _ Server.t =
      { Server.
        service_name="System";
        package=[];
        handlers=[
           (version _rpc_version);
           (gc_stats _rpc_gc_stats);
        ];
      }
  end
  
end
