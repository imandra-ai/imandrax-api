type ('term, 'ty) t_poly = {
  f_id: Imandrax_api.Uid.t;
  f_args: 'ty Var.t_poly list;
  regions: ('term, 'ty) Region.t_poly list;
}
[@@deriving show, twine, typereg]
