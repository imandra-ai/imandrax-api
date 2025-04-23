(** Cryptographic name.

    Most logic objects in ImandraX are content-addressed. Their identity is tied
    to the cryptographic hash ({!Chash.t}) of their {b definition}.

    This means they can be shared freely and independently, and do not depend on
    incidental or generative state. *)

type t_ = {
  name: string;
  chash: Chash.t;
  is_key: bool;
      (** Is this cname a key (ie a toplevel definition)? Or, if [false], is it
          just a symbol defined as part of another symbol (cstor, label, etc) *)
}
[@@deriving eq, ord, twine, typereg]

type t = t_ Util_twine.With_tag6.t [@@deriving twine, eq, ord, typereg]

let hash self =
  CCHash.(
    combine3 (string self.name) (Chash.hash self.chash) (bool self.is_key))

let () =
  (* now add caching *)
  Imandrakit_twine.Encode.add_cache_with ~eq:equal ~hash to_twine_ref;
  Imandrakit_twine.Decode.add_cache of_twine_ref

let pp_name out self = Fmt.string out self.name
let pp out self = Fmt.fprintf out "%s/%a" self.name Chash.pp self.chash
let show = Fmt.to_string pp

let pp_abbrev out self =
  Fmt.fprintf out "%s/%a" self.name Chash.pp_abbrev self.chash

let show_abbrev self = spf "%s/%s" self.name (Chash.show_abbrev self.chash)

open struct
  let sep_websafe_ = '/'
end

let slugify self : string =
  let base = spf "%s%c%s" self.name sep_websafe_ (Chash.slugify self.chash) in
  if self.is_key then
    base
  else
    spf "notkey-%s" base

let unslugify (str : string) : t option =
  (* look from the right, since the name itself could contain [sep_websafe_] *)
  if String.length str <= 1 + Chash.n_bytes then
    None
  else (
    match String.rindex_opt str sep_websafe_ with
    | exception Not_found -> None
    | None -> None
    | Some i ->
      let name = String.sub str 0 i in
      let name, is_key =
        if CCString.prefix ~pre:"notkey-" name then
          CCString.chop_prefix ~pre:"notkey-" name |> Option.get, false
        else
          name, true
      in
      let hash = String.sub str (i + 1) (String.length str - i - 2) in
      (match Chash.unslugify hash with
      | chash -> Some { name; chash; is_key }
      | exception Invalid_argument _ -> None)
  )
