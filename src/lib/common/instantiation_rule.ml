type ('term, 'ty) t_poly = {
  ir_from: ('term, 'ty) Fun_def.t_poly;
  ir_triggers: 'ty Trigger.t_poly list;
  ir_kind: Instantiation_rule_kind.t;
}
[@@deriving twine, typereg, map, iter, show { with_path = false }]
