/**
 * Proof terms
 *
 * A proof term concludes a sequent from its premises: by assumption, by substitution into an
 * earlier step, by deduction, or by a leaf rule such as an axiom.
 *
 * @module
 */

// Note:
// Proof terms form a DAG: a sub-proof can be the premise of several steps, and the OCaml side
// keeps it shared. `proofTermOfLib` converts each occurrence separately, so a shared
// sub-proof is converted, and held in memory, once per occurrence.

import { UnexpectedResponseError } from "./errors.js";
import { Sequent, type Term, type Type, Uid, Variable, termOfLib, typeOfLib } from "./mir.js";
import * as lib from "./raw/types.js";

type RawArg = lib.Proof_Arg<lib.Mir_Term, lib.Mir_Type>;
type RawProofTerm = lib.Proof_Proof_term_t_poly<lib.Mir_Term, lib.Mir_Type>;

export class TermArgument {
  readonly kind = "term";
  constructor(
    readonly term: Term,
    readonly raw: RawArg,
  ) {}
}

export class TypeArgument {
  readonly kind = "type";
  constructor(
    readonly type: Type,
    readonly raw: RawArg,
  ) {}
}

export class IntArgument {
  readonly kind = "int";
  constructor(
    readonly value: bigint,
    readonly raw: RawArg,
  ) {}
}

export class StringArgument {
  readonly kind = "string";
  constructor(
    readonly value: string,
    readonly raw: RawArg,
  ) {}
}

export class ListArgument {
  readonly kind = "list";
  constructor(
    readonly elements: readonly ProofArgument[],
    readonly raw: RawArg,
  ) {}
}

export class DictArgument {
  readonly kind = "dict";
  constructor(
    readonly entries: readonly (readonly [string, ProofArgument])[],
    readonly raw: RawArg,
  ) {}
}

export class SequentArgument {
  readonly kind = "sequent";
  constructor(
    readonly sequent: Sequent,
    readonly raw: RawArg,
  ) {}
}

export type ProofArgument =
  | TermArgument
  | TypeArgument
  | IntArgument
  | StringArgument
  | ListArgument
  | DictArgument
  | SequentArgument;

export function proofArgumentOfLib(x: RawArg): ProofArgument {
  if (x instanceof lib.Proof_Arg_A_term) return new TermArgument(termOfLib(x.arg), x);
  if (x instanceof lib.Proof_Arg_A_ty) return new TypeArgument(typeOfLib(x.arg), x);
  if (x instanceof lib.Proof_Arg_A_int) return new IntArgument(x.arg, x);
  if (x instanceof lib.Proof_Arg_A_string) return new StringArgument(x.arg, x);
  if (x instanceof lib.Proof_Arg_A_list) return new ListArgument(x.arg.map(proofArgumentOfLib), x);
  if (x instanceof lib.Proof_Arg_A_dict) {
    return new DictArgument(
      x.arg.map(([k, v]) => [k, proofArgumentOfLib(v)] as const),
      x,
    );
  }
  if (x instanceof lib.Proof_Arg_A_seq) return new SequentArgument(Sequent.ofLib(x.arg), x);
  throw new UnexpectedResponseError(`unexpected proof argument: ${(x as object).constructor.name}`);
}

/** A proof term */
export abstract class ProofTermBase {
  abstract readonly kind: ProofTerm["kind"];

  constructor(
    /** unique generative id */
    readonly id: number,
    readonly conclusion: Sequent,
    readonly raw: RawProofTerm,
  ) {}
}

/**
 * The rest of the proof is elsewhere. This can be replaced with the actual proof of this proof's
 * goal.
 */
export class AssumeProof extends ProofTermBase {
  readonly kind = "assume";
}

/** Instantiation of a previous step */
export class SubstProof extends ProofTermBase {
  readonly kind = "subst";
  constructor(
    readonly termSubstitution: readonly (readonly [Variable, Term])[],
    readonly typeSubstitution: readonly (readonly [Uid, Type])[],
    readonly premise: ProofTerm,
    id: number,
    conclusion: Sequent,
    raw: RawProofTerm,
  ) {
    super(id, conclusion, raw);
  }
}

export class DeductionProof extends ProofTermBase {
  readonly kind = "deduction";
  constructor(
    /**
     * Groups of premises. The conclusion should be provable via QF_UF reasoning from the conjunction
     * of all premises.
     */
    readonly premises: readonly (readonly [string, readonly ProofTerm[]])[],
    id: number,
    conclusion: Sequent,
    raw: RawProofTerm,
  ) {
    super(id, conclusion, raw);
  }
}

/** A leaf rule, e.g. an axiom or a particular theory rule. */
export class RuleProof extends ProofTermBase {
  readonly kind = "rule";
  readonly rule: string;
  readonly arguments: readonly ProofArgument[];

  constructor(
    rule: string,
    args: readonly ProofArgument[],
    id: number,
    conclusion: Sequent,
    raw: RawProofTerm,
  ) {
    super(id, conclusion, raw);
    this.rule = rule;
    this.arguments = args;
  }
}

/** A proof term */
export type ProofTerm = AssumeProof | SubstProof | DeductionProof | RuleProof;

export function proofTermOfLib(x: RawProofTerm): ProofTerm {
  const concl = Sequent.ofLib(x.concl);
  const id = Number(x.id);
  const v = x.view;
  if (v instanceof lib.Proof_View_T_assume) return new AssumeProof(id, concl, x);
  if (v instanceof lib.Proof_View_T_subst) {
    return new SubstProof(
      v.t_subst.map(
        ([[u, ty], t]) =>
          [Variable.ofLib(new lib.Common_Var_t_poly(u, ty)), termOfLib(t)] as const,
      ),
      v.ty_subst.map(([u, ty]) => [new Uid(u), typeOfLib(ty)] as const),
      proofTermOfLib(v.premise),
      id,
      concl,
      x,
    );
  }
  if (v instanceof lib.Proof_View_T_deduction) {
    return new DeductionProof(
      v.premises.map(([n, group]) => [n, group.map(proofTermOfLib)] as const),
      id,
      concl,
      x,
    );
  }
  if (v instanceof lib.Proof_View_T_rule) {
    return new RuleProof(v.rule, v.args.map(proofArgumentOfLib), id, concl, x);
  }
  throw new UnexpectedResponseError(`unexpected proof term: ${(v as object).constructor.name}`);
}
