(** Helper module interface *)

type config = {
  output_dir: string;
  verbose: bool;
}

val default_config : unit -> config
(** Create a default configuration *)

val greet : string -> string
(** Format a greeting message *)

val process_list : string list -> string
(** Process a list of strings and return a concatenated result *)
