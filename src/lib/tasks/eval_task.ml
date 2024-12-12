(** Evaluation tasks *)

type t = {
  db: Imandrax_api_mir.Db_ser.t;
  term: Imandrax_api_mir.Term.t;
  anchor: Imandrax_api.Anchor.t;
  timeout: int option;
}
[@@deriving show { with_path = false }, twine, typereg]
(** A task associated to an expression the user asked to evaluate.
    These tasks' results are to be displayed in the LSP, among other places. *)
