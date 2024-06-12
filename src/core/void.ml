(** Void type. *)
type t = |

let to_twine _ (self : t) =
  match self with
  | _ -> .

let of_twine _ _ : t = assert false

let pp _ (self : t) =
  match self with
  | _ -> .
