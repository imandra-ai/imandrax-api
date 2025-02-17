(** All the hints for a function coming from explicit attributes (`[@@..]`
    annotations)*)

include Imandrax_api_common.Hints

type t = (Term.t, Type.t) t_poly
[@@deriving show { with_path = false }, eq, twine, typereg]
