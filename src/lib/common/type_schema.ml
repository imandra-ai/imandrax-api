type 'ty t_poly = {
  params: Imandrax_api.Uid.t list;
  ty: 'ty;
}
[@@deriving twine, typereg, eq, ord, map, iter, show { with_path = false }]
