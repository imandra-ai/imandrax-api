(** A single item in a trigger *)

type t = Term.t Imandrax_api_common.Pre_trigger.t_poly
[@@deriving show, twine, typereg]
