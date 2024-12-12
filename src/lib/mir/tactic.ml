include Imandrax_api.Tactic_poly

type t = Term.t t_poly [@@deriving show { with_path = false }, twine, typereg]
(** Tactic used to solve a PO *)
