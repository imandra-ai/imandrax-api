(** A cryptographic pointer to a proof3 trace stored in CA store.

    The value can be large and might be garbage collected after a set amount of
    time so we need to expect it to not always be present *)

type t = {
  key: Key.t;
  size_in_B: int;
}
[@@deriving show { with_path = false }, twine]
