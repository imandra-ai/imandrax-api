type 't view =
  | FO_any
  | FO_bool of bool
  | FO_const of Const.t
  | FO_var of Var.t  (** free variable to match *)
  | FO_app of Applied_symbol.t * 't list  (** function applied to args *)
  | FO_cstor of Applied_symbol.t option * 't list
      (** constructor, tuple, record… *)
  | FO_destruct of {
      c: Applied_symbol.t option;
      i: int;
      u: 't;
    }
  | FO_is_a of {
      c: Applied_symbol.t;
      u: 't;
    }
[@@deriving twine, typereg, eq, show { with_path = false }]

type t = {
  view: t view;
  ty: Type.t;
}
[@@deriving twine, typereg, eq, show { with_path = false }]
(** A first-order pattern *)
