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

let[@inline] write_step (self : #t) p : _ offset_for = self#write_step p

let[@inline] write_deep_step (self : #t) p : Types.deep_proof_step offset_for =
  self#write_deep_step p

let[@inline] write_tree (self : #t) p : Types.deep_proof_tree offset_for =
  self#write_tree p

let[@inline] write_entrypoint (self : #t) e : unit = self#write_entrypoint e

class dummy : t =
  object
    method descr = "<dummy>"
    method write_step (_ : Types.proof_step) = Imandrakit_twine.Offset_for 0

    method write_deep_step (_ : Types.deep_proof_step) =
      Imandrakit_twine.Offset_for 0

    method write_tree (_ : Types.deep_proof_tree) =
      Imandrakit_twine.Offset_for 0

    method write_entrypoint (_ : Entrypoint.t) = ()
  end

class twine (out : #Iostream.Out.t) : t =
  let enc = Imandrakit_twine.Encode.create () in
  let wrote_entrypoint = ref false in

  let check_entrypoint_not_written () =
    if !wrote_entrypoint then invalid_arg "proof-writer was already finalized"
  in
  object
    method descr = "<twine writer>"

    method write_step (p : Types.proof_step) : _ Imandrakit_twine.offset_for =
      check_entrypoint_not_written ();
      let off =
        Imandrakit_twine.Encode.write_offset_for enc Types.proof_step_to_twine p
      in
      Imandrakit_twine.Encode.write_internal_data enc out;
      off

    method write_deep_step (p : Types.deep_proof_step) =
      check_entrypoint_not_written ();
      let off =
        Imandrakit_twine.Encode.write_offset_for enc
          Types.deep_proof_step_to_twine p
      in
      Imandrakit_twine.Encode.write_internal_data enc out;
      off

    method write_tree (p : Types.deep_proof_tree) =
      check_entrypoint_not_written ();
      let off =
        Imandrakit_twine.Encode.write_offset_for enc
          Types.deep_proof_tree_to_twine p
      in
      Imandrakit_twine.Encode.write_internal_data enc out;
      off

    method write_entrypoint (e : Entrypoint.t) =
      check_entrypoint_not_written ();
      wrote_entrypoint := true;
      let off = Entrypoint.to_twine enc e in
      let data = Imandrakit_twine.Encode.finalize_copy enc ~entrypoint:off in
      Iostream.Out.output_string out data
  end
