(** Cryptographic name.

    Most logic objects in ImandraX are content-addressed. Their identity is tied
    to the cryptographic hash ({!Chash.t}) of their {b definition}.

    This means they can be shared freely and independently, and do not depend on
    incidental or generative state. *)

type t = {
  name: string;
  chash: Chash.t;
}
[@@deriving eq, ord, twine, typereg]

let hash self = CCHash.(combine2 (string self.name) (Chash.hash self.chash))

let () =
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
  spf "%s%c%s" self.name sep_websafe_ (Chash.slugify self.chash)

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
      let hash = String.sub str (i + 1) (String.length str - i - 2) in
      (match Chash.unslugify hash with
      | chash -> Some { name; chash }
      | exception Invalid_argument _ -> None)
  )
