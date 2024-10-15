open Imandrax_api

module Region = struct
  type status =
    | Unknown
    | Feasible of Model.t
  [@@deriving show, twine, typereg]

  type t = {
    constraints: Term.t list;
    invariant: Term.t;
    status: status;
  }
  [@@deriving show, twine, typereg]
end

type t = {
  f_id: Uid.t;
  f_args: Var.t list;
  regions: Region.t list;
}
[@@deriving show, twine, typereg]
