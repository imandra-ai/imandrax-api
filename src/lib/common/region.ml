module Util_twine = Imandrax_api.Util_twine

type ('term, 'ty) status =
  | Unknown
  | Feasible of ('term, 'ty) Model.t_poly
  | Feasibility_check_failed of string
      (** Trying to assess feasibility failed, eg with a timeout *)
[@@deriving show, twine, map, iter, typereg]

type 'term meta =
  | Null
  | Bool of bool
  | Int of Util_twine.Z.t
  | Real of Util_twine.Q.t
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
