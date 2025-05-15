type t =
  | Named of Cname.t
  | Eval of int
  | Proof_check of t
  | Decomp of t
  | Sub of t * int  (** A more precise location inside an anchor *)
[@@deriving show { with_path = false }, eq, ord, twine, typereg]
