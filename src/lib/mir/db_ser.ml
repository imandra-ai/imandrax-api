(** A serializable logic database. It contains all relevant context for
    proof obligations. *)

include Imandrax_api_common.Db_ser
module PH = Pattern_head

type t = (Term.t, Type.t) t_poly [@@deriving show, twine, typereg]
(** A serializable logic database. *)
