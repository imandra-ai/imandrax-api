(* Script to load and decode artifact *)

open Printf
open Imandrax_api
open Py_gen
module Mir = Imandrax_api_mir

let read_json () =
  (* let json_str = CCIO.File.read_exn "examples/art/movement/movement.json" *)
  let json_str =
    CCIO.File.read_exn "examples/art/primitives/int.json"
    (* let json_str = CCIO.File.read_exn "examples/art/primitives/bool_list.json" *)
  in
  Yojson.Safe.from_string json_str

let () = ()

(* printf "%s\n" (Mir.Model.show model); *)
