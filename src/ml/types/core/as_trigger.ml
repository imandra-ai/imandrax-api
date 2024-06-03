(** Style of trigger for forward chaining and other tactics *)

type t =
  | Trig_none
  | Trig_anon
  | Trig_named of int
  | Trig_rw
[@@deriving eq, twine, typereg]

let to_string = function
  | Trig_none -> "none"
  | Trig_anon -> "anon"
  | Trig_rw -> "rw"
  | Trig_named i -> string_of_int i

let pp out self = Fmt.string out (to_string self)
