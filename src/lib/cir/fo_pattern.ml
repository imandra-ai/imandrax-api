include Imandrax_api_common.Fo_pattern

type t = Type.t t_poly [@@deriving twine, typereg, eq, show]
(** A first-order pattern *)
