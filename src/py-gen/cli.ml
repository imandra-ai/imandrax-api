let () =
  (* Use the helper module *)
  let config = Py_gen.Helper.default_config () in

  Printf.printf "Config: output_dir=%s, verbose=%b\n"
    config.output_dir config.verbose;

  (* Use the greet function *)
  let msg = Py_gen.Helper.greet "Developer" in
  print_endline msg;

  (* Process a list *)
  let items = ["foo"; "bar"; "baz"] in
  let result = Py_gen.Helper.process_list items in
  Printf.printf "Processed: %s\n" result;
