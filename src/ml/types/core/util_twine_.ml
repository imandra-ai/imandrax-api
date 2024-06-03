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
