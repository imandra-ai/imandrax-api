type ('term, 'ty) ty_def =
  | Ty_finite of 'term list
      (** interpretation of the type as a finite domain *)
  | Ty_alias_unit of 'ty
      (** Interpretation of the type as an alias to [unit] *)
[@@deriving show { with_path = false }, eq, map, iter, twine, typereg]

type ('term, 'ty) fi = {
  fi_args: 'ty Var.t_poly list;
  fi_ty_ret: 'ty;
  fi_cases: ('term list * 'term) list;
      (** A list of cases. Each case is [guard list -> rhs], meaning that
      for a list of inputs and [sigma] a substitution mapping [fi_args] to
      these inputs, if [/\_i sigma(guard_i)] is true then
        the function is equal to [sigma(rhs)] *)
  fi_else: 'term;  (** Value if none of the cases above fires. *)
}
[@@deriving show { with_path = false }, eq, map, iter, twine, typereg]
(** function interpretation *)

type ('term, 'ty) t_poly = {
  tys: ('ty * ('term, 'ty) ty_def) list;  (** interpretation of types *)
  consts: ('ty Applied_symbol.t_poly * 'term) list;
      (** interpretation of constant functions *)
  funs: ('ty Applied_symbol.t_poly * ('term, 'ty) fi) list;  (** functions *)
  representable: bool;
      (** Can it be entirely represented into OCaml?
        Not the case if it contains irrational reals *)
  completed: bool;  (** Indicates whether the model has been completed *)
  ty_subst: (Imandrax_api.Uid.t * 'ty) list;
      (** Types that had new ones substituted during model extraction. *)
}
[@@deriving show { with_path = false }, eq, map, iter, twine, typereg]
(** A model. *)
