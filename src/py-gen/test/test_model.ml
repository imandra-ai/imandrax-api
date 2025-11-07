open Printf
open Py_gen
open Py_gen.Parse
module Mir = Imandrax_api_mir
module Type = Imandrax_api_mir.Type
module Term = Imandrax_api_mir.Term
module Model = Imandrax_api_mir.Model

(* Load a Mir.model from a yaml file *)
let load_artifact (sub_dir : string option) (name : string) : Model.t =
  let yaml_str =
    match sub_dir with
    | None -> CCIO.File.read_exn (sprintf "data/model/%s.yaml" name)
    | Some sub_dir ->
      CCIO.File.read_exn (sprintf "data/model/%s/%s.yaml" sub_dir name)
  in
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
  printf "iml_code:\n%s\n\n" iml_code;

  Util.yaml_to_model yaml

let test_parse_model (sub_dir : string option) (name : string) : unit =
  let model = load_artifact sub_dir name in
  let _app_sym, term = unpack_model model in
  let ty_defs, type_annot, expr =
    match parse_term term with
    | Ok (ty_defs, type_annot, expr) -> ty_defs, type_annot, expr
    | Error msg -> failwith msg
  in
  printf "Type defs:\n";
  List.iter (fun ty_def -> print_endline (Ast.show_stmt ty_def)) ty_defs;
  printf "\n";

  printf "Type annot:\n";
  (match type_annot with
  | None -> print_endline "None"
  | Some type_annot -> print_endline (Ast.show_expr type_annot));
  printf "\n";

  printf "Expr:\n";
  print_endline (Ast.show_expr expr);
  ()

let%expect_test "bool list" =
  test_parse_model (Some "primitive") "bool_list";

  [%expect
    {|
    name: bool list
    iml_code:
    let v =
      fun w ->
        if w = [true; false] then true else false

    Type defs:

    Type annot:
    (Ast.Subscript
       { Ast.value = (Ast.Name { Ast.id = "list"; ctx = Ast.Load });
         slice = (Ast.Name { Ast.id = "bool"; ctx = Ast.Load }); ctx = Ast.Load })

    Expr:
    (Ast.List
       { Ast.elts =
         [(Ast.Constant { Ast.value = (Ast.Bool true); kind = None });
           (Ast.Constant { Ast.value = (Ast.Bool false); kind = None })];
         ctx = Ast.Load })
    |}]

let%expect_test "empty list" =
  test_parse_model (Some "primitive") "empty_list";
  [%expect
    {|
    name: empty list
    iml_code:
    let v =
      fun w ->
        if w = [] then true else false

    Type defs:

    Type annot:
    None

    Expr:
    (Ast.List { Ast.elts = []; ctx = Ast.Load })
    |}]

let%expect_test "int option" =
  test_parse_model (Some "primitive") "int_option";
  [%expect
    {|
    name: int option
    iml_code:
    let v =
      fun w ->
        if w = Some 2 then true else false

    Type defs:
    (Ast.ClassDef
       { Ast.name = "Some"; bases = []; keywords = [];
         body =
         [(Ast.AnnAssign
             { Ast.target = (Ast.Name { Ast.id = "arg0"; ctx = Ast.Load });
               annotation = (Ast.Name { Ast.id = "int"; ctx = Ast.Load });
               value = None; simple = 1 })
           ];
         decorator_list = [(Ast.Name { Ast.id = "dataclass"; ctx = Ast.Load })] })
    (Ast.Assign
       { Ast.targets = [(Ast.Name { Ast.id = "option"; ctx = Ast.Load })];
         value = (Ast.Name { Ast.id = "Some"; ctx = Ast.Load });
         type_comment = None })

    Type annot:
    (Ast.Name { Ast.id = "option"; ctx = Ast.Load })

    Expr:
    (Ast.Call
       { Ast.func = (Ast.Name { Ast.id = "Some"; ctx = Ast.Load });
         args = [(Ast.Constant { Ast.value = (Ast.Int 2); kind = None })];
         keywords = [] })
    |}]

let%expect_test "int" =
  test_parse_model (Some "primitive") "int";
  [%expect
    {|
    name: int
    iml_code:
    let v =
      fun w ->
        if w = 2 then true else false

    Type defs:

    Type annot:
    (Ast.Name { Ast.id = "int"; ctx = Ast.Load })

    Expr:
    (Ast.Constant { Ast.value = (Ast.Int 2); kind = None })
    |}]

let%expect_test "LChar" =
  test_parse_model (Some "primitive") "LChar";
  [%expect
    {|
    name: LChar
    iml_code:
    let v =
      fun w ->
        if w = LChar.zero then true else false

    Type defs:

    Type annot:
    (Ast.Name { Ast.id = "str"; ctx = Ast.Load })

    Expr:
    (Ast.Constant { Ast.value = (Ast.String "\000"); kind = None })
    |}]

let%expect_test "LString" =
  test_parse_model (Some "primitive") "LString";
  [%expect
    {|
    name: LString
    iml_code:
    let v =
      fun w ->
        if w = {l|hi|l} then true else false

    Type defs:

    Type annot:
    (Ast.Subscript
       { Ast.value = (Ast.Name { Ast.id = "list"; ctx = Ast.Load });
         slice = (Ast.Name { Ast.id = "str"; ctx = Ast.Load }); ctx = Ast.Load })

    Expr:
    (Ast.List
       { Ast.elts =
         [(Ast.Constant { Ast.value = (Ast.String "h"); kind = None });
           (Ast.Constant { Ast.value = (Ast.String "i"); kind = None })];
         ctx = Ast.Load })
    |}]

let%expect_test "real" =
  test_parse_model (Some "primitive") "real";
  [%expect
    {|
    name: real
    iml_code:
    let v =
      fun w ->
        if w = 3.14 then true else false

    Type defs:

    Type annot:
    (Ast.Name { Ast.id = "float"; ctx = Ast.Load })

    Expr:
    (Ast.Constant { Ast.value = (Ast.Float 3.14); kind = None })
    |}]

let%expect_test "record" =
  test_parse_model (Some "primitive") "record";
  [%expect
    {|
    name: record
    iml_code:
    type user = {
        id: int;
        active: bool;
    }

    let v = {id = 1; active = true}

    let v =
      fun w ->
        if w = v then true else false

    Type defs:
    (Ast.ClassDef
       { Ast.name = "user"; bases = []; keywords = [];
         body =
         [(Ast.AnnAssign
             { Ast.target = (Ast.Name { Ast.id = "id"; ctx = Ast.Load });
               annotation = (Ast.Name { Ast.id = "int"; ctx = Ast.Load });
               value = None; simple = 1 });
           (Ast.AnnAssign
              { Ast.target = (Ast.Name { Ast.id = "active"; ctx = Ast.Load });
                annotation = (Ast.Name { Ast.id = "bool"; ctx = Ast.Load });
                value = None; simple = 1 })
           ];
         decorator_list = [(Ast.Name { Ast.id = "dataclass"; ctx = Ast.Load })] })

    Type annot:
    (Ast.Name { Ast.id = "user"; ctx = Ast.Load })

    Expr:
    (Ast.Call
       { Ast.func = (Ast.Name { Ast.id = "user"; ctx = Ast.Load });
         args =
         [(Ast.Constant { Ast.value = (Ast.Int 1); kind = None });
           (Ast.Constant { Ast.value = (Ast.Bool true); kind = None })];
         keywords = [] })
    |}]

let%expect_test "single element int list" =
  test_parse_model (Some "primitive") "single_element_int_list";
  [%expect
    {|
    name: single element int list
    iml_code:
    let v =
      fun w ->
        if w = [1] then true else false

    Type defs:

    Type annot:
    (Ast.Subscript
       { Ast.value = (Ast.Name { Ast.id = "list"; ctx = Ast.Load });
         slice = (Ast.Name { Ast.id = "int"; ctx = Ast.Load }); ctx = Ast.Load })

    Expr:
    (Ast.List
       { Ast.elts = [(Ast.Constant { Ast.value = (Ast.Int 1); kind = None })];
         ctx = Ast.Load })
    |}]

let%expect_test "tuple (bool * int)" =
  test_parse_model (Some "primitive") "tuple_(bool_*_int)";
  [%expect
    {|
    name: tuple (bool * int)
    iml_code:
    let v =
      fun w ->
        if w = (true, 2) then true else false

    Type defs:

    Type annot:
    (Ast.Subscript
       { Ast.value = (Ast.Name { Ast.id = "tuple"; ctx = Ast.Load });
         slice =
         (Ast.Tuple
            { Ast.elts =
              [(Ast.Name { Ast.id = "bool"; ctx = Ast.Load });
                (Ast.Name { Ast.id = "int"; ctx = Ast.Load })];
              ctx = Ast.Load; dims = [] });
         ctx = Ast.Load })

    Expr:
    (Ast.Tuple
       { Ast.elts =
         [(Ast.Constant { Ast.value = (Ast.Bool true); kind = None });
           (Ast.Constant { Ast.value = (Ast.Int 2); kind = None })];
         ctx = Ast.Load; dims = [] })
    |}]

let%expect_test "variant1" =
  test_parse_model (Some "primitive") "variant1";
  [%expect
    {|
    name: variant1
    iml_code:
    type status =
        | Active
        | Waitlist of int

    let v = Active

    let v =
      fun w ->
        if w = v then true else false

    Type defs:
    (Ast.ClassDef
       { Ast.name = "Active"; bases = []; keywords = []; body = [Ast.Pass];
         decorator_list = [(Ast.Name { Ast.id = "dataclass"; ctx = Ast.Load })] })
    (Ast.Assign
       { Ast.targets = [(Ast.Name { Ast.id = "status"; ctx = Ast.Load })];
         value = (Ast.Name { Ast.id = "Active"; ctx = Ast.Load });
         type_comment = None })

    Type annot:
    (Ast.Name { Ast.id = "status"; ctx = Ast.Load })

    Expr:
    (Ast.Call
       { Ast.func = (Ast.Name { Ast.id = "Active"; ctx = Ast.Load }); args = [];
         keywords = [] })
    |}]

let%expect_test "variant2" =
  test_parse_model (Some "primitive") "variant2";
  [%expect
    {|
    name: variant2
    iml_code:
    type status =
        | Active
        | Waitlist of int

    let v = Waitlist 1

    let v =
      fun w ->
        if w = v then true else false

    Type defs:
    (Ast.ClassDef
       { Ast.name = "Waitlist"; bases = []; keywords = [];
         body =
         [(Ast.AnnAssign
             { Ast.target = (Ast.Name { Ast.id = "arg0"; ctx = Ast.Load });
               annotation = (Ast.Name { Ast.id = "int"; ctx = Ast.Load });
               value = None; simple = 1 })
           ];
         decorator_list = [(Ast.Name { Ast.id = "dataclass"; ctx = Ast.Load })] })
    (Ast.Assign
       { Ast.targets = [(Ast.Name { Ast.id = "status"; ctx = Ast.Load })];
         value = (Ast.Name { Ast.id = "Waitlist"; ctx = Ast.Load });
         type_comment = None })

    Type annot:
    (Ast.Name { Ast.id = "status"; ctx = Ast.Load })

    Expr:
    (Ast.Call
       { Ast.func = (Ast.Name { Ast.id = "Waitlist"; ctx = Ast.Load });
         args = [(Ast.Constant { Ast.value = (Ast.Int 1); kind = None })];
         keywords = [] })
    |}]

let%expect_test "variant3" =
  test_parse_model (Some "primitive") "variant3";
  [%expect
    {|
    name: variant3
    iml_code:
    type status =
        | Active
        | Waitlist of int * bool

    let v = Waitlist (2, true)

    let v =
      fun w ->
        if w = v then true else false

    Type defs:
    (Ast.ClassDef
       { Ast.name = "Waitlist"; bases = []; keywords = [];
         body =
         [(Ast.AnnAssign
             { Ast.target = (Ast.Name { Ast.id = "arg0"; ctx = Ast.Load });
               annotation = (Ast.Name { Ast.id = "int"; ctx = Ast.Load });
               value = None; simple = 1 });
           (Ast.AnnAssign
              { Ast.target = (Ast.Name { Ast.id = "arg1"; ctx = Ast.Load });
                annotation = (Ast.Name { Ast.id = "bool"; ctx = Ast.Load });
                value = None; simple = 1 })
           ];
         decorator_list = [(Ast.Name { Ast.id = "dataclass"; ctx = Ast.Load })] })
    (Ast.Assign
       { Ast.targets = [(Ast.Name { Ast.id = "status"; ctx = Ast.Load })];
         value = (Ast.Name { Ast.id = "Waitlist"; ctx = Ast.Load });
         type_comment = None })

    Type annot:
    (Ast.Name { Ast.id = "status"; ctx = Ast.Load })

    Expr:
    (Ast.Call
       { Ast.func = (Ast.Name { Ast.id = "Waitlist"; ctx = Ast.Load });
         args =
         [(Ast.Constant { Ast.value = (Ast.Int 2); kind = None });
           (Ast.Constant { Ast.value = (Ast.Bool true); kind = None })];
         keywords = [] })
    |}]

let%expect_test "variant_and_record" =
  test_parse_model (Some "composite") "variant_and_record";
  [%expect
    {|
    name: variant_and_record
    iml_code:
    type direction = North | South | East | West

    type position = { x: int; y: int; z: real }

    type movement =
      | Stay of position
      | Move of position * direction

    let v =
      fun w ->
          if w = Move ({x=1; y=2; z=3.0}, North) then true else false

    Type defs:
    (Ast.ClassDef
       { Ast.name = "position"; bases = []; keywords = [];
         body =
         [(Ast.AnnAssign
             { Ast.target = (Ast.Name { Ast.id = "x"; ctx = Ast.Load });
               annotation = (Ast.Name { Ast.id = "int"; ctx = Ast.Load });
               value = None; simple = 1 });
           (Ast.AnnAssign
              { Ast.target = (Ast.Name { Ast.id = "y"; ctx = Ast.Load });
                annotation = (Ast.Name { Ast.id = "int"; ctx = Ast.Load });
                value = None; simple = 1 });
           (Ast.AnnAssign
              { Ast.target = (Ast.Name { Ast.id = "z"; ctx = Ast.Load });
                annotation = (Ast.Name { Ast.id = "real"; ctx = Ast.Load });
                value = None; simple = 1 })
           ];
         decorator_list = [(Ast.Name { Ast.id = "dataclass"; ctx = Ast.Load })] })
    (Ast.ClassDef
       { Ast.name = "North"; bases = []; keywords = []; body = [Ast.Pass];
         decorator_list = [(Ast.Name { Ast.id = "dataclass"; ctx = Ast.Load })] })
    (Ast.Assign
       { Ast.targets = [(Ast.Name { Ast.id = "direction"; ctx = Ast.Load })];
         value = (Ast.Name { Ast.id = "North"; ctx = Ast.Load });
         type_comment = None })
    (Ast.ClassDef
       { Ast.name = "Move"; bases = []; keywords = [];
         body =
         [(Ast.AnnAssign
             { Ast.target = (Ast.Name { Ast.id = "arg0"; ctx = Ast.Load });
               annotation = (Ast.Name { Ast.id = "position"; ctx = Ast.Load });
               value = None; simple = 1 });
           (Ast.AnnAssign
              { Ast.target = (Ast.Name { Ast.id = "arg1"; ctx = Ast.Load });
                annotation = (Ast.Name { Ast.id = "direction"; ctx = Ast.Load });
                value = None; simple = 1 })
           ];
         decorator_list = [(Ast.Name { Ast.id = "dataclass"; ctx = Ast.Load })] })
    (Ast.Assign
       { Ast.targets = [(Ast.Name { Ast.id = "movement"; ctx = Ast.Load })];
         value = (Ast.Name { Ast.id = "Move"; ctx = Ast.Load });
         type_comment = None })

    Type annot:
    (Ast.Name { Ast.id = "movement"; ctx = Ast.Load })

    Expr:
    (Ast.Call
       { Ast.func = (Ast.Name { Ast.id = "Move"; ctx = Ast.Load });
         args =
         [(Ast.Call
             { Ast.func = (Ast.Name { Ast.id = "position"; ctx = Ast.Load });
               args =
               [(Ast.Constant { Ast.value = (Ast.Int 1); kind = None });
                 (Ast.Constant { Ast.value = (Ast.Int 2); kind = None });
                 (Ast.Constant { Ast.value = (Ast.Float 3.); kind = None })];
               keywords = [] });
           (Ast.Call
              { Ast.func = (Ast.Name { Ast.id = "North"; ctx = Ast.Load });
                args = []; keywords = [] })
           ];
         keywords = [] })
    |}]

let%expect_test "inline record" =
  test_parse_model (Some "composite") "inline_record";
  [%expect
    {|
    name: inline_record
    iml_code:
    type event =
        | Click of { x: int; y: int }
        | Keypress of { key: LChar.t; modifiers: LString.t list }
        | Scroll of { delta: real }

    let v = Scroll {delta = 2.0}
    let v = fun w -> if w = v then true else false

    Type defs:
    (Ast.ClassDef
       { Ast.name = "Scroll"; bases = []; keywords = [];
         body =
         [(Ast.AnnAssign
             { Ast.target = (Ast.Name { Ast.id = "arg0"; ctx = Ast.Load });
               annotation = (Ast.Name { Ast.id = "real"; ctx = Ast.Load });
               value = None; simple = 1 })
           ];
         decorator_list = [(Ast.Name { Ast.id = "dataclass"; ctx = Ast.Load })] })
    (Ast.Assign
       { Ast.targets = [(Ast.Name { Ast.id = "event"; ctx = Ast.Load })];
         value = (Ast.Name { Ast.id = "Scroll"; ctx = Ast.Load });
         type_comment = None })

    Type annot:
    (Ast.Name { Ast.id = "event"; ctx = Ast.Load })

    Expr:
    (Ast.Call
       { Ast.func = (Ast.Name { Ast.id = "Scroll"; ctx = Ast.Load });
         args = [(Ast.Constant { Ast.value = (Ast.Float 2.); kind = None })];
         keywords = [] })
    |}]

let%expect_test "map 0" =
  test_parse_model (Some "composite") "map_int_bool_0";
  [%expect
    {|
    name: map_int_bool
    iml_code:
    let v : (int, bool) Map.t =
      Map.const false

    let v = fun w -> if w = v then true else false

    Type defs:

    Type annot:
    (Ast.Subscript
       { Ast.value = (Ast.Name { Ast.id = "defaultdict"; ctx = Ast.Load });
         slice =
         (Ast.Tuple
            { Ast.elts =
              [(Ast.Name { Ast.id = "int"; ctx = Ast.Load });
                (Ast.Name { Ast.id = "bool"; ctx = Ast.Load })];
              ctx = Ast.Load; dims = [] });
         ctx = Ast.Load })

    Expr:
    (Ast.Call
       { Ast.func = (Ast.Name { Ast.id = "defaultdict"; ctx = Ast.Load });
         args =
         [(Ast.Lambda
             { Ast.args =
               { Ast.posonlyargs = []; args = []; vararg = None; kwonlyargs = [];
                 kw_defaults = []; kwarg = None; defaults = [] };
               body =
               (Ast.Constant { Ast.value = (Ast.Bool false); kind = None }) })
           ];
         keywords = [] })
    |}]

let%expect_test "map 1" =
  test_parse_model (Some "composite") "map_int_bool_1";
  [%expect
    {|
    name: map_int_bool_1
    iml_code:
    let v : (int, bool) Map.t =
      Map.const false
      |> Map.add 2 true

    let v = fun w -> if w = v then true else false

    Type defs:

    Type annot:
    (Ast.Subscript
       { Ast.value = (Ast.Name { Ast.id = "defaultdict"; ctx = Ast.Load });
         slice =
         (Ast.Tuple
            { Ast.elts =
              [(Ast.Name { Ast.id = "int"; ctx = Ast.Load });
                (Ast.Name { Ast.id = "bool"; ctx = Ast.Load })];
              ctx = Ast.Load; dims = [] });
         ctx = Ast.Load })

    Expr:
    (Ast.Call
       { Ast.func = (Ast.Name { Ast.id = "defaultdict"; ctx = Ast.Load });
         args =
         [(Ast.Lambda
             { Ast.args =
               { Ast.posonlyargs = []; args = []; vararg = None; kwonlyargs = [];
                 kw_defaults = []; kwarg = None; defaults = [] };
               body =
               (Ast.Constant { Ast.value = (Ast.Bool false); kind = None }) });
           (Ast.Dict
              { Ast.keys =
                [(Some (Ast.Constant { Ast.value = (Ast.Int 2); kind = None }))];
                values =
                [(Ast.Constant { Ast.value = (Ast.Bool true); kind = None })] })
           ];
         keywords = [] })
    |}]

let%expect_test "map 2" =
  test_parse_model (Some "composite") "map_int_bool_2";
  [%expect
    {|
    name: map_int_bool_2
    iml_code:
    let v : (int, bool) Map.t =
      Map.const false
      |> Map.add 2 true
      |> Map.add 3 true

    let v = fun w -> if w = v then true else false

    Type defs:

    Type annot:
    (Ast.Subscript
       { Ast.value = (Ast.Name { Ast.id = "defaultdict"; ctx = Ast.Load });
         slice =
         (Ast.Tuple
            { Ast.elts =
              [(Ast.Name { Ast.id = "int"; ctx = Ast.Load });
                (Ast.Name { Ast.id = "bool"; ctx = Ast.Load })];
              ctx = Ast.Load; dims = [] });
         ctx = Ast.Load })

    Expr:
    (Ast.Call
       { Ast.func = (Ast.Name { Ast.id = "defaultdict"; ctx = Ast.Load });
         args =
         [(Ast.Lambda
             { Ast.args =
               { Ast.posonlyargs = []; args = []; vararg = None; kwonlyargs = [];
                 kw_defaults = []; kwarg = None; defaults = [] };
               body =
               (Ast.Constant { Ast.value = (Ast.Bool false); kind = None }) });
           (Ast.Dict
              { Ast.keys =
                [(Some (Ast.Constant { Ast.value = (Ast.Int 2); kind = None }));
                  (Some (Ast.Constant { Ast.value = (Ast.Int 3); kind = None }))];
                values =
                [(Ast.Constant { Ast.value = (Ast.Bool true); kind = None });
                  (Ast.Constant { Ast.value = (Ast.Bool true); kind = None })]
                })
           ];
         keywords = [] })
    |}]

let%expect_test "map 3" =
  test_parse_model (Some "composite") "map_int_bool_3";
  [%expect
    {|
    name: map_int_bool_3
    iml_code:
    let v : (int, bool) Map.t =
      Map.const false
      |> Map.add 2 true
      |> Map.add 3 false
      |> Map.add 5 true

    let v = fun w -> if w = v then true else false

    Type defs:

    Type annot:
    (Ast.Subscript
       { Ast.value = (Ast.Name { Ast.id = "defaultdict"; ctx = Ast.Load });
         slice =
         (Ast.Tuple
            { Ast.elts =
              [(Ast.Name { Ast.id = "int"; ctx = Ast.Load });
                (Ast.Name { Ast.id = "bool"; ctx = Ast.Load })];
              ctx = Ast.Load; dims = [] });
         ctx = Ast.Load })

    Expr:
    (Ast.Call
       { Ast.func = (Ast.Name { Ast.id = "defaultdict"; ctx = Ast.Load });
         args =
         [(Ast.Lambda
             { Ast.args =
               { Ast.posonlyargs = []; args = []; vararg = None; kwonlyargs = [];
                 kw_defaults = []; kwarg = None; defaults = [] };
               body =
               (Ast.Constant { Ast.value = (Ast.Bool false); kind = None }) });
           (Ast.Dict
              { Ast.keys =
                [(Some (Ast.Constant { Ast.value = (Ast.Int 2); kind = None }));
                  (Some (Ast.Constant { Ast.value = (Ast.Int 3); kind = None }));
                  (Some (Ast.Constant { Ast.value = (Ast.Int 5); kind = None }))];
                values =
                [(Ast.Constant { Ast.value = (Ast.Bool true); kind = None });
                  (Ast.Constant { Ast.value = (Ast.Bool false); kind = None });
                  (Ast.Constant { Ast.value = (Ast.Bool true); kind = None })]
                })
           ];
         keywords = [] })
    |}]

let%expect_test "nonempty set" =
  test_parse_model (Some "composite") "set_nonempty";
  [%expect
    {|
    name: set_nonempty
    iml_code:
    let v = Set.of_list [1; 2; 3; 2; 1]

    let v = fun w -> if w = v then true else false

    Type defs:

    Type annot:
    (Ast.Subscript
       { Ast.value = (Ast.Name { Ast.id = "defaultdict"; ctx = Ast.Load });
         slice =
         (Ast.Tuple
            { Ast.elts =
              [(Ast.Name { Ast.id = "int"; ctx = Ast.Load });
                (Ast.Name { Ast.id = "bool"; ctx = Ast.Load })];
              ctx = Ast.Load; dims = [] });
         ctx = Ast.Load })

    Expr:
    (Ast.Call
       { Ast.func = (Ast.Name { Ast.id = "defaultdict"; ctx = Ast.Load });
         args =
         [(Ast.Lambda
             { Ast.args =
               { Ast.posonlyargs = []; args = []; vararg = None; kwonlyargs = [];
                 kw_defaults = []; kwarg = None; defaults = [] };
               body =
               (Ast.Constant { Ast.value = (Ast.Bool false); kind = None }) });
           (Ast.Dict
              { Ast.keys =
                [(Some (Ast.Constant { Ast.value = (Ast.Int 1); kind = None }));
                  (Some (Ast.Constant { Ast.value = (Ast.Int 3); kind = None }));
                  (Some (Ast.Constant { Ast.value = (Ast.Int 2); kind = None }))];
                values =
                [(Ast.Constant { Ast.value = (Ast.Bool true); kind = None });
                  (Ast.Constant { Ast.value = (Ast.Bool true); kind = None });
                  (Ast.Constant { Ast.value = (Ast.Bool true); kind = None })]
                })
           ];
         keywords = [] })
    |}]

let%expect_test "nonempty multiset" =
  test_parse_model (Some "composite") "multiset_nonempty";
  [%expect
    {|
    name: multiset_nonempty
    iml_code:
    let v = Multiset.of_list [1; 2; 3; 2; 1]

    let v = fun w -> if w = v then true else false

    Type defs:

    Type annot:
    (Ast.Subscript
       { Ast.value = (Ast.Name { Ast.id = "defaultdict"; ctx = Ast.Load });
         slice =
         (Ast.Tuple
            { Ast.elts =
              [(Ast.Name { Ast.id = "int"; ctx = Ast.Load });
                (Ast.Name { Ast.id = "int"; ctx = Ast.Load })];
              ctx = Ast.Load; dims = [] });
         ctx = Ast.Load })

    Expr:
    (Ast.Call
       { Ast.func = (Ast.Name { Ast.id = "defaultdict"; ctx = Ast.Load });
         args =
         [(Ast.Lambda
             { Ast.args =
               { Ast.posonlyargs = []; args = []; vararg = None; kwonlyargs = [];
                 kw_defaults = []; kwarg = None; defaults = [] };
               body = (Ast.Constant { Ast.value = (Ast.Int 0); kind = None }) });
           (Ast.Dict
              { Ast.keys =
                [(Some (Ast.Constant { Ast.value = (Ast.Int 1); kind = None }));
                  (Some (Ast.Constant { Ast.value = (Ast.Int 3); kind = None }));
                  (Some (Ast.Constant { Ast.value = (Ast.Int 2); kind = None }))];
                values =
                [(Ast.Constant { Ast.value = (Ast.Int 2); kind = None });
                  (Ast.Constant { Ast.value = (Ast.Int 1); kind = None });
                  (Ast.Constant { Ast.value = (Ast.Int 2); kind = None })]
                })
           ];
         keywords = [] })
    |}]
