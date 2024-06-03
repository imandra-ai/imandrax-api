(** Structured arguments *)

(** Arguments for a proof term *)
type ('term, 'ty) t =
  | A_term of 'term
  | A_ty of 'ty
  | A_int of int
  | A_string of string
  | A_list of ('term, 'ty) t list
  | A_dict of (string * ('term, 'ty) t) list
  | A_seq of 'term Sequent_poly.t
[@@deriving show { with_path = false }, eq, twine, typereg, map, iter]
