open Printf
open Imandrax_api
module Artifact = Imandrax_api_artifact.Artifact
module Mir = Imandrax_api_mir
module Type = Imandrax_api_mir.Type
module Term = Imandrax_api_mir.Term
module Ty_view = Imandrax_api.Ty_view
module Ast = Ast

let show_term_view : (Term.term, Type.t) Term.view -> string =
  Term.show_view Term.pp Type.pp

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
  (* Constant *)
  | Term.Const const, _ ->
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
  (* Tuple *)
  | Term.Tuple { l = (terms : Term.term list) }, (_ty : Type.t) ->
    let expr_opts = List.map (fun term -> parse_term term) terms in
    let raising_msg = "None found when parsing tuple items" in
    let exprs =
      List.map (fun opt -> opt |> CCOption.get_exn_or raising_msg) expr_opts
    in
    Some (Ast.tuple_of_exprs exprs)
  (* Record *)
  | Term.Record { rows; rest }, (_ty : Type.t) ->
    print_endline "WIP: record";
    let _ = rows in
    let _ = rest in
    None
  (* Construct *)
  | ( Term.Construct { c = _construct; args = (construct_args : Term.term list) },
      (ty : Type.t) ) ->
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

    (* Check ty view to see if it's a list *)
    let is_list =
      match ty_view with
      | Ty_view.Constr (constr_name_uid, constr_args) ->
        let name = constr_name_uid.name in
        (match name, constr_args with
        | "list", [ _ ] -> true
        | "list", args ->
          let args_str = CCString.concat ", " (List.map Type.show args) in
          let msg =
            sprintf "Never: list should have only 1 arg, got %d: %s"
              (List.length args) args_str
          in
          failwith msg
        | _ -> false)
      | _ -> false
    in

    let unwrap : 'a option -> 'a = function
      | Some x -> x
      | None -> failwith "unwrap: None"
    in

    let res =
      match is_lchar, is_list with
      | false, false ->
        print_endline "WIP";
        None
      | true, false ->
        (* LChar *)
        let bool_terms =
          List.map (fun arg -> parse_term arg |> unwrap) construct_args
        in
        let char_expr = Ast.bool_list_expr_to_char_expr bool_terms in
        Some char_expr
      | false, true ->
        (* List
        For empty list, the construct args is empty.
        For non-empty list, the construct args is at two terms, with the
        The first term is the head, the second term is the existing list (tail).
        *)
        (* List - check if nil or cons *)
        let is_nil = construct_args = [] in
        if is_nil then
          (* Empty list [] *)
          Some (Ast.empty_list_expr ())
        else (
          let list_elements =
            List.map (fun arg -> parse_term arg |> unwrap) construct_args
          in
          match list_elements with
          | [] -> failwith "Never: empty constuct arg for non-Nil"
          | [ _ ] -> failwith "Never: single element list for non-Nil"
          | [ head; tail ] ->
            Some (Ast.cons_list_expr head tail)
            (* let n_elem = CCList.length elems in
            let except_last = CCList.take (n_elem - 1) elems in
            Some (Ast.list_of_exprs except_last) *)
          | _ -> failwith "Never: more than 2 elements list for non-Nil"
        )
      | true, true -> failwith "Never: both is_lchar and is_list"
    in
    res
  | _, _ ->
    print_endline "case other than const or construct";
    None

let sep : string = "\n" ^ CCString.repeat "<>" 10 ^ "\n"

(* <><><><><><><><><><><><><><><><><><><><> *)

let%expect_test "decode artifact" =
  let yaml_str = CCIO.File.read_exn "../examples/art/art.yaml" in
  let yaml = Yaml.of_string_exn yaml_str in

  (* Get item by index *)
  let index = 9 in
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
    name: record
    code: type user = {
        id: int;
        active: bool;
    }

    let v = {id = 1; active = true}

    let v =
      fun w ->
        if w = v then true else false

    <><><><><><><><><><>

    Applied symbol:
    (w/349617 : { view = (Constr (user/QIIePJC32dnXpa-ApKIloQsQ1Ql77O465AHp8E-VacE, [])); generation = 1 })

    <><><><><><><><><><>

    Term:
    { view =
      Record {
        rows =
        [((id/dW6Xq1VvQEe89X8BPre2ndcIFc8_dKuXiGKM55tMrC0 : { view =
                                                              (Arrow ((), { view = (Constr (user/QIIePJC32dnXpa-ApKIloQsQ1Ql77O465AHp8E-VacE, [])); generation = 1 },
                                                                 { view = (Constr (int, [])); generation = 1 }));
                                                              generation = 1 }),
          { view = (Const 1); ty = { view = (Constr (int, [])); generation = 1 }; generation = 0; sub_anchor = None });
          ((active/8W7TgFsQ2TyL8dH3GP194mCwP6ECHUjxu2P5NAEVFFM : { view =
                                                                   (Arrow ((), { view = (Constr (user/QIIePJC32dnXpa-ApKIloQsQ1Ql77O465AHp8E-VacE, [])); generation = 1 },
                                                                      { view = (Constr (bool, [])); generation = 1 }));
                                                                   generation = 1 }),
           { view = (Const true); ty = { view = (Constr (bool, [])); generation = 1 }; generation = 0; sub_anchor = None })
          ];
        rest = None};
      ty = { view = (Constr (user/QIIePJC32dnXpa-ApKIloQsQ1Ql77O465AHp8E-VacE, [])); generation = 1 }; generation = 0; sub_anchor = None }

    <><><><><><><><><><>

    Parsing term:
    WIP: record
    None
    |}]
