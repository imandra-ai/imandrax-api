open Imandrax_api
include Imandrax_api.Ty_view

type var = Imandrax_api.Uid.t [@@deriving show, twine, typereg, eq, ord]
(** Type variables *)

type clique = Imandrax_api.Uid_set.t [@@deriving twine, typereg, eq, ord, show]
(** set of mutually recursive types *)

module Build_ : sig
  type generation [@@deriving show, eq, twine]

  module State : sig
    type t

    val create : ?size:int -> unit -> t
    val k_state : t Hmap.key
    val generation : t -> generation
    val add_to_dec : Imandrakit_twine.Decode.t -> t -> unit

    val get_from_dec_exn : Imandrakit_twine.Decode.t -> t
    (** @raise Failwith if not present *)

    val non_hashconsing : t
    (** A special state that doesn't hashcons *)
  end

  type ser = { view: (unit, var, t) view } [@@unboxed]

  and t = private {
    view: (unit, var, t) Imandrax_api.Ty_view.view;
    generation: generation;
  }
  [@@deriving twine, show, eq]
  (** A type expression *)

  val hash : t -> int
  val make : State.t -> (unit, var, t) view -> t
end = struct
  type generation = int [@@deriving show, eq, twine, typereg]

  let non_hashconsed_generation = -42

  type t = {
    view: (unit, var, t) Imandrax_api.Ty_view.view;
    generation: (generation[@ocaml_only]);
  }
  [@@deriving twine, typereg, show { with_path = false }]

  let rec equal_rec_ t1 t2 : bool =
    let hashconsed_same_gen =
      t1.generation == t2.generation
      && t1.generation != non_hashconsed_generation
    in
    if hashconsed_same_gen then
      t1 == t2
    else
      equal_view (fun () () -> true) Uid.equal equal_rec_ t1.view t2.view

  let[@inline] equal a b = a == b || equal_rec_ a b

  let rec hash_rec_ depth (t : t) : int =
    if depth = 0 then
      hash_view (fun () -> 0) Uid.hash (fun _ -> 0) t.view
    else
      hash_view (fun () -> 0) Uid.hash (hash_rec_ (depth - 1)) t.view

  let[@inline] hash (t : t) : int = hash_rec_ 2 t

  module H = Hashcons.Make (struct
    type nonrec t = t

    let equal (t1 : t) (t2 : t) =
      equal_view (fun () () -> true) equal_var equal t1.view t2.view

    let hash t =
      Imandrax_api.Ty_view.hash_view
        (fun _ -> 0)
        Imandrax_api.Uid.hash hash t.view

    let set_id _t _id = ()
  end)

  module State = struct
    type t = {
      hcons: H.t option;
      generation: generation;
    }

    let gen_counter = Atomic.make 0

    let create ?size () : t =
      let generation = Atomic.fetch_and_add gen_counter 1 in
      { hcons = Some (H.create ?size ()); generation }

    let non_hashconsing : t =
      { generation = non_hashconsed_generation; hcons = None }

    let[@inline] generation self = self.generation
    let k_state : t Hmap.key = Hmap.Key.create ()

    let add_to_dec dec (self : t) : unit =
      Imandrakit_twine.Decode.hmap_set dec k_state self

    let get_from_dec_exn dec : t =
      match Imandrakit_twine.Decode.hmap_get dec k_state with
      | Some st -> st
      | None -> failwith "MIR type: no state in the decoder"
  end

  let make (st : State.t) view : t =
    let t = { view; generation = st.generation } in
    match st.hcons with
    | None -> t
    | Some h -> H.hashcons h t

  type ty = t

  type ser = { view: (unit, var, t) Imandrax_api.Ty_view.view }
  [@@unboxed] [@@deriving twine, show, eq, typereg]

  open struct
    let[@inline] ser_of_ty (t : ty) : ser = { view = t.view }
    let[@inline] ser_to_ty st (ser : ser) : ty = make st ser.view
  end

  let () =
    (* serializing skips [id] entirely by converting to [ser] on the fly,
       and deserializing re-hashconses on the fly *)
    (to_twine_ref := fun enc t -> ser_to_twine enc @@ ser_of_ty t);
    (of_twine_ref :=
       fun dec t ->
         let st = State.get_from_dec_exn dec in
         ser_of_twine dec t |> ser_to_ty st);

    Imandrakit_twine.Decode.add_cache of_twine_ref;
    Imandrakit_twine.Encode.add_cache_with ~eq:equal ~hash to_twine_ref;
    ()
end

include Build_

let pp_ = ref pp
let pp out x = !pp_ out x
let show = Fmt.to_string pp
let[@inline] view (self : t) = self.view

let rec compare (t1 : t) t2 : int =
  if t1 == t2 then
    0
  else
    compare_view (fun () () -> 0) Uid.compare compare t1.view t2.view

type def = t Imandrax_api.Ty_view.def_poly [@@deriving twine, typereg]

let () =
  Imandrakit_twine.Encode.add_cache_with
    ~eq:(fun d1 d2 -> Uid.equal d1.name d2.name)
    ~hash:(fun d -> Uid.hash d.name)
    def_to_twine_ref;
  Imandrakit_twine.Decode.add_cache def_of_twine_ref

module As_key = struct
  type nonrec t = t

  let equal = equal
  let hash = hash
  let compare = compare
end

module Tbl = CCHashtbl.Make (As_key)
module Map = CCMap.Make (As_key)
module Set = CCSet.Make (As_key)

let[@inline] belongs (st : State.t) (ty : t) : bool =
  equal_generation (State.generation st) ty.generation

(** [transfer st ty] tranfers [ty] from its current state to [st] *)
let transfer (st : State.t) (ty : t) : t =
  let rec loop ty =
    if belongs st ty then
      ty
    else (
      let view = map_view Fun.id Fun.id loop ty.view in
      make st view
    )
  in
  loop ty
