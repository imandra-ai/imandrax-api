open Common_

type t = {
  hyps: Imandrax_api_mir.Sequent.t list;
  concl: Imandrax_api_mir.Sequent.t;
}
[@@deriving eq, twine, typereg, show { with_path = false }]
(** A deep sequent: constructive sequent of sequents *)
