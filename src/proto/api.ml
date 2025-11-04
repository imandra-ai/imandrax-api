[@@@ocaml.warning "-23-27-30-39-44"]

type code_snippet = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable session : Session.session option;
  mutable code : string;
}

type eval_result =
  | Eval_ok 
  | Eval_errors 

type code_snippet_eval_result = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable res : eval_result;
  mutable duration_s : float;
  mutable tasks : Task.task list;
  mutable errors : Error.error list;
}

type parse_query = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable code : string;
}

type artifact_list_query = {
  mutable task_id : Task.task_id option;
}

type artifact_list_result = {
  mutable kinds : string list;
}

type artifact_get_query = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable task_id : Task.task_id option;
  mutable kind : string;
}

type artifact = {
  mutable art : Artmsg.art option;
}

type artifact_zip = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable art_zip : bytes;
}

let default_code_snippet (): code_snippet =
{
  _presence=Pbrt.Bitfield.empty;
  session=None;
  code="";
}

let default_eval_result () = (Eval_ok:eval_result)

let default_code_snippet_eval_result (): code_snippet_eval_result =
{
  _presence=Pbrt.Bitfield.empty;
  res=default_eval_result ();
  duration_s=0.;
  tasks=[];
  errors=[];
}

let default_parse_query (): parse_query =
{
  _presence=Pbrt.Bitfield.empty;
  code="";
}

let default_artifact_list_query (): artifact_list_query =
{
  task_id=None;
}

let default_artifact_list_result (): artifact_list_result =
{
  kinds=[];
}

let default_artifact_get_query (): artifact_get_query =
{
  _presence=Pbrt.Bitfield.empty;
  task_id=None;
  kind="";
}

let default_artifact (): artifact =
{
  art=None;
}

let default_artifact_zip (): artifact_zip =
{
  _presence=Pbrt.Bitfield.empty;
  art_zip=Bytes.create 0;
}


(** {2 Make functions} *)

let[@inline] code_snippet_has_code (self:code_snippet) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] code_snippet_set_session (self:code_snippet) (x:Session.session) : unit =
  self.session <- Some x
let[@inline] code_snippet_set_code (self:code_snippet) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.code <- x

let copy_code_snippet (self:code_snippet) : code_snippet =
  { self with session = self.session }

let make_code_snippet 
  ?(session:Session.session option)
  ?(code:string option)
  () : code_snippet  =
  let _res = default_code_snippet () in
  (match session with
  | None -> ()
  | Some v -> code_snippet_set_session _res v);
  (match code with
  | None -> ()
  | Some v -> code_snippet_set_code _res v);
  _res

let[@inline] code_snippet_eval_result_has_res (self:code_snippet_eval_result) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] code_snippet_eval_result_has_duration_s (self:code_snippet_eval_result) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] code_snippet_eval_result_set_res (self:code_snippet_eval_result) (x:eval_result) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.res <- x
let[@inline] code_snippet_eval_result_set_duration_s (self:code_snippet_eval_result) (x:float) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.duration_s <- x
let[@inline] code_snippet_eval_result_set_tasks (self:code_snippet_eval_result) (x:Task.task list) : unit =
  self.tasks <- x
let[@inline] code_snippet_eval_result_set_errors (self:code_snippet_eval_result) (x:Error.error list) : unit =
  self.errors <- x

let copy_code_snippet_eval_result (self:code_snippet_eval_result) : code_snippet_eval_result =
  { self with res = self.res }

let make_code_snippet_eval_result 
  ?(res:eval_result option)
  ?(duration_s:float option)
  ?(tasks=[])
  ?(errors=[])
  () : code_snippet_eval_result  =
  let _res = default_code_snippet_eval_result () in
  (match res with
  | None -> ()
  | Some v -> code_snippet_eval_result_set_res _res v);
  (match duration_s with
  | None -> ()
  | Some v -> code_snippet_eval_result_set_duration_s _res v);
  code_snippet_eval_result_set_tasks _res tasks;
  code_snippet_eval_result_set_errors _res errors;
  _res

let[@inline] parse_query_has_code (self:parse_query) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] parse_query_set_code (self:parse_query) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.code <- x

let copy_parse_query (self:parse_query) : parse_query =
  { self with code = self.code }

let make_parse_query 
  ?(code:string option)
  () : parse_query  =
  let _res = default_parse_query () in
  (match code with
  | None -> ()
  | Some v -> parse_query_set_code _res v);
  _res


let[@inline] artifact_list_query_set_task_id (self:artifact_list_query) (x:Task.task_id) : unit =
  self.task_id <- Some x

let copy_artifact_list_query (self:artifact_list_query) : artifact_list_query =
  { self with task_id = self.task_id }

let make_artifact_list_query 
  ?(task_id:Task.task_id option)
  () : artifact_list_query  =
  let _res = default_artifact_list_query () in
  (match task_id with
  | None -> ()
  | Some v -> artifact_list_query_set_task_id _res v);
  _res


let[@inline] artifact_list_result_set_kinds (self:artifact_list_result) (x:string list) : unit =
  self.kinds <- x

let copy_artifact_list_result (self:artifact_list_result) : artifact_list_result =
  { self with kinds = self.kinds }

let make_artifact_list_result 
  ?(kinds=[])
  () : artifact_list_result  =
  let _res = default_artifact_list_result () in
  artifact_list_result_set_kinds _res kinds;
  _res

let[@inline] artifact_get_query_has_kind (self:artifact_get_query) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] artifact_get_query_set_task_id (self:artifact_get_query) (x:Task.task_id) : unit =
  self.task_id <- Some x
let[@inline] artifact_get_query_set_kind (self:artifact_get_query) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.kind <- x

let copy_artifact_get_query (self:artifact_get_query) : artifact_get_query =
  { self with task_id = self.task_id }

let make_artifact_get_query 
  ?(task_id:Task.task_id option)
  ?(kind:string option)
  () : artifact_get_query  =
  let _res = default_artifact_get_query () in
  (match task_id with
  | None -> ()
  | Some v -> artifact_get_query_set_task_id _res v);
  (match kind with
  | None -> ()
  | Some v -> artifact_get_query_set_kind _res v);
  _res


let[@inline] artifact_set_art (self:artifact) (x:Artmsg.art) : unit =
  self.art <- Some x

let copy_artifact (self:artifact) : artifact =
  { self with art = self.art }

let make_artifact 
  ?(art:Artmsg.art option)
  () : artifact  =
  let _res = default_artifact () in
  (match art with
  | None -> ()
  | Some v -> artifact_set_art _res v);
  _res

let[@inline] artifact_zip_has_art_zip (self:artifact_zip) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] artifact_zip_set_art_zip (self:artifact_zip) (x:bytes) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.art_zip <- x

let copy_artifact_zip (self:artifact_zip) : artifact_zip =
  { self with art_zip = self.art_zip }

let make_artifact_zip 
  ?(art_zip:bytes option)
  () : artifact_zip  =
  let _res = default_artifact_zip () in
  (match art_zip with
  | None -> ()
  | Some v -> artifact_zip_set_art_zip _res v);
  _res

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Formatters} *)

let rec pp_code_snippet fmt (v:code_snippet) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "session" (Pbrt.Pp.pp_option Session.pp_session) fmt v.session;
    Pbrt.Pp.pp_record_field ~absent:(not (code_snippet_has_code v)) ~first:false "code" Pbrt.Pp.pp_string fmt v.code;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_eval_result fmt (v:eval_result) =
  match v with
  | Eval_ok -> Format.fprintf fmt "Eval_ok"
  | Eval_errors -> Format.fprintf fmt "Eval_errors"

let rec pp_code_snippet_eval_result fmt (v:code_snippet_eval_result) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (code_snippet_eval_result_has_res v)) ~first:true "res" pp_eval_result fmt v.res;
    Pbrt.Pp.pp_record_field ~absent:(not (code_snippet_eval_result_has_duration_s v)) ~first:false "duration_s" Pbrt.Pp.pp_float fmt v.duration_s;
    Pbrt.Pp.pp_record_field ~first:false "tasks" (Pbrt.Pp.pp_list Task.pp_task) fmt v.tasks;
    Pbrt.Pp.pp_record_field ~first:false "errors" (Pbrt.Pp.pp_list Error.pp_error) fmt v.errors;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_parse_query fmt (v:parse_query) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (parse_query_has_code v)) ~first:true "code" Pbrt.Pp.pp_string fmt v.code;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_artifact_list_query fmt (v:artifact_list_query) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "task_id" (Pbrt.Pp.pp_option Task.pp_task_id) fmt v.task_id;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_artifact_list_result fmt (v:artifact_list_result) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "kinds" (Pbrt.Pp.pp_list Pbrt.Pp.pp_string) fmt v.kinds;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_artifact_get_query fmt (v:artifact_get_query) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "task_id" (Pbrt.Pp.pp_option Task.pp_task_id) fmt v.task_id;
    Pbrt.Pp.pp_record_field ~absent:(not (artifact_get_query_has_kind v)) ~first:false "kind" Pbrt.Pp.pp_string fmt v.kind;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_artifact fmt (v:artifact) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "art" (Pbrt.Pp.pp_option Artmsg.pp_art) fmt v.art;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_artifact_zip fmt (v:artifact_zip) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (artifact_zip_has_art_zip v)) ~first:true "art_zip" Pbrt.Pp.pp_bytes fmt v.art_zip;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_code_snippet (v:code_snippet) encoder = 
  begin match v.session with
  | Some x -> 
    Pbrt.Encoder.nested Session.encode_pb_session x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  if code_snippet_has_code v then (
    Pbrt.Encoder.string v.code encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  ()

let rec encode_pb_eval_result (v:eval_result) encoder =
  match v with
  | Eval_ok -> Pbrt.Encoder.int_as_varint (0) encoder
  | Eval_errors -> Pbrt.Encoder.int_as_varint 1 encoder

let rec encode_pb_code_snippet_eval_result (v:code_snippet_eval_result) encoder = 
  if code_snippet_eval_result_has_res v then (
    encode_pb_eval_result v.res encoder;
    Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  );
  if code_snippet_eval_result_has_duration_s v then (
    Pbrt.Encoder.float_as_bits32 v.duration_s encoder;
    Pbrt.Encoder.key 3 Pbrt.Bits32 encoder; 
  );
  Pbrt.List_util.rev_iter_with (fun x encoder ->
    Pbrt.Encoder.nested Task.encode_pb_task x encoder;
    Pbrt.Encoder.key 9 Pbrt.Bytes encoder; 
  ) v.tasks encoder;
  Pbrt.List_util.rev_iter_with (fun x encoder ->
    Pbrt.Encoder.nested Error.encode_pb_error x encoder;
    Pbrt.Encoder.key 10 Pbrt.Bytes encoder; 
  ) v.errors encoder;
  ()

let rec encode_pb_parse_query (v:parse_query) encoder = 
  if parse_query_has_code v then (
    Pbrt.Encoder.string v.code encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
  ()

let rec encode_pb_artifact_list_query (v:artifact_list_query) encoder = 
  begin match v.task_id with
  | Some x -> 
    Pbrt.Encoder.nested Task.encode_pb_task_id x encoder;
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
    Pbrt.Encoder.nested Task.encode_pb_task_id x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  if artifact_get_query_has_kind v then (
    Pbrt.Encoder.string v.kind encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  ()

let rec encode_pb_artifact (v:artifact) encoder = 
  begin match v.art with
  | Some x -> 
    Pbrt.Encoder.nested Artmsg.encode_pb_art x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  ()

let rec encode_pb_artifact_zip (v:artifact_zip) encoder = 
  if artifact_zip_has_art_zip v then (
    Pbrt.Encoder.bytes v.art_zip encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
  ()

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_code_snippet d =
  let v = default_code_snippet () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      code_snippet_set_session v (Session.decode_pb_session (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "code_snippet" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      code_snippet_set_code v (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "code_snippet" 2 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : code_snippet)

let rec decode_pb_eval_result d : eval_result = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> Eval_ok
  | 1 -> Eval_errors
  | _ -> Pbrt.Decoder.malformed_variant "eval_result"

let rec decode_pb_code_snippet_eval_result d =
  let v = default_code_snippet_eval_result () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      (* put lists in the correct order *)
      code_snippet_eval_result_set_errors v (List.rev v.errors);
      code_snippet_eval_result_set_tasks v (List.rev v.tasks);
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      code_snippet_eval_result_set_res v (decode_pb_eval_result d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "code_snippet_eval_result" 1 pk
    | Some (3, Pbrt.Bits32) -> begin
      code_snippet_eval_result_set_duration_s v (Pbrt.Decoder.float_as_bits32 d);
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "code_snippet_eval_result" 3 pk
    | Some (9, Pbrt.Bytes) -> begin
      code_snippet_eval_result_set_tasks v ((Task.decode_pb_task (Pbrt.Decoder.nested d)) :: v.tasks);
    end
    | Some (9, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "code_snippet_eval_result" 9 pk
    | Some (10, Pbrt.Bytes) -> begin
      code_snippet_eval_result_set_errors v ((Error.decode_pb_error (Pbrt.Decoder.nested d)) :: v.errors);
    end
    | Some (10, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "code_snippet_eval_result" 10 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : code_snippet_eval_result)

let rec decode_pb_parse_query d =
  let v = default_parse_query () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      parse_query_set_code v (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "parse_query" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : parse_query)

let rec decode_pb_artifact_list_query d =
  let v = default_artifact_list_query () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      artifact_list_query_set_task_id v (Task.decode_pb_task_id (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "artifact_list_query" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : artifact_list_query)

let rec decode_pb_artifact_list_result d =
  let v = default_artifact_list_result () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      (* put lists in the correct order *)
      artifact_list_result_set_kinds v (List.rev v.kinds);
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      artifact_list_result_set_kinds v ((Pbrt.Decoder.string d) :: v.kinds);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "artifact_list_result" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : artifact_list_result)

let rec decode_pb_artifact_get_query d =
  let v = default_artifact_get_query () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      artifact_get_query_set_task_id v (Task.decode_pb_task_id (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "artifact_get_query" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      artifact_get_query_set_kind v (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "artifact_get_query" 2 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : artifact_get_query)

let rec decode_pb_artifact d =
  let v = default_artifact () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      artifact_set_art v (Artmsg.decode_pb_art (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "artifact" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : artifact)

let rec decode_pb_artifact_zip d =
  let v = default_artifact_zip () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      artifact_zip_set_art_zip v (Pbrt.Decoder.bytes d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "artifact_zip" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : artifact_zip)

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_code_snippet (v:code_snippet) = 
  let assoc = ref [] in
  assoc := (match v.session with
    | None -> !assoc
    | Some v -> ("session", Session.encode_json_session v) :: !assoc);
  if code_snippet_has_code v then (
    assoc := ("code", Pbrt_yojson.make_string v.code) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_eval_result (v:eval_result) = 
  match v with
  | Eval_ok -> `String "EVAL_OK"
  | Eval_errors -> `String "EVAL_ERRORS"

let rec encode_json_code_snippet_eval_result (v:code_snippet_eval_result) = 
  let assoc = ref [] in
  if code_snippet_eval_result_has_res v then (
    assoc := ("res", encode_json_eval_result v.res) :: !assoc;
  );
  if code_snippet_eval_result_has_duration_s v then (
    assoc := ("durationS", Pbrt_yojson.make_float v.duration_s) :: !assoc;
  );
  assoc := (
    let l = v.tasks |> List.map Task.encode_json_task in
    ("tasks", `List l) :: !assoc 
  );
  assoc := (
    let l = v.errors |> List.map Error.encode_json_error in
    ("errors", `List l) :: !assoc 
  );
  `Assoc !assoc

let rec encode_json_parse_query (v:parse_query) = 
  let assoc = ref [] in
  if parse_query_has_code v then (
    assoc := ("code", Pbrt_yojson.make_string v.code) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_artifact_list_query (v:artifact_list_query) = 
  let assoc = ref [] in
  assoc := (match v.task_id with
    | None -> !assoc
    | Some v -> ("taskId", Task.encode_json_task_id v) :: !assoc);
  `Assoc !assoc

let rec encode_json_artifact_list_result (v:artifact_list_result) = 
  let assoc = ref [] in
  assoc := (
    let l = v.kinds |> List.map Pbrt_yojson.make_string in
    ("kinds", `List l) :: !assoc 
  );
  `Assoc !assoc

let rec encode_json_artifact_get_query (v:artifact_get_query) = 
  let assoc = ref [] in
  assoc := (match v.task_id with
    | None -> !assoc
    | Some v -> ("taskId", Task.encode_json_task_id v) :: !assoc);
  if artifact_get_query_has_kind v then (
    assoc := ("kind", Pbrt_yojson.make_string v.kind) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_artifact (v:artifact) = 
  let assoc = ref [] in
  assoc := (match v.art with
    | None -> !assoc
    | Some v -> ("art", Artmsg.encode_json_art v) :: !assoc);
  `Assoc !assoc

let rec encode_json_artifact_zip (v:artifact_zip) = 
  let assoc = ref [] in
  if artifact_zip_has_art_zip v then (
    assoc := ("artZip", Pbrt_yojson.make_bytes v.art_zip) :: !assoc;
  );
  `Assoc !assoc

[@@@ocaml.warning "-23-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_code_snippet d =
  let v = default_code_snippet () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("session", json_value) -> 
      code_snippet_set_session v (Session.decode_json_session json_value)
    | ("code", json_value) -> 
      code_snippet_set_code v (Pbrt_yojson.string json_value "code_snippet" "code")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    session = v.session;
    code = v.code;
  } : code_snippet)

let rec decode_json_eval_result json =
  match json with
  | `String "EVAL_OK" -> (Eval_ok : eval_result)
  | `String "EVAL_ERRORS" -> (Eval_errors : eval_result)
  | _ -> Pbrt_yojson.E.malformed_variant "eval_result"

let rec decode_json_code_snippet_eval_result d =
  let v = default_code_snippet_eval_result () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("res", json_value) -> 
      code_snippet_eval_result_set_res v ((decode_json_eval_result json_value))
    | ("durationS", json_value) -> 
      code_snippet_eval_result_set_duration_s v (Pbrt_yojson.float json_value "code_snippet_eval_result" "duration_s")
    | ("tasks", `List l) -> begin
      code_snippet_eval_result_set_tasks v @@ List.map (function
        | json_value -> (Task.decode_json_task json_value)
      ) l;
    end
    | ("errors", `List l) -> begin
      code_snippet_eval_result_set_errors v @@ List.map (function
        | json_value -> (Error.decode_json_error json_value)
      ) l;
    end
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    res = v.res;
    duration_s = v.duration_s;
    tasks = v.tasks;
    errors = v.errors;
  } : code_snippet_eval_result)

let rec decode_json_parse_query d =
  let v = default_parse_query () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("code", json_value) -> 
      parse_query_set_code v (Pbrt_yojson.string json_value "parse_query" "code")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    code = v.code;
  } : parse_query)

let rec decode_json_artifact_list_query d =
  let v = default_artifact_list_query () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("taskId", json_value) -> 
      artifact_list_query_set_task_id v (Task.decode_json_task_id json_value)
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    task_id = v.task_id;
  } : artifact_list_query)

let rec decode_json_artifact_list_result d =
  let v = default_artifact_list_result () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("kinds", `List l) -> begin
      artifact_list_result_set_kinds v @@ List.map (function
        | json_value -> Pbrt_yojson.string json_value "artifact_list_result" "kinds"
      ) l;
    end
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    kinds = v.kinds;
  } : artifact_list_result)

let rec decode_json_artifact_get_query d =
  let v = default_artifact_get_query () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("taskId", json_value) -> 
      artifact_get_query_set_task_id v (Task.decode_json_task_id json_value)
    | ("kind", json_value) -> 
      artifact_get_query_set_kind v (Pbrt_yojson.string json_value "artifact_get_query" "kind")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    task_id = v.task_id;
    kind = v.kind;
  } : artifact_get_query)

let rec decode_json_artifact d =
  let v = default_artifact () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("art", json_value) -> 
      artifact_set_art v (Artmsg.decode_json_art json_value)
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    art = v.art;
  } : artifact)

let rec decode_json_artifact_zip d =
  let v = default_artifact_zip () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("artZip", json_value) -> 
      artifact_zip_set_art_zip v (Pbrt_yojson.bytes json_value "artifact_zip" "art_zip")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    art_zip = v.art_zip;
  } : artifact_zip)

module Eval = struct
  open Pbrt_services.Value_mode
  module Client = struct
    open Pbrt_services
    
    let eval_code_snippet : (code_snippet, unary, code_snippet_eval_result, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"api"]
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
        ~package:["imandrax";"api"]
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
        ~package:["imandrax";"api"]
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
        ~package:["imandrax";"api"]
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
        ~package:["imandrax";"api"]
        ~service_name:"Eval" ~rpc_name:"get_artifact"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_artifact_get_query
        ~encode_pb_req:encode_pb_artifact_get_query
        ~decode_json_res:decode_json_artifact
        ~decode_pb_res:decode_pb_artifact
        () : (artifact_get_query, unary, artifact, unary) Client.rpc)
    open Pbrt_services
    
    let get_artifact_zip : (artifact_get_query, unary, artifact_zip, unary) Client.rpc =
      (Client.mk_rpc 
        ~package:["imandrax";"api"]
        ~service_name:"Eval" ~rpc_name:"get_artifact_zip"
        ~req_mode:Client.Unary
        ~res_mode:Client.Unary
        ~encode_json_req:encode_json_artifact_get_query
        ~encode_pb_req:encode_pb_artifact_get_query
        ~decode_json_res:decode_json_artifact_zip
        ~decode_pb_res:decode_pb_artifact_zip
        () : (artifact_get_query, unary, artifact_zip, unary) Client.rpc)
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
    
    let get_artifact_zip : (artifact_get_query,unary,artifact_zip,unary) Server.rpc = 
      (Server.mk_rpc ~name:"get_artifact_zip"
        ~req_mode:Server.Unary
        ~res_mode:Server.Unary
        ~encode_json_res:encode_json_artifact_zip
        ~encode_pb_res:encode_pb_artifact_zip
        ~decode_json_req:decode_json_artifact_get_query
        ~decode_pb_req:decode_pb_artifact_get_query
        () : _ Server.rpc)
    
    let make
      ~eval_code_snippet:__handler__eval_code_snippet
      ~parse_term:__handler__parse_term
      ~parse_type:__handler__parse_type
      ~list_artifacts:__handler__list_artifacts
      ~get_artifact:__handler__get_artifact
      ~get_artifact_zip:__handler__get_artifact_zip
      () : _ Server.t =
      { Server.
        service_name="Eval";
        package=["imandrax";"api"];
        handlers=[
           (__handler__eval_code_snippet eval_code_snippet);
           (__handler__parse_term parse_term);
           (__handler__parse_type parse_type);
           (__handler__list_artifacts list_artifacts);
           (__handler__get_artifact get_artifact);
           (__handler__get_artifact_zip get_artifact_zip);
        ];
      }
  end
  
end
