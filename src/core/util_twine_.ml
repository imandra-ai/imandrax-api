include Imandrakit.Util_twine

module Z = struct
  type t = Z.t

  let pp = Z.pp_print
  let equal = Z.equal
  let compare = Z.compare

  let to_twine =
    Twine.Encode.(
      fun _ser x ->
        let open Z in
        let is_neg = x < zero in
        let n = shift_left (abs x) 1 in
        let n =
          if is_neg then
            Z.logor n one
          else
            n
        in
        Immediate.blob (Z.to_bits n))

  let of_twine =
    Twine.Decode.(
      fun dec x ->
        let open Z in
        let n = of_bits (blob dec x) in
        let is_neg = is_odd n in
        let n = shift_right_trunc n 1 in
        if is_neg then
          ~-n
        else
          n)
end

module Q : sig
  type t = Q.t [@@deriving twine, show, eq, ord]
end = struct
  type as_pair = {
    num: Z.t;
    denum: Z.t;
  }
  [@@deriving twine, typereg]

  type t = Q.t

  let equal = Q.equal
  let show = Q.to_string
  let compare = Q.compare
  let pp = Q.pp_print

  let[@inline] to_twine ser x =
    as_pair_to_twine ser { num = Q.num x; denum = Q.den x }

  let[@inline] of_twine deser x =
    let { num; denum } = as_pair_of_twine deser x in
    Q.make num denum
end

module Make_with_tag (X : sig
  val tag : int
end) =
struct
  type 'a tagged = 'a [@@deriving show, eq, ord]

  let to_twine enc_a enc (self : 'a tagged) =
    Imandrakit_twine.Encode.(tag enc ~tag:X.tag ~v:(enc_a enc self))

  let of_twine (dec_a : 'a Imandrakit_twine.Decode.decoder) dec off : 'a tagged
      =
    Imandrakit_twine.Decode.(
      let n, v = tag dec off in
      if n <> X.tag then fail (spf "expected a `tag(%d, …)`" X.tag);
      let s = dec_a dec v in
      s)
end

(** a value that will be tagged with 7 in twine *)
module With_tag7 = struct
  include Make_with_tag (struct
    let tag = 7
  end)

  type 'a t = 'a tagged
  [@@deriving show, eq, ord, typereg] [@@typereg.name "with_tag7"]
end

module With_tag6 = struct
  include Make_with_tag (struct
    let tag = 6
  end)

  type 'a t = 'a tagged
  [@@deriving show, eq, ord, typereg] [@@typereg.name "with_tag6"]
end
