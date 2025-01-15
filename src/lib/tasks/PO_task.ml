open Common_tasks_

type ('term, 'ty) t_poly = {
  from_sym: string;
  count: int;
  db: ('term, 'ty) Imandrax_api_common.Db_ser.t_poly;
  po: ('term, 'ty) Imandrax_api_common.Proof_obligation.t_poly;
}
[@@deriving show { with_path = false }, twine, typereg]
(** Serializable version of the task *)

module Mir = struct
  type t = (Mir.Term.t, Mir.Type.t) t_poly
  [@@deriving show, twine, typereg] [@@typereg.name "Mir.t"]
end
