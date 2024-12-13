include Imandrax_api_common.Fun_def

type t = (Term.t, Type.t) t_poly [@@deriving twine, typereg, eq, show]
(** A function definition. *)

let pp_ = ref pp
let pp out d = !pp_ out d
let show = Fmt.to_string pp

open Imandrax_api

let () =
  Imandrakit_twine.Encode.add_cache_with
    ~eq:(fun a b -> Uid.equal a.f_name b.f_name)
    ~hash:(fun a -> Uid.hash a.f_name)
    to_twine_ref;
  Imandrakit_twine.Decode.add_cache of_twine_ref
