(** Decomposition tasks *)

open Common_tasks_

type ('term, 'ty) t_poly = {
  db: ('term, 'ty) Imandrax_api_common.Db_ser.t_poly;
  decomp: Imandrax_api_common.Decomp.t;
  anchor: Imandrax_api.Anchor.t;
}
[@@deriving show { with_path = false }, twine, typereg]

module Cir = struct
  type t = (Cir.Term.t, Cir.Type.t) t_poly
  [@@deriving show, twine, typereg] [@@typereg.name "Cir.t"]
end

module Mir = struct
  type t = (Mir.Term.t, Mir.Type.t) t_poly
  [@@deriving show, twine, typereg] [@@typereg.name "Mir.t"]
end
