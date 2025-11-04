[@@@ocaml.warning "-23-27-30-39-44"]

type task_kind =
  | Task_unspecified 
  | Task_eval 
  | Task_check_po 
  | Task_proof_check 
  | Task_decomp 

type task_id = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable id : string;
}

type task = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable id : task_id option;
  mutable kind : task_kind;
}

type origin = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable from_sym : string;
  mutable count : int32;
}

let default_task_kind () = (Task_unspecified:task_kind)

let default_task_id (): task_id =
{
  _presence=Pbrt.Bitfield.empty;
  id="";
}

let default_task (): task =
{
  _presence=Pbrt.Bitfield.empty;
  id=None;
  kind=default_task_kind ();
}

let default_origin (): origin =
{
  _presence=Pbrt.Bitfield.empty;
  from_sym="";
  count=0l;
}


(** {2 Make functions} *)

let[@inline] task_id_has_id (self:task_id) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] task_id_set_id (self:task_id) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.id <- x

let copy_task_id (self:task_id) : task_id =
  { self with id = self.id }

let make_task_id 
  ?(id:string option)
  () : task_id  =
  let _res = default_task_id () in
  (match id with
  | None -> ()
  | Some v -> task_id_set_id _res v);
  _res

let[@inline] task_has_kind (self:task) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] task_set_id (self:task) (x:task_id) : unit =
  self.id <- Some x
let[@inline] task_set_kind (self:task) (x:task_kind) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.kind <- x

let copy_task (self:task) : task =
  { self with id = self.id }

let make_task 
  ?(id:task_id option)
  ?(kind:task_kind option)
  () : task  =
  let _res = default_task () in
  (match id with
  | None -> ()
  | Some v -> task_set_id _res v);
  (match kind with
  | None -> ()
  | Some v -> task_set_kind _res v);
  _res

let[@inline] origin_has_from_sym (self:origin) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] origin_has_count (self:origin) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] origin_set_from_sym (self:origin) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.from_sym <- x
let[@inline] origin_set_count (self:origin) (x:int32) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.count <- x

let copy_origin (self:origin) : origin =
  { self with from_sym = self.from_sym }

let make_origin 
  ?(from_sym:string option)
  ?(count:int32 option)
  () : origin  =
  let _res = default_origin () in
  (match from_sym with
  | None -> ()
  | Some v -> origin_set_from_sym _res v);
  (match count with
  | None -> ()
  | Some v -> origin_set_count _res v);
  _res

[@@@ocaml.warning "-23-27-30-39"]

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
    Pbrt.Pp.pp_record_field ~absent:(not (task_id_has_id v)) ~first:true "id" Pbrt.Pp.pp_string fmt v.id;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_task fmt (v:task) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "id" (Pbrt.Pp.pp_option pp_task_id) fmt v.id;
    Pbrt.Pp.pp_record_field ~absent:(not (task_has_kind v)) ~first:false "kind" pp_task_kind fmt v.kind;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_origin fmt (v:origin) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (origin_has_from_sym v)) ~first:true "from_sym" Pbrt.Pp.pp_string fmt v.from_sym;
    Pbrt.Pp.pp_record_field ~absent:(not (origin_has_count v)) ~first:false "count" Pbrt.Pp.pp_int32 fmt v.count;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_task_kind (v:task_kind) encoder =
  match v with
  | Task_unspecified -> Pbrt.Encoder.int_as_varint (0) encoder
  | Task_eval -> Pbrt.Encoder.int_as_varint 1 encoder
  | Task_check_po -> Pbrt.Encoder.int_as_varint 2 encoder
  | Task_proof_check -> Pbrt.Encoder.int_as_varint 3 encoder
  | Task_decomp -> Pbrt.Encoder.int_as_varint 4 encoder

let rec encode_pb_task_id (v:task_id) encoder = 
  if task_id_has_id v then (
    Pbrt.Encoder.string v.id encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
  ()

let rec encode_pb_task (v:task) encoder = 
  begin match v.id with
  | Some x -> 
    Pbrt.Encoder.nested encode_pb_task_id x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  | None -> ();
  end;
  if task_has_kind v then (
    encode_pb_task_kind v.kind encoder;
    Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  );
  ()

let rec encode_pb_origin (v:origin) encoder = 
  if origin_has_from_sym v then (
    Pbrt.Encoder.string v.from_sym encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
  if origin_has_count v then (
    Pbrt.Encoder.int32_as_varint v.count encoder;
    Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  );
  ()

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_task_kind d : task_kind = 
  match Pbrt.Decoder.int_as_varint d with
  | 0 -> Task_unspecified
  | 1 -> Task_eval
  | 2 -> Task_check_po
  | 3 -> Task_proof_check
  | 4 -> Task_decomp
  | _ -> Pbrt.Decoder.malformed_variant "task_kind"

let rec decode_pb_task_id d =
  let v = default_task_id () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      task_id_set_id v (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "task_id" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : task_id)

let rec decode_pb_task d =
  let v = default_task () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      task_set_id v (decode_pb_task_id (Pbrt.Decoder.nested d));
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "task" 1 pk
    | Some (2, Pbrt.Varint) -> begin
      task_set_kind v (decode_pb_task_kind d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "task" 2 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : task)

let rec decode_pb_origin d =
  let v = default_origin () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      origin_set_from_sym v (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "origin" 1 pk
    | Some (2, Pbrt.Varint) -> begin
      origin_set_count v (Pbrt.Decoder.int32_as_varint d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "origin" 2 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : origin)

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_task_kind (v:task_kind) = 
  match v with
  | Task_unspecified -> `String "TASK_UNSPECIFIED"
  | Task_eval -> `String "TASK_EVAL"
  | Task_check_po -> `String "TASK_CHECK_PO"
  | Task_proof_check -> `String "TASK_PROOF_CHECK"
  | Task_decomp -> `String "TASK_DECOMP"

let rec encode_json_task_id (v:task_id) = 
  let assoc = ref [] in
  if task_id_has_id v then (
    assoc := ("id", Pbrt_yojson.make_string v.id) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_task (v:task) = 
  let assoc = ref [] in
  assoc := (match v.id with
    | None -> !assoc
    | Some v -> ("id", encode_json_task_id v) :: !assoc);
  if task_has_kind v then (
    assoc := ("kind", encode_json_task_kind v.kind) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_origin (v:origin) = 
  let assoc = ref [] in
  if origin_has_from_sym v then (
    assoc := ("fromSym", Pbrt_yojson.make_string v.from_sym) :: !assoc;
  );
  if origin_has_count v then (
    assoc := ("count", Pbrt_yojson.make_int (Int32.to_int v.count)) :: !assoc;
  );
  `Assoc !assoc

[@@@ocaml.warning "-23-27-30-39"]

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
  let v = default_task_id () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("id", json_value) -> 
      task_id_set_id v (Pbrt_yojson.string json_value "task_id" "id")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    id = v.id;
  } : task_id)

let rec decode_json_task d =
  let v = default_task () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("id", json_value) -> 
      task_set_id v (decode_json_task_id json_value)
    | ("kind", json_value) -> 
      task_set_kind v ((decode_json_task_kind json_value))
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    id = v.id;
    kind = v.kind;
  } : task)

let rec decode_json_origin d =
  let v = default_origin () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("fromSym", json_value) -> 
      origin_set_from_sym v (Pbrt_yojson.string json_value "origin" "from_sym")
    | ("count", json_value) -> 
      origin_set_count v (Pbrt_yojson.int32 json_value "origin" "count")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    from_sym = v.from_sym;
    count = v.count;
  } : origin)
