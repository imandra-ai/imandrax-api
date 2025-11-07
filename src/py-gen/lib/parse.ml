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
let unpack_model (model : (Term.term, Type.t) Imandrax_api_common.Model.t_poly)
    : Type.t Applied_symbol.t_poly * Term.term =
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

exception Early_return of string

let unzip3 triples =
  List.fold_right
    (fun (x, y, z) (xs, ys, zs) -> x :: xs, y :: ys, z :: zs)
    triples ([], [], [])

let unwrap : ('a, 'b) result -> 'a = function
  | Ok x -> x
  | Error msg -> failwith msg

(*
Return:
  type definition statements
  expression option (type-annotation)
  expression (term)
*)
let rec parse_term (term : Term.term) :
    (Ast.stmt list * Ast.expr option * Ast.expr, string) result =
  let debug = true in
  match (term.view : (Term.term, Type.t) Term.view), (term.ty : Type.t) with
  (* Constant *)
  | Term.Const const, _ ->
    (match const with
    | Const_bool b ->
      let open Ast in
      Ok
        ( [],
          Some (mk_name_expr "bool"),
          Constant { value = Bool b; kind = None } )
    | Const_float f ->
      (* printf "%f" f; *)
      let open Ast in
      Ok
        ( [],
          Some (mk_name_expr "float"),
          Constant { value = Float f; kind = None } )
    | Const_q q ->
      let num = Q.num q in
      let den = Q.den q in
      (* printf "%s/%s" (Z.to_string num) (Z.to_string den); *)
      let open Ast in
      (* Should we use Decimal instead? *)
      Ok
        ( [],
          Some (mk_name_expr "float"),
          Constant
            { value = Float (Z.to_float num /. Z.to_float den); kind = None } )
    | Const_z z ->
      let open Ast in
      Ok
        ( [],
          Some (mk_name_expr "int"),
          Ast.Constant { value = Int (Z.to_int z); kind = None } )
    | Const_string s ->
      let open Ast in
      Ok
        ( [],
          Some (mk_name_expr "str"),
          Constant { value = String s; kind = None } )
    | c ->
      (* Uid and real_approx *)
      let msg = sprintf "unhandled const %s" (Imandrax_api.Const.show c) in
      Error msg)
  (* Tuple *)
  | Term.Tuple { l = (terms : Term.term list) }, (_ty : Type.t) ->
    let parsed_elems = List.map (fun term -> parse_term term |> unwrap) terms in
    let type_defs_of_elems, type_annot_of_elems, term_of_elems =
      unzip3 parsed_elems
    in
    let tuple_annot =
      type_annot_of_elems
      |> List.map (CCOption.get_exn_or "Tuple element has no type annotation")
      |> Ast.tuple_annot_of_annots
    in
    let type_def_of_elems = List.flatten type_defs_of_elems in
    Ok (type_def_of_elems, Some tuple_annot, Ast.tuple_of_exprs term_of_elems)
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
      let type_defs_of_row, _type_annot_of_row, row_val_expr =
        parse_term term |> unwrap
      in
      (* TODO(ENH): maybe using kwargs is clearer? *)
      type_defs_of_row, (def_row_var_name, def_row_type_name), row_val_expr
    in

    let type_defs_of_rows, def_rows, row_val_exprs =
      List.map (fun (applied_sym, term) -> parse_row applied_sym term) rows
      |> unzip3
    in

    let type_def_of_rows = List.flatten type_defs_of_rows in
    let open Ast in
    Ok
      ( type_def_of_rows @ [ def_dataclass ty_name def_rows ],
        Some (Ast.mk_name_expr ty_name),
        init_dataclass ty_name ~args:row_val_exprs ~kwargs:[] )
  (* Construct LChar.t *)
  | ( Term.Construct
        {
          c = (_ : Type.t Applied_symbol.t_poly);
          args = (construct_args : Term.term list);
        },
      {
        view =
          Ty_view.Constr
            (Uid.{ name = "LChar.t"; view = _ }, ty_view_constr_args);
        _;
      } ) ->
    if not debug then
      ()
    else if List.length ty_view_constr_args <> 0 then
      failwith "Never: LChar.t should have no args"
    else
      ();

    let bool_type_defs_s, _bool_type_annot_s, bool_terms =
      List.map (fun arg -> parse_term arg |> unwrap) construct_args |> unzip3
    in
    let bool_type_defs = List.flatten bool_type_defs_s in

    if not debug then
      ()
    else (
      match bool_type_defs with
      | [] -> ()
      (* Why would bool need type def? *)
      | _ -> failwith "Never: bool_type_defs should be empty"
    );

    let char_expr = Ast.bool_list_expr_to_char_expr bool_terms in
    (* NOTE: Python has no char type, so we use str *)
    Ok ([], Some (Ast.mk_name_expr "str"), char_expr)
  (* Construct list *)
  | ( Term.Construct
        {
          c = (_ : Type.t Applied_symbol.t_poly);
          args = (construct_args : Term.term list);
        },
      {
        view =
          Ty_view.Constr (Uid.{ name = "list"; view = _ }, ty_view_constr_args);
        _;
      } ) ->
    (* For empty list, the construct arg is empty.
      For non-empty list, the construct arg has two terms, with the first term
      being the head and the second term being the tail (existing list).
    *)
    if not debug then
      ()
    else if List.length ty_view_constr_args <> 1 then (
      let args_str =
        CCString.concat ", " (List.map Type.show ty_view_constr_args)
      in
      let msg =
        sprintf "Never: list should have only 1 arg, got %d: %s"
          (List.length ty_view_constr_args)
          args_str
      in
      failwith msg
    );

    let type_def_of_elems, type_annot_of_elems, term_of_elems =
      match construct_args with
      | [] ->
        (* Nil *)
        [], None, Ast.empty_list_expr ()
      | _ ->
        let type_defs_of_elems, type_annot_of_elems, term_of_elems =
          List.map (fun arg -> parse_term arg |> unwrap) construct_args
          |> unzip3
        in
        let type_def_of_elems = List.flatten type_defs_of_elems in
        (match term_of_elems with
        | [] -> failwith "Never: empty constuct arg for non-Nil"
        | [ _ ] -> failwith "Never: single element list for non-Nil"
        | [ head; tail ] ->
          let type_annot_of_elem =
            type_annot_of_elems |> List.hd
            |> CCOption.get_exn_or
                 "No type annotation for the first list element"
          in
          let type_annot =
            Ast.(
              Subscript
                {
                  value = Name { id = "list"; ctx = mk_ctx () };
                  slice = type_annot_of_elem;
                  ctx = mk_ctx ();
                })
          in

          type_def_of_elems, Some type_annot, Ast.cons_list_expr head tail
          (* let n_elem = CCList.length elems in
          let except_last = CCList.take (n_elem - 1) elems in
          Some (Ast.list_of_exprs except_last) *)
        | _ -> failwith "Never: more than 2 elements list for non-Nil")
    in

    Ok (type_def_of_elems, type_annot_of_elems, term_of_elems)
  (* Construct - other *)
  | ( Term.Construct
        {
          c = (construct : Type.t Applied_symbol.t_poly);
          args = (construct_args : Term.term list);
        },
      (_ : Type.t) ) ->
    (* Flatten the arrow type view to a list of types *)
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

    let res : (Ast.stmt list * Ast.expr option * Ast.expr, string) result =
      let variant_constr_name = construct.sym.id.name in
      (* the last arg is the variant name *)
      let variant_constr_args_and_variant_name : string list =
        unpack_arrows construct.ty.view
      in

      (* print_endline
          (CCString.concat "->" variant_constr_args_and_variant_name);
        printf "variant constructor name: %s\n" variant_constr_name; *)
      let split_last xs =
        match List.rev xs with
        | [] -> failwith "Never: empty list"
        | x :: xs -> List.rev xs, x
      in

      let variant_constr_args, variant_name =
        let constr_args_, name =
          split_last variant_constr_args_and_variant_name
        in
        (* Map Ocaml type names to Python type names *)
        let constr_args =
          List.map
            (fun (caml_type : string) : string ->
              let py_type_opt =
                CCList.assoc_opt ~eq:( = ) caml_type
                  Ast.ty_view_constr_name_mapping
              in
              match py_type_opt with
              | Some py_type -> py_type
              | None -> caml_type)
            constr_args_
        in
        constr_args, name
      in

      let ty_defs =
        Ast.variant_dataclass variant_name
          [ variant_constr_name, variant_constr_args ]
      in

      let parsed_constr_args =
        List.map (fun arg -> parse_term arg |> unwrap) construct_args
      in

      let ( constr_arg_type_stmt_lists,
            _constr_arg_type_annot_lists,
            constr_arg_terms ) =
        unzip3 parsed_constr_args
      in

      let constr_arg_type_stmts = List.flatten constr_arg_type_stmt_lists in

      let term =
        Ast.init_dataclass variant_constr_name ~args:constr_arg_terms ~kwargs:[]
      in
      Ok
        ( constr_arg_type_stmts @ ty_defs,
          Some Ast.(Name { id = variant_name; ctx = Load }),
          term )
    in

    res
  | Term.Apply { f : Term.term; l : Term.term list }, (ty : Type.t) ->
    (try
       (* Extract Map key and value type from ty *)
       let key_ty_name, val_ty_name =
         match ty.view with
         | Ty_view.Constr
             ( { name = "Map.t"; _ },
               ([
                  {
                    view = Ty_view.Constr (Uid.{ name = key_ty_name; _ }, _);
                    _;
                  };
                  {
                    view = Ty_view.Constr (Uid.{ name = val_ty_name; _ }, _);
                    _;
                  };
                ] :
                 Type.t list) ) ->
           key_ty_name, val_ty_name
         | _ -> raise (Early_return "Non-map Apply term view")
       in

       (* printf "key_ty_name: %s\n" key_ty_name;
       printf "val_ty_name: %s\n" val_ty_name; *)
       let type_annot =
         Ast.defaultdict_type_annotation key_ty_name val_ty_name
       in

       (* Parse the [l] of Map.add'
        - [Map.add' m k v] adds the pair (k, v) to map m
        - it should be exactly 3 terms
        - if the first term is `Map.const`, it contains the default value
        - if the first term is `Map.add'` again, we recursively call parsing

        Return:
          - the key-value pairs that have been parsed so far
          - the default value
       *)
       let rec parse_map_term_view
           (f : Term.term)
           (l : Term.term list)
           (accu_key_val_pairs : (Term.term * Term.term) list) :
           (Term.term * Term.term) list * Term.term =
         let key_val_pairs, default =
           match f with
           | ({
                view =
                  Term.Sym
                    Applied_symbol.
                      { sym = { id = Uid.{ name = "Map.add'"; _ }; _ }; _ };
                _;
              } :
               Term.term) ->
             (* f is Map.add', l should have exactly 3 terms
               - the first term, which should have view of Apply, goes to next call
               - the second and third terms go to the key_val_pairs
             *)
             let key_val_pairs, default =
               match l with
               | [ inner_l1; inner_l2; inner_l3 ] ->
                 let next_accu = accu_key_val_pairs @ [ inner_l2, inner_l3 ] in
                 let f_, l_ =
                   match inner_l1.view with
                   | Term.Apply { f; l; _ } -> f, l
                   | _ -> failwith "Never: Map.add' first term should be Apply"
                 in
                 parse_map_term_view f_ l_ next_accu
               | _ ->
                 let msg =
                   sprintf
                     "Never: Map.add' should have exactly 3 terms in the l, \
                      but got %d"
                     (List.length l)
                 in
                 failwith msg
             in
             key_val_pairs, default
           | ({
                view =
                  Term.Sym
                    Applied_symbol.
                      { sym = { id = Uid.{ name = "Map.const"; _ }; _ }; _ };
                _;
              } :
               Term.term) ->
             (* f is Map.const, l should have only one term, which is default *)
             let default_term =
               match l with
               | [ default_term ] -> default_term
               | _ ->
                 failwith "Never: Map.const should have exactly 1 term in the l"
             in
             accu_key_val_pairs, default_term
           | _ -> failwith "Never: Map.add' or Map.const not found"
         in
         key_val_pairs, default
       in
       let key_val_pairs, default = parse_map_term_view f l [] in

       let default_val_ty_defs, _default_val_type_annot, default_val_expr =
         default |> parse_term |> unwrap
       in

       let key_terms, val_terms = key_val_pairs |> List.rev |> List.split in

       let keys_ty_defs, _key_type_annots, key_exprs =
         key_terms |> List.map (fun k -> parse_term k |> unwrap) |> unzip3
       in

       let vals_ty_defs, _val_type_annots, val_exprs =
         val_terms |> List.map (fun k -> parse_term k |> unwrap) |> unzip3
       in

       let defaultdict_expr =
         Ast.init_defaultdict default_val_expr
           (CCList.combine key_exprs val_exprs)
       in

       (* print_endline "key_val_pairs:";
       List.iter
         (fun (k, v) ->
           let fmt = Format.str_formatter in
           Format.fprintf fmt "%a@?" Pretty_print.pp_term k;
           print_endline (Format.flush_str_formatter ());
           Format.fprintf fmt "%a@?" Pretty_print.pp_term v;
           print_endline (Format.flush_str_formatter ()))
         key_val_pairs;

       print_endline "default:";
       let fmt = Format.str_formatter in
       Format.fprintf fmt "%a@?" Pretty_print.pp_term default;
       print_endline (Format.flush_str_formatter ()); *)
       Ok
         ( default_val_ty_defs @ List.flatten keys_ty_defs
           @ List.flatten vals_ty_defs,
           Some type_annot,
           defaultdict_expr )
     with Early_return msg -> Error msg)
  | _, _ ->
    let msg = "case other than const, construct, or apply" in
    Error msg

let parse_model (model : (Term.term, Type.t) Imandrax_api_common.Model.t_poly) :
    Ast.stmt list =
  let (app_sym : Type.t Applied_symbol.t_poly), term = unpack_model model in
  let ty_defs, type_annot, term_expr =
    match parse_term term with
    | Ok (ty_defs, type_annot, term_expr) -> ty_defs, type_annot, term_expr
    | Error msg -> failwith msg
  in

  let assign_stmt =
    let target = app_sym.sym.id.name in
    match type_annot with
    | None ->
      Ast.Assign
        {
          targets = [ Ast.Name { Ast.id = target; ctx = Ast.Load } ];
          value = term_expr;
          type_comment = None;
        }
    | Some type_annot ->
      Ast.AnnAssign
        {
          target = Ast.Name { Ast.id = target; ctx = Ast.Load };
          annotation = type_annot;
          value = Some term_expr;
          simple = 1;
        }
  in
  List.append ty_defs [ assign_stmt ]

let sep : string = "\n" ^ CCString.repeat "<>" 10 ^ "\n"

(* <><><><><><><><><><><><><><><><><><><><> *)

let%expect_test "parse fun decomp art" =
  let yaml_str = CCIO.File.read_exn "../test/data/fun_decomp/basic.yaml" in
  let (yaml : Yaml.value) = Yaml.of_string_exn yaml_str in
  let name, code, art =
    match yaml with
    | `O
        (("name", `String name)
        :: ("iml", `String code)
        :: _
        :: ("decomp_res", `O (("artifact", art) :: _))
        :: _) ->
      name, code, art
    | _ -> failwith "Invalid yaml"
  in

  printf "name: %s\n" name;
  printf "code:\n %s\n" code;

  let (fun_decomp : Mir.Fun_decomp.t) = Util.yaml_to_fun_decomp art in

  printf "Fun decomp:\n";
  let fmt = Format.str_formatter in
  Format.fprintf fmt "%a@?" Pretty_print.pp_fun_decomp fun_decomp;
  print_endline (Format.flush_str_formatter ());

  ();
  [%expect
    {|
    name: basic
    code:
     let g = fun x -> x + 1

    let f = fun x -> if x > 0 then x + 2 else g x

    Fun decomp:
    {
      f_id = g/hQBmX1o7EiqK6op4OPzD1QzuQ7yFh7B29Cpq7flvUtI;
      f_args =
        [{ id = x/223129; ty = { view = (Constr (int,[]));
                                 generation = 1 } }];
      regions =
        [(1 elements)
         {
           constraints =
             [{ view = (Const true);
                ty = { view = (Constr (bool,[]));
                       generation = 1 };
                generation = 0;
                sub_anchor = None }];
           invariant =
             { view =
                 Apply {f = { view =
                                (Sym
                                  (+ : { view =
                                           (Arrow ((),
                                                   { view = (Constr (int,[]));
                                                     generation = 1 },
                                                   { view =
                                                       (Arrow ((),
                                                               { view =
                                                                   (Constr
                                                                     (int,[]));
                                                                 generation = 1 },
                                                               { view =
                                                                   (Constr
                                                                     (int,[]));
                                                                 generation = 1 }));
                                                     generation = 1 }));
                                         generation = 1 }));
                              ty =
                                { view =
                                    (Arrow ((),
                                            { view = (Constr (int,[]));
                                              generation = 1 },
                                            { view =
                                                (Arrow ((),
                                                        { view =
                                                            (Constr (int,[]));
                                                          generation = 1 },
                                                        { view =
                                                            (Constr (int,[]));
                                                          generation = 1 }));
                                              generation = 1 }));
                                  generation = 1 };
                              generation = 0;
                              sub_anchor = None };
                        l =
                          [{ view =
                               (Var
                                 { id = x/223129;
                                   ty =
                                   { view = (Constr (int,[]));
                                     generation = 1 }
                                   });
                             ty = { view = (Constr (int,[]));
                                    generation = 1 };
                             generation = 0;
                             sub_anchor = None };
                           { view = (Const 1);
                             ty = { view = (Constr (int,[]));
                                    generation = 1 };
                             generation = 0;
                             sub_anchor = None }]
                        };
               ty = { view = (Constr (int,[]));
                      generation = 1 };
               generation = 0;
               sub_anchor = None };
           meta =
             ["str":
                Assoc
                  {"model_eval": String "1";
                   "invariant": String "x + 1";
                   "constraints": List [String "true"];
                   "model": Assoc {"x": String "0"}};
              "model_eval":
                Term
                  { view = (Const 1);
                    ty = { view = (Constr (int,[]));
                           generation = 1 };
                    generation = 0;
                    sub_anchor = None };
              "id": String "0e497a79-d75e-4c74-95b2-5d3c64396aae"];
           status =
             Feasible
               { tys = [];
                 consts =
                 [((x/223129 : { view = (Constr (int,[]));
                                 generation = 1 }),
                   { view = (Const 0);
                     ty = { view = (Constr (int,[]));
                            generation = 1 };
                     generation = 0;
                     sub_anchor = None })
                   ];
                 funs = []; representable = true; completed = false;
                 ty_subst = [] }
           }]
      }
    |}]

(* <><><><><><><><><><><><><><><><><><><><> *)

let%expect_test "parse model art" =
  (* let yaml_str = CCIO.File.read_exn "../examples/art/art.yaml" in *)
  let yaml_str =
    (* CCIO.File.read_exn "../test/data/model/composite/map_default_value_only.yaml" *)
    (* CCIO.File.read_exn "../test/data/model/primitive/empty_list.yaml" *)
    CCIO.File.read_exn "../test/data/model/polymorphic/annotated_list.yaml"
    (* CCIO.File.read_exn "../test/data/model/polymorphic/ambiguous_type_name.yaml" *)
  in
  let yaml = Yaml.of_string_exn yaml_str in

  let name, code =
    match yaml with
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

  let model = Util.yaml_to_model yaml in
  let app_sym, term = unpack_model model in

  (* Create a custom formatter with wider margin *)
  let fmt = Format.str_formatter in
  Format.pp_set_margin fmt 400;
  Format.pp_set_max_indent fmt 390;

  let _term_view = term.view in

  print_endline sep;

  print_endline "Applied symbol:";
  Format.fprintf fmt "%a@?"
    (Imandrax_api_common.Applied_symbol.pp_t_poly Mir.Type.pp)
    app_sym;
  print_endline (Format.flush_str_formatter ());
  printf "%s\n" sep;

  print_endline "Term:";
  Format.fprintf fmt "%a@?" Pretty_print.pp_term term;
  print_endline (Format.flush_str_formatter ());
  printf "%s\n" sep;

  (* print_endline "Term view:";
  Format.fprintf fmt "%a@?" (Term.pp_view Type.pp) term_view;
  print_endline (Format.flush_str_formatter ());
  printf "%s\n" sep; *)
  print_endline "Parsing term:\n";
  let ty_defs, type_annot, expr =
    match parse_term term with
    | Ok (ty_defs, type_annot, expr) -> ty_defs, type_annot, expr
    | Error msg -> failwith msg
  in

  printf "Type defs:\n";
  List.iter (fun ty_def -> print_endline (Ast.show_stmt ty_def)) ty_defs;

  printf "Type annot: ";
  (match type_annot with
  | None -> print_endline "None"
  | Some ty_annot -> print_endline (Ast.show_expr ty_annot));

  printf "\n";
  printf "Expr:\n";
  print_endline (Ast.show_expr expr);

  print_endline sep;
  print_endline "Json:\n";

  let stmts = parse_model model in

  (* Convert each statement to JSON and collect them in a list *)
  let json_out : Yojson.Safe.t = `List (List.map Ast.stmt_to_yojson stmts) in

  (* Also print to stdout for the test *)
  Yojson.Safe.pretty_to_string json_out |> print_endline;

  [%expect
    {|
    name: annotated_list
    code: let v =  (fun (w: _ list) -> if w = [] then true else false)

    <><><><><><><><><><>

    Applied symbol:
    (w/16003 : { view = (Constr (list, [{ view = (Var a/16002); generation = 3 }])); generation = 3 })

    <><><><><><><><><><>

    Term:
    { view = Construct {c = ([] : { view = (Constr (list,[{ view = (Constr (_a_0/0[temp],[]));
                                                            generation = 3 }]));
                                    generation = 3 });args = []};
      ty = { view = (Constr (list,[{ view = (Constr (_a_0/0[temp],[]));
                                     generation = 3 }]));
             generation = 3 };
      generation = 1; sub_anchor = None }

    <><><><><><><><><><>

    Parsing term:

    Type defs:
    Type annot: None

    Expr:
    (Ast.List { Ast.elts = []; ctx = Ast.Load })

    <><><><><><><><><><>

    Json:

    [
      [
        "Assign",
        {
          "targets": [ [ "Name", { "id": "w", "ctx": [ "Load" ] } ] ],
          "value": [ "List", { "elts": [], "ctx": [ "Load" ] } ],
          "type_comment": null
        }
      ]
    ]
    |}]
