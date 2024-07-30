type t =
  | Named of Cname.t
  | Eval of int
  | Proof_check of t
[@@deriving show { with_path = false }, eq, ord, twine, typereg]
