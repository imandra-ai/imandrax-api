(** A single item in a trigger *)

type t = Term.t * As_trigger.t [@@deriving show, twine, typereg]
