(** Encode a {!Value.t} with imandrakit's encoder, the reference. *)

module Enc = Imandrakit_twine.Encode
module Imm = Imandrakit_twine.Immediate

(** Write [v] and return the immediate that refers to it.

    With [memo], every subtree is written once: the first occurrence is written
    and its offset recorded under the subtree's text form, and every occurrence
    (the first included) becomes a pointer to that offset. *)
let rec immediate ?memo (enc : Enc.t) (v : Value.t) : Imm.t =
  match memo with
  | None -> immediate_ ?memo enc v
  | Some tbl ->
    let key = Sexp.to_string (Sexp.of_value v) in
    (match Hashtbl.find_opt tbl key with
    | Some off -> Imm.pointer off
    | None ->
      let off = Enc.write_or_ref_immediate enc (immediate_ ?memo enc v) in
      Hashtbl.add tbl key off;
      Imm.pointer off)

and immediate_ ?memo enc (v : Value.t) : Imm.t =
  let imm = immediate ?memo enc in
  match v with
  | Null -> Imm.null
  | Bool b -> Imm.bool b
  | Int z -> Imm.int64 (Z.to_int64 z)
  | F32 f -> Imm.float32 f
  | F64 f -> Imm.float f
  | Str s -> Imm.string s
  | Blob s -> Imm.blob s
  (* children are written before their container: the encoder needs their
     immediates before it writes the container's header *)
  | Array l ->
    let items = List.map imm l in
    Enc.list enc items
  | Dict l ->
    let pairs =
      List.map
        (fun (k, v) ->
          let k = imm k in
          let v = imm v in
          k, v)
        l
    in
    Enc.dict_list enc pairs
  | Tag (n, x) ->
    let x = imm x in
    Enc.tag enc ~tag:(Z.to_int n) ~v:x
  | Cstor (index, l) ->
    let args = Array.of_list (List.map imm l) in
    Enc.cstor enc ~index:(Z.to_int index) args
  | Ref x ->
    let off = Enc.write_or_ref_immediate enc (imm x) in
    Imm.ref_ off

(** [encode ~share v] is the full twine encoding of [v]. With [share], every
    repeated subtree is written once and referred to by pointers. *)
let encode ?(share = false) (v : Value.t) : string =
  let enc = Enc.create () in
  let memo =
    if share then
      Some (Hashtbl.create 16)
    else
      None
  in
  let entrypoint = immediate ?memo enc v in
  Enc.finalize_copy enc ~entrypoint

(** A [Z.t] encoded the way ImandraX encodes integers (a blob, see
    [Util_twine.Z]) *)
let encode_bigint (z : Z.t) : string =
  let enc = Enc.create () in
  let entrypoint = Imandrax_api.Util_twine.Z.to_twine enc z in
  Enc.finalize_copy enc ~entrypoint
