(** Result of evaluating the PO *)

type stats = Imandrax_api.Stat_time.t [@@deriving show, twine, typereg]

module Cir = Imandrax_api_cir
module PT = Imandrax_api_proof.Cir_proof_term

type proof_found = {
  anchor: Anchor.t;
  proof: PT.t;  (** Proof term. *)
}
[@@deriving twine, typereg, show { with_path = false }]
(** Type returned on success for verify *)

type instance = {
  anchor: Anchor.t;
  model: Cir.Model.t;
}
[@@deriving twine, typereg, show { with_path = false }]
(** Success case for instance *)

type no_proof = {
  err: Error.t;
  counter_model: Cir.Model.t option;
  subgoals: Cir.Sequent.t list;
}
[@@deriving twine, typereg, show { with_path = false }]
(** Error case for verify (the PO failed) *)

type unsat = {
  anchor: Anchor.t;
  err: Error.t;
  proof: PT.t;  (** Proof term for unsat. *)
}
[@@deriving twine, typereg, show { with_path = false }]
(** Error case for instance *)

type success =
  | Proof of proof_found  (** For verify *)
  | Instance of instance  (** For instance *)
[@@deriving twine, typereg, show { with_path = false }]

type error =
  | No_proof of no_proof  (** For verify *)
  | Unsat of unsat  (** For instance *)
  | Invalid_model of Error.t * Cir.Model.t  (** Model validation failure *)
  | Error of Error.t
[@@deriving twine, typereg, show { with_path = false }]

type 'a result = ('a, error) Util_twine.Result.t
[@@deriving twine, typereg, show]

type t = {
  from: Proof_obligation.t Cstore_ptr.t;
  res: success result;
  stats: stats;
  report:
    (Imandrax_api_report.Report.t In_mem_archive.t
    [@twine.encode In_mem_archive.to_twine]
    [@twine.decode In_mem_archive.of_twine]
    [@printer In_mem_archive.pp]);
      (** The report, when it's not serialized it's stored compressed in memory. *)
}
[@@deriving twine, typereg]
