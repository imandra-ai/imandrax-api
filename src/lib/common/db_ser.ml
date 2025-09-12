(** A serializable logic database. It contains all relevant context for proof
    obligations. *)

type 'a ca_ptr = 'a Imandrax_api_ca_store.Ca_ptr.t [@@deriving twine, typereg]

open struct
  let pp_ca_ptr _ out c = Imandrax_api_ca_store.Ca_ptr.pp out c
end

type ('term, 'ty) t_poly = { ops: ('term, 'ty) Db_op.t_poly ca_ptr list }
[@@deriving show { with_path = false }, twine, typereg]
(** A serializable logic database. *)
