(** A serializable logic database. It contains all relevant context for
    proof obligations. *)

include Imandrax_api_common.Db_ser

type t = (Term.t, Type.t) t_poly
