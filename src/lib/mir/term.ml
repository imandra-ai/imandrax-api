(** Surface terms.

    These terms use content-addressed names for functions, constructors, etc.
    They have optional hashconsing and can be serialized efficiently using
    twine. *)

type ('t, 'ty) view =
  | Const of Imandrax_api.Const.t
  | If of 't * 't * 't
  | Apply of {
      f: 't;
      l: 't list;
    }
  | Var of 'ty Imandrax_api_common.Var.t_poly
  | Sym of 'ty Imandrax_api_common.Applied_symbol.t_poly
  | Construct of {
      c: 'ty Imandrax_api_common.Applied_symbol.t_poly;
      args: 't list;
    }
  | Destruct of {
      c: 'ty Imandrax_api_common.Applied_symbol.t_poly;
      i: int;
      t: 't;
    }
  | Is_a of {
      c: 'ty Imandrax_api_common.Applied_symbol.t_poly;
      t: 't;
    }
  | Tuple of { l: 't list }
  | Field of {
      f: 'ty Imandrax_api_common.Applied_symbol.t_poly;
      t: 't;
    }
  | Tuple_field of {
      i: int;
      t: 't;
    }
  | Record of {
      rows: ('ty Imandrax_api_common.Applied_symbol.t_poly * 't) list;
      rest: 't option;
    }
  | Case of {
      u: 't;
      cases: ('ty Imandrax_api_common.Applied_symbol.t_poly * 't) list;
      default: 't option;
    }
  | Sequence of 't list * 't
      (** [Sequence (t1...tn, u)] is the same as [u] but with a hint that we
          evaluate [t1...tn] in order first. *)
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

  val non_hashconsed_generation : generation

  module State : sig
    type hcons

    type t = private {
      ty_st: Type.State.t;
      hcons: hcons;
      generation: generation;
    }

    val create : ?size:int -> unit -> t
    val generation : t -> generation
    val ty_st : t -> Type.State.t
    val k_state : t Hmap.key
    val add_to_dec : Imandrakit_twine.Decode.t -> t -> unit

    val get_from_dec_exn : Imandrakit_twine.Decode.t -> t
    (** @raise Failwith if not present *)

    val non_hashconsing : t
    (** A special state that doesn't hashcons *)
  end

  type ser = {
    view: (t, Type.t) view;
    ty: Type.t;
    sub_anchor: Imandrax_api.Sub_anchor.t option;
  }

  and t = private {
    view: (t, Type.t) view;
    ty: Type.t;
    generation: generation;
    sub_anchor: Imandrax_api.Sub_anchor.t option;
  }
  [@@deriving twine, show, eq]

  val hash : t -> int

  val make :
    ?sub_anchor:Imandrax_api.Sub_anchor.t ->
    State.t ->
    (t, Type.t) view ->
    Type.t ->
    t

  val set_sub_anchor : State.t -> t -> Imandrax_api.Sub_anchor.t -> t
end = struct
  type generation = int [@@deriving show, eq, twine, typereg]

  let non_hashconsed_generation = -42

  type t = {
    view: (t, Type.t) view;
    ty: Type.t;
    generation: (generation[@ocaml_only]);
    sub_anchor: Imandrax_api.Sub_anchor.t option;
  }
  [@@deriving twine, typereg, show { with_path = false }]

  (** Recursive equality check *)
  let rec equal_rec t1 t2 : bool =
    let hashconsed_same_gen =
      t1.generation == t2.generation
      && t1.generation != non_hashconsed_generation
    in
    if hashconsed_same_gen then
      t1 == t2
    else
      Type.equal t1.ty t2.ty
      && equal_view equal_rec Type.equal t1.view t2.view
      && Option.equal Imandrax_api.Sub_anchor.equal t1.sub_anchor t2.sub_anchor

  (** Hash. We cannot use [t.id] because it doesn't work across generations or
      on non hashconsed terms. *)
  let hash (t : t) : int =
    let rec hash_rec_ depth t =
      if depth = 0 then
        hash_view (fun _ -> 1) t.view
      else
        CCHash.combine3 (Type.hash t.ty)
          (hash_view (hash_rec_ (depth - 1)) t.view)
          (CCHash.opt Imandrax_api.Sub_anchor.hash t.sub_anchor)
    in
    hash_rec_ 3 t

  let[@inline] equal t1 t2 : bool = t1 == t2 || equal_rec t1 t2

  module H = Hashtbl.Make (struct
    type nonrec t = t

    let equal t1 t2 =
      Type.equal t1.ty t2.ty
      && equal_view equal Type.equal t1.view t2.view
      && Option.equal Imandrax_api.Sub_anchor.equal t1.sub_anchor t2.sub_anchor

    let hash = hash
  end)

  module State = struct
    type hcons = t H.t option

    type t = {
      ty_st: Type.State.t;
      hcons: hcons;
      generation: generation;
    }

    let gen_counter = Atomic.make 0

    let create ?size () : t =
      let generation = Atomic.fetch_and_add gen_counter 1 in
      let size = Option.value ~default:16 size in
      { ty_st = Type.State.create (); hcons = Some (H.create size); generation }

    let non_hashconsing =
      {
        generation = non_hashconsed_generation;
        hcons = None;
        ty_st = Type.State.non_hashconsing;
      }

    let k_state = Hmap.Key.create ()
    let[@inline] ty_st self = self.ty_st
    let[@inline] generation self = self.generation

    let add_to_dec dec (self : t) : unit =
      Type.State.add_to_dec dec self.ty_st;
      Imandrakit_twine.Decode.hmap_set dec k_state self

    let get_from_dec_exn dec : t =
      match Imandrakit_twine.Decode.hmap_get dec k_state with
      | Some st -> st
      | None -> failwith "MIR term: no state in the decoder"
  end

  let[@inline never] hashcons_ (tbl : _ H.t) t : t =
    match H.find tbl t with
    | u -> u
    | exception Not_found ->
      H.add tbl t t;
      t

  let[@inline] make ?sub_anchor (st : State.t) view ty : t =
    let t = { view; ty; generation = st.generation; sub_anchor } in
    match st.hcons with
    | None -> t
    | Some h -> hashcons_ h t

  let[@inline] set_sub_anchor st t sub_anchor : t =
    make ~sub_anchor st t.view t.ty

  type term = t

  type ser = {
    view: (t, Type.t) view;
    ty: Type.t;
    sub_anchor: Imandrax_api.Sub_anchor.t option;
  }
  [@@deriving twine, typereg, show, eq]

  open struct
    let[@inline] ser_of_term (t : term) : ser =
      { view = t.view; ty = t.ty; sub_anchor = t.sub_anchor }

    let[@inline] ser_to_term st ser : term =
      make st ?sub_anchor:ser.sub_anchor ser.view ser.ty
  end

  let () =
    (* serializing skips [id] entirely by converting to [ser] on the fly,
       and deserializing re-hashconses on the fly *)
    (to_twine_ref := fun enc t -> ser_to_twine enc @@ ser_of_term t);
    (of_twine_ref :=
       fun dec t ->
         (* NOTE: maybe we could handle [None] by using non hashconsing state? *)
         let st = State.get_from_dec_exn dec in
         ser_of_twine dec t |> ser_to_term st);

    Imandrakit_twine.Decode.add_cache of_twine_ref;
    Imandrakit_twine.Encode.add_cache_with to_twine_ref ~eq:equal ~hash
      ~skip:(fun t ->
        (* comparison on non hashconsed terms might be very costly, just skip *)
        t.generation = non_hashconsed_generation);
    ()
end

include Build_

let pp_ = ref pp
let pp_view_ : (_ -> _ -> (t, Type.t) view Fmt.printer) ref = ref pp_view
let pp out x = !pp_ out x
let pp_view out v = !pp_view_ pp out v
let show = Fmt.to_string pp

type term = t [@@deriving twine, typereg, show]

open Imandrax_api

let[@inline] view (self : t) : (t, Type.t) view = self.view

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
        let ty = Type.transfer st.ty_st t.ty in
        let view = map_view loop (Type.transfer st.ty_st) t.view in
        let u = make st view ty in
        Tbl.add tbl t u;
        u
    )
  in
  loop t
