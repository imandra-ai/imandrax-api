(* Script to load and decode artifact *)

open Printf
open Imandrax_api
open Py_gen
module Mir = Imandrax_api_mir

let () =
  (* Read the JSON file *)
  (* let json_str = CCIO.File.read_exn "examples/art/movement/movement.json" in *)
  let json_str = CCIO.File.read_exn "examples/art/primitives/int.json" in
  (* let json_str = CCIO.File.read_exn "examples/art/primitives/bool_list.json" in *)

  (* Parse JSON *)
  let json = Yojson.Safe.from_string json_str in
  let model = Art_loader.json_to_model json in

  printf "%s\n" (Mir.Model.show model);
  ()
