(** View of a proof *)
type ('term, 'ty, 'proof) t =
  | T_assume
      (** The rest of the proof is elsewhere.
          This can be replaced with the actual proof of this proof's goal. *)
  | T_subst of {
      t_subst: ('ty Var_poly.t * 'term) list;
      ty_subst: (Imandrax_api.Uid.t * 'ty) list;
      premise: 'proof;
    }  (** Instantiation of a previous step *)
  | T_deduction of {
      premises: (string * 'proof list) list;
          (** Groups of premises.
              The conclusion should be provable
              via QF_UF reasoning from the conjunction of all premises. *)
    }
  | T_rule of {
      rule: string;
      args: ('term, 'ty) Arg.t list;
    }  (** A leaf rule, e.g. an axiom or a particular theory rule. *)
[@@deriving eq, show { with_path = false }, twine, typereg, map, iter]
