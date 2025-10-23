type expr =
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
  dims: expr list;
}

and assign_stmt = {
  targets: expr list;
  value: expr; (* TODO: type_comment: str option *)
}

and stmt = Assign of assign_stmt
