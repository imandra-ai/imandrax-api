open Printf
open Py_gen

let%expect_test "basic test example" =
  printf "Hello from test!\n";
  [%expect {|
    Hello from test!
    |}]
