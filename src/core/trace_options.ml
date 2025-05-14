type proof_type =
  | NONE
  | FULL
  | PRUNED
[@@deriving show, twine]

type detail =
  | MINIMAL
  | FULL
[@@deriving show, twine]

type t = {
  proof: proof_type;
  detail: detail;
  file: string option;
}
[@@deriving show, twine]

let default () = { proof = NONE; detail = MINIMAL; file = None }
