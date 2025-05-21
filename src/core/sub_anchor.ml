type t = {
  id: Uid.t;
  anchor: int;
}
[@@deriving eq, ord, show { with_path = false }, twine]
