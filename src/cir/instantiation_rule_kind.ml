type t =
  | IR_forward_chaining
  | IR_generalization
[@@deriving twine, typereg, eq, show { with_path = false }]
