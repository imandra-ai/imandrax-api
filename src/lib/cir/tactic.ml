include Imandrax_api_common.Tactic

type t = (Term.t, Type.t) t_poly
[@@deriving show { with_path = false }, twine, typereg]
(** Tactic used to solve a PO *)
