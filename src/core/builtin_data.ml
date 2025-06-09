type kind =
  | Logic_core of { logic_core_name: string }
  | Special of { tag: string }
  | Tactic of { tac_name: string }
  | Decomp of { decomp_name: string }
[@@deriving twine, typereg, eq, ord, show { with_path = false }]

let[@inline] hash_kind = function
  | Logic_core { logic_core_name } ->
    CCHash.(combine2 30 (string logic_core_name))
  | Special { tag } -> CCHash.(combine2 40 (string tag))
  | Tactic { tac_name } -> CCHash.(combine2 50 (string tac_name))
  | Decomp { decomp_name : string } -> CCHash.(combine2 60 (string decomp_name))
