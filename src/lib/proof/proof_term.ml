(** Proof terms *)

type ('term, 'ty) t_poly = {
  id: int;  (** unique generative id *)
  concl: 'term Imandrax_api_common.Sequent.t_poly;
  view: ('term, 'ty, ('term, 'ty) t_poly) View.t;
}
[@@deriving show { with_path = false }, twine, typereg, map, iter]
(** A proof term *)
