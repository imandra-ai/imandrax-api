type 'ty t_poly = {
  trigger_head: 'ty Pattern_head.t_poly;  (** Root of the pattern *)
  trigger_patterns: 'ty Fo_pattern.t_poly list;
  trigger_instantiation_rule_name: Imandrax_api.Uid.t;
      (** Name of the instantiation rule *)
}
[@@deriving twine, typereg, eq, map, iter, show { with_path = false }]
