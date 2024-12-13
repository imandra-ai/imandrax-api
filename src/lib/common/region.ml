type ('term, 'ty) status =
  | Unknown
  | Feasible of ('term, 'ty) Model.t_poly
[@@deriving show, twine, map, iter, typereg]

type ('term, 'ty) t_poly = {
  constraints: 'term list;
  invariant: 'term;
  status: ('term, 'ty) status;
}
[@@deriving show, twine, map, iter, typereg]
