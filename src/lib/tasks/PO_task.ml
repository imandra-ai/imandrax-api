type t = {
  from_sym: string;
  count: int;
  db: Db_ser.t;
  po: Proof_obligation.t;
}
[@@deriving show { with_path = false }, twine, typereg]
(** Serializable version of the task *)
