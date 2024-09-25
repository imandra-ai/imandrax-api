(** Representation of proofs *)

module PSE = Imandra_proof_system_encode

(** {2 Aliases} *)

module Const_id = PSE.Const_id
module Var_id = PSE.Var_id
module FunDefID = PSE.FunDefID_id
module TypeDefID = PSE.TypeDefID_id
module Term_id = PSE.Term_id
module Type_id = PSE.Type_id
module Clause_id = PSE.Clause_id
module Scope_id = PSE.Scope_id
module MSeq_id = PSE.MSeq_id
module ProofStep_id = PSE.ProofStep_id
module MProofStep_id = PSE.MProofStep_id
module MProofTreeNode_id = PSE.MProofTreeNode_id

type proof_step = ProofStep_id.t [@@deriving show, twine]
type mproof_step = MetaProofStep_id.t [@@deriving show, twine]

(** {2 Outputting proofs} *)

module Output = PSE.Output

type output = Output.t

(** {2 Serialized proof} *)

type proof = { data: bytes [@use_bytes] } [@@deriving typereg, twine]

let pp_proof out (self : proof) =
  Fmt.fprintf out "<proof (%a)>" Util.pp_byte_size (Bytes.length self.data)
