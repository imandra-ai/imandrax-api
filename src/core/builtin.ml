(** Builtin functions *)
module Fun = struct
  type t = {
    id: Uid.t;
    kind: Builtin_data.kind;
    lassoc: bool;
    commutative: bool;
    connective: bool;
  }
  [@@deriving show { with_path = false }, eq, twine, typereg]
  [@@typereg.name "Fun.t"]

  let () =
    Imandrakit_twine.Encode.add_cache_with
      ~eq:(fun a b -> Uid.equal a.id b.id)
      ~hash:(fun a -> Uid.hash a.id)
      to_twine_ref;
    Imandrakit_twine.Decode.add_cache of_twine_ref
end

(** Builtin sorts *)
module Ty = struct
  type t = {
    id: Uid.t;
    kind: Builtin_data.kind;
  }
  [@@deriving show { with_path = false }, eq, twine, typereg]
  [@@typereg.name "Ty.t"]

  let () =
    Imandrakit_twine.Encode.add_cache_with
      ~eq:(fun a b -> Uid.equal a.id b.id)
      ~hash:(fun a -> Uid.hash a.id)
      to_twine_ref;
    Imandrakit_twine.Decode.add_cache of_twine_ref
end
