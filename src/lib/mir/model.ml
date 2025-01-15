include Imandrax_api_common.Model

type t = (Term.t, Type.t) Imandrax_api_common.Model.t_poly
[@@deriving twine, typereg, show]
