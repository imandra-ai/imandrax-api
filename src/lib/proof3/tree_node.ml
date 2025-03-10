(** Proof exploration tree.

    Used to represent a tactic or waterfall execution, even if it failed. *)

open Common_pr_
open Types

type t = {
  goal: Imandrax_api_mir.Sequent.t;
  children: t offset_for list;
  view: view;
}
(** A node in the proof tree, annotated with a deep sequent, used to encode the
    structure of the proof. *)

and view =
  | Success of {
      local_proof: deep_proof_step offset_for;  (** [children ||- goal] *)
      full_proof: deep_proof_step offset_for;
          (** unconditional proof of [||- goal]. This is obtained from the
              proofs of childen nodes and from [local_proof]. *)
    }
  | Failed of {
      msg: string;
      local_proof: deep_proof_step offset_for;  (** [children ||- goal] *)
    }
  | Tried of t offset_for list
  | Unexplored of { reason: string }
[@@deriving twine, show { with_path = false }, typereg]

let iter_deep_proof_tree ~yield_proofstep:_ ~yield_deepproofstep ~yield_treenode
    x =
  List.iter yield_treenode x.children;
  match x.view with
  | Success x ->
    yield_deepproofstep x.local_proof;
    yield_deepproofstep x.full_proof
  | Failed x -> yield_deepproofstep x.local_proof
  | Tried l -> List.iter yield_treenode l
  | Unexplored _ -> ()
