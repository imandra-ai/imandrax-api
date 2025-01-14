(** Codec with complex deserialization state *)

type ('st, 'a) t =
  | C : {
      codec: 'a Codec.t;
      init: Imandrakit_twine.Decode.t -> 'res -> unit;
      with_setup: 'a. 'st -> ('res -> 'a) -> 'a;
    }
      -> ('st, 'a) t

let name (C self) = self.codec.name

let of_codec codec : (unit, _) t =
  C { codec; init = (fun _ () -> ()); with_setup = (fun () f -> f ()) }

let encode_to_string (C self : (_, 'a) t) (x : 'a) : string =
  Imandrakit_twine.Encode.encode_to_string self.codec.enc x

let decode_string (C self : ('res, 'a) t) (res : 'res) (str : string) : 'a =
  let@ res = self.with_setup res in
  Imandrakit_twine.Decode.decode_string
    ~init:(fun dec -> self.init dec res)
    self.codec.dec str
