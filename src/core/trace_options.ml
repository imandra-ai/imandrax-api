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

module Server = struct
  type client = t

  type t = {
    proof: proof_type;
    detail: detail;
  }
  [@@deriving show, twine]

  let default () =
    let tod = default () in
    { proof = tod.proof; detail = tod.detail }

  let of_client (opts : client) = { proof = opts.proof; detail = opts.detail }
end
