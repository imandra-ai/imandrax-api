type 't t = {
  case_cstor: Applied_symbol.t;
  case_vars: Var.t list;
  case_rhs: 't;
  case_labels: Uid.t list option;
}
[@@deriving twine, typereg, eq, show { with_path = false }, map, iter]
(** Case in a shallow pattern match *)
