let parse_log_level =
  Cmdliner.Arg.enum
    [
      "info", Logs.Info;
      "warn", Logs.Warning;
      "debug", Logs.Debug;
      "app", Logs.App;
      "error", Logs.Error;
    ]

(*
type repl = {
  files: string list; [@aka [ "l"; "load" ]] [@opt_all] [@docv "FILES"]
      (** Files to load before starting the REPL *)
  j: int option;  (** Size of internal thread pool *)
  color: bool; [@enum [ "true", true; "false", false ]] [@default true]
      (** Colorize dump output *)
  debug: bool; [@default false] [@aka [ "d" ]]  (** Enable debug *)
  log_level: Logger.level option; [@conv parse_log_level]  (** Log level *)
  log_stderr: bool;
      (** Log on stderr (caution, this mixes with the regular output) *)
  log_file: string option; [@docv "FILE"]
      (** Specify the file into which to log. *)
  proof_check: bool option;  (** Do proof checking if PO is successful *)
  dump_decls: bool; [@enum [ "true", true; "false", false ]] [@default false]
      (** Dump entire declarations (rather than type signatures)? *)
  eval_ocaml: bool;  (** Evaluate phrases in OCaml as well. *)
  reify_errors: bool; [@default false]  (** Reify errors into AST nodes *)
  syntax: IXP.Syntax_name.t option; [@enum [ "iml", IXP.Syntax_name.Iml ]]
      (** Syntax for the code *)
  store: bool; [@enum [ "true", true; "false", false ]] [@default false]
      (** Store results on disk in DB *)
  store_dir: string option;  (** Directory for the DB *)
  store_file: string option;  (** File name for the DB *)
  prelude: bool; [@enum [ "true", true; "false", false ]] [@default true]
      (** If [false], do not load the prelude *)
  serve: bool; [@enum [ "true", true; "false", false ]] [@default false]
      (** Spawn http server in the background. *)
  serve_port: int option;  (** Port for the http server *)
  use_cache: string option;  (** Use given file as cache *)
  use_ro_cache: string option;  (** Use given file as read-only cache *)
  json_log_file: string option; [@docv "FILE"]
      (** Specify the file that is used for ["/logs/"], using jsonl *)
  gc_stats: bool;  (** log regular GC statistics *)
  bt: bool;  (** Enable backtraces *)
}
[@@deriving cmdliner, show { with_path = false }]
(** Run the ImandraX REPL. *)
*)

type conn = {
  port: int option;
  debug: bool;  (** Enable debug *)
}
[@@deriving cmdliner, show { with_path = false }]
(** Show imports by calling `dot`. *)
