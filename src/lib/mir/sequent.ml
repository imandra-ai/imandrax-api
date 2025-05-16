include Imandrax_api_common.Sequent
(** @inline *)

type t = Term.t Imandrax_api_common.Sequent.t_poly
[@@deriving show, eq, twine, typereg]
