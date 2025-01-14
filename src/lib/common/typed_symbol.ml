type 'ty t_poly = {
  id: Imandrax_api.Uid.t;
  ty: 'ty Type_schema.t_poly;
}
[@@deriving twine, typereg, eq, ord, map, iter, show { with_path = false }]
(** A value with its type schema *)

let pp_name out (self : _ t_poly) = Imandrax_api.Uid.pp_name out self.id
