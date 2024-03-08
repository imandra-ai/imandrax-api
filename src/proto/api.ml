[@@@ocaml.warning "-27-30-39"]

type task_kind =
  | Task_unspecified 
  | Task_eval 
  | Task_check_po 
  | Task_proof_check 

type task_id = {
  id : string;
}

type task = {
  id : task_id option;
  kind : task_kind;
}

type session = {
  id : string;
}

type session_create = {
  po_check : bool option;
}

type session_open = {
  id : session option;
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
  tasks : task list;
  errors : Error.error list;
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
  ?tasks:((tasks:task list) = [])
  ?errors:((errors:Error.error list) = [])
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
  mutable tasks : task list;
  mutable errors : Error.error list;
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
  ~(tasks:task list)
  ~(errors:Error.error list)
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

let rec pp_task_kind fmt (v:task_kind) =
  match v with
  | Task_unspecified -> Format.fprintf fmt "Task_unspecified"
  | Task_eval -> Format.fprintf fmt "Task_eval"
  | Task_check_po -> Format.fprintf fmt "Task_check_po"
  | Task_proof_check -> Format.fprintf fmt "Task_proof_check"

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
    Pbrt.Pp.pp_record_field ~first:false "tasks" (Pbrt.Pp.pp_list pp_task) fmt v.tasks;
    Pbrt.Pp.pp_record_field ~first:false "errors" (Pbrt.Pp.pp_list Error.pp_error) fmt v.errors;
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

let rec encode_pb_task_kind (v:task_kind) encoder =
  match v with
  | Task_unspecified -> Pbrt.Encoder.int_as_varint (0) encoder
  | Task_eval -> Pbrt.Encoder.int_as_varint 1 encoder
  | Task_check_po -> Pbrt.Encoder.int_as_varint 2 encoder
  | Task_proof_check -> Pbrt.Encoder.int_as_varint 3 encoder

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
    Pbrt.Encoder.nested encode_pb_task x encoder;
    Pbrt.Encoder.key 9 Pbrt.Bytes encoder; 
  ) v.tasks encoder;
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested Error.encode_pb_error x encoder;
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

let rec decode_pb_task_kind d = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> (Task_unspecified:task_kind)
  | 1 -> (Task_eval:task_kind)
  | 2 -> (Task_check_po:task_kind)
  | 3 -> (Task_proof_check:task_kind)
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
      v.tasks <- (decode_pb_task (Pbrt.Decoder.nested d)) :: v.tasks;
    end
    | Some (9, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(code_snippet_eval_result), field(9)" pk
    | Some (10, Pbrt.Bytes) -> begin
      v.errors <- (Error.decode_pb_error (Pbrt.Decoder.nested d)) :: v.errors;
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

let rec encode_json_task_kind (v:task_kind) = 
  match v with
  | Task_unspecified -> `String "TASK_UNSPECIFIED"
  | Task_eval -> `String "TASK_EVAL"
  | Task_check_po -> `String "TASK_CHECK_PO"
  | Task_proof_check -> `String "TASK_PROOF_CHECK"

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
    let l = v.tasks |> List.map encode_json_task in
    ("tasks", `List l) :: assoc 
  in
  let assoc =
    let l = v.errors |> List.map Error.encode_json_error in
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

let rec decode_json_task_kind json =
  match json with
  | `String "TASK_UNSPECIFIED" -> (Task_unspecified : task_kind)
  | `String "TASK_EVAL" -> (Task_eval : task_kind)
  | `String "TASK_CHECK_PO" -> (Task_check_po : task_kind)
  | `String "TASK_PROOF_CHECK" -> (Task_proof_check : task_kind)
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
        | json_value -> (decode_json_task json_value)
      ) l;
    end
    | ("errors", `List l) -> begin
      v.errors <- List.map (function
        | json_value -> (Error.decode_json_error json_value)
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
    open Pbrt_services
    
    let open_session : (session_open, unary, unit, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:[]
        ~service_name:"SessionManager" ~rpc_name:"open_session"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_session_open
        ~encode_pb_req:encode_pb_session_open
        ~decode_json_res:(fun _ -> ())
        ~decode_pb_res:(fun d -> Pbrt.Decoder.empty_nested d)
        () : (session_open, unary, unit, unary) Client.rpc)
    open Pbrt_services
    
    let keep_session_alive : (session, unary, unit, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:[]
        ~service_name:"SessionManager" ~rpc_name:"keep_session_alive"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_session
        ~encode_pb_req:encode_pb_session
        ~decode_json_res:(fun _ -> ())
        ~decode_pb_res:(fun d -> Pbrt.Decoder.empty_nested d)
        () : (session, unary, unit, unary) Client.rpc)
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
    
    let _rpc_open_session : (session_open,unary,unit,unary) Server.rpc = 
      (Server.mk_rpc ~name:"open_session"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:(fun () -> `Assoc [])
        ~encode_pb_res:(fun () enc -> Pbrt.Encoder.empty_nested enc)
        ~decode_json_req:decode_json_session_open
        ~decode_pb_req:decode_pb_session_open
        () : _ Server.rpc)
    
    let _rpc_keep_session_alive : (session,unary,unit,unary) Server.rpc = 
      (Server.mk_rpc ~name:"keep_session_alive"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:(fun () -> `Assoc [])
        ~encode_pb_res:(fun () enc -> Pbrt.Encoder.empty_nested enc)
        ~decode_json_req:decode_json_session
        ~decode_pb_req:decode_pb_session
        () : _ Server.rpc)
    
    let make
      ~create_session
      ~open_session
      ~keep_session_alive
      () : _ Server.t =
      { Server.
        service_name="SessionManager";
        package=[];
        handlers=[
           (create_session _rpc_create_session);
           (open_session _rpc_open_session);
           (keep_session_alive _rpc_keep_session_alive);
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
    open Pbrt_services
    
    let release_memory : (unit, unary, gc_stats, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:[]
        ~service_name:"System" ~rpc_name:"release_memory"
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
    
    let _rpc_release_memory : (unit,unary,gc_stats,unary) Server.rpc = 
      (Server.mk_rpc ~name:"release_memory"
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
      ~release_memory
      () : _ Server.t =
      { Server.
        service_name="System";
        package=[];
        handlers=[
           (version _rpc_version);
           (gc_stats _rpc_gc_stats);
           (release_memory _rpc_release_memory);
        ];
      }
  end
  
end
