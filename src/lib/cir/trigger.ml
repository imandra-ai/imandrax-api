type t = {
  trigger_head: Pattern_head.t;  (** Root of the pattern *)
  trigger_patterns: Fo_pattern.t list;
  trigger_instantiation_rule_name: Imandrax_api.Uid.t;
      (** Name of the instantiation rule *)
}
[@@deriving twine, typereg, eq, show { with_path = false }]
