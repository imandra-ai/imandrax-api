(* Test file for the helper module *)
open Py_gen_lib

let test_greet () =
  let result = Helper.greet "World" in
  assert (result = "Hello, World!");
  print_endline "✓ test_greet passed"

let test_process_list () =
  let input = ["apple"; "banana"; "cherry"] in
  let result = Helper.process_list input in
  assert (result = "APPLE, BANANA, CHERRY");
  print_endline "✓ test_process_list passed"

let test_default_config () =
  let config = Helper.default_config () in
  assert (config.output_dir = ".");
  assert (config.verbose = false);
  print_endline "✓ test_default_config passed"

let () =
  print_endline "Running tests...";
  test_greet ();
  test_process_list ();
  test_default_config ();
  print_endline "All tests passed!"
