open Imandrax_api

type status =
  | Unknown
  | Feasible of Model.t
[@@deriving show, twine, typereg]

module Region = struct
  type t = {
    constraints: Term.t list;
    invariant: Term.t;
    status: status;
  }
  [@@deriving show, twine, typereg] [@@typereg.name "Region.t"]
end

type t = {
  f_id: Imandrax_api.Uid.t;
  f_args: Var.t list;
  regions: Region.t list;
}
[@@deriving show, twine, typereg]
