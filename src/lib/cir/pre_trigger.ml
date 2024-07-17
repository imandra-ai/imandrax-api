(** A single item in a trigger *)

type t = Term.t * Imandrax_api.As_trigger.t [@@deriving show, twine, typereg]
