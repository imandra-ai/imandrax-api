module Mir = Imandrax_api_mir
include Proof_term

type t = (Mir.Term.t, Mir.Type.t) t_poly [@@deriving show, twine]
(** A MIR-level proof term *)

let pp out self = Proof_term.pp_t_poly Mir.Term.pp Mir.Type.pp out self
let show = Fmt.to_string pp

type view = (Mir.Term.t, Mir.Type.t, t) View.t [@@deriving show]
type arg = (Mir.Term.t, Mir.Type.t) Arg.t [@@deriving show]

module Phys = struct
  module As_key = struct
    type nonrec t = t

    let equal a b = a.id = b.id
    let hash a = CCHash.int a.id
    let compare a b = compare a.id b.id
  end

  module Map = CCMap.Make (As_key)
  module Tbl = CCHashtbl.Make (As_key)
  module Weak_Tbl = Ephemeron.K1.Make (As_key)
end

let () =
  Imandrakit_twine.Encode.add_cache_with ~eq:Phys.As_key.equal
    ~hash:Phys.As_key.hash to_twine_ref;
  Imandrakit_twine.Decode.add_cache of_twine_ref
