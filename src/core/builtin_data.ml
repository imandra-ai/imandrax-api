type kind =
  | Logic_core of { logic_core_name: string }
  | Special of { tag: string }
  | Tactic of { tac_name: string }
  | Decomp of { decomp_name: string }
[@@deriving twine, typereg, eq, ord, show { with_path = false }]

let hash_kind = function
  | Logic_core { logic_core_name } -> Hashtbl.hash (30, logic_core_name)
  | Special { tag } -> Hashtbl.hash (40, tag)
  | Tactic { tac_name } -> Hashtbl.hash (50, tac_name)
  | Decomp { decomp_name : string } -> Hashtbl.hash (60, decomp_name)
