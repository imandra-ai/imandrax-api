include Imandrax_api_common.Instantiation_rule

type t = (Term.t, Type.t) t_poly [@@deriving twine, typereg, show]
