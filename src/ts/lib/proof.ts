/**
 * Proof terms
 *
 * A proof term concludes a sequent from its premises: by assumption, by substitution into an
 * earlier step, by deduction, or by a leaf rule such as an axiom.
 *
 * @module
 */

export type {
  TermArgument,
  TypeArgument,
  IntArgument,
  StringArgument,
  ListArgument,
  DictArgument,
  SequentArgument,
  ProofArgument,
  ProofTermBase,
  AssumeProof,
  SubstProof,
  DeductionProof,
  RuleProof,
  ProofTerm,
} from "./internal/proof.js";
