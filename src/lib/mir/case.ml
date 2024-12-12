include Imandrax_api.Case_poly

type 't t = ('t, Var.t, Applied_symbol.t) t_poly
[@@deriving twine, typereg, eq, show { with_path = false }, map, iter]
(** Case in a shallow pattern match *)

let hash hasht (c : _ t) =
  CCHash.(combine2 (Applied_symbol.hash c.case_cstor) (hasht c.case_rhs))
