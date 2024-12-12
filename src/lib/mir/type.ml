include Imandrax_api.Ty_view

type var = Imandrax_api.Uid.t [@@deriving show, twine, typereg, eq, ord]
(** Type variables *)

type clique = Imandrax_api.Uid_set.t [@@deriving twine, typereg, eq, ord, show]
(** set of mutually recursive types *)

type t = { view: (unit, var, t) Imandrax_api.Ty_view.view }
[@@unboxed] [@@deriving twine, typereg, show]
(** A type expression *)

open Imandrax_api

let pp_ = ref pp
let pp out x = !pp_ out x
let show = Fmt.to_string pp
let[@inline] view (self : t) = self.view

let rec equal (a : t) (b : t) : bool =
  a == b
  || equal_view
       (fun () () -> true)
       Imandrax_api.Uid.equal equal (view a) (view b)

let rec compare (a : t) (b : t) : int =
  if a == b then
    0
  else
    compare_view (fun () () -> 0) Uid.compare compare (view a) (view b)

let hash_shallow ~h_var ~h_sub ty : int =
  let module H = CCHash in
  match view ty with
  | Var v -> H.combine2 10 (h_var v)
  | Arrow (_, a, b) -> H.combine3 20 (h_sub a) (h_sub b)
  | Tuple l -> H.combine2 30 (H.list h_sub l)
  | Constr (p, l) -> H.combine3 40 (Uid.hash p) (H.list h_sub l)

let hash (t : t) : int =
  let rec aux (a : t) = hash_shallow ~h_var:Uid.hash ~h_sub:aux a in
  aux t

let () =
  (* it's worth paying for sharing, types are normally small and there's
     many copies of the same type. *)
  Imandrakit_twine.Encode.add_cache_with ~eq:equal ~hash to_twine_ref;
  Imandrakit_twine.Decode.add_cache of_twine_ref

type def = {
  name: Imandrax_api.Uid.t;
  params: var list;
  decl: (Imandrax_api.Uid.t, t, Void.t) Imandrax_api.Ty_view.decl;
  clique: clique option;
  timeout: int option;
}
[@@deriving twine, typereg]

let () =
  Imandrakit_twine.Encode.add_cache_with
    ~eq:(fun d1 d2 -> Uid.equal d1.name d2.name)
    ~hash:(fun d -> Uid.hash d.name)
    def_to_twine_ref;
  Imandrakit_twine.Decode.add_cache def_of_twine_ref
