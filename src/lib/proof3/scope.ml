type t = { sc: int list }
[@@unboxed] [@@deriving show { with_path = false }, twine, typereg, eq]
(** A scope used to hold local assumptions *)

