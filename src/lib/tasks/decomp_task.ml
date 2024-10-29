(** Decomposition tasks *)

type t = {
  db: Imandrax_api_cir.Db_ser.t;
  decomp: Imandrax_api_cir.Decomp.t;
  anchor: Imandrax_api.Anchor.t;
}
[@@deriving show { with_path = false }, twine, typereg]
