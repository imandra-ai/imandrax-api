type ('t, 'ty) view =
  | FO_any
  | FO_bool of bool
  | FO_const of Imandrax_api.Const.t
  | FO_var of 'ty Var.t_poly  (** free variable to match *)
  | FO_app of 'ty Applied_symbol.t_poly * 't list
      (** function applied to args *)
  | FO_cstor of 'ty Applied_symbol.t_poly option * 't list
      (** constructor, tuple, record… *)
  | FO_destruct of {
      c: 'ty Applied_symbol.t_poly option;
      i: int;
      u: 't;
    }
  | FO_is_a of {
      c: 'ty Applied_symbol.t_poly;
      u: 't;
    }
[@@deriving twine, typereg, eq, map, iter, show { with_path = false }]

type 'ty t_poly = {
  view: ('ty t_poly, 'ty) view;
  ty: 'ty;
}
[@@deriving twine, typereg, eq, map, iter, show { with_path = false }]
(** A first-order pattern *)
