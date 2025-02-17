(** Function expansion *)

type 'term t = {
  f_name: Imandrax_api.Uid.t;
  lhs: 'term;  (** The function call [f t1…tn] *)
  rhs: 'term;
      (** The expansion of [f]'s body with variables replaced with [t1…tn]. By
          definition of [f], [f(t1…tn)@lhs := rhs] *)
}
[@@deriving twine, typereg, map, show { with_path = false }]
(** Assertion that [lhs = rhs] because [lhs := f(...args)] and
    [rhs := body_f[...args]], by definition of [f]. *)
