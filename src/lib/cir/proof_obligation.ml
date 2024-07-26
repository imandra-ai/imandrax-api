type t = {
  descr: string;  (** description *)
  goal: Term.t;  (** Initial goal *)
  tactic: Tactic.t;
      (** Tactic term. It will be evaluated while trying to solve this obligation *)
  is_instance: bool;
      (** If true, we're trying to find an instance of the goal, not a proof.
          This means we won't negate the goal. *)
  anchor: Imandrax_api.Anchor.t;
      (** An identifier linking this PO to some user-defined object *)
  timeout: int option;  (** Timeout *)
}
[@@deriving show { with_path = false }, twine, typereg]
(** Proof obligation.

  A proof obligation ("PO") is the pair of a {b statement} (a formula to prove)
  and a {b tactic} (a potential mean to prove it).

  Proof obligations are generated in several places:
  - for each defined recursive function, there's a termination PO for each of its recursive call;
  - for each theorem, there's a PO for proving its validity.
 *)
