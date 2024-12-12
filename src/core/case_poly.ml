type ('t, 'var, 'sym) t_poly = {
  case_cstor: 'sym;
  case_vars: 'var list;
  case_rhs: 't;
  case_labels: Uid.t list option;
}
[@@deriving twine, typereg, eq, show { with_path = false }, map, iter]
(** Case in a shallow pattern match *)
