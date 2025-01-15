(** Evaluation tasks *)

open Common_tasks_

type ('term, 'ty) t_poly = {
  db: ('term, 'ty) Imandrax_api_common.Db_ser.t_poly;
  term: 'ty Var.t_poly list * 'term;
  anchor: Imandrax_api.Anchor.t;
  timeout: int option;
}
[@@deriving show { with_path = false }, twine, typereg]
(** A task associated to an expression the user asked to evaluate.
    These tasks' results are to be displayed in the LSP, among other places. *)

module Mir = struct
  type t = (Mir.Term.t, Mir.Type.t) t_poly
  [@@deriving show, twine, typereg] [@@typereg.name "Mir.t"]
end
