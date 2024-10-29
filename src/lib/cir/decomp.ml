open Imandrax_api

type t = {
  f_id: Imandrax_api.Uid.t;
  assuming: Imandrax_api.Uid.t option;
  basis: Imandrax_api.Uid_set.t;
  rule_specs: Imandrax_api.Uid_set.t;
  prune: bool;
}
[@@deriving show, twine, typereg]
