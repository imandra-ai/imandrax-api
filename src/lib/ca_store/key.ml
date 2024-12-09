type t = string Util_twine_.With_tag7.t [@@deriving eq, ord, typereg, twine]
(** A CA store key.

      We wrap the string in tag(7,...)
      so we can statically find keys in stored blobs, potentially
      enabling things like GC in the future *)

let show self = spf "(cstore.key %s)" self
let pp = Fmt.of_to_string show
let slugify : t -> string = Fun.id
let unslugify_exn : string -> t = Fun.id
let hash = CCHash.string

module Tbl = Str_tbl
module Map = Str_map
module Set = Str_set

(* caching *)
let () =
  Imandrakit_twine.Encode.add_cache_with ~eq:equal ~hash to_twine_ref;
  Imandrakit_twine.Decode.add_cache of_twine_ref

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

let[@inline] custom ~ns str : t = of_str_ @@ spf "custom:%s:%s" ns str

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

let iter_in_twine (s : string) : t Iter.t =
 fun yield ->
  let module V = Imandrakit_twine.Decode.Value in
  let dec = Imandrakit_twine.Decode.of_string s in
  let off_entrypoint = Imandrakit_twine.Decode.get_entrypoint dec in

  let seen = Int_tbl.create 16 in
  let rec loop off : unit =
    let off = Imandrakit_twine.Decode.deref_rec dec off in
    match Imandrakit_twine.Decode.read ~auto_deref:false dec off with
    | V.Null | V.True | V.False | V.Int _ | V.Float _ | V.String _ | V.Blob _
    | V.Cstor0 _ ->
      ()
    | V.Pointer _ -> assert false
    | _ when Int_tbl.mem seen off -> ()
    | V.CstorN (_, a) | V.Array a ->
      Int_tbl.add seen off ();
      Imandrakit_twine.Decode.Array_cursor.to_iter_of a Fun.id |> Iter.iter loop
    | V.Tag (7, v) ->
      (* found a key *)
      let key = Imandrakit_twine.Decode.string dec v in
      yield key
    | V.Dict d ->
      Int_tbl.add seen off ();
      Imandrakit_twine.Decode.Dict_cursor.to_iter_of d (fun k v -> k, v)
      |> Iter.iter (fun (k, v) ->
             loop k;
             loop v)
  in
  loop off_entrypoint
