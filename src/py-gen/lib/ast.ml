type location = {
  lineno: int;
  col_offset: int;
  end_lineno: int option;
  end_col_offset: int option;
}
[@@deriving show]

type ast =
  | Keyword of keyword
  | Expr of expr
  | Module of module_ast

and module_ast = { body: stmt list (* type_ignores: list[TypeIgnore] *) }

and keyword = {
  (* location: location; *)
  arg: string option;
  value: expr;
}

and expr =
  | Constant of constant
  | BoolOp of bool_op
  | BinOp of bin_op
  | UnaryOp of unary_op
  (* | Lambda *)
  | IfExp of (expr * expr * expr)
  | Dict of (expr option list * expr list)
  | Set of expr list
  | ListComp of list_comp
  | List of list_expr
  | Tuple of tuple_expr
  | Name of name_expr
  | Attribute of attribute_expr
  | Subscript of subscript_expr
  | Call of call_expr

and constant = {
  value: constant_value;
  kind: string option;
}

and constant_value =
  | String of string
  | Bytes of bytes
  | Bool of bool
  | Int of int
  | Float of float
  | Unit
(* TODO: complex and EllipsisType *)

and bool_op =
  | And
  | Or

and bin_op = {
  left: expr;
  op: operator;
  right: expr;
}

and operator =
  | Add
  | Sub
  | Mult
  | MatMult
  | Div
  | Mod
  | Pow
  | LShift
  | RShift
  | BitOr
  | BitXor
  | BitAnd
  | FloorDiv

and unary_op =
  | Invert
  | Not
  | UAdd
  | USub

(* and cmpop =
  | Eq
  | NotEq
  | Lt
  | LtE
  | Gt
  | GtE
  | Is
  | IsNot
  | In
  | NotIn *)
and comprehension = {
  target: expr;
  iter: expr;
  ifs: expr list;
  is_async: int;
}

and list_comp = {
  elt: expr;
  generators: comprehension list;
}

and expr_context =
  | Load
  | Store
  | Del

and list_expr = {
  elts: expr list;
  ctx: expr_context;
}

and tuple_expr = {
  elts: expr list;
  ctx: expr_context;
  (* contains type parameter expressions (like T, U in generic syntax) *)
  dims: expr list;
}

and name_expr = {
  id: string;
  ctx: expr_context;
}

and attribute_expr = {
  value: expr;
  attr: string;
  ctx: expr_context;
}

and subscript_expr = {
  value: expr;
  slice: expr;
  ctx: expr_context;
}

and call_expr = {
  func: expr;
  args: expr list;
  keywords: keyword list;
}
[@@deriving show]

(* <><><><><><><><><><><><><><><><><><><><> *)
and stmt =
  | Assign of assign_stmt
  | AnnAssign of ann_assign_stmt
  | ClassDef of class_def_stmt
  | Pass

and assign_stmt = {
  targets: expr list;
  value: expr;
  type_comment: string option;
}

and ann_assign_stmt = {
  target: stmt_target;
  annotation: expr;
  value: expr option; (* simple: int *)
}

and stmt_target =
  | Name of name_expr
  | Attribute of attribute_expr
  | Subscript of subscript_expr

and class_def_stmt = {
  name: string;
  bases: expr list;
  keywords: keyword list;
  (* capture arguments like metaclass specification and other keyword arguments
     passed to `__init_sublcass__` or the metaclass
  *)
  body: stmt list;
  decorator_list: expr list;
}

(* <><><><><><><><><><><><><><><><><><><><> *)

(* Placeholder for ctx *)
let mk_ctx () = Load
let bool_expr (b : bool) : expr = Constant { value = Bool b; kind = None }
let string_expr (s : string) : expr = Constant { value = String s; kind = None }

let bools_to_char (bools : bool list) : char =
  if List.length bools <> 8 then
    invalid_arg "bools_to_char: list must contain exactly 8 booleans"
  else (
    let rec bools_to_int acc = function
      | [] -> acc
      | b :: rest ->
        let bit =
          if b then
            1
          else
            0
        in
        bools_to_int ((acc lsl 1) lor bit) rest
    in
    let ascii_value = bools_to_int 0 bools in
    Char.chr ascii_value
  )

let char_to_bools (c : char) : bool list =
  let ascii_value = Char.code c in
  let rec int_to_bools acc n bit_pos =
    if bit_pos < 0 then
      acc
    else (
      let bit = (n lsr bit_pos) land 1 in
      int_to_bools ((bit = 1) :: acc) n (bit_pos - 1)
    )
  in
  int_to_bools [] ascii_value 7

let bool_list_expr_to_char_expr (exprs : expr list) : expr =
  let bools =
    List.map
      (function
        | Constant { value = Bool b; _ } -> b
        | _ -> invalid_arg "bool_list_expr_to_string: expected bool constant")
      exprs
  in
  let char = bools_to_char bools in
  string_expr (String.make 1 char)

let tuple_of_exprs (exprs : expr list) : expr =
  Tuple { elts = exprs; ctx = Load; dims = [] }

let empty_list_expr () : expr = List { elts = []; ctx = mk_ctx () }

let list_of_exprs (exprs : expr list) : expr =
  List { elts = exprs; ctx = mk_ctx () }

let cons_list_expr (head : expr) (tail : expr) : expr =
  match tail with
  | List { elts; _ } -> List { elts = head :: elts; ctx = mk_ctx () }
  | _ -> invalid_arg "cons_list_expr: tail is not a list expr"

(* <><><><><><><><><><><><><><><><><><><><> *)

(* Type view constructor name to Python type name *)
let ty_view_constr_name_mapping : (string * string) list =
  [ "int", "int"; "bool", "bool"; "string", "str" ]

(* AST for define a dataclass *)
let def_dataclass (name : string) (rows : (string * string) list) : stmt =
  let body : stmt list =
    match rows with
    | [] -> [ Pass ]
    | _ ->
      List.map
        (fun (tgt, ann) ->
          AnnAssign
            {
              target = Name { id = tgt; ctx = mk_ctx () };
              annotation = Name { id = ann; ctx = mk_ctx () };
              value = None;
            })
        rows
  in
  ClassDef
    {
      name;
      bases = [];
      keywords = [];
      body;
      decorator_list = [ Name { id = "dataclass"; ctx = mk_ctx () } ];
    }

(* AST for initiate a dataclass instance *)
let init_dataclass
    (dataclass_name : string)
    ~(args : expr list)
    ~(kwargs : (string * expr) list) : expr =
  let keywords : keyword list =
    List.map (fun (k, v) -> { arg = Some k; value = v }) kwargs
  in
  Call { func = Name { id = dataclass_name; ctx = mk_ctx () }; args; keywords }

let def_union (name : string) (union_names : string list) : stmt =
  let left_targets = [ Name { id = name; ctx = mk_ctx () } ] in
  let right_value =
    match union_names with
    | [] -> invalid_arg "def_union: empty union"
    | [ single ] -> Name { id = single; ctx = mk_ctx () }
    | _ ->
      let component_exprs : expr list =
        List.map
          (fun component_name -> Name { id = component_name; ctx = mk_ctx () })
          union_names
      in
      let rec mk_union (components : expr list) : expr =
        match components with
        | [] -> invalid_arg "mk_union: empty union"
        | [ _single ] -> invalid_arg "mk_union: singleton union"
        | [ left; right ] -> BinOp { left; op = BitOr; right }
        | left :: right :: rest ->
          let merged_left_and_right = BinOp { left; op = BitOr; right } in
          mk_union (merged_left_and_right :: rest)
      in
      mk_union component_exprs
  in
  Assign { targets = left_targets; value = right_value; type_comment = None }

(* AST for defining types corresponding to variant
  - Each variant constructor is a dataclass with anonymous fields
  - The variant is a union of the dataclasses

  variants: A list of variant constructor name, and types of its arguments
*)
let variant_dataclass (name : string) (variants : (string * string list) list) :
    stmt list =
  let variant_names = List.map fst variants in
  (* Define a single variant constructor as a dataclass *)
  let def_variant_constructor_as_dataclass (variant : string * string list) :
      stmt =
    let name = fst variant in
    let rows : (string * string) list =
      List.mapi
        (fun i type_name -> "arg" ^ string_of_int i, type_name)
        (snd variant)
    in
    def_dataclass name rows
  in
  let constructor_defs =
    List.map def_variant_constructor_as_dataclass variants
  in
  constructor_defs @ [ def_union name variant_names ]

(* <><><><><><><><><><><><><><><><><><><><> *)

let%expect_test "bool list expr to string" =
  let bools = [ false; true; false; false; false; false; false; true ] in
  let c = bools_to_char bools in
  Printf.printf "%c\n" c;
  [%expect {| A |}]

let%expect_test "char to bools" =
  let c = '0' in
  let bools = char_to_bools c in
  List.iter (Printf.printf "%b ") bools;
  [%expect {| false false false false true true false false |}]

let%expect_test "build union" =
  let union_stmt = def_union "Status" [ "str"; "int" ] in
  print_endline (show_stmt union_stmt);
  [%expect
    {|
    (Ast.Assign
       { Ast.targets = [(Ast.Name { Ast.id = "Status"; ctx = Ast.Load })];
         value =
         (Ast.BinOp
            { Ast.left = (Ast.Name { Ast.id = "str"; ctx = Ast.Load });
              op = Ast.BitOr;
              right = (Ast.Name { Ast.id = "int"; ctx = Ast.Load }) });
         type_comment = None })
    |}]
