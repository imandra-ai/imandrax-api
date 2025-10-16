type color =
  | Red
  | Green
  | Blue

type simple_result =
  | Ok
  | Error of string

type binary_op =
  | Add of int * int
  | Subtract of int * int
  | Multiply of int * int

type shape =
  | Circle of float
  | Rectangle of float * float
  | Triangle of float * float * float

type expr =
  | Const of int
  | Var of string
  | Add of expr * expr
  | Mul of expr * expr

type http_method =
  | GET
  | POST of string
  | PUT of string * string list
  | DELETE

type option_like =
  | Nothing
  | Something of int

let make_color () : color = Red

let make_simple_result () : simple_result = Error "not found"

let make_binary_op () : binary_op = Add (10, 20)

let make_shape () : shape = Circle 5.0

let make_expr () : expr = Add (Const 1, Mul (Var "x", Const 2))

let make_http_method () : http_method = POST "body data"

let make_option_like () : option_like = Something 42
