type lift_bool =
  | Default
      (** Includes the rules [x1 && x2] --> [if x1 then x2 else false]
          [x1 || x2] --> [if x1 then true else x2] [x1 ==> x2] -->
          [if x1 then x2 else true] *)
  | Nested_equalities
      (** Extends [Default] with the rules [(x = y) = z] -->
          [if x = y then z else not z] [z = (x = y)] -->
          [if z then (x = y) else not (x = y)] *)
  | Equalities
      (** Extends [Default] with the rule [x = y] -->
          [if x = y then true else false] *)
  | All
      (** Extends [Default] with the rule [(t : bool)] -->
          [if t then true else false] *)
[@@deriving show, twine, typereg]

type t_ = {
  f_id: Imandrax_api.Uid.t;
  assuming: Imandrax_api.Uid.t option;
  basis: Imandrax_api.Uid_set.t;
  rule_specs: Imandrax_api.Uid_set.t;
  ctx_simp: bool;
  lift_bool: lift_bool;
  prune: bool;
}
[@@deriving show, twine, typereg]
(** Root decomposition task, from the name of a function to decompose *)

