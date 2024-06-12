module Cir = Imandrax_api_cir

type t = { p: t_inner } [@@unboxed]
(** A CIR-level proof term *)

and t_inner = (Cir.Term.t, Cir.Type.t, t) Proof_term_poly.t
[@@deriving twine, typereg]

let rec pp out self = Proof_term_poly.pp Cir.Term.pp Cir.Type.pp pp out self.p
let show = Fmt.to_string pp

type view = (Cir.Term.t, Cir.Type.t, t) View.t [@@deriving show]
type arg = (Cir.Term.t, Cir.Type.t) Arg.t [@@deriving show]

module Phys = struct
  module As_key = struct
    type nonrec t = t

    let equal a b = a.p.id = b.p.id
    let hash a = CCHash.int a.p.id
    let compare a b = compare a.p.id b.p.id
  end

  module Map = CCMap.Make (As_key)
  module Tbl = CCHashtbl.Make (As_key)
  module Weak_Tbl = Ephemeron.K1.Make (As_key)
end

let () =
  (* remove layer of indirection *)
  (to_twine_ref := fun enc t -> t_inner_to_twine enc t.p);
  (of_twine_ref := fun dec off -> { p = t_inner_of_twine dec off });

  Imandrakit_twine.Encode.add_cache_with ~eq:Phys.As_key.equal
    ~hash:Phys.As_key.hash to_twine_ref;
  Imandrakit_twine.Decode.add_cache of_twine_ref
