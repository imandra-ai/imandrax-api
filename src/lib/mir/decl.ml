include Imandrax_api_common.Decl

type t = (Term.t, Type.t) Imandrax_api_common.Decl.t_poly
[@@deriving twine, typereg, show]
