type 'term t = {
  assertion: 'term;
      (** New boolean term that is true and can be added to the context *)
  from_rule: Uid.t;  (** Name of the rule used *)
}
[@@deriving show { with_path = false }, twine, typereg, map]
