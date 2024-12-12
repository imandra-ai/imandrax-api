type 'ty t_poly = {
  params: Uid.t list;
  ty: 'ty;
}
[@@deriving twine, typereg, eq, ord, map, iter, show { with_path = false }]
