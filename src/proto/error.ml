[@@@ocaml.warning "-23-27-30-39-44"]

type error_message = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable msg : string;
  mutable locs : Locs.location list;
  mutable backtrace : string;
}

type error = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable msg : error_message option;
  mutable kind : string;
  mutable stack : error_message list;
  mutable process : string;
}

let default_error_message (): error_message =
{
  _presence=Pbrt.Bitfield.empty;
  msg="";
  locs=[];
  backtrace="";
}

let default_error (): error =
{
  _presence=Pbrt.Bitfield.empty;
  msg=None;
  kind="";
  stack=[];
  process="";
}


(** {2 Make functions} *)

let[@inline] error_message_has_msg (self:error_message) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] error_message_has_backtrace (self:error_message) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] error_message_set_msg (self:error_message) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.msg <- x
let[@inline] error_message_set_locs (self:error_message) (x:Locs.location list) : unit =
  self.locs <- x
let[@inline] error_message_set_backtrace (self:error_message) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.backtrace <- x

let copy_error_message (self:error_message) : error_message =
  { self with msg = self.msg }

let make_error_message 
  ?(msg:string option)
  ?(locs=[])
  ?(backtrace:string option)
  () : error_message  =
  let _res = default_error_message () in
  (match msg with
  | None -> ()
  | Some v -> error_message_set_msg _res v);
  error_message_set_locs _res locs;
  (match backtrace with
  | None -> ()
  | Some v -> error_message_set_backtrace _res v);
  _res

let[@inline] error_has_kind (self:error) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] error_has_process (self:error) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] error_set_msg (self:error) (x:error_message) : unit =
  self.msg <- Some x
let[@inline] error_set_kind (self:error) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.kind <- x
let[@inline] error_set_stack (self:error) (x:error_message list) : unit =
  self.stack <- x
let[@inline] error_set_process (self:error) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.process <- x

let copy_error (self:error) : error =
  { self with msg = self.msg }

let make_error 
  ?(msg:error_message option)
  ?(kind:string option)
  ?(stack=[])
  ?(process:string option)
  () : error  =
  let _res = default_error () in
  (match msg with
  | None -> ()
  | Some v -> error_set_msg _res v);
  (match kind with
  | None -> ()
  | Some v -> error_set_kind _res v);
  error_set_stack _res stack;
  (match process with
  | None -> ()
  | Some v -> error_set_process _res v);
  _res

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Formatters} *)

let rec pp_error_message fmt (v:error_message) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (error_message_has_msg v)) ~first:true "msg" Pbrt.Pp.pp_string fmt v.msg;
    Pbrt.Pp.pp_record_field ~first:false "locs" (Pbrt.Pp.pp_list Locs.pp_location) fmt v.locs;
    Pbrt.Pp.pp_record_field ~absent:(not (error_message_has_backtrace v)) ~first:false "backtrace" Pbrt.Pp.pp_string fmt v.backtrace;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_error fmt (v:error) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "msg" (Pbrt.Pp.pp_option pp_error_message) fmt v.msg;
    Pbrt.Pp.pp_record_field ~absent:(not (error_has_kind v)) ~first:false "kind" Pbrt.Pp.pp_string fmt v.kind;
    Pbrt.Pp.pp_record_field ~first:false "stack" (Pbrt.Pp.pp_list pp_error_message) fmt v.stack;
    Pbrt.Pp.pp_record_field ~absent:(not (error_has_process v)) ~first:false "process" Pbrt.Pp.pp_string fmt v.process;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_error_message (v:error_message) encoder = 
  if error_message_has_msg v then (
    Pbrt.Encoder.string v.msg encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
  Pbrt.List_util.rev_iter_with (fun x encoder ->
    Pbrt.Encoder.nested Locs.encode_pb_location x encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  ) v.locs encoder;
  if error_message_has_backtrace v then (
    Pbrt.Encoder.string v.backtrace encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  );
  ()

let rec encode_pb_error (v:error) encoder = 
  begin match v.msg with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_error_message x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  if error_has_kind v then (
    Pbrt.Encoder.string v.kind encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  Pbrt.List_util.rev_iter_with (fun x encoder ->
    Pbrt.Encoder.nested encode_pb_error_message x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  ) v.stack encoder;
  if error_has_process v then (
    Pbrt.Encoder.string v.process encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  );
  ()

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_error_message d =
  let v = default_error_message () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      (* put lists in the correct order *)
      error_message_set_locs v (List.rev v.locs);
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      error_message_set_msg v (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "error_message" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      error_message_set_locs v ((Locs.decode_pb_location (Pbrt.Decoder.nested d)) :: v.locs);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "error_message" 2 pk
    | Some (3, Pbrt.Bytes) -> begin
      error_message_set_backtrace v (Pbrt.Decoder.string d);
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "error_message" 3 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : error_message)

let rec decode_pb_error d =
  let v = default_error () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      (* put lists in the correct order *)
      error_set_stack v (List.rev v.stack);
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      error_set_msg v (decode_pb_error_message (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "error" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      error_set_kind v (Pbrt.Decoder.string d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "error" 2 pk
    | Some (3, Pbrt.Bytes) -> begin
      error_set_stack v ((decode_pb_error_message (Pbrt.Decoder.nested d)) :: v.stack);
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "error" 3 pk
    | Some (4, Pbrt.Bytes) -> begin
      error_set_process v (Pbrt.Decoder.string d);
    end
    | Some (4, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "error" 4 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : error)

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_error_message (v:error_message) = 
  let assoc = ref [] in
  if error_message_has_msg v then (
    assoc := ("msg", Pbrt_yojson.make_string v.msg) :: !assoc;
  );
  assoc := (
    let l = v.locs |> List.map Locs.encode_json_location in
    ("locs", `List l) :: !assoc 
  );
  if error_message_has_backtrace v then (
    assoc := ("backtrace", Pbrt_yojson.make_string v.backtrace) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_error (v:error) = 
  let assoc = ref [] in
  assoc := (match v.msg with
    | None -> !assoc
    | Some v -> ("msg", encode_json_error_message v) :: !assoc);
  if error_has_kind v then (
    assoc := ("kind", Pbrt_yojson.make_string v.kind) :: !assoc;
  );
  assoc := (
    let l = v.stack |> List.map encode_json_error_message in
    ("stack", `List l) :: !assoc 
  );
  if error_has_process v then (
    assoc := ("process", Pbrt_yojson.make_string v.process) :: !assoc;
  );
  `Assoc !assoc

[@@@ocaml.warning "-23-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_error_message d =
  let v = default_error_message () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("msg", json_value) -> 
      error_message_set_msg v (Pbrt_yojson.string json_value "error_message" "msg")
    | ("locs", `List l) -> begin
      error_message_set_locs v @@ List.map (function
        | json_value -> (Locs.decode_json_location json_value)
      ) l;
    end
    | ("backtrace", json_value) -> 
      error_message_set_backtrace v (Pbrt_yojson.string json_value "error_message" "backtrace")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    msg = v.msg;
    locs = v.locs;
    backtrace = v.backtrace;
  } : error_message)

let rec decode_json_error d =
  let v = default_error () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("msg", json_value) -> 
      error_set_msg v (decode_json_error_message json_value)
    | ("kind", json_value) -> 
      error_set_kind v (Pbrt_yojson.string json_value "error" "kind")
    | ("stack", `List l) -> begin
      error_set_stack v @@ List.map (function
        | json_value -> (decode_json_error_message json_value)
      ) l;
    end
    | ("process", json_value) -> 
      error_set_process v (Pbrt_yojson.string json_value "error" "process")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    msg = v.msg;
    kind = v.kind;
    stack = v.stack;
    process = v.process;
  } : error)
