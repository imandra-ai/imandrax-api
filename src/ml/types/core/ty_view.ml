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
