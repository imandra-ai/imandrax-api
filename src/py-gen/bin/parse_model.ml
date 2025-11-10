open Printf

(* Type definitions for better code organization *)
type input_source =
  | Stdin
  | File of string

type output_target =
  | Stdout
  | File of string

type file_format =
  | YAML
  | JSON

type config = {
  input: input_source;
  output: output_target;
  format: file_format;
}

(* Helper functions *)
let log use_stdout fmt =
  if not use_stdout then
    printf fmt
  else
    ifprintf stdout fmt

let read_content = function
  | Stdin -> CCIO.read_all stdin
  | File path -> CCIO.File.read_exn path

let validate_content content =
  if String.trim content = "" then
    failwith
      "Empty input: stdin contains no data (check if previous command in \
       pipeline failed)"

let determine_format input_file use_stdin =
  if use_stdin then
    JSON
  else if
    Filename.check_suffix input_file ".yaml"
    || Filename.check_suffix input_file ".yml"
  then
    YAML
  else if Filename.check_suffix input_file ".json" then
    JSON
  else
    failwith "Input file must be .json, .yaml, or .yml"

let parse_yaml_input input use_stdout =
  log use_stdout "Parsing YAML file...\n";
  let yaml_str = read_content input in
  validate_content yaml_str;
  let yaml = Yaml.of_string_exn yaml_str in
  Py_gen.Util.yaml_to_model ~debug:false yaml

let parse_json_input input use_stdout =
  log use_stdout "Parsing JSON file...\n";
  let content = read_content input in
  validate_content content;
  let json = Yojson.Safe.from_string content in
  Py_gen.Util.json_to_model ~debug:false json

let parse_input config =
  let use_stdout =
    match config.output with
    | Stdout -> true
    | _ -> false
  in
  match config.format with
  | YAML -> parse_yaml_input config.input use_stdout
  | JSON -> parse_json_input config.input use_stdout

let convert_to_ast parsed_input use_stdout =
  log use_stdout "Converting to Python AST...\n";
  Py_gen.Parse.parse_model parsed_input

let write_output output stmts =
  let json_out = `List (List.map Py_gen.Ast.stmt_to_yojson stmts) in
  match output with
  | Stdout ->
    Yojson.Safe.to_channel stdout json_out;
    print_newline ()
  | File path ->
    printf "Writing output to: %s\n" path;
    CCIO.with_out path (fun out -> Yojson.Safe.pretty_to_channel out json_out);
    printf "Done. Output written to %s\n" path

let handle_error use_stdin = function
  | Failure msg ->
    eprintf "Error parsing input: %s\n" msg;
    exit 1
  | Yojson.Json_error msg ->
    eprintf "JSON parse error: %s\n" msg;
    (match use_stdin with
    | Stdin ->
      eprintf
        "Hint: Ensure stdin contains valid JSON (use 'yq -o json' to convert \
         YAML to JSON)\n"
    | _ -> ());
    exit 1
  | e ->
    eprintf "Unexpected error: %s\n" (Printexc.to_string e);
    exit 1

(* Main program *)
let () =
  (* Parse command line arguments *)
  if Array.length Sys.argv < 2 then (
    eprintf "Usage: %s [input_file.json|yaml|-] <output_file.json|->\n"
      Sys.argv.(0);
    eprintf
      "  input_file: input JSON/YAML file path, or '-' for stdin (defaults to \
       JSON)\n";
    eprintf "  output_file: output JSON file path, or '-' for stdout\n";
    exit 1
  );

  let input_file = Sys.argv.(1) in
  let output_file =
    if Array.length Sys.argv > 2 then
      Sys.argv.(2)
    else
      "-"
  in

  let input =
    if input_file = "-" then
      Stdin
    else
      File input_file
  in
  let output =
    if output_file = "-" then
      Stdout
    else
      File output_file
  in

  (* Validate input file exists *)
  (match input with
  | File path when not (Sys.file_exists path) ->
    eprintf "Error: Input file '%s' does not exist\n" path;
    exit 1
  | _ -> ());

  let format =
    try determine_format input_file (input = Stdin)
    with Failure msg ->
      eprintf "Error: %s\n" msg;
      exit 1
  in

  let config = { input; output; format } in

  (* Log configuration *)
  let use_stdout =
    match output with
    | Stdout -> true
    | _ -> false
  in
  if not use_stdout then (
    (match input with
    | Stdin -> printf "Reading from: stdin\n"
    | File path -> printf "Reading from: %s\n" path);
    printf "Output to: %s\n" output_file
  );

  (* Main processing pipeline *)
  try
    let model = parse_input config in
    log use_stdout "Successfully parsed model\n";

    let stmts = convert_to_ast model use_stdout in
    log use_stdout "Generated %d statements\n" (List.length stmts);

    write_output output stmts
  with e -> handle_error input e
