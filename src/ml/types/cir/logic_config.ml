type t = {
  timeout: int;
  validate: bool;  (** validate definitions *)
  skip_proofs: bool;  (** skip proofs *)
  max_induct: int option;  (** max induction depth *)
  backchain_limit: int;  (** global back-chaining limit, for rewriting *)
  enable_all: bool;  (** Force all symbols to be enabled *)
  induct_unroll_depth: int;  (** Depth of unrolling in induction checks *)
  induct_subgoal_depth: int;
      (** Max depth of successive subgoals in induction *)
  unroll_enable_all: bool;
  unroll_depth: int;
}
[@@deriving show { with_path = false }, eq, twine, typereg]
(** Configuration for logical reasoning *)

type op =
  | Op_timeout of int
  | Op_validate of bool
  | Op_skip_proofs of bool
  | Op_max_induct of int option
  | Op_backchain_limit of int
  | Op_enable_all of bool
  | Op_induct_unroll_depth of int
  | Op_induct_subgoal_depth of int
  | Op_unroll_enable_all of bool
  | Op_unroll_depth of int
[@@deriving show { with_path = false }, eq, twine, typereg]
