type t =
  | IR_forward_chaining
  | IR_generalization
[@@deriving twine, typereg, eq]

let show = function
  | IR_forward_chaining -> "fc"
  | IR_generalization -> "gen"

let pp = Fmt.of_to_string show
