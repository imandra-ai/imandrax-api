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
  local_http: bool;
  dev: bool;  (** Use dev environment *)
  debug: bool;  (** Enable debug *)
  json: bool;
}
[@@deriving subliner, show { with_path = false }]
(** Show imports by calling `dot`. *)

type conn_with_repeat = {
  local_http: bool;  (** Use HTTP on localhost *)
  dev: bool;  (** Use dev environment *)
  debug: bool;  (** Enable debug *)
  repeat: float option;  (** Repeat every [repeat] seconds *)
  json: bool;  (** use json wire protocol *)
}
[@@deriving subliner, show { with_path = false }]
(** Show imports by calling `dot`. *)

type login = {
  dev: bool;  (** Use dev environment *)
  debug: bool;  (** Enable debug *)
  log_level: (Logs.level[@conv parse_log_level]) option; [@conv parse_log_level]
      (** Log level *)
  local_port: int; [@default 3009]  (** Port for the local http server *)
}
[@@deriving subliner, show { with_path = false }]
