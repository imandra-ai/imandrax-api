type t =
  | Named of Cname.t
  | Eval of int
  | Proof_check of t
[@@deriving show, eq, ord, twine, typereg]
