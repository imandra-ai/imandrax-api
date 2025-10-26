open Printf
open Imandrax_api
module Artifact = Imandrax_api_artifact.Artifact
module Mir = Imandrax_api_mir
module Type = Imandrax_api_mir.Type
module Term = Imandrax_api_mir.Term
module Ty_view = Imandrax_api.Ty_view
module Ast = Ast

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

let rec parse_term (term : Term.term) : Ast.expr option =
  let term_view = term.view in
  let term_ty = term.ty in
  match term_view, term_ty with
  | Term.Const const, _ ->
    (* Constant *)
    (match const with
    | Const_bool b -> Some Ast.(Constant { value = Bool b; kind = None })
    | Const_float f ->
      (* printf "%f" f; *)
      Ast.(Some (Constant { value = Float f; kind = None }))
    | Const_q q ->
      let num = Q.num q in
      let den = Q.den q in
      (* printf "%s/%s" (Z.to_string num) (Z.to_string den); *)
      let open Ast in
      (* Should we use Decimal instead? *)
      Some
        (Constant
           { value = Float (Z.to_float num /. Z.to_float den); kind = None })
    | Const_z z ->
      print_endline (Z.to_string z);
      Some (Ast.Constant { value = Int (Z.to_int z); kind = None })
    | Const_string s ->
      print_endline s;
      Some (Ast.Constant { value = String s; kind = None })
    | c ->
      (* Uid and real_approx *)
      print_endline (sprintf "unhandle const %s" (Imandrax_api.Const.show c));
      None)
  | ( Term.Construct { c = construct; args = (construct_args : Term.term list) },
      ty ) ->
    let ty_view = ty.view in

    (* Check ty view to see if it's a LChar.t *)
    let is_lchar =
      match ty_view with
      | Ty_view.Constr (constr_name_uid, constr_args) ->
        let name = constr_name_uid.name in
        (match name, constr_args with
        | "LChar.t", [] -> true
        | "LChar.t", _x :: _xs -> failwith "LChar.t shouldn't have args"
        | _ -> false)
      | _ -> false
    in

    let _ = construct in

    if is_lchar then (
      let unwrap : 'a option -> 'a = function
        | Some x -> x
        | None -> failwith "unwrap: None"
      in
      let bool_terms =
        List.map (fun arg -> parse_term arg |> unwrap) construct_args
      in
      let char_expr = Ast.bool_list_expr_to_char_expr bool_terms in
      Some char_expr
    ) else
      None
  (* | _ ->
    failwith "non-constr ty view";
    let _, _, _ = c, args, ty in
    print_endline "Construct" *)
  | _, _ ->
    print_endline "case other than const or construct";
    None

let show_term_view : (Term.term, Type.t) Term.view -> string =
  Term.show_view Term.pp Type.pp

let sep : string = "\n" ^ CCString.repeat "<>" 10 ^ "\n"

(* <><><><><><><><><><><><><><><><><><><><> *)

let%expect_test "decode artifact" =
  let yaml_str = CCIO.File.read_exn "../examples/art/art.yaml" in
  let yaml = Yaml.of_string_exn yaml_str in

  (* Get item by index *)
  let index = 4 in
  let item =
    match yaml with
    | `A items -> List.nth items index
    | _ -> failwith "Expected YAML list"
  in

  let name, code =
    match item with
    | `O assoc ->
      let name =
        match List.assoc_opt "name" assoc with
        | Some (`String s) -> s
        | _ -> "unknown"
      in
      let code =
        match List.assoc_opt "iml" assoc with
        | Some (`String s) -> s
        | _ -> "unknown"
      in
      name, code
    | _ -> "unknown name", "unknown value"
  in
  printf "name: %s\n" name;
  printf "code: %s\n" code;

  let model = Util.yaml_to_model item in
  let app_sym, term = parse_model model in

  (* Create a custom formatter with wider margin *)
  let fmt = Format.str_formatter in
  Format.pp_set_margin fmt 200;
  Format.pp_set_max_indent fmt 190;

  let _term_view = term.view in

  print_endline sep;

  print_endline "Applied symbol:";
  Format.fprintf fmt "%a@?"
    (Imandrax_api_common.Applied_symbol.pp_t_poly Mir.Type.pp)
    app_sym;
  print_endline (Format.flush_str_formatter ());
  printf "%s\n" sep;

  print_endline "Term:";
  Format.fprintf fmt "%a@?" Term.pp term;
  print_endline (Format.flush_str_formatter ());
  printf "%s\n" sep;

  (* print_endline "Term view:";
  Format.fprintf fmt "%a@?" (Term.pp_view Type.pp) term_view;
  print_endline (Format.flush_str_formatter ());
  printf "%s\n" sep; *)
  print_endline "Parsing term:";
  let expr = parse_term term in
  (match expr with
  | Some expr -> print_endline (Ast.show_expr expr)
  | None -> print_endline "None");

  [%expect
    {|
    name: tuple (bool * int)
    code: (true, 2)

    <><><><><><><><><><>

    Applied symbol:
    (w/311234 : { view = (Tuple [{ view = (Constr (bool, [])); generation = 1 }; { view = (Constr (int, [])); generation = 1 }]); generation = 1 })

    <><><><><><><><><><>

    Term:
    { view =
      Tuple {
        l =
        [{ view = (Const true); ty = { view = (Constr (bool, [])); generation = 1 }; generation = 0; sub_anchor = None };
          { view = (Const 2); ty = { view = (Constr (int, [])); generation = 1 }; generation = 0; sub_anchor = None }]};
      ty = { view = (Tuple [{ view = (Constr (bool, [])); generation = 1 }; { view = (Constr (int, [])); generation = 1 }]); generation = 1 }; generation = 0; sub_anchor = None }

    <><><><><><><><><><>

    Parsing term:
    case other than const or construct
    None
    |}]
