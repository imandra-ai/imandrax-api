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
  local_rpc: bool;  (** Use RPC on localhost *)
  rpc_port: int option;
  rpc_json: bool;  (** use json wire protocol *)
  dev: bool;  (** Use dev environment *)
  debug: bool;  (** Enable debug *)
  json: bool;
}
[@@deriving subliner, show { with_path = false }]
(** Show imports by calling `dot`. *)

type conn_with_repeat = {
  local_rpc: bool;  (** Use RPC on localhost *)
  rpc_port: int option;
  rpc_json: bool;  (** use json wire protocol *)
  dev: bool;  (** Use dev environment *)
  debug: bool;  (** Enable debug *)
  repeat: float option;  (** Repeat every [repeat] seconds *)
  json: bool;  (** use json wire protocol *)
}
[@@deriving subliner, show { with_path = false }]
(** Show imports by calling `dot`. *)

type repl = {
  local_rpc: bool;  (** Use RPC on localhost *)
  rpc_port: int option;
  rpc_json: bool;  (** use json wire protocol *)
  dev: bool;  (** Use dev environment *)
  debug: bool; [@default false] [@aka [ "d" ]]  (** Enable debug *)
  log_level: (Logs.level[@conv parse_log_level]) option; [@conv parse_log_level]
      (** Log level *)
  log_file: string option;
  session: string option;
      (** Attempt to reconnect to the session with the given ID *)
  raw: bool;  (** Disable linenoise *)
  bt: bool;  (** backtraces *)
}
[@@deriving subliner, show { with_path = false }]
(** Run the ImandraX REPL. *)
