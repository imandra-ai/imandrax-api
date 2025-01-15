include Imandrax_api_common.Rewrite_rule

type t = (Term.t, Type.t) Imandrax_api_common.Rewrite_rule.t_poly
[@@deriving show, twine, typereg]
(** A rewrite rule *)
