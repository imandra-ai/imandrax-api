type t = string [@@deriving eq, ord, typereg]

let show self = spf "(cstore.key %s)" self
let pp = Fmt.of_to_string show
let slugify : t -> string = Fun.id
let unslugify_exn : string -> t = Fun.id
let hash = CCHash.string

module Tbl = Str_tbl
module Map = Str_map

open struct
  (* serialization: we encode as string, but we wrap in tag(7,...)
      so we can statically find keys in stored blobs, potentially
      enabling things like GC in the future *)
  let to_twine_basic_ enc (self : t) =
    Imandrakit_twine.Encode.(tag enc ~tag:7 ~v:(Immediate.string self))

  let to_twine_ref = ref to_twine_basic_

  let of_twine_basic_ dec off : t =
    Imandrakit_twine.Decode.(
      let n, v = tag dec off in
      if n <> 7 then fail "expected a Cstore key as `tag(7, <string>)`";
      let s = string dec v in
      s)

  let of_twine_ref = ref of_twine_basic_

  (* caching *)
  let () =
    Imandrakit_twine.Encode.add_cache_with ~eq:equal ~hash to_twine_ref;
    Imandrakit_twine.Decode.add_cache of_twine_ref
end

let[@inline] to_twine enc x = !to_twine_ref enc x
let[@inline] of_twine dec x = !of_twine_ref dec x

module Private_ = struct
  let to_string = Fun.id
  let of_string = Fun.id
end

let to_str_ = (Private_.to_string [@alert "-expert"])
let of_str_ = (Private_.of_string [@alert "-expert"])
let[@inline] chasher ctx (self : t) = Chash.string ctx (to_str_ self)

let[@inline] chash ~ty hash : t =
  of_str_ @@ spf "hash:%s:%s" ty (Chash.slugify hash)

let[@inline] cname ~ty cname : t =
  of_str_ @@ spf "cname:%s:%s" ty (Cname.slugify cname)

let[@inline] task ~kind hash : t =
  of_str_ @@ spf "task:%s:%s" kind (Chash.slugify hash)

let as_ty_chash_ ~pre (self : t) : _ option =
  match
    let s = self |> to_str_ |> CCString.chop_prefix ~pre |> Option.get in
    let ty, cname = CCString.Split.left_exn ~by:":" s in
    let chash = Chash.unslugify cname in
    ty, chash
  with
  | exception (Not_found | Invalid_argument _) -> None
  | pair -> Some pair

let[@inline] as_chash self = as_ty_chash_ ~pre:"hash:" self
let[@inline] as_task self = as_ty_chash_ ~pre:"task:" self
let[@inline] is_task self = CCString.prefix ~pre:"task:" @@ to_str_ self

let as_cname (self : t) : _ option =
  match
    let s =
      self |> to_str_ |> CCString.chop_prefix ~pre:"cname:" |> Option.get
    in
    let ty, cname = CCString.Split.left_exn ~by:":" s in
    let cname = Cname.unslugify cname |> Option.get in
    ty, cname
  with
  | exception (Not_found | Invalid_argument _) -> None
  | pair -> Some pair
