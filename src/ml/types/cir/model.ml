module M = Imandrax_api_model

type ty_def = (Term.t, Type.t) M.ty_def [@@deriving twine, typereg]
(** How to interpret a type *)

type fi = (Term.t, Var.t, Type.t) M.fi [@@deriving show, twine, typereg]
(** function interpretation *)

type t = (Term.t, Applied_symbol.t, Var.t, Type.t) M.t
[@@deriving twine, typereg, show]
