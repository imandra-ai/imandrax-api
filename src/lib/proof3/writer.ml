(** Proof writer *)

open Common_pr_

(** A proof writer. This is used to stream proof steps during proof search, to
    some storage where the proof can be accessed (and pruned) later. *)
class type t = object
  method descr : string
  method write_step : Types.proof_step -> Types.proof_step offset_for

  method write_deep_step :
    Types.deep_proof_step -> Types.deep_proof_step offset_for

  method write_tree : Types.deep_proof_tree -> Types.deep_proof_tree offset_for

  method write_entrypoint : Entrypoint.t -> unit
  (** To close a proof blob, provide the entrypoint *)
end

class twine (out : #Iostream.Out_buf.t) : t =
  object
    method descr = "<twine writer>"
  end
