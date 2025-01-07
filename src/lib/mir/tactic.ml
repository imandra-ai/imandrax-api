include Imandrax_api_common.Tactic

type t = Top_fun.t t_poly
[@@deriving show { with_path = false }, twine, typereg]
(** Tactic used to solve a PO *)
