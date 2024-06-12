type t = {
  ir_from: Fun_def.t;
  ir_triggers: Trigger.t list;
  ir_kind: Instantiation_rule_kind.t;
}
[@@deriving twine, typereg, show { with_path = false }]
