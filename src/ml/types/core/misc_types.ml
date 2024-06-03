(** Misc definitions *)

type rec_flag =
  | Recursive
  | Nonrecursive
[@@deriving show { with_path = false }, eq, twine, typereg]

type apply_label =
  | Nolabel
  | Label of string
  | Optional of string
[@@deriving show { with_path = false }, eq, twine, typereg]
