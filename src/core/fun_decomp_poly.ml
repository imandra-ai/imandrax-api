type ('term, 'ty) status =
  | Unknown
  | Feasible of
      ('term, 'ty Applied_symbol_poly.t_poly, 'ty Var_poly.t_poly, 'ty) Model.t
[@@deriving show, twine, map, iter, typereg]

module Region_poly = struct
  type ('term, 'ty) t = {
    constraints: 'term list;
    invariant: 'term;
    status: ('term, 'ty) status;
  }
  [@@deriving show, twine, map, iter, typereg] [@@typereg.name "Region.t"]
end

type ('term, 'ty) t_poly = {
  f_id: Uid.t;
  f_args: 'ty Var_poly.t_poly list;
  regions: ('term, 'ty) Region_poly.t list;
}
[@@deriving show, twine, typereg]
