type t = {
  params: Type.var list;
  ty: Type.t;
}
[@@deriving twine, typereg, eq, ord, show { with_path = false }]
