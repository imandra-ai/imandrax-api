type 'ty t_poly = {
  sym: 'ty Typed_symbol.t_poly;
  args: 'ty list;
  ty: 'ty;  (** computed *)
}
[@@deriving twine, typereg, ord, eq, map, iter, show { with_path = false }]
(** A value with its type schema *)

let pp_name out (self : _ t_poly) = Imandrax_api.Uid.pp_name out self.sym.id
