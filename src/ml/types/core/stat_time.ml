(** Statistics for time *)

type t = { time_s: float [@printer Util.pp_duration_s] }
[@@unboxed] [@@deriving twine, typereg, show { with_path = false }]
(** Statistics for time *)
