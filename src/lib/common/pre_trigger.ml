(** A single item in a trigger *)

type 'term t_poly = 'term * Imandrax_api.As_trigger.t
[@@deriving show, twine, typereg, map, iter]
