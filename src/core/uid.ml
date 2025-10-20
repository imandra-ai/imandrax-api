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

let hash_kind_1 = CCHash.int 1
let hash_kind_2 = CCHash.int 2

let[@inline] hash_gen_kind = function
  | Local -> hash_kind_1
  | To_be_rewritten -> hash_kind_2

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

let pp_name out self = Fmt.string out self.name

let full_suffix (x : t) : string =
  match x.view with
  | Generative { id; gen_kind } ->
    let proc_name =
      match gen_kind with
      | Local -> ""
      | To_be_rewritten -> "[temp]"
    in
    spf "/%d%s" id proc_name
  | Cname c -> "/" ^ Chash.show c.cname.chash
  | Persistent | Builtin _ -> ""

let pp_full out (x : t) : unit = Fmt.fprintf out "%s%s" x.name (full_suffix x)
let show_full x = spf "%s%s" x.name (full_suffix x)

(* ppx-deriving printer becomes "pp_debug", and "pp" defaults to the full printer *)
let pp_debug = pp
let pp = pp_full
