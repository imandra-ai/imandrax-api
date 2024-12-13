(** the kind of function. *)
type fun_kind =
  | Fun_defined of {
      is_macro: bool;
      from_lambda: bool;
    }
  | Fun_builtin of Imandrax_api.Builtin.Fun.t
  | Fun_opaque
[@@deriving show { with_path = false }, eq, twine, typereg]

type ('term, 'ty) t_poly = {
  f_name: Imandrax_api.Uid.t; [@printer Util.pp_backquote Imandrax_api.Uid.pp]
  f_ty: 'ty Type_schema.t_poly;
  f_args: 'ty Var.t_poly list;
  f_body: 'term;
  f_clique: Imandrax_api.Clique.t option;
      (** If the function is recursive, this is the set of functions in the
          same block of mutual defs, this one included. It's [None]
          for non-recursive functions. *)
  f_kind: fun_kind;
  f_hints: 'term Hints.t_poly;
}
[@@deriving twine, typereg, eq, map, iter, show { with_path = false }]
(** A function definition. *)
