(** Sequent *)

type 'term t = {
  hyps: 'term list;  (** Hypotheses *)
  concls: 'term list;  (** Conclusions *)
}
[@@deriving eq, ord, twine, typereg, map, iter, show { with_path = false }]
(** A classical sequent *)
