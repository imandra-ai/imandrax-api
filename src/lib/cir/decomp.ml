open Imandrax_api

type t = {
  f_id: Imandrax_api.Uid.t;
  assuming: Imandrax_api.Uid.t option;
  basis: Imandrax_api.Uid.t list;
  prune: bool;
}
[@@deriving show, twine, typereg]
