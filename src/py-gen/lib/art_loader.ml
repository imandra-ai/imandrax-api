open Printf
open Imandrax_api
module Artifact = Imandrax_api_artifact.Artifact
module Mir = Imandrax_api_mir
module Type = Imandrax_api_mir.Type
module Term = Imandrax_api_mir.Term

let json_to_art ?(debug = false) (json : Yojson.Safe.t) : string * string =
  let log fmt =
    if debug then
      printf fmt
    else
      ifprintf stdout fmt
  in

  (* Extract fields *)
  let kind_str = Yojson.Safe.Util.(json |> member "kind" |> to_string) in
  let data_b64 = Yojson.Safe.Util.(json |> member "data" |> to_string) in
  let api_version =
    Yojson.Safe.Util.(json |> member "api_version" |> to_string)
  in

  (* log "Kind: %s\n" kind_str; *)
  log "API Version: %s\n" api_version;

  (* log.log "Data (base64): %s...\n"
    (String.sub data_b64 0 (min 50 (String.length data_b64))); *)
  data_b64, kind_str

let art_to_model ?(debug = false) (data_b64 : string) (kind_str : string) :
    Mir.Model.t =
  let log fmt =
    if debug then
      printf fmt
    else
      ifprintf stdout fmt
  in

  match Artifact.kind_of_string kind_str with
  | Error err ->
    eprintf "Error parsing kind: %s\n" err;
    exit 1
  | Ok (Artifact.Any_kind kind) ->
    log "Parsed kind successfully\n";

    (* Decode base64 data *)
    let data_bytes = Base64.decode_exn data_b64 in
    log "Decoded %d bytes from base64\n" (String.length data_bytes);

    (* Decode using Twine *)
    let decoder = Artifact.of_twine kind in
    let twine_decoder = Imandrakit_twine.Decode.of_string data_bytes in

    (* Add MIR state to decoder for MIR types *)
    let term_state = Imandrax_api_mir.Term.State.create () in
    let type_state = Imandrax_api_mir.Type.State.create () in
    Imandrax_api_mir.Term.State.add_to_dec twine_decoder term_state;
    Imandrax_api_mir.Type.State.add_to_dec twine_decoder type_state;

    let entrypoint = Imandrakit_twine.Decode.get_entrypoint twine_decoder in

    let art : Artifact.t =
      let decoded_data = decoder twine_decoder entrypoint in
      log "\nSuccessfully decoded artifact\n";

      let artifact = Artifact.make ~storage:[] ~kind decoded_data in

      (* Pretty print the decoded data *)
      (* log "\nDecoded artifact:\n";
      Format.printf "%a\n%!" Artifact.pp artifact; *)
      artifact
    in

    let model : Mir.Model.t =
      match Artifact.as_model art with
      | Some model -> model
      | None -> raise (Failure "Error: artifact is not a model")
    in
    model

let json_to_model ?(debug = false) (json : Yojson.Safe.t) : Mir.Model.t =
  let data_b64, kind_str = json_to_art ~debug json in
  art_to_model ~debug data_b64 kind_str

(* Helper functions for testing *)
let parse_model model =
  match model.Mir.Model.consts with
  | [] -> failwith "No constants\n"
  | [ const ] ->
    let app_sym, term = const in
    app_sym, term
  | _ ->
    let s =
      sprintf "more than 1 const, not supported\n len = %d"
        (List.length model.Mir.Model.consts)
    in
    failwith s

let parse_term (term : Term.term) =
  let term_view = term.view in
  let term_ty = term.ty in
  match term_view with
  | Term.Const const ->
    (match const with
    | Const_bool b -> printf "%b" b
    | Const_float f -> printf "%f" f
    | Const_q q -> print_endline (Util_twine.Q.show q)
    | Const_z z -> print_endline (Z.to_string z)
    | Const_string s -> print_endline s
    | c ->
      print_endline (sprintf "unhandle const %s" (Imandrax_api.Const.show c)))
  | _ -> print_endline "non-const term"

(* <><><><><><><><><><><><><><><><><><><><> *)

let%expect_test "decode int artifact" =
  let json_str = CCIO.File.read_exn "../examples/art/primitives/int.json" in
  let json = Yojson.Safe.from_string json_str in
  let model = json_to_model json in
  let app_sym, term = parse_model model in
  let app_sym_str =
    Format.asprintf "%a"
      (Imandrax_api_common.Applied_symbol.pp_t_poly Mir.Type.pp)
      app_sym
  in

  let term_view = term.view in

  let term_ty = term.ty in

  print_endline app_sym_str;
  print_newline ();
  print_endline (Term.show term);

  print_newline ();
  print_endline (Term.show_view Term.pp Type.pp term_view);

  print_newline ();
  parse_term term;
  [%expect
    {|
    (x/252218 : { view = (Constr (int, [])); generation = 1 })

    { view = (Const 0); ty = { view = (Constr (int, [])); generation = 1 };
      generation = 0; sub_anchor = None }

    (Const 0)
    0
    |}]
