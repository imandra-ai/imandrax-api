[@@@ocaml.warning "-27-30-39-44"]

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

type code_snippet = {
  session : Session.session option;
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

type parse_query = {
  code : string;
}

type artifact_list_query = {
  task_id : task_id option;
}

type artifact_list_result = {
  kinds : string list;
}

type artifact_get_query = {
  task_id : task_id option;
  kind : string;
}

type artifact = {
  art : Artmsg.art option;
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

let rec default_code_snippet 
  ?session:((session:Session.session option) = None)
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

let rec default_parse_query 
  ?code:((code:string) = "")
  () : parse_query  = {
  code;
}

let rec default_artifact_list_query 
  ?task_id:((task_id:task_id option) = None)
  () : artifact_list_query  = {
  task_id;
}

let rec default_artifact_list_result 
  ?kinds:((kinds:string list) = [])
  () : artifact_list_result  = {
  kinds;
}

let rec default_artifact_get_query 
  ?task_id:((task_id:task_id option) = None)
  ?kind:((kind:string) = "")
  () : artifact_get_query  = {
  task_id;
  kind;
}

let rec default_artifact 
  ?art:((art:Artmsg.art option) = None)
  () : artifact  = {
  art;
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

type code_snippet_mutable = {
  mutable session : Session.session option;
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

type parse_query_mutable = {
  mutable code : string;
}

let default_parse_query_mutable () : parse_query_mutable = {
  code = "";
}

type artifact_list_query_mutable = {
  mutable task_id : task_id option;
}

let default_artifact_list_query_mutable () : artifact_list_query_mutable = {
  task_id = None;
}

type artifact_list_result_mutable = {
  mutable kinds : string list;
}

let default_artifact_list_result_mutable () : artifact_list_result_mutable = {
  kinds = [];
}

type artifact_get_query_mutable = {
  mutable task_id : task_id option;
  mutable kind : string;
}

let default_artifact_get_query_mutable () : artifact_get_query_mutable = {
  task_id = None;
  kind = "";
}

type artifact_mutable = {
  mutable art : Artmsg.art option;
}

let default_artifact_mutable () : artifact_mutable = {
  art = None;
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

let rec make_code_snippet 
  ?session:((session:Session.session option) = None)
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

let rec make_parse_query 
  ~(code:string)
  () : parse_query  = {
  code;
}

let rec make_artifact_list_query 
  ?task_id:((task_id:task_id option) = None)
  () : artifact_list_query  = {
  task_id;
}

let rec make_artifact_list_result 
  ~(kinds:string list)
  () : artifact_list_result  = {
  kinds;
}

let rec make_artifact_get_query 
  ?task_id:((task_id:task_id option) = None)
  ~(kind:string)
  () : artifact_get_query  = {
  task_id;
  kind;
}

let rec make_artifact 
  ?art:((art:Artmsg.art option) = None)
  () : artifact  = {
  art;
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

let rec pp_code_snippet fmt (v:code_snippet) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
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

let rec pp_parse_query fmt (v:parse_query) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "code" Pbrt.Pp.pp_string fmt v.code;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_artifact_list_query fmt (v:artifact_list_query) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "task_id" (Pbrt.Pp.pp_option pp_task_id) fmt v.task_id;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_artifact_list_result fmt (v:artifact_list_result) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "kinds" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.kinds;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_artifact_get_query fmt (v:artifact_get_query) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "task_id" (Pbrt.Pp.pp_option pp_task_id) fmt v.task_id;
    Pbrt.Pp.pp_record_field ~first:false "kind" Pbrt.Pp.pp_string fmt v.kind;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_artifact fmt (v:artifact) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "art" (Pbrt.Pp.pp_option Artmsg.pp_art) fmt v.art;
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

let rec encode_pb_code_snippet (v:code_snippet) encoder = 
  begin match v.session with
  | Some x -> 
    Pbrt.Encoder.nested Session.encode_pb_session x encoder;
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

let rec encode_pb_parse_query (v:parse_query) encoder = 
  Pbrt.Encoder.string v.code encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ()

let rec encode_pb_artifact_list_query (v:artifact_list_query) encoder = 
  begin match v.task_id with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_task_id x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_artifact_list_result (v:artifact_list_result) encoder = 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.string x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ) v.kinds encoder;
  ()

let rec encode_pb_artifact_get_query (v:artifact_get_query) encoder = 
  begin match v.task_id with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_task_id x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  Pbrt.Encoder.string v.kind encoder;
  Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  ()

let rec encode_pb_artifact (v:artifact) encoder = 
  begin match v.art with
  | Some x -> 
    Pbrt.Encoder.nested Artmsg.encode_pb_art x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
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

let rec decode_pb_code_snippet d =
  let v = default_code_snippet_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.session <- Some (Session.decode_pb_session (Pbrt.Decoder.nested d));
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

let rec decode_pb_parse_query d =
  let v = default_parse_query_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.code <- Pbrt.Decoder.string d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(parse_query), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    code = v.code;
  } : parse_query)

let rec decode_pb_artifact_list_query d =
  let v = default_artifact_list_query_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.task_id <- Some (decode_pb_task_id (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(artifact_list_query), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    task_id = v.task_id;
  } : artifact_list_query)

let rec decode_pb_artifact_list_result d =
  let v = default_artifact_list_result_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.kinds <- List.rev v.kinds;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.kinds <- (Pbrt.Decoder.string d) :: v.kinds;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(artifact_list_result), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    kinds = v.kinds;
  } : artifact_list_result)

let rec decode_pb_artifact_get_query d =
  let v = default_artifact_get_query_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.task_id <- Some (decode_pb_task_id (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(artifact_get_query), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      v.kind <- Pbrt.Decoder.string d;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(artifact_get_query), field(2)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    task_id = v.task_id;
    kind = v.kind;
  } : artifact_get_query)

let rec decode_pb_artifact d =
  let v = default_artifact_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.art <- Some (Artmsg.decode_pb_art (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(artifact), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    art = v.art;
  } : artifact)

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

let rec encode_json_code_snippet (v:code_snippet) = 
  let assoc = [] in 
  let assoc = match v.session with
    | None -> assoc
    | Some v -> ("session", Session.encode_json_session v) :: assoc
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

let rec encode_json_parse_query (v:parse_query) = 
  let assoc = [] in 
  let assoc = ("code", Pbrt_yojson.make_string v.code) :: assoc in
  `Assoc assoc

let rec encode_json_artifact_list_query (v:artifact_list_query) = 
  let assoc = [] in 
  let assoc = match v.task_id with
    | None -> assoc
    | Some v -> ("taskId", encode_json_task_id v) :: assoc
  in
  `Assoc assoc

let rec encode_json_artifact_list_result (v:artifact_list_result) = 
  let assoc = [] in 
  let assoc =
    let l = v.kinds |> List.map Pbrt_yojson.make_string in
    ("kinds", `List l) :: assoc 
  in
  `Assoc assoc

let rec encode_json_artifact_get_query (v:artifact_get_query) = 
  let assoc = [] in 
  let assoc = match v.task_id with
    | None -> assoc
    | Some v -> ("taskId", encode_json_task_id v) :: assoc
  in
  let assoc = ("kind", Pbrt_yojson.make_string v.kind) :: assoc in
  `Assoc assoc

let rec encode_json_artifact (v:artifact) = 
  let assoc = [] in 
  let assoc = match v.art with
    | None -> assoc
    | Some v -> ("art", Artmsg.encode_json_art v) :: assoc
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

let rec decode_json_code_snippet d =
  let v = default_code_snippet_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      v.session <- Some ((Session.decode_json_session json_value))
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

let rec decode_json_parse_query d =
  let v = default_parse_query_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("code", json_value) -> 
      v.code <- Pbrt_yojson.string json_value "parse_query" "code"
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    code = v.code;
  } : parse_query)

let rec decode_json_artifact_list_query d =
  let v = default_artifact_list_query_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("taskId", json_value) -> 
      v.task_id <- Some ((decode_json_task_id json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    task_id = v.task_id;
  } : artifact_list_query)

let rec decode_json_artifact_list_result d =
  let v = default_artifact_list_result_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("kinds", `List l) -> begin
      v.kinds <- List.map (function
        | json_value -> Pbrt_yojson.string json_value "artifact_list_result" "kinds"
      ) l;
    end
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    kinds = v.kinds;
  } : artifact_list_result)

let rec decode_json_artifact_get_query d =
  let v = default_artifact_get_query_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("taskId", json_value) -> 
      v.task_id <- Some ((decode_json_task_id json_value))
    | ("kind", json_value) -> 
      v.kind <- Pbrt_yojson.string json_value "artifact_get_query" "kind"
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    task_id = v.task_id;
    kind = v.kind;
  } : artifact_get_query)

let rec decode_json_artifact d =
  let v = default_artifact_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("art", json_value) -> 
      v.art <- Some ((Artmsg.decode_json_art json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    art = v.art;
  } : artifact)

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
    open Pbrt_services
    
    let parse_term : (code_snippet, unary, artifact, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:[]
        ~service_name:"Eval" ~rpc_name:"parse_term"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_code_snippet
        ~encode_pb_req:encode_pb_code_snippet
        ~decode_json_res:decode_json_artifact
        ~decode_pb_res:decode_pb_artifact
        () : (code_snippet, unary, artifact, unary) Client.rpc)
    open Pbrt_services
    
    let parse_type : (code_snippet, unary, artifact, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:[]
        ~service_name:"Eval" ~rpc_name:"parse_type"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_code_snippet
        ~encode_pb_req:encode_pb_code_snippet
        ~decode_json_res:decode_json_artifact
        ~decode_pb_res:decode_pb_artifact
        () : (code_snippet, unary, artifact, unary) Client.rpc)
    open Pbrt_services
    
    let list_artifacts : (artifact_list_query, unary, artifact_list_result, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:[]
        ~service_name:"Eval" ~rpc_name:"list_artifacts"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_artifact_list_query
        ~encode_pb_req:encode_pb_artifact_list_query
        ~decode_json_res:decode_json_artifact_list_result
        ~decode_pb_res:decode_pb_artifact_list_result
        () : (artifact_list_query, unary, artifact_list_result, unary) Client.rpc)
    open Pbrt_services
    
    let get_artifact : (artifact_get_query, unary, artifact, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:[]
        ~service_name:"Eval" ~rpc_name:"get_artifact"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_artifact_get_query
        ~encode_pb_req:encode_pb_artifact_get_query
        ~decode_json_res:decode_json_artifact
        ~decode_pb_res:decode_pb_artifact
        () : (artifact_get_query, unary, artifact, unary) Client.rpc)
  end
  
  module Server = struct
    open Pbrt_services
    
    let eval_code_snippet : (code_snippet,unary,code_snippet_eval_result,unary) Server.rpc = 
      (Server.mk_rpc ~name:"eval_code_snippet"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_code_snippet_eval_result
        ~encode_pb_res:encode_pb_code_snippet_eval_result
        ~decode_json_req:decode_json_code_snippet
        ~decode_pb_req:decode_pb_code_snippet
        () : _ Server.rpc)
    
    let parse_term : (code_snippet,unary,artifact,unary) Server.rpc = 
      (Server.mk_rpc ~name:"parse_term"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_artifact
        ~encode_pb_res:encode_pb_artifact
        ~decode_json_req:decode_json_code_snippet
        ~decode_pb_req:decode_pb_code_snippet
        () : _ Server.rpc)
    
    let parse_type : (code_snippet,unary,artifact,unary) Server.rpc = 
      (Server.mk_rpc ~name:"parse_type"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_artifact
        ~encode_pb_res:encode_pb_artifact
        ~decode_json_req:decode_json_code_snippet
        ~decode_pb_req:decode_pb_code_snippet
        () : _ Server.rpc)
    
    let list_artifacts : (artifact_list_query,unary,artifact_list_result,unary) Server.rpc = 
      (Server.mk_rpc ~name:"list_artifacts"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_artifact_list_result
        ~encode_pb_res:encode_pb_artifact_list_result
        ~decode_json_req:decode_json_artifact_list_query
        ~decode_pb_req:decode_pb_artifact_list_query
        () : _ Server.rpc)
    
    let get_artifact : (artifact_get_query,unary,artifact,unary) Server.rpc = 
      (Server.mk_rpc ~name:"get_artifact"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_artifact
        ~encode_pb_res:encode_pb_artifact
        ~decode_json_req:decode_json_artifact_get_query
        ~decode_pb_req:decode_pb_artifact_get_query
        () : _ Server.rpc)
    
    let make
      ~eval_code_snippet:__handler__eval_code_snippet
      ~parse_term:__handler__parse_term
      ~parse_type:__handler__parse_type
      ~list_artifacts:__handler__list_artifacts
      ~get_artifact:__handler__get_artifact
      () : _ Server.t =
      { Server.
        service_name="Eval";
        package=[];
        handlers=[
           (__handler__eval_code_snippet eval_code_snippet);
           (__handler__parse_term parse_term);
           (__handler__parse_type parse_type);
           (__handler__list_artifacts list_artifacts);
           (__handler__get_artifact get_artifact);
        ];
      }
  end
  
end
