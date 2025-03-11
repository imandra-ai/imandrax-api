(** A deep sequent, ie a constructive sequent of sequents. *)

open Common_

(** A deep sequent, ie a constructive sequent of sequents. *)
type t = {
  hyps: Imandrax_api_mir.Sequent.t list;  (** List of hypothese *)
  concl: Imandrax_api_mir.Sequent.t;  (** Conclusion *)
}
[@@deriving eq, twine, typereg, show { with_path = false }]
(** A deep sequent: constructive sequent of sequents *)
