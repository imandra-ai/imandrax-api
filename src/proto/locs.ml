[@@@ocaml.warning "-23-27-30-39-44"]

type position = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 2 fields *)
  mutable line : int32;
  mutable col : int32;
}

type location = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable file : string;
  mutable start : position option;
  mutable stop : position option;
}

let default_position (): position =
{
  _presence=Pbrt.Bitfield.empty;
  line=0l;
  col=0l;
}

let default_location (): location =
{
  _presence=Pbrt.Bitfield.empty;
  file="";
  start=None;
  stop=None;
}


(** {2 Make functions} *)

let[@inline] position_has_line (self:position) : bool = (Pbrt.Bitfield.get self._presence 0)
let[@inline] position_has_col (self:position) : bool = (Pbrt.Bitfield.get self._presence 1)

let[@inline] position_set_line (self:position) (x:int32) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.line <- x
let[@inline] position_set_col (self:position) (x:int32) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 1); self.col <- x

let copy_position (self:position) : position =
  { self with line = self.line }

let make_position 
  ?(line:int32 option)
  ?(col:int32 option)
  () : position  =
  let _res = default_position () in
  (match line with
  | None -> ()
  | Some v -> position_set_line _res v);
  (match col with
  | None -> ()
  | Some v -> position_set_col _res v);
  _res

let[@inline] location_has_file (self:location) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] location_set_file (self:location) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.file <- x
let[@inline] location_set_start (self:location) (x:position) : unit =
  self.start <- Some x
let[@inline] location_set_stop (self:location) (x:position) : unit =
  self.stop <- Some x

let copy_location (self:location) : location =
  { self with file = self.file }

let make_location 
  ?(file:string option)
  ?(start:position option)
  ?(stop:position option)
  () : location  =
  let _res = default_location () in
  (match file with
  | None -> ()
  | Some v -> location_set_file _res v);
  (match start with
  | None -> ()
  | Some v -> location_set_start _res v);
  (match stop with
  | None -> ()
  | Some v -> location_set_stop _res v);
  _res

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Formatters} *)

let rec pp_position fmt (v:position) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (position_has_line v)) ~first:true "line" Pbrt.Pp.pp_int32 fmt v.line;
    Pbrt.Pp.pp_record_field ~absent:(not (position_has_col v)) ~first:false "col" Pbrt.Pp.pp_int32 fmt v.col;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_location fmt (v:location) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (location_has_file v)) ~first:true "file" Pbrt.Pp.pp_string fmt v.file;
    Pbrt.Pp.pp_record_field ~first:false "start" (Pbrt.Pp.pp_option pp_position) fmt v.start;
    Pbrt.Pp.pp_record_field ~first:false "stop" (Pbrt.Pp.pp_option pp_position) fmt v.stop;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_position (v:position) encoder = 
  if position_has_line v then (
    Pbrt.Encoder.int32_as_varint v.line encoder;
    Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  );
  if position_has_col v then (
    Pbrt.Encoder.int32_as_varint v.col encoder;
    Pbrt.Encoder.key 2 Pbrt.Varint encoder; 
  );
  ()

let rec encode_pb_location (v:location) encoder = 
  if location_has_file v then (
    Pbrt.Encoder.string v.file encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
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

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_position d =
  let v = default_position () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      position_set_line v (Pbrt.Decoder.int32_as_varint d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "position" 1 pk
    | Some (2, Pbrt.Varint) -> begin
      position_set_col v (Pbrt.Decoder.int32_as_varint d);
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "position" 2 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : position)

let rec decode_pb_location d =
  let v = default_location () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      location_set_file v (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "location" 1 pk
    | Some (2, Pbrt.Bytes) -> begin
      location_set_start v (decode_pb_position (Pbrt.Decoder.nested d));
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "location" 2 pk
    | Some (3, Pbrt.Bytes) -> begin
      location_set_stop v (decode_pb_position (Pbrt.Decoder.nested d));
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "location" 3 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : location)

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_position (v:position) = 
  let assoc = ref [] in
  if position_has_line v then (
    assoc := ("line", Pbrt_yojson.make_int (Int32.to_int v.line)) :: !assoc;
  );
  if position_has_col v then (
    assoc := ("col", Pbrt_yojson.make_int (Int32.to_int v.col)) :: !assoc;
  );
  `Assoc !assoc

let rec encode_json_location (v:location) = 
  let assoc = ref [] in
  if location_has_file v then (
    assoc := ("file", Pbrt_yojson.make_string v.file) :: !assoc;
  );
  assoc := (match v.start with
    | None -> !assoc
    | Some v -> ("start", encode_json_position v) :: !assoc);
  assoc := (match v.stop with
    | None -> !assoc
    | Some v -> ("stop", encode_json_position v) :: !assoc);
  `Assoc !assoc

[@@@ocaml.warning "-23-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_position d =
  let v = default_position () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("line", json_value) -> 
      position_set_line v (Pbrt_yojson.int32 json_value "position" "line")
    | ("col", json_value) -> 
      position_set_col v (Pbrt_yojson.int32 json_value "position" "col")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    line = v.line;
    col = v.col;
  } : position)

let rec decode_json_location d =
  let v = default_location () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("file", json_value) -> 
      location_set_file v (Pbrt_yojson.string json_value "location" "file")
    | ("start", json_value) -> 
      location_set_start v (decode_json_position json_value)
    | ("stop", json_value) -> 
      location_set_stop v (decode_json_position json_value)
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    file = v.file;
    start = v.start;
    stop = v.stop;
  } : location)
