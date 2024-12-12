(** the kind of function. *)
type fun_kind =
  | Fun_defined of {
      is_macro: bool;
      from_lambda: bool;
    }
  | Fun_builtin of Builtin.Fun.t
  | Fun_opaque
[@@deriving show { with_path = false }, eq, twine, typereg]

type ('term, 'ty) t_poly = {
  f_name: Uid.t; [@printer Util.pp_backquote Uid.pp]
  f_ty: 'ty Type_schema_poly.t_poly;
  f_args: 'ty Var_poly.t_poly list;
  f_body: 'term;
  f_clique: Clique.t option;
      (** If the function is recursive, this is the set of functions in the
          same block of mutual defs, this one included. It's [None]
          for non-recursive functions. *)
  f_kind: fun_kind;
  f_hints: 'term Hints_poly.t_poly;
}
[@@deriving twine, typereg, eq, show { with_path = false }]
(** A function definition. *)
