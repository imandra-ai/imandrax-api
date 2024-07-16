[@@@ocaml.warning "-27-30-39-44"]

type empty = unit

type string_msg = {
  msg : string;
}

let rec default_empty = ()

let rec default_string_msg 
  ?msg:((msg:string) = "")
  () : string_msg  = {
  msg;
}

type string_msg_mutable = {
  mutable msg : string;
}

let default_string_msg_mutable () : string_msg_mutable = {
  msg = "";
}


(** {2 Make functions} *)


let rec make_string_msg 
  ~(msg:string)
  () : string_msg  = {
  msg;
}

[@@@ocaml.warning "-27-30-39"]

(** {2 Formatters} *)

let rec pp_empty fmt (v:empty) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_unit fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

let rec pp_string_msg fmt (v:string_msg) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_record_field ~first:true "msg" Pbrt.Pp.pp_string fmt v.msg;
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_empty (v:empty) encoder = 
()

let rec encode_pb_string_msg (v:string_msg) encoder = 
  Pbrt.Encoder.string v.msg encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_empty d =
  match Pbrt.Decoder.key d with
  | None -> ();
  | Some (_, pk) -> 
    Pbrt.Decoder.unexpected_payload "Unexpected fields in empty message(empty)" pk

let rec decode_pb_string_msg d =
  let v = default_string_msg_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.msg <- Pbrt.Decoder.string d;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(string_msg), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    msg = v.msg;
  } : string_msg)

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_empty (v:empty) = 
Pbrt_yojson.make_unit v

let rec encode_json_string_msg (v:string_msg) = 
  let assoc = [] in 
  let assoc = ("msg", Pbrt_yojson.make_string v.msg) :: assoc in
  `Assoc assoc

[@@@ocaml.warning "-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_empty d =
Pbrt_yojson.unit d "empty" "empty record"

let rec decode_json_string_msg d =
  let v = default_string_msg_mutable () in
  let assoc = match d with
    | `Assoc assoc -> assoc
    | _ -> assert(false)
  in
  List.iter (function 
    | ("msg", json_value) -> 
      v.msg <- Pbrt_yojson.string json_value "string_msg" "msg"
    
    | (_, _) -> () (*Unknown fields are ignored*)
  ) assoc;
  ({
    msg = v.msg;
  } : string_msg)
