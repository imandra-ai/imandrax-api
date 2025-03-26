module Util_twine_ = Imandrax_api.Util_twine_

type ('term, 'ty) status =
  | Unknown
  | Feasible of ('term, 'ty) Model.t_poly
[@@deriving show, twine, map, iter, typereg]

type 'term meta =
  | Null
  | Bool of bool
  | Int of Util_twine_.Z.t
  | Real of Util_twine_.Q.t
  | String of string
  | Assoc of (string * 'term meta) list
  | Term of 'term
  | List of 'term meta list
[@@deriving show, twine, map, iter, typereg]

type ('term, 'ty) t_poly = {
  constraints: 'term list;
  invariant: 'term;
  meta: (string * 'term meta) list;
  status: ('term, 'ty) status;
}
[@@deriving show, twine, map, iter, typereg]
