(** Commonalities for types *)

type ('id, 't) adt_row = {
  c: 'id;
  labels: 'id list option;  (** for inline records; same length as [args] *)
  args: 't list;
  doc: string option;
}
[@@deriving twine, typereg, show { with_path = false }, iter, map]
(** List of constructors for an algebraic type *)

type ('id, 't) rec_row = {
  f: 'id;
  ty: 't;
  doc: string option;
}
[@@deriving twine, typereg, show { with_path = false }, iter, map]
(** List of record fields *)

(** Definition of a named type *)
type ('id, 't, 'alias) decl =
  | Algebraic of ('id, 't) adt_row list
  | Record of ('id, 't) rec_row list
  | Alias of {
      target: 'alias;  (** Aliased type *)
      reexport_def: ('id, 't, 'alias) decl option;
          (** Do we re-export the definition here? *)
    }
  | Skolem
  | Builtin of Builtin.Ty.t
  | Other
[@@deriving twine, typereg, show { with_path = false }, iter, map]

(** A general type expression for ImandraX *)
type ('lbl, 'var, +'t) view =
  | Var of 'var
  | Arrow of 'lbl * 't * 't
  | Tuple of 't list
  | Constr of Uid.t * 't list
[@@deriving twine, typereg, eq, ord, map, iter, show { with_path = false }]

let hash_view h_lbl h_var h_sub view : int =
  let module H = CCHash in
  match view with
  | Var v -> H.combine2 10 (h_var v)
  | Arrow (lbl, a, b) -> H.combine4 20 (h_lbl lbl) (h_sub a) (h_sub b)
  | Tuple l -> H.combine2 30 (H.list h_sub l)
  | Constr (p, l) -> H.combine3 40 (Uid.hash p) (H.list h_sub l)

type 'ty def_poly = {
  name: Uid.t;
  params: Uid.t list;
  decl: (Uid.t, 'ty, Void.t) decl;
  clique: Clique.t option;
  timeout: int option;
}
[@@deriving twine, show { with_path = false }, typereg]
