module Raw = struct
  type t = { key: Cstore_key.t } [@@unboxed] [@@deriving eq, ord]

  let show self = Cstore_key.show self.key

  let pp out self = Cstore_key.pp out self.key

  let to_twine st self = Cstore_key.to_twine st self.key

  let of_twine st v =
    let key = Cstore_key.of_twine st v in
    { key }

  let to_string self = Cstore_key.slugify self.key

  let[@inline] slugify (self : t) = Cstore_key.slugify self.key

  let[@inline] unslugify_exn s : t = { key = Cstore_key.unslugify_exn s }
end

type 'a t = Raw.t

let[@inline] raw self = self

let show (self : _ t) = Raw.show self

let pp out self = Raw.pp out self

let to_twine' st (self : _ t) = Raw.to_twine st (raw self)

let of_twine' : _ t Imandrakit_twine.decoder = fun dec x -> Raw.of_twine dec x

let to_twine _ st self = to_twine' st self

let of_twine _ st c = of_twine' st c

module Private_ = struct
  let[@inline] unsafe_of_raw r = r

  let[@inline] raw_of_key key = { Raw.key }

  let[@inline] raw_to_key r = r.Raw.key
end
