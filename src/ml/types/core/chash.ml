(** Cryptographic Hash *)

type t = (string[@use_bytes]) [@@deriving twine, typereg, show, ord, eq]

let hash = CCHash.string

let () =
  Imandrakit_twine.Encode.add_cache_with ~max_string_size:0 ~eq:equal ~hash
    to_twine_ref;
  Imandrakit_twine.Decode.add_cache of_twine_ref

module Private_ = struct
  let dummy : t = "\xDE\xAD\xBE\xEF"

  let n_bits = 256

  let n_bytes = n_bits / 8

  let _of_bin x : t =
    if String.length x <> n_bytes then
      Imandrakit.Error.failf ~kind:Error_kinds.deserializationError
        "chash: expected %dB, got a blob %dB long." n_bytes (String.length x);

    x
end
