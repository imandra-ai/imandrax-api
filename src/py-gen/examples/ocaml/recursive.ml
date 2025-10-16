type int_list =
  | Nil
  | Cons of int * int_list

type 'a binary_tree =
  | Empty
  | Node of 'a * 'a binary_tree * 'a binary_tree

type json =
  | Null
  | Bool of bool
  | Number of float
  | String of string
  | Array of json list
  | Object of (string * json) list

type expr =
  | Lit of int
  | Var of string
  | Add of expr * expr
  | Mul of expr * expr
  | Let of string * expr * expr

type node = {
  id: int;
  children: node list;
}

type tree_node = {
  value: int;
  left: tree_node option;
  right: tree_node option;
}

type file_system =
  | File of { name: string; size: int }
  | Directory of { name: string; contents: file_system list }

type a_type = B of b_type
and b_type = A of a_type | Done

type even = Zero | Succ of odd
and odd = Succ of even

let make_int_list () : int_list = Cons (1, Cons (2, Cons (3, Nil)))

let make_binary_tree () : int binary_tree =
  Node (5, Node (3, Empty, Empty), Node (7, Empty, Empty))

let make_json () : json =
  Object [
    ("name", String "Alice");
    ("age", Number 30.0);
    ("active", Bool true)
  ]

let make_expr () : expr =
  Let ("x", Lit 10, Add (Var "x", Mul (Var "x", Lit 2)))

let make_node () : node = {
  id = 1;
  children = [
    { id = 2; children = [] };
    { id = 3; children = [] }
  ]
}

let make_tree_node () : tree_node = {
  value = 10;
  left = Some { value = 5; left = None; right = None };
  right = Some { value = 15; left = None; right = None };
}

let make_file_system () : file_system =
  Directory {
    name = "root";
    contents = [
      File { name = "a.txt"; size = 100 };
      Directory { name = "subdir"; contents = [] }
    ]
  }

let make_a_type () : a_type = B (A (B Done))

let make_even () : even = Succ (Succ Zero)
