open Printf
open Imandrax_api
module Artifact = Imandrax_api_artifact.Artifact
module Mir = Imandrax_api_mir
module Type = Imandrax_api_mir.Type
module Term = Imandrax_api_mir.Term

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

let%expect_test "decode tuple artifact from yaml" =
  let yaml_str = CCIO.File.read_exn "../examples/art/art.yaml" in
  let yaml = Yaml.of_string_exn yaml_str in

  (* Get item by index *)
  let index = 0 in
  let item =
    match yaml with
    | `A items -> List.nth items index
    | _ -> failwith "Expected YAML list"
  in

  let name =
    match item with
    | `O assoc ->
      (match List.assoc_opt "name" assoc with
      | Some (`String s) -> s
      | _ -> "unknown")
    | _ -> "unknown"
  in
  printf "name: %s\n" name;

  let model = Util.yaml_to_model item in
  let app_sym, term = parse_model model in
  let app_sym_str =
    Format.asprintf "%a"
      (Imandrax_api_common.Applied_symbol.pp_t_poly Mir.Type.pp)
      app_sym
  in

  let term_view = term.view in

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
