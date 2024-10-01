module Fmt = CCFormat
open Imandrakit
module L_API = Imandrax_api

let () = print_endline @@ String.make 80 '#'

let art_task =
  match Imandrax_api_artifact_zip.read_zip_file "art.po_task.zip" with
  | Ok (_m, art) -> art
  | Error err ->
    Fmt.printf "error when reading artifact: %a@." Error.pp err;
    exit 1

let () =
  Fmt.printf "artifact task: %a@." Imandrax_api_artifact.Artifact.pp art_task

let art_res =
  match Imandrax_api_artifact_zip.read_zip_file "art.po_res.zip" with
  | Ok (_m, art) -> art
  | Error err ->
    Fmt.printf "error when reading artifact: %a@." Error.pp err;
    exit 1

let () =
  Fmt.printf "artifact res: %a@." Imandrax_api_artifact.Artifact.pp art_res
