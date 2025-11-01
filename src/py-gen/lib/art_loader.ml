open Printf
open Imandrax_api
module Artifact = Imandrax_api_artifact.Artifact
module Mir = Imandrax_api_mir
module Type = Imandrax_api_mir.Type
module Term = Imandrax_api_mir.Term
module Ty_view = Imandrax_api.Ty_view
module Applied_symbol = Imandrax_api_common.Applied_symbol
module Ast = Ast

let show_term_view : (Term.term, Type.t) Term.view -> string =
  Term.show_view Term.pp Type.pp

(* Model to applied symbol and term *)
let parse_model (model : (Term.term, Type.t) Imandrax_api_common.Model.t_poly) :
    Type.t Applied_symbol.t_poly * Term.term =
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

(*
Return:
  type definition statements
  expression (term)
*)
let rec parse_term (term : Term.term) : Ast.stmt list * Ast.expr option =
  let term_view = term.view in
  let term_ty = term.ty in
  let unwrap : 'a option -> 'a = function
    | Some x -> x
    | None -> failwith "unwrap: None"
  in
  match term_view, term_ty with
  (* Constant *)
  | Term.Const const, _ ->
    (match const with
    | Const_bool b -> [], Some Ast.(Constant { value = Bool b; kind = None })
    | Const_float f ->
      (* printf "%f" f; *)
      [], Ast.(Some (Constant { value = Float f; kind = None }))
    | Const_q q ->
      let num = Q.num q in
      let den = Q.den q in
      (* printf "%s/%s" (Z.to_string num) (Z.to_string den); *)
      let open Ast in
      (* Should we use Decimal instead? *)
      ( [],
        Some
          (Constant
             { value = Float (Z.to_float num /. Z.to_float den); kind = None })
      )
    | Const_z z ->
      [], Some (Ast.Constant { value = Int (Z.to_int z); kind = None })
    | Const_string s ->
      [], Some (Ast.Constant { value = String s; kind = None })
    | c ->
      (* Uid and real_approx *)
      print_endline (sprintf "unhandle const %s" (Imandrax_api.Const.show c));
      [], None)
  (* Tuple *)
  | Term.Tuple { l = (terms : Term.term list) }, (_ty : Type.t) ->
    let expr_opts = List.map (fun term -> parse_term term |> snd) terms in
    let raising_msg = "None found when parsing tuple items" in
    let exprs =
      List.map (fun opt -> opt |> CCOption.get_exn_or raising_msg) expr_opts
    in
    [], Some (Ast.tuple_of_exprs exprs)
  (* Record *)
  | ( Term.Record
        {
          rows : (Type.t Applied_symbol.t_poly * Term.term) list;
          rest : Term.term option;
        },
      (ty : Type.t) ) ->
    let _ = rest in

    (* Get dataclass name from ty *)
    let ty_name =
      match ty.view with
      | Ty_view.Constr (constr_name_uid, _constr_args) -> constr_name_uid.name
      | _ -> failwith "Never: ty should be a constr"
    in

    (* For each row,
      the first element applied_symbol gives dataclass definition
      the second element gives the value
      *)
    let parse_row
        (applied_symbol : Type.t Applied_symbol.t_poly)
        (term : Term.term) =
      let def_row_var_name = applied_symbol.sym.id.name in
      let def_row_type_name =
        match applied_symbol.ty.view with
        | Ty_view.Arrow (_, _record_view, row_view) ->
          (match row_view.view with
          | Ty_view.Constr (constr_name_uid, _constr_args) ->
            constr_name_uid.name
          | _ -> failwith "Never: row_view should be a constr")
        | _ -> failwith "Never: applied_symbol.ty.view should be a arrow"
      in
      let row_val_expr = parse_term term |> snd |> unwrap in
      (* ENH: maybe using kwargs is clearer? *)
      (def_row_var_name, def_row_type_name), row_val_expr
    in

    let def_rows, row_val_exprs =
      List.map (fun (applied_sym, term) -> parse_row applied_sym term) rows
      |> CCList.split
    in
    let open Ast in
    ( [ def_dataclass ty_name def_rows ],
      Some (init_dataclass ty_name ~args:row_val_exprs ~kwargs:[]) )
  (* Construct *)
  | ( Term.Construct
        {
          c = (construct : Type.t Applied_symbol.t_poly);
          args = (construct_args : Term.term list);
        },
      (ty : Type.t) ) ->
    (*
      Check by ty to see it's a predefined type: LChar.t, list
      *)
    let is_predefined_type : string =
      match ty.view with
      | Ty_view.Constr (constr_name_uid, constr_args) ->
        let name = constr_name_uid.name in
        (match name, constr_args with
        | "LChar.t", [] -> "LChar.t"
        | "LChar.t", _x :: _xs -> failwith "LChar.t shouldn't have args"
        | "list", [ _ ] -> "list"
        | "list", args ->
          let args_str = CCString.concat ", " (List.map Type.show args) in
          let msg =
            sprintf "Never: list should have only 1 arg, got %d: %s"
              (List.length args) args_str
          in
          failwith msg
        | _ -> "_")
      | _ -> "_"
    in

    let term_of_predefined_type : Ast.expr option =
      match is_predefined_type with
      | "LChar.t" ->
        let bool_terms =
          List.map (fun arg -> parse_term arg |> snd |> unwrap) construct_args
        in
        let char_expr = Ast.bool_list_expr_to_char_expr bool_terms in
        Some char_expr
      | "list" ->
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
            List.map (fun arg -> parse_term arg |> snd |> unwrap) construct_args
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
      | _ -> None
    in

    (* Flatten the arrow type view *)
    let unpack_arrows (ty_view : (unit, Uid.t, Type.t) Ty_view.view) :
        string list =
      let rec helper
          (types : string list)
          (ty_view : (unit, Uid.t, Type.t) Ty_view.view) : string list =
        match ty_view with
        | Ty_view.Arrow (_, left_t, right_t) ->
          let left_type =
            match left_t.view with
            | Ty_view.Constr (constr_name_uid, _empty_constr_args) ->
              constr_name_uid.name
            | _ -> failwith "Never: left of arrow type view should be a constr"
          in
          helper (types @ [ left_type ]) right_t.view
        | Ty_view.Constr (constr_name_uid, _empty_constr_args) ->
          let final_type = constr_name_uid.name in
          List.append types [ final_type ]
        | _ ->
          failwith
            "Never: arrow type view should be either a constr or an arrow"
      in
      helper [] ty_view
    in

    let final_expr =
      match term_of_predefined_type with
      | Some expr -> Some expr
      | None ->
        let v_const_name = construct.sym.id.name in
        let v_types : string list = unpack_arrows construct.ty.view in
        print_endline (CCString.concat "->" v_types);
        printf "variant constructor name: %s\n" v_const_name;
        None
    in

    [], final_expr
  | _, _ ->
    print_endline "case other than const or construct";
    [], None

let sep : string = "\n" ^ CCString.repeat "<>" 10 ^ "\n"

(* <><><><><><><><><><><><><><><><><><><><> *)

let%expect_test "decode artifact" =
  let yaml_str = CCIO.File.read_exn "../examples/art/art.yaml" in
  let yaml = Yaml.of_string_exn yaml_str in

  (* Get item by index *)
  let index = 12 in
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
  print_endline "Parsing term:\n";
  let ty_defs, expr = parse_term term in

  printf "Type defs:\n";
  List.iter (fun ty_def -> print_endline (Ast.show_stmt ty_def)) ty_defs;

  printf "\n";
  printf "Expr:\n";
  (match expr with
  | Some expr -> print_endline (Ast.show_expr expr)
  | None -> print_endline "None");

  [%expect
    {|
    name: variant3
    code: type status =
        | Active
        | Waitlist of int * bool

    let v = Waitlist (2, true)

    let v =
      fun w ->
        if w = v then true else false

    <><><><><><><><><><>

    Applied symbol:
    (w/1032786 : { view = (Constr (status/qqWZZQx7LXdT2w5j2j5T3gSw6m0irQ9a20wqWALqqnE, [])); generation = 1 })

    <><><><><><><><><><>

    Term:
    { view =
      Construct {
        c =
        (Waitlist/9Ry2N2hNVo7CogUKiguTwROyoQc8AgV_gR5a_dQglhw : { view =
                                                                  (Arrow ((), { view = (Constr (int, [])); generation = 1 },
                                                                     { view =
                                                                       (Arrow ((), { view = (Constr (bool, [])); generation = 1 },
                                                                          { view = (Constr (status/qqWZZQx7LXdT2w5j2j5T3gSw6m0irQ9a20wqWALqqnE, [])); generation = 1 }));
                                                                       generation = 1 }
                                                                     ));
                                                                  generation = 1 });
        args =
        [{ view = (Const 2); ty = { view = (Constr (int, [])); generation = 1 }; generation = 0; sub_anchor = None };
          { view = (Const true); ty = { view = (Constr (bool, [])); generation = 1 }; generation = 0; sub_anchor = None }]};
      ty = { view = (Constr (status/qqWZZQx7LXdT2w5j2j5T3gSw6m0irQ9a20wqWALqqnE, [])); generation = 1 }; generation = 0; sub_anchor = None }

    <><><><><><><><><><>

    Parsing term:

    int->bool->status
    variant constructor name: Waitlist
    Type defs:

    Expr:
    None
    |}]

(* <><><><><><><><><><><><><><><><><><><><>
Variant 3

Term:
{ view =
    Construct {
      c =
      (Waitlist/9Ry2N2hNVo7CogUKiguTwROyoQc8AgV_gR5a_dQglhw : {
          view = (
            Arrow (
              (),
              { view = (Constr (int, [])); generation = 1 },
              {
                view = (
                  Arrow (
                    (),
                    { view = (Constr (bool, [])); generation = 1 },
                    { view = (Constr (status/qqWZZQx7LXdT2w5j2j5T3gSw6m0irQ9a20wqWALqqnE, [])); generation = 1 }
                  )
                );
                generation = 1
              }
            )
          );
          generation = 1
        }
      );
      args = [
        { view = (Const 2); ty = { view = (Constr (int, [])); generation = 1 }; generation = 0; sub_anchor = None };
        { view = (Const true); ty = { view = (Constr (bool, [])); generation = 1 }; generation = 0; sub_anchor = None }
      ]
    };
    ty = { view = (Constr (status/qqWZZQx7LXdT2w5j2j5T3gSw6m0irQ9a20wqWALqqnE, [])); generation = 1 }; generation = 0; sub_anchor = None
  }


Variant 2

Term:
{
  view =
    Construct {
      c =
        (
          Waitlist/660Y_bgBvqk9Xe1F-l9jcPX5hyd3hCs6mcRM0nhyFQQ : {
            view = (
              Arrow (
                (),
                { view = (Constr (int, [])); generation = 1 },
                { view = (Constr (status/xR35DT0_zCONpK0ZVZi_10jyedKzUDTzqBZBB1xe-TE, [])); generation = 1 }
              )
            );
            generation = 1
          }
        );
      args = [
        { view = (Const 1); ty = { view = (Constr (int, [])); generation = 1 }; generation = 0; sub_anchor = None }
      ]
    };
  ty = { view = (Constr (status/xR35DT0_zCONpK0ZVZi_10jyedKzUDTzqBZBB1xe-TE, [])); generation = 1 }; generation = 0; sub_anchor = None
}

<><><><><><><><><><><><><><><><><><><><>
Variant 1

Term:
{
  view = Construct {
    c = (
      Active/G0qPSm_ZzxxTmDsk2dm1ZUuFNXx8GI2cvepYwMWjAF8 : {
        view = (
          Constr (status/xR35DT0_zCONpK0ZVZi_10jyedKzUDTzqBZBB1xe-TE, [])
        );
        generation = 1
      }
    );
    args = []
  };
  ty = { view = (Constr (status/xR35DT0_zCONpK0ZVZi_10jyedKzUDTzqBZBB1xe-TE, [])); generation = 1 }; generation = 0; sub_anchor = None
}
<><><><><><><><><><><><><><><><><><><><> *)
