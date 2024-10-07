let internal_count =
  let ic = open_in "API_TYPES_VERSION" in
  let line = input_line ic in
  close_in ic;
  line |> String.trim |> int_of_string

let () =
  Printf.printf "let version = %S\n" (Printf.sprintf "v%d" internal_count)
