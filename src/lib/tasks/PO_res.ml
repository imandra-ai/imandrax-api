(** Result of evaluating the PO *)

open Common_tasks_

type stats = Imandrax_api.Stat_time.t [@@deriving show, twine, typereg]

type ('term, 'ty) proof_found = {
  anchor: Imandrax_api.Anchor.t;
  proof: ('term, 'ty) Imandrax_api_proof.Proof_term.t_poly;  (** Proof term. *)
}
[@@deriving twine, typereg, map, iter, show { with_path = false }]
(** Type returned on success for verify *)

type ('term, 'ty) instance = {
  anchor: Imandrax_api.Anchor.t;
  model: ('term, 'ty) Imandrax_api_common.Model.t_poly;
}
[@@deriving twine, typereg, map, iter, show { with_path = false }]
(** Success case for instance *)

type ('term, 'ty) no_proof = {
  err: Imandrakit_error.Error_core.t;
  counter_model: ('term, 'ty) Imandrax_api_common.Model.t_poly option;
  subgoals: Imandrax_api_mir.Sequent.t list;
}
[@@deriving twine, typereg, map, iter, show { with_path = false }]
(** Error case for verify (the PO failed) *)

type ('term, 'ty) unsat = {
  anchor: Imandrax_api.Anchor.t;
  err: Imandrakit_error.Error_core.t;
  proof: ('term, 'ty) Imandrax_api_proof.Proof_term.t_poly;
      (** Proof term for unsat. *)
}
[@@deriving twine, typereg, map, iter, show { with_path = false }]
(** Error case for instance *)

type ('term, 'ty) success =
  | Proof of ('term, 'ty) proof_found  (** For verify *)
  | Instance of ('term, 'ty) instance  (** For instance *)
[@@deriving twine, typereg, map, iter, show { with_path = false }]

type ('term, 'ty) error =
  | No_proof of ('term, 'ty) no_proof  (** For verify *)
  | Unsat of ('term, 'ty) unsat  (** For instance *)
  | Invalid_model of
      Imandrakit_error.Error_core.t
      * ('term, 'ty) Imandrax_api_common.Model.t_poly
      (** Model validation failure *)
  | Error of Imandrakit_error.Error_core.t
[@@deriving twine, typereg, map, iter, show { with_path = false }]

type ('a, 'term, 'ty) result = ('a, ('term, 'ty) error) Util_twine.Result.t
[@@deriving twine, typereg, show, map, iter]

(** Parts are referenced via a cptr *)
module Shallow = struct
  type ('term, 'ty) t_poly = {
    from:
      (Imandrax_api_mir.Proof_obligation.t Imandrax_api_ca_store.Ca_ptr.t
      [@printer Imandrax_api_ca_store.Ca_ptr.pp]);
    res: (('term, 'ty) success, 'term, 'ty) result;
    stats: stats;
    report:
      (Imandrax_api_report.Report.Mir.t Imandrax_api.In_mem_archive.t
      [@twine.encode In_mem_archive.to_twine]
      [@twine.decode In_mem_archive.of_twine]
      [@printer In_mem_archive.pp ()]);
        (** The report, when it's not serialized it's stored compressed in memory. *)
  }
  [@@deriving twine, typereg, map, iter, show { with_path = false }]

  type t = (Mir.Term.t, Mir.Type.t) t_poly [@@deriving twine, typereg, show]
end

(** All included *)
module Full = struct
  type ('term, 'ty) t_poly = {
    from: 'term Imandrax_api_common.Proof_obligation.t_poly;
    res: (('term, 'ty) success, 'term, 'ty) result;
    stats: stats;
    report:
      (Imandrax_api_report.Report.Mir.t Imandrax_api.In_mem_archive.t
      [@twine.encode In_mem_archive.to_twine]
      [@twine.decode In_mem_archive.of_twine]
      [@printer In_mem_archive.pp ()]);
        (** The report, when it's not serialized it's stored compressed in memory. *)
  }
  [@@deriving twine, typereg, map, iter, show { with_path = false }]
  [@@typereg.name "full.t_poly"]

  type t = (Mir.Term.t, Mir.Type.t) t_poly
  [@@deriving twine, typereg] [@@typereg.name "full.t"]
end
