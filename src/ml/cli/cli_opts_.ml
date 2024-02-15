let parse_log_level =
  Cmdliner.Arg.enum
    [
      "info", Logs.Info;
      "warn", Logs.Warning;
      "debug", Logs.Debug;
      "app", Logs.App;
      "error", Logs.Error;
    ]

type conn = {
  port: int option;
  debug: bool;  (** Enable debug *)
}
[@@deriving cmdliner, show { with_path = false }]
(** Show imports by calling `dot`. *)

type conn_with_repeat = {
  port: int option;
  debug: bool;  (** Enable debug *)
  repeat: float option;  (** Repeat every [repeat] seconds *)
}
[@@deriving cmdliner, show { with_path = false }]
(** Show imports by calling `dot`. *)

type repl = {
  port: int option;
  debug: bool; [@default false] [@aka [ "d" ]]  (** Enable debug *)
  log_level: Logs.level option; [@conv parse_log_level]  (** Log level *)
  log_file: string option;
  session: string option;  (** Session ID *)
  raw: bool;  (** Disable linenoise *)
  bt: bool;  (** backtraces *)
}
[@@deriving cmdliner, show { with_path = false }]
(** Run the ImandraX REPL. *)
