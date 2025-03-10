(** Proof reader *)

open Common_pr_

(** A proof reader. This is used to parse/traverse proof steps during proof
    checking or postprocessing. *)
class type t = object
  method descr : string
  method read_step : Types.proof_step offset_for -> Types.proof_step

  method read_deep_step :
    Types.deep_proof_step offset_for -> Types.deep_proof_step

  method read_tree : Types.deep_proof_tree offset_for -> Types.deep_proof_tree

  method read_entrypoint : unit -> Entrypoint.t
  (** Access the entrypoint *)
end

let[@inline] read_step (self : #t) p : Types.proof_step = self#read_step p

let[@inline] read_deep_step (self : #t) p : Types.deep_proof_step =
  self#read_deep_step p

let[@inline] read_tree (self : #t) p : Types.deep_proof_tree = self#read_tree p

let[@inline] read_entrypoint (self : #t) : Entrypoint.t =
  self#read_entrypoint ()

class dummy : t =
  object
    method descr = "<dummy>"

    method read_step (_ : Types.proof_step offset_for) : Types.proof_step =
      Error.fail ~kind:Error_kinds.proofDeserError "dummy reader"

    method read_deep_step (_ : Types.deep_proof_step offset_for) :
        Types.deep_proof_step =
      Error.fail ~kind:Error_kinds.proofDeserError "dummy reader"

    method read_tree (_ : Types.deep_proof_tree offset_for) :
        Types.deep_proof_tree =
      Error.fail ~kind:Error_kinds.proofDeserError "dummy reader"

    method read_entrypoint () : Entrypoint.t =
      Error.fail ~kind:Error_kinds.proofDeserError "dummy reader"
  end

(* TODO: eventually, a way to read from a bigstring *)
class twine ~(mt : Mir.Term.State.t) (str : string) : t =
  let dec = Imandrakit_twine.Decode.of_string str in
  let () = Mir.Term.State.add_to_dec dec mt in
  object
    method descr = "<twine reader>"

    method read_step (p : Types.proof_step offset_for) : Types.proof_step =
      Imandrakit_twine.Decode.read_ref dec Types.proof_step_of_twine p

    method read_deep_step (p : Types.deep_proof_step offset_for) =
      Imandrakit_twine.Decode.read_ref dec Types.deep_proof_step_of_twine p

    method read_tree (p : Types.deep_proof_tree offset_for) =
      Imandrakit_twine.Decode.read_ref dec Types.deep_proof_tree_of_twine p

    method read_entrypoint () : Entrypoint.t =
      let off = Imandrakit_twine.Decode.get_entrypoint dec in
      Entrypoint.of_twine dec off
  end
