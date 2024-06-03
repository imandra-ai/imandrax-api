(** Cryptographic name.

    Most logic objects in ImandraX are content-addressed.
    Their identity is
    tied to the cryptographic hash ({!Chash.t}) of their
    {b definition}.

    This means they can be shared freely and independently, and do not depend
    on incidental or generative state.
*)

type t = {
  name: string;
  chash: Chash.t;
}
[@@deriving show, eq, ord, twine, typereg]

let hash self = CCHash.(combine2 (string self.name) (Chash.hash self.chash))

let () =
  Imandrakit_twine.Encode.add_cache_with ~eq:equal ~hash to_twine_ref;
  Imandrakit_twine.Decode.add_cache of_twine_ref
