(** Result of evaluating the PO *)

type stats = Imandrax_api.Stat_time.t [@@deriving show, twine, typereg]

type proof_found = {
  anchor: Imandrax_api.Anchor.t;
  proof: Imandrax_api_proof.meta_proof_step;  (** Proof term. *)
}
[@@deriving twine, typereg, show { with_path = false }]
(** Type returned on success for verify *)

type instance = {
  anchor: Imandrax_api.Anchor.t;
  model: Imandrax_api_cir.Model.t;
}
[@@deriving twine, typereg, show { with_path = false }]
(** Success case for instance *)

type no_proof = {
  err: Imandrakit_error.Error_core.t;
  counter_model: Imandrax_api_cir.Model.t option;
  subgoals: Imandrax_api_cir.Sequent.t list;
}
[@@deriving twine, typereg, show { with_path = false }]
(** Error case for verify (the PO failed) *)

type unsat = {
  anchor: Imandrax_api.Anchor.t;
  err: Imandrakit_error.Error_core.t;
  proof: Imandrax_api_proof.mproof_step;  (** Proof term for unsat. *)
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
  | Invalid_model of Imandrakit_error.Error_core.t * Imandrax_api_cir.Model.t
      (** Model validation failure *)
  | Error of Imandrakit_error.Error_core.t
[@@deriving twine, typereg, show { with_path = false }]

type 'a result = ('a, error) Util_twine.Result.t
[@@deriving twine, typereg, show]

type t = {
  from:
    (Imandrax_api_cir.Proof_obligation.t Imandrax_api_ca_store.Ca_ptr.t
    [@printer Imandrax_api_ca_store.Ca_ptr.pp]);
  res: success result;
  stats: stats;
  report:
    (Imandrax_api_report.Report.t Imandrax_api.In_mem_archive.t
    [@twine.encode In_mem_archive.to_twine]
    [@twine.decode In_mem_archive.of_twine]
    [@printer In_mem_archive.pp ()]);
      (** The report, when it's not serialized it's stored compressed in memory. *)
}
[@@deriving twine, typereg, show { with_path = false }]
