type t = {
  from_sym: string;
  count: int;
  db: Imandrax_api_cir.Db_ser.t;
  po: Imandrax_api_cir.Proof_obligation.t;
}
[@@deriving show { with_path = false }, twine, typereg]
(** Serializable version of the task *)
