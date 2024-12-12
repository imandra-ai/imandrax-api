(** All the hints for a function coming from explicit attributes
      (`[@@..]` annotations) *)

include Imandrax_api.Hints_poly

type t = Term.t t_poly
[@@deriving show { with_path = false }, eq, twine, typereg]
