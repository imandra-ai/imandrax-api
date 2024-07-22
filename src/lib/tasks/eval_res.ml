type value = Imandrax_api_eval.Value.t [@@deriving show, twine, typereg]

type stats = {
  compile_time: float; [@printer Util.pp_duration_s]
  exec_time: float; [@printer Util.pp_duration_s]
}
[@@deriving show { with_path = false }, twine, typereg]
(** Evaluation statistics for the whole task *)

type success = { v: value }
[@@unboxed] [@@deriving show { with_path = false }, twine, typereg]
(** Type returned on success *)

type t = {
  res: success Error.result;  (** Result *)
  stats: stats;
}
[@@deriving show { with_path = false }, twine, typereg]
(** The result of evaluating a top sentence. *)
