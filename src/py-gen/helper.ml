(* Helper module with utility functions *)

(** A simple type to demonstrate *)
type config = {
  output_dir: string;
  verbose: bool;
}

(** Create a default configuration *)
let default_config () = {
  output_dir = ".";
  verbose = false;
}

(** Format a greeting message *)
let greet name =
  Printf.sprintf "Hello, %s!" name

(** Example function using Containers *)
let process_list items =
  items
  |> List.map String.uppercase_ascii
  |> String.concat ", "
