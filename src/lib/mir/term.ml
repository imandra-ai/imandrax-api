(** Surface terms.

    These terms use content-addressed names for functions, constructors, etc.
    They're also serializable (using cbor-pack).
*)

module ID : sig
  type t = private int [@@deriving twine, eq, ord, show]

  val hash : t -> int
  val gen : unit -> t [@@alert expert "please use Term.make"]
  val of_int : int -> t [@@alert expert "Please use Term.make"]
end = struct
  type t = int [@@deriving twine, eq, ord, show]

  let hash = CCHash.int
  let id_gen_ = Atomic.make 0
  let[@inline] gen () = Atomic.fetch_and_add id_gen_ 1
  let of_int = Fun.id
end

type 't view =
  | Const of Imandrax_api.Const.t
  | If of 't * 't * 't
  | Apply of {
      f: 't;
      l: 't list;
    }
  | Var of Var.t
  | Sym of Applied_symbol.t
  | Construct of {
      c: Applied_symbol.t;
      args: 't list;
    }
  | Destruct of {
      c: Applied_symbol.t;
      i: int;
      t: 't;
    }
  | Is_a of {
      c: Applied_symbol.t;
      t: 't;
    }
  | Tuple of { l: 't list }
  | Field of {
      f: Applied_symbol.t;
      t: 't;
    }
  | Tuple_field of {
      i: int;
      t: 't;
    }
  | Record of {
      rows: (Applied_symbol.t * 't) list;
      rest: 't option;
    }
  | Case of {
      u: 't;
      cases: (Applied_symbol.t * 't) list;
      default: 't option;
    }
[@@deriving map, iter, eq, twine, typereg, show { with_path = false }]

open struct
  module Const = Imandrax_api.Const
end

let hash_view hasht (v : _ view) : int =
  match v with
  | Const c -> CCHash.(combine2 1 (Const.hash c))
  | If (a, b, c) -> CCHash.(combine4 2 (hasht a) (hasht b) (hasht c))
  | Apply { f; l = args } -> CCHash.(combine3 4 (hasht f) (list hasht args))
  | Var v -> CCHash.(combine2 10 (Var.hash v))
  | Sym f -> CCHash.(combine2 11 (Applied_symbol.hash f))
  | Construct { c; args } ->
    CCHash.(combine3 15 (Applied_symbol.hash c) (list hasht args))
  | Destruct { c; i; t } ->
    CCHash.(combine4 16 (Applied_symbol.hash c) (int i) (hasht t))
  | Is_a { c; t } -> CCHash.(combine3 17 (Applied_symbol.hash c) (hasht t))
  | Tuple { l } -> CCHash.(combine2 20 (list hasht l))
  | Field { f; t } -> CCHash.(combine3 30 (Applied_symbol.hash f) (hasht t))
  | Tuple_field { i; t } -> CCHash.(combine3 31 (int i) (hasht t))
  | Record { rows; rest } ->
    CCHash.(
      combine3 40 (list (pair Applied_symbol.hash hasht) rows) (opt hasht rest))
  | Case { u; cases; default } ->
    CCHash.(
      combine4 50 (hasht u)
        (list (pair Applied_symbol.hash hasht) cases)
        (opt hasht default))

module Build_ : sig
  type generation [@@deriving show, eq, twine]

  module State : sig
    type t

    val create : ?size:int -> unit -> t
    val generation : t -> generation
    val ty_st : t -> Type.State.t
    val k_state : t Hmap.key
    val add_to_dec : Imandrakit_twine.Decode.t -> t -> unit

    val get_from_dec_exn : Imandrakit_twine.Decode.t -> t
    (** @raise Failwith if not present *)
  end

  type t = private {
    view: t view;
    ty: Type.t;
    mutable id: int;
    generation: generation;
  }
  [@@deriving twine, show, eq]

  val hash : t -> int
  val make : State.t -> t view -> Type.t -> t
end = struct
  type generation = int [@@deriving show, eq, twine]

  type t = {
    view: t view;
    ty: Type.t;
    mutable id: int;  (** Generative ID *)
    generation: generation;
  }
  [@@deriving twine, typereg, show { with_path = false }]

  let[@inline] equal t1 t2 : bool =
    assert (t1.generation = t2.generation);
    t1 == t2

  let[@inline] hash t = CCHash.int t.id

  module H = Hashcons.Make (struct
    type nonrec t = t

    let equal t1 t2 = Type.equal t1.ty t2.ty && equal_view equal t1.view t2.view
    let hash t = CCHash.combine2 (Type.hash t.ty) (hash_view hash t.view)

    let set_id t id =
      assert (t.id = -1);
      t.id <- id
  end)

  module State = struct
    type t = {
      ty_st: Type.State.t;
      hcons: H.t;
      generation: generation;
    }

    let gen_counter = Atomic.make 0

    let create ?size () : t =
      let generation = Atomic.fetch_and_add gen_counter 1 in
      { ty_st = Type.State.create (); hcons = H.create ?size (); generation }

    let k_state = Hmap.Key.create ()
    let[@inline] ty_st self = self.ty_st
    let[@inline] generation self = self.generation

    let add_to_dec dec (self : t) : unit =
      Imandrakit_twine.Decode.hmap_set dec k_state self

    let get_from_dec_exn dec : t =
      match Imandrakit_twine.Decode.hmap_get dec k_state with
      | Some st -> st
      | None -> failwith "MIR term: no state in the decoder"
  end

  let[@inline] make (st : State.t) view ty : t =
    H.hashcons st.hcons { view; ty; generation = st.generation; id = -1 }

  type term = t

  open struct
    type ser = {
      view: t view;
      ty: Type.t;
    }
    [@@deriving twine]

    let[@inline] ser_of_term (t : term) : ser = { view = t.view; ty = t.ty }
    let[@inline] ser_to_term st ser : term = make st ser.view ser.ty
  end

  let () =
    (* serializing skips [id] entirely by converting to [ser] on the fly,
       and deserializing re-hashconses on the fly *)
    (to_twine_ref := fun enc t -> ser_to_twine enc @@ ser_of_term t);
    (of_twine_ref :=
       fun dec t ->
         let st = State.get_from_dec_exn dec in
         ser_of_twine dec t |> ser_to_term st);

    Imandrakit_twine.Decode.add_cache of_twine_ref;
    Imandrakit_twine.Encode.add_cache_with ~eq:( == )
      ~hash:(fun t -> CCHash.int t.id)
      to_twine_ref;
    ()
end

include Build_

let pp_ = ref pp
let pp_view_ = ref pp_view
let pp out x = !pp_ out x
let pp_view out v = !pp_view_ pp out v
let show = Fmt.to_string pp

type term = t [@@deriving twine, typereg, show]

open Imandrax_api

let[@inline] view (self : t) : t view = self.view

module As_key = struct
  type nonrec t = t

  let equal = equal
  let hash = hash
  let compare = compare
end

module Tbl = CCHashtbl.Make (As_key)
module Map = CCMap.Make (As_key)
module Set = CCSet.Make (As_key)

let[@inline] belongs (st : State.t) (t : t) : bool =
  equal_generation (State.generation st) t.generation

(** [transfer st t] tranfers [t] from its current state to [st] *)
let transfer (st : State.t) (t : t) : t =
  let tbl = Tbl.create 16 in
  let rec loop t =
    if belongs st t then (
      assert (Type.belongs (State.ty_st st) t.ty);
      t
    ) else (
      match Tbl.find tbl t with
      | u -> u
      | exception Not_found ->
        let ty = Type.transfer (State.ty_st st) t.ty in
        let view = map_view loop t.view in
        let u = make st view ty in
        Tbl.add tbl t u;
        u
    )
  in
  loop t
