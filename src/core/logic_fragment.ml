module B = Bit_field.Make ()

open struct
  let ser_ (_ : Imandrakit_twine.Encode.t) (self : B.t) =
    Imandrakit_twine.Immediate.(int (self :> int))

  let deser_ dec c : B.t =
    let i = Imandrakit_twine.Decode.int_truncate dec c in
    B.unsafe_of_int i
end

type t = (B.t[@twine.encode ser_] [@twine.decode deser_])
[@@deriving twine, typereg]

type field = B.field

(** Datatypes *)
let f_dt : field = B.mk_field ()

(** Recursive functions *)
let f_recfuns : field = B.mk_field ()

(** LRA *)
let f_lra : field = B.mk_field ()

(** LIA *)
let f_lia : field = B.mk_field ()

(** NRA *)
let f_nra : field = B.mk_field ()

(** NIA *)
let f_nia : field = B.mk_field ()

let () = B.freeze ()

module Expanded = struct
  type t = {
    dt: bool;
    lra: bool;
    lia: bool;
    nra: bool;
    nia: bool;
  }
  [@@deriving show { with_path = false }]
end

let expand (self : t) : Expanded.t =
  {
    Expanded.dt = B.get f_dt self;
    lra = B.get f_lra self;
    lia = B.get f_lia self;
    nra = B.get f_nra self;
    nia = B.get f_nia self;
  }

let pp out (self : t) = Expanded.pp out (expand self)

let show self = Expanded.show (expand self)
