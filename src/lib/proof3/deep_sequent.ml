(** A deep sequent, ie a constructive sequent of sequents. *)

open Common_

(** A deep sequent, ie a constructive sequent of sequents.

    Its individual elements, of type {!Sequent.t}, can be considered as the
    universal closure of their formula form. In other words, a deep sequent's
    logical meaning is [( /\_i forall hyps[i] ) ==> (forall concl)].

    Each sequent is universally closed and thus doesn't share any free variable
    with the other sequents. *)
type t = {
  hyps: Imandrax_api_mir.Sequent.t list;  (** List of hypotheses *)
  concl: Imandrax_api_mir.Sequent.t;  (** Conclusion *)
}
[@@deriving eq, twine, typereg, show { with_path = false }]
(** A deep sequent: constructive sequent of sequents *)
