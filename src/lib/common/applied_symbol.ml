type 'ty t_poly = {
  sym: 'ty Typed_symbol.t_poly;
  args: 'ty list;
  ty: 'ty;  (** computed *)
}
[@@deriving twine, typereg, ord, eq, map, iter]
(** A value with its type schema *)

let pp_t_poly pp_ty out (self : _ t_poly) =
  Fmt.fprintf out "(@[%a : %a@])" Imandrax_api.Uid.pp_full self.sym.id pp_ty
    self.ty

let pp_name out (self : _ t_poly) = Imandrax_api.Uid.pp_name out self.sym.id
