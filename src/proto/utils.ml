[@@@ocaml.warning "-23-27-30-39-44"]

type empty = unit

type string_msg = {
  mutable _presence: Pbrt.Bitfield.t; (** presence for 1 fields *)
  mutable msg : string;
}

let default_empty : empty = ()

let default_string_msg (): string_msg =
{
  _presence=Pbrt.Bitfield.empty;
  msg="";
}


(** {2 Make functions} *)

let[@inline] string_msg_has_msg (self:string_msg) : bool = (Pbrt.Bitfield.get self._presence 0)

let[@inline] string_msg_set_msg (self:string_msg) (x:string) : unit =
  self._presence <- (Pbrt.Bitfield.set self._presence 0); self.msg <- x

let copy_string_msg (self:string_msg) : string_msg =
  { self with msg = self.msg }

let make_string_msg 
  ?(msg:string option)
  () : string_msg  =
  let _res = default_string_msg () in
  (match msg with
  | None -> ()
  | Some v -> string_msg_set_msg _res v);
  _res

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Formatters} *)

let rec pp_empty fmt (v:empty) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_unit fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_string_msg fmt (v:string_msg) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~absent:(not (string_msg_has_msg v)) ~first:true "msg" Pbrt.Pp.pp_string fmt v.msg;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_empty (v:empty) encoder = 
()

let rec encode_pb_string_msg (v:string_msg) encoder = 
  if string_msg_has_msg v then (
    Pbrt.Encoder.string v.msg encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  );
  ()

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_empty d =
  match Pbrt.Decoder.key d with
  | None -> ();
  | Some (_, pk) -> 
    Pbrt.Decoder.unexpected_payload "Unexpected fields in empty message(empty)" pk

let rec decode_pb_string_msg d =
  let v = default_string_msg () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      string_msg_set_msg v (Pbrt.Decoder.string d);
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload_message "string_msg" 1 pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  (v : string_msg)

[@@@ocaml.warning "-23-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_empty (v:empty) = 
Pbrt_yojson.make_unit v

let rec encode_json_string_msg (v:string_msg) = 
  let assoc = ref [] in
  if string_msg_has_msg v then (
    assoc := ("msg", Pbrt_yojson.make_string v.msg) :: !assoc;
  );
  `Assoc !assoc

[@@@ocaml.warning "-23-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_empty d =
Pbrt_yojson.unit d "empty" "empty record"

let rec decode_json_string_msg d =
  let v = default_string_msg () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("msg", json_value) -> 
      string_msg_set_msg v (Pbrt_yojson.string json_value "string_msg" "msg")
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    _presence = v._presence;
    msg = v.msg;
  } : string_msg)
