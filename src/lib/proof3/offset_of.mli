type raw = private Imandrakit_twine.offset [@@deriving show, eq, twine]
type _ t = private Imandrakit_twine.offset

val make : Imandrakit_twine.offset -> _ t
val equal : 'a t -> 'a t -> bool
val show : _ t -> string
val pp : _ t Fmt.printer
val to_twine' : _ t Imandrakit_twine.Encode.encoder

val to_twine :
  'a Imandrakit_twine.Encode.encoder -> 'a t Imandrakit_twine.Encode.encoder

val of_twine' : _ t Imandrakit_twine.Decode.decoder

val of_twine :
  'a Imandrakit_twine.Decode.decoder -> 'a t Imandrakit_twine.Decode.decoder
