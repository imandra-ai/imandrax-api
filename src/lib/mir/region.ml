include Imandrax_api_common.Region

type t = (Term.t, Type.t) Imandrax_api_common.Region.t_poly
[@@deriving show, twine, typereg] [@@typereg.name "Region.t"]
