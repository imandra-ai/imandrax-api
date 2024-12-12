type 'ty t_poly = {
  id: Uid.t;
  ty: 'ty Type_schema_poly.t_poly;
}
[@@deriving twine, typereg, eq, ord, map, iter, show { with_path = false }]
(** A value with its type schema *)
