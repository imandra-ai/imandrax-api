include Imandrax_api_common.Model

type t = (Term.t, Type.t) t_poly [@@deriving twine, typereg, show]
