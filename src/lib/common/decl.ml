type ('term, 'ty) t_poly =
  | Fun of ('term, 'ty) Fun_def.t_poly
  | Ty of 'ty Imandrax_api.Ty_view.def_poly
  | Theorem of ('term, 'ty) Theorem.t_poly
  | Rule_spec of ('term, 'ty) Rule_spec.t_poly
  | Verify of ('term, 'ty) Verify.t_poly
[@@deriving show { with_path = false }, map, iter, twine]
