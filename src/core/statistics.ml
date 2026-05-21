(** Tactic Execution Statistics *)

type t = {
  time_s: float; [@printer Util.pp_duration_s] (* Execution time *)
  tactic: (string * string) list option; (* Tactic-level statistics *)
}
[@@deriving twine, typereg, show { with_path = false }]
(** Tactic Execution Statistics *)
