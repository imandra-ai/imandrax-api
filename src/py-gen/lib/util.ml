open Printf
module Artifact = Imandrax_api_artifact.Artifact
module Mir = Imandrax_api_mir
module Type = Imandrax_api_mir.Type
module Term = Imandrax_api_mir.Term

let json_to_art_data ?(debug = false) (json : Yojson.Safe.t) : string * string =
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

let art_data_to_art ?(debug = false) (data_b64 : string) (kind_str : string) :
    Artifact.t =
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
    art

let art_data_to_model ?(debug = false) (data_b64 : string) (kind_str : string) :
    Mir.Model.t =
  let art = art_data_to_art ~debug data_b64 kind_str in
  let model : Mir.Model.t =
    match Artifact.as_model art with
    | Some model -> model
    | None -> raise (Failure "Error: artifact is not a model")
  in
  model

let art_data_to_fun_decomp
    ?(debug = false)
    (data_b64 : string)
    (kind_str : string) : Mir.Fun_decomp.t =
  let art = art_data_to_art ~debug data_b64 kind_str in
  let fun_decomp : Mir.Fun_decomp.t =
    match Artifact.as_fun_decomp art with
    | Some fd -> fd
    | None -> raise (Failure "Error: artifact is not a model")
  in
  fun_decomp

let json_to_model ?(debug = false) (json : Yojson.Safe.t) : Mir.Model.t =
  let data_b64, kind_str = json_to_art_data ~debug json in
  art_data_to_model ~debug data_b64 kind_str

let json_to_fun_decomp ?(debug = false) (json : Yojson.Safe.t) :
    Mir.Fun_decomp.t =
  let data_b64, kind_str = json_to_art_data ~debug json in
  art_data_to_fun_decomp ~debug data_b64 kind_str

let yaml_to_art ?(debug = false) (yaml : Yaml.value) : string * string =
  let log fmt =
    if debug then
      printf fmt
    else
      ifprintf stdout fmt
  in

  (* Extract fields from YAML mapping *)
  match yaml with
  | `O assoc ->
    let get_string key =
      match List.assoc_opt key assoc with
      | Some (`String s) -> s
      | _ -> failwith (sprintf "Missing or invalid field: %s" key)
    in
    let kind_str = get_string "kind" in
    let data_b64 = get_string "data" in
    let api_version = get_string "api_version" in

    log "Kind: %s\n" kind_str;
    log "API Version: %s\n" api_version;

    data_b64, kind_str
  | _ -> failwith "Expected YAML mapping (object)"

let yaml_to_model ?(debug = false) (yaml : Yaml.value) : Mir.Model.t =
  let data_b64, kind_str = yaml_to_art ~debug yaml in
  art_data_to_model ~debug data_b64 kind_str

let yaml_to_fun_decomp ?(debug = false) (yaml : Yaml.value) : Mir.Fun_decomp.t =
  (* Extract artifact from decomp_res if present, otherwise use yaml as-is *)
  let artifact_yaml =
    match yaml with
    | `O assoc ->
      (match List.assoc_opt "decomp_res" assoc with
      | Some (`O decomp_res_assoc) ->
        (match List.assoc_opt "artifact" decomp_res_assoc with
        | Some artifact -> artifact
        | None -> yaml (* fall back to root level *))
      | _ -> yaml (* fall back to root level *))
    | _ -> yaml
  in
  let data_b64, kind_str = yaml_to_art ~debug artifact_yaml in
  art_data_to_fun_decomp ~debug data_b64 kind_str
