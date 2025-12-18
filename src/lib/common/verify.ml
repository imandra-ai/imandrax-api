type kind =
  | K_verify
  | K_instance
  | K_quickcheck
[@@deriving show { with_path = false }, eq, ord, enum, twine, typereg]

type ('term, 'ty) t_poly = {
  verify_link: ('term, 'ty) Fun_def.t_poly;
      (** nameless function representing the property to check *)
  verify_simplify: bool;  (** simplify first? *)
  verify_nonlin: bool;  (** nonlinear real arithmetic? *)
  verify_upto: Imandrax_api.Upto.t option;
  verify_kind: kind;
  verify_minimize: 'term list;  (** arithmetic terms to minimize in models *)
  verify_by: ('ty Var.t_poly list * 'term) option;
}
[@@deriving twine, iter, map, show { with_path = false }, typereg]
(** A [verify (fun x y -> <formula using x,y>)] event, for nameless theorems. *)

let name self = self.verify_link.f_name
