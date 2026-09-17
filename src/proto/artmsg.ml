[@@@ocaml.warning "-23-27-30-39-44"]

type storage_entry = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable key : string;
  mutable value : bytes;
}

type artifact = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 3 fields *)
  mutable kind : string;
  mutable data : bytes;
  mutable api_version : string;
  mutable storage : storage_entry list;
}

let default_storage_entry (): storage_entry =
{
  _presence=Pbrt.Bitfield.empty;
  key="";
  value=Bytes.create 0;
}

let default_artifact (): artifact =
{
  _presence=Pbrt.Bitfield.empty;
  kind="";
  data=Bytes.create 0;
  api_version="";
  storage=[];
}


(** {2 Make functions} *)

let[@inline] storage_entry_has_key (self:storage_entry) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] storage_entry_has_value (self:storage_entry) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] storage_entry_set_key (self:storage_entry) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.key <- x
let[@inline] storage_entry_set_value (self:storage_entry) (x:bytes) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.value <- x

let copy_storage_entry (self:storage_entry) : storage_entry =
  { self with key = self.key }

let make_storage_entry 
  ?(key:string option)
  ?(value:bytes option)
  () : storage_entry  =
  let _res = default_storage_entry () in
  (match key with
  | None -> ()
  | Some v -> storage_entry_set_key _res v);
  (match value with
  | None -> ()
  | Some v -> storage_entry_set_value _res v);
  _res

let[@inline] artifact_has_kind (self:artifact) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] artifact_has_data (self:artifact) : bool = (Pbrt.Bitfield.get self._presence 1)
let[@inline] artifact_has_api_version (self:artifact) : bool = (Pbrt.Bitfield.get self._presence 2)

let[@inline] artifact_set_kind (self:artifact) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.kind <- x
let[@inline] artifact_set_data (self:artifact) (x:bytes) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.data <- x
let[@inline] artifact_set_api_version (self:artifact) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 2); self.api_version <- x
let[@inline] artifact_set_storage (self:artifact) (x:storage_entry list) : unit =
  self.storage <- x

let copy_artifact (self:artifact) : artifact =
  { self with kind = self.kind }

let make_artifact 
  ?(kind:string option)
  ?(data:bytes option)
  ?(api_version:string option)
  ?(storage=[])
  () : artifact  =
  let _res = default_artifact () in
  (match kind with
  | None -> ()
  | Some v -> artifact_set_kind _res v);
  (match data with
  | None -> ()
  | Some v -> artifact_set_data _res v);
  (match api_version with
  | None -> ()
  | Some v -> artifact_set_api_version _res v);
  artifact_set_storage _res storage;
  _res

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Formatters} *)

let rec pp_storage_entry fmt (v:storage_entry) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (storage_entry_has_key v)) ~first:true "key" Pbrt.Pp.pp_string fmt v.key;
    Pbrt.Pp.pp_record_field ~absent:(not (storage_entry_has_value v)) ~first:false "value" Pbrt.Pp.pp_bytes fmt v.value;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_artifact fmt (v:artifact) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (artifact_has_kind v)) ~first:true "kind" Pbrt.Pp.pp_string fmt v.kind;
    Pbrt.Pp.pp_record_field ~absent:(not (artifact_has_data v)) ~first:false "data" Pbrt.Pp.pp_bytes fmt v.data;
    Pbrt.Pp.pp_record_field ~absent:(not (artifact_has_api_version v)) ~first:false "api_version" Pbrt.Pp.pp_string fmt v.api_version;
    Pbrt.Pp.pp_record_field ~first:false "storage" (Pbrt.Pp.pp_list pp_storage_entry) fmt v.storage;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_storage_entry (v:storage_entry) encoder = 
  if storage_entry_has_key v then (
    Pbrt.Encoder.string v.key encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
  if storage_entry_has_value v then (
    Pbrt.Encoder.bytes v.value encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  ()

let rec encode_pb_artifact (v:artifact) encoder = 
  if artifact_has_kind v then (
    Pbrt.Encoder.string v.kind encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
  if artifact_has_data v then (
    Pbrt.Encoder.bytes v.data encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  );
  if artifact_has_api_version v then (
    Pbrt.Encoder.string v.api_version encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  );
  Pbrt.List_util.rev_iter_with (fun x encoder ->
    Pbrt.Encoder.nested encode_pb_storage_entry x encoder;
    Pbrt.Encoder.key 4 Pbrt.Bytes encoder; 
  ) v.storage encoder;
  ()

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_storage_entry d =
  let v = default_storage_entry () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      storage_entry_set_key v (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "storage_entry" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      storage_entry_set_value v (Pbrt.Decoder.bytes d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "storage_entry" 2 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : storage_entry)

let rec decode_pb_artifact d =
  let v = default_artifact () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      (* put lists in the correct order *)
      artifact_set_storage v (List.rev v.storage);
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      artifact_set_kind v (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "artifact" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      artifact_set_data v (Pbrt.Decoder.bytes d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "artifact" 2 pk
    | Some (3, Pbrt.Bytes) -> begin
      artifact_set_api_version v (Pbrt.Decoder.string d);
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "artifact" 3 pk
    | Some (4, Pbrt.Bytes) -> begin
      artifact_set_storage v ((decode_pb_storage_entry (Pbrt.Decoder.nested d)) :: v.storage);
    end
    | Some (4, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "artifact" 4 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : artifact)

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_storage_entry (v:storage_entry) = 
  let assoc = ref [] in
  if storage_entry_has_key v then (
    assoc := ("key", Pbrt_yojson.make_string v.key) :: !assoc;
  );
  if storage_entry_has_value v then (
    assoc := ("value", Pbrt_yojson.make_bytes v.value) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_artifact (v:artifact) = 
  let assoc = ref [] in
  if artifact_has_kind v then (
    assoc := ("kind", Pbrt_yojson.make_string v.kind) :: !assoc;
  );
  if artifact_has_data v then (
    assoc := ("data", Pbrt_yojson.make_bytes v.data) :: !assoc;
  );
  if artifact_has_api_version v then (
    assoc := ("apiVersion", Pbrt_yojson.make_string v.api_version) :: !assoc;
  );
  assoc := (
    let l = v.storage |> List.map encode_json_storage_entry in
    ("storage", `List l) :: !assoc 
  );
  `Assoc !assoc

[@@@ocaml.warning "-23-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_storage_entry d =
  let v = default_storage_entry () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("key", json_value) -> 
      storage_entry_set_key v (Pbrt_yojson.string json_value "storage_entry" "key")
    | ("value", json_value) -> 
      storage_entry_set_value v (Pbrt_yojson.bytes json_value "storage_entry" "value")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    key = v.key;
    value = v.value;
  } : storage_entry)

let rec decode_json_artifact d =
  let v = default_artifact () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("kind", json_value) -> 
      artifact_set_kind v (Pbrt_yojson.string json_value "artifact" "kind")
    | ("data", json_value) -> 
      artifact_set_data v (Pbrt_yojson.bytes json_value "artifact" "data")
    | ("apiVersion", json_value) -> 
      artifact_set_api_version v (Pbrt_yojson.string json_value "artifact" "api_version")
    | ("storage", `List l) -> begin
      artifact_set_storage v @@ List.map (function
        | json_value -> (decode_json_storage_entry json_value)
      ) l;
    end
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    kind = v.kind;
    data = v.data;
    api_version = v.api_version;
    storage = v.storage;
  } : artifact)
