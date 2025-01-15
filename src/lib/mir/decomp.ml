include Imandrax_api_common.Decomp

type t = Imandrax_api_common.Decomp.t_ = {
  f_id: Imandrax_api.Uid.t;
  assuming: Imandrax_api.Uid.t option;
  basis: Imandrax_api.Uid_set.t;
  rule_specs: Imandrax_api.Uid_set.t;
  ctx_simp: bool;
  lift_bool: lift_bool;
  prune: bool;
}
[@@deriving twine, show, typereg]
