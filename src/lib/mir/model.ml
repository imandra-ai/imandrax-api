type ty_def = (Term.t, Type.t) Imandrax_api.Model.ty_def
[@@deriving twine, typereg]
(** How to interpret a type *)

type fi = (Term.t, Var.t, Type.t) Imandrax_api.Model.fi
[@@deriving show, twine, typereg]
(** function interpretation *)

type t = (Term.t, Applied_symbol.t, Var.t, Type.t) Imandrax_api.Model.t
[@@deriving twine, typereg, show]
