type gen_kind =
  | Local
  | To_be_rewritten
[@@deriving twine, typereg, eq, ord, show { with_path = false }]

type view =
  | Generative of {
      id: int;
      gen_kind: gen_kind;
    }
  | Persistent
  | Cname of { cname: Cname.t }
  | Builtin of { kind: Builtin_data.kind }
[@@deriving twine, typereg, eq, ord, show { with_path = false }]

type t = {
  name: string;
  mutable view: view;
}
[@@deriving twine, typereg, eq, ord, show { with_path = false }]

let hash_gen_kind = function
  | Local -> CCHash.int 1
  | To_be_rewritten -> CCHash.int 2

let hash x =
  match x.view with
  | Persistent -> CCHash.(combine2 10 (string x.name))
  | Cname c -> CCHash.combine2 50 (Cname.hash c.cname)
  | Generative { id; gen_kind } ->
    CCHash.(combine4 20 (string x.name) (int id) (hash_gen_kind gen_kind))
  | Builtin { kind = b } ->
    CCHash.(combine3 30 (string x.name) (Builtin_data.hash_kind b))

(* now make sure we use sharing when writing Uids *)
let () =
  Imandrakit_twine.Encode.add_cache_with ~eq:equal ~hash to_twine_ref;
  Imandrakit_twine.Decode.add_cache of_twine_ref;
  ()

module As_key = struct
  type nonrec t = t

  let equal = equal
  let hash = hash
  let compare = compare
end

module Tbl = HashtblCache.Make (As_key)
module Weak_Tbl = WeakHashtblCache.Make (As_key)
module Map = CCMap.Make (As_key)
module Set = CCSet.Make (As_key)

module Private_ = struct
  let[@inline] make name view : t = { name; view }
  let[@inline] set_view self v = self.view <- v
end
