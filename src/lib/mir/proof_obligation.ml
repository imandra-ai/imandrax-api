include Imandrax_api_common.Proof_obligation

type t = (Term.t, Type.t) t_poly [@@deriving show, twine, typereg]
