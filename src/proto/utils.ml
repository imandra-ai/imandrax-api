[@@@ocaml.warning "-27-30-39"]

type empty = unit

let rec default_empty = ()


(** {2 Make functions} *)


[@@@ocaml.warning "-27-30-39"]

(** {2 Formatters} *)

let rec pp_empty fmt (v:empty) = 
  let pp_i fmt () =
    Pbrt.Pp.pp_unit fmt ()
  in
  Pbrt.Pp.pp_brk pp_i fmt ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_empty (v:empty) encoder = 
()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_empty d =
  match Pbrt.Decoder.key d with
  | None -> ();
  | Some (_, pk) -> 
    Pbrt.Decoder.unexpected_payload "Unexpected fields in empty message(empty)" pk

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf YoJson Encoding} *)

let rec encode_json_empty (v:empty) = 
Pbrt_yojson.make_unit v

[@@@ocaml.warning "-27-30-39"]

(** {2 JSON Decoding} *)

let rec decode_json_empty d =
Pbrt_yojson.unit d "empty" "empty record"
