open Printf

let () =
  (* Parse command line arguments *)
  if Array.length Sys.argv < 2 then (
    eprintf "Usage: %s [input_file.json|yaml|-] <output_file.json|-> [index]\n"
      Sys.argv.(0);
    eprintf "  input_file: input JSON/YAML file path, or '-' for stdin (defaults to JSON)\n";
    eprintf "  output_file: output JSON file path, or '-' for stdout\n";
    eprintf
      "  index: optional index for YAML/JSON arrays (0-based, or -1 for last)\n";
    exit 1
  );

  let input_file = Sys.argv.(1) in
  let use_stdin = input_file = "-" in
  let output_file = if Array.length Sys.argv > 2 then Sys.argv.(2) else "-" in
  let use_stdout = output_file = "-" in
  let index_opt =
    if Array.length Sys.argv > 3 then
      Some (int_of_string Sys.argv.(3))
    else
      None
    (* default to whole document *)
  in

  (* Check if input file exists (skip for stdin) *)
  if not use_stdin && not (Sys.file_exists input_file) then (
    eprintf "Error: Input file '%s' does not exist\n" input_file;
    exit 1
  );

  (* Determine file type from extension or default to JSON for stdin *)
  let is_yaml =
    if use_stdin then
      false  (* default to JSON for stdin *)
    else
      Filename.check_suffix input_file ".yaml"
      || Filename.check_suffix input_file ".yml"
  in
  let is_json =
    if use_stdin then
      true  (* default to JSON for stdin *)
    else
      Filename.check_suffix input_file ".json"
  in

  if not (is_yaml || is_json) then (
    eprintf "Error: Input file must be .json, .yaml, or .yml\n";
    exit 1
  );

  if not use_stdout then (
    if use_stdin then
      printf "Reading from: stdin\n"
    else
      printf "Reading from: %s\n" input_file;
    printf "Output to: %s\n" output_file
  );

  (* Read and parse the input file or stdin *)
  let model =
    try
      if is_yaml then (
        if not use_stdout then printf "Parsing YAML file...\n";
        let yaml_str =
          if use_stdin then
            CCIO.read_all stdin
          else
            CCIO.File.read_exn input_file
        in
        if String.trim yaml_str = "" then
          failwith "Empty input: stdin contains no data (check if previous command in pipeline failed)";
        let yaml = Yaml.of_string_exn yaml_str in
        (* If index is specified and it's a list, extract the requested item *)
        let yaml_item =
          match index_opt, yaml with
          | Some index, `A items ->
            let len = List.length items in
            let actual_index =
              if index < 0 then
                len + index
              else
                index
            in
            if actual_index < 0 || actual_index >= len then
              failwith
                (sprintf "Index %d out of bounds (list has %d items)" index len);
            if not use_stdout then
              printf "Found YAML list with %d items, using index %d\n" len
                actual_index;
            List.nth items actual_index
          | Some index, `O _ ->
            if not use_stdout then
              printf "Warning: index %d ignored for single YAML object\n" index;
            yaml
          | None, _ ->
            if not use_stdout then printf "Using whole document\n";
            yaml
          | _ -> failwith "Expected YAML mapping or list"
        in
        Py_gen.Util.yaml_to_model ~debug:false yaml_item
      ) else (
        if not use_stdout then printf "Parsing JSON file...\n";
        let json =
          if use_stdin then (
            (* Check if stdin has any content *)
            let content = CCIO.read_all stdin in
            if String.trim content = "" then
              failwith "Empty input: stdin contains no data (check if previous command in pipeline failed)";
            Yojson.Safe.from_string content
          ) else
            Yojson.Safe.from_file input_file
        in
        Py_gen.Util.json_to_model ~debug:false json
      )
    with
    | Failure msg ->
      eprintf "Error parsing input: %s\n" msg;
      exit 1
    | Yojson.Json_error msg ->
      eprintf "JSON parse error: %s\n" msg;
      if use_stdin then
        eprintf "Hint: Ensure stdin contains valid JSON (use 'yq -o json' to convert YAML to JSON)\n";
      exit 1
    | e ->
      eprintf "Unexpected error: %s\n" (Printexc.to_string e);
      exit 1
  in

  if not use_stdout then printf "Successfully parsed model\n";

  (* Parse the model to AST statements *)
  if not use_stdout then printf "Converting model to Python AST...\n";
  let stmts =
    try Py_gen.Parse.parse_model model with
    | Failure msg ->
      eprintf "Error converting model: %s\n" msg;
      exit 1
    | e ->
      eprintf "Unexpected error during conversion: %s\n" (Printexc.to_string e);
      exit 1
  in

  if not use_stdout then printf "Generated %d statements\n" (List.length stmts);

  (* Convert statements to JSON *)
  let json_out : Yojson.Safe.t =
    `List (List.map Py_gen.Ast.stmt_to_yojson stmts)
  in

  (* Write to output file or stdout *)
  if use_stdout then (
    Yojson.Safe.to_channel stdout json_out;
    print_newline ()
  ) else (
    printf "Writing output to: %s\n" output_file;
    CCIO.with_out output_file (fun out ->
        Yojson.Safe.pretty_to_channel out json_out);
    printf "Done. Output written to %s\n" output_file
  )
