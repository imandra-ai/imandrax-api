open Printf
open Py_gen
open Py_gen.Parse
module Mir = Imandrax_api_mir
module Type = Imandrax_api_mir.Type
module Term = Imandrax_api_mir.Term
module Model = Imandrax_api_mir.Model

(* Load a Mir.model from a yaml file *)
let load_artifact (name : string) : Model.t =
  let yaml_str = CCIO.File.read_exn (sprintf "data/%s.yaml" name) in
  let yaml = Yaml.of_string_exn yaml_str in
  let name, iml_code =
    match yaml with
    | `O assoc ->
      let name =
        match List.assoc_opt "name" assoc with
        | Some (`String name) -> name
        | _ -> failwith "invalid yaml"
      in
      let iml_code =
        match List.assoc_opt "iml" assoc with
        | Some (`String s) -> s
        | _ -> failwith "invalid yaml"
      in
      name, iml_code
    | _ -> failwith "invalid yaml"
  in
  printf "name: %s\n" name;
  printf "iml_code:\n%s\n" iml_code;

  Util.yaml_to_model yaml

let%expect_test "bool list" =
  let model = load_artifact "bool_list" in
  let _app_sym, term = unpack_model model in
  let ty_defs, expr =
    match parse_term term with
    | Ok (ty_defs, expr) -> ty_defs, expr
    | Error msg -> failwith msg
  in
  printf "Type defs:\n";
  List.iter (fun ty_def -> print_endline (Ast.show_stmt ty_def)) ty_defs;

  printf "\n";
  printf "Expr:\n";
  print_endline (Ast.show_expr expr);

  [%expect
    {|
    name: bool list
    iml_code:
    let v =
      fun w ->
        if w = [true; false] then true else false
    Type defs:

    Expr:
    (Ast.List
       { Ast.elts =
         [(Ast.Constant { Ast.value = (Ast.Bool true); kind = None });
           (Ast.Constant { Ast.value = (Ast.Bool false); kind = None })];
         ctx = Ast.Load })
    |}]
