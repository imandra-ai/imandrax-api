(* Script to load and decode movement.json artifact *)

open Imandrax_api
module Artifact = Imandrax_api_artifact.Artifact
module Mir = Imandrax_api_mir

let () =
  (* Read the JSON file *)
  let json_str = CCIO.File.read_exn "examples/art/movement.json" in

  (* Parse JSON *)
  let json = Yojson.Safe.from_string json_str in

  (* Extract fields *)
  let kind_str = Yojson.Safe.Util.(json |> member "kind" |> to_string) in
  let data_b64 = Yojson.Safe.Util.(json |> member "data" |> to_string) in
  let api_version =
    Yojson.Safe.Util.(json |> member "api_version" |> to_string)
  in

  Printf.printf "Kind: %s\n" kind_str;
  Printf.printf "API Version: %s\n" api_version;
  Printf.printf "Data (base64): %s...\n"
    (String.sub data_b64 0 (min 50 (String.length data_b64)));

  (* Parse the kind *)
  match Artifact.kind_of_string kind_str with
  | Error err ->
    Printf.eprintf "Error parsing kind: %s\n" err;
    exit 1
  | Ok (Artifact.Any_kind kind) ->
    Printf.printf "Parsed kind successfully\n";

    (* Decode base64 data *)
    let data_bytes = Base64.decode_exn data_b64 in
    Printf.printf "Decoded %d bytes from base64\n" (String.length data_bytes);

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
      Printf.printf "\nSuccessfully decoded artifact\n";

      let artifact = Artifact.make ~storage:[] ~kind decoded_data in

      (* Pretty print the decoded data *)
      (* Printf.printf "\nDecoded artifact:\n";
      Format.printf "%a\n%!" Artifact.pp artifact; *)
      artifact
    in

    (match Artifact.as_model art with
    | Some model ->
      Printf.printf "Successfully extracted model\n";
      Format.printf "Model: %a\n%!" Mir.Model.pp model
    | None ->
      Printf.eprintf "Error: artifact is not a model\n";
      exit 1)
