type gen_kind =
  | Local
  | To_be_rewritten
[@@deriving twine, eq, ord, show { with_path = false }]

type view =
  | Generative of {
      id: int;
      gen_kind: gen_kind;
    }
  | Persistent
  | Cname of { cname: Cname.t }
  | Builtin of { kind: Builtin_data.kind }
[@@deriving twine, eq, ord, show { with_path = false }]

type t = private {
  name: string;
  mutable view: view;
}
[@@deriving twine, eq, ord, show { with_path = false }]

val hash_gen_kind : gen_kind -> int

val hash : t -> int

module Tbl : HashtblCache.S with type key = t

module Weak_Tbl : WeakHashtblCache.S with type key = t

module Map : CCMap.S with type key = t

module Set : CCSet.S with type elt = t

(**/**)

module Private_ : sig
  val make : string -> view -> t [@@alert expert "respect invariants"]

  val set_view : t -> view -> unit [@@alert expert "respect invariants"]
end

(**/**)
