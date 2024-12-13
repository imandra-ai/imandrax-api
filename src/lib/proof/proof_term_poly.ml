(** A proof term *)
type ('term, 'ty, 'proof) t = {
  id: int;  (** unique generative id *)
  concl: 'term Imandrax_api_common.Sequent.t_poly;
  view: ('term, 'ty, 'proof) View.t;
}
[@@deriving show { with_path = false }, twine, typereg, map]
(** A proof term *)
