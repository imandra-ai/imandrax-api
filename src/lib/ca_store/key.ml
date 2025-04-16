type t = string Util_twine_.With_tag7.t [@@deriving eq, ord, typereg, twine]
(** A CA store key.

    We wrap the string in tag(7,...) so we can statically find keys in stored
    blobs, potentially enabling things like GC in the future *)

let show self = spf "(cstore.key %s)" self
let pp = Fmt.of_to_string show
let slugify : t -> string = Fun.id
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

let to_str_ = Private_.to_string [@alert "-expert"]
let of_str_ = Private_.of_string [@alert "-expert"]
let[@inline] chasher ctx (self : t) = Chash.string ctx (to_str_ self)

let[@inline] chash ~ty hash : t =
  if String.contains ty ':' then invalid_arg "chash key: ty cannot contain ':'";
  of_str_ @@ spf "hash:%s:%s" ty (Chash.slugify hash)

let[@inline] cname (cname : Cname.t) : t =
  assert cname.is_key;
  let ty = "id" in
  of_str_ @@ spf "cname:%s:%s" ty (Cname.slugify cname)

let[@inline] task ~kind hash : t =
  if String.contains kind ':' then
    invalid_arg "task key: kind cannot contain ':'";
  of_str_ @@ spf "task:%s:%s" kind (Chash.slugify hash)

let[@inline] custom ~ns str : t =
  if String.contains ns ':' then
    invalid_arg "custom key: namespace cannot contain ':'";
  of_str_ @@ spf "custom:%s:%s" ns str

type view =
  | Chash of {
      ty: string;
      h: Chash.t;
    }
  | Cname of {
      ty: string;
      name: Cname.t;
    }
  | Task of {
      kind: string;
      h: Chash.t;
    }
  | Custom of {
      ns: string;
      data: string;
    }

let split2_ s =
  try
    let s1, s2 = CCString.Split.left_exn ~by:":" s in
    let s2, s3 = CCString.Split.left_exn ~by:":" s2 in
    s1, s2, s3
  with _ ->
    Error.failf ~kind:Error_kinds.deserializationError
      "Invalid CA Store key: %S" s

let view (self : t) : view =
  match split2_ self with
  | "hash", ty, h ->
    let h = Chash.unslugify h in
    Chash { ty; h }
  | "cname", ty, name ->
    let name =
      match Cname.unslugify name with
      | Some c -> c
      | None ->
        Error.failf ~kind:Error_kinds.deserializationError "Invalid cname: %S"
          name
    in
    Cname { ty; name }
  | "task", kind, h ->
    let h = Chash.unslugify h in
    Task { kind; h }
  | "custom", ns, data -> Custom { ns; data }
  | _ ->
    Error.failf ~kind:Error_kinds.deserializationError
      "Invalid CA Store key: %S" self

let unslugify (str : string) : t option =
  try
    ignore (view str : view);
    Some str
  with _ -> None

let unslugify_exn (str : string) : t =
  ignore (view str : view);
  str

let[@inline] as_chash self =
  match view self with
  | Chash { ty; h } -> Some (ty, h)
  | _ -> None

let[@inline] as_task self =
  match view self with
  | Task { kind; h } -> Some (kind, h)
  | _ -> None

let[@inline] is_task self = Option.is_some @@ as_task self

let as_cname (self : t) : _ option =
  match view self with
  | Cname { ty; name } -> Some (ty, name)
  | _ -> None
