(** Evaluation tasks *)

type t = {
  db: Db_ser.t;
  term: Term.t;
  anchor: Anchor.t;
  timeout: int option;
}
[@@deriving show { with_path = false }, twine, typereg]
(** A task associated to an expression the user asked to evaluate.
    These tasks' results are to be displayed in the LSP, among other places. *)
