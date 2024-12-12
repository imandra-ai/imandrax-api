include Imandrax_api.Fun_decomp_poly

module Region = struct
  type t = (Term.t, Type.t) Region_poly.t
  [@@deriving show, twine, typereg] [@@typereg.name "Region.t"]
end

type t = (Term.t, Type.t) t_poly [@@deriving show, twine, typereg]
