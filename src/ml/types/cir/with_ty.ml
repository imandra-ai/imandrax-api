(** A view paired with a type. *)

type 'a t = {
  view: 'a;
  ty: Type.t;
}
[@@deriving show { with_path = false }, eq, ord, twine, typereg]
(** A view paired with a type. *)
