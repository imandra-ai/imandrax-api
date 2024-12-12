type 'ty t_poly = {
  id: Uid.t;
  ty: 'ty;
}
[@@deriving twine, typereg, show { with_path = false }, map, iter, eq]
