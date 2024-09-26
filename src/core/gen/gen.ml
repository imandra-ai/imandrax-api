let internal_count =
  CCIO.File.read_exn "API_TYPES_VERSION" |> String.trim |> int_of_string

let () =
  Printf.printf "let version = %S\n" (Printf.sprintf "v%d" internal_count)
