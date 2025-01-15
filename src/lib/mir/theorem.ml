include Imandrax_api_common.Theorem

type t = (Term.t, Type.t) Imandrax_api_common.Theorem.t_poly
[@@deriving twine, typereg, show { with_path = false }]
