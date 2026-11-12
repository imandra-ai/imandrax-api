/**
 * Constructors for the decomposition request of `Client.decomposeFull`
 *
 * A request is a tree: start from a function or an earlier decomposition, then merge
 * decompositions, prune or combine their regions, and bind intermediate results to names to
 * reuse them.
 *
 * @example
 * ```ts
 * import { decomp } from "imandrax-api";
 *
 * const d = decomp.let_(
 *   [["base", decomp.byName("f", { prune: true })]],
 *   decomp.merge(decomp.get("base"), decomp.byName("g")),
 * );
 * const res = await client.decomposeFull(d);
 * ```
 */

import { liftBoolToPb } from "./lift_bool.js";
import * as artmsgPb from "./raw/proto/artmsg.js";
import * as simplePb from "./raw/proto/simple_api.js";
import { Artifact } from "./responses.js";
import { DecompositionTaskResult, type LiftBool } from "./tasks.js";

/** A decomposition request, the protobuf message `decomposeFull` sends */
export type Decomp = simplePb.DecomposeReqFull_Decomp;

export interface ByNameOptions {
  /** The side condition function the decomposition assumes */
  assuming?: string;
  /** Functions not to unfold during decomposition */
  basis?: string[];
  /** Rule specs to use during decomposition */
  ruleSpecs?: string[];
  /** Whether to prune infeasible regions */
  prune?: boolean;
  /** Whether to simplify regions in their context */
  ctxSimp?: boolean;
  /** How Boolean subterms are lifted into region constraints */
  liftBool?: LiftBool;
}

/** Decompose the function `name` */
export function byName(name: string, options: ByNameOptions = {}): Decomp {
  return simplePb.DecomposeReqFull_Decomp.fromPartial({
    byName: {
      name,
      assuming: options.assuming,
      basis: options.basis ?? [],
      ruleSpecs: options.ruleSpecs ?? [],
      prune: options.prune,
      ctxSimp: options.ctxSimp,
      liftBool: liftBoolToPb(options.liftBool),
    },
  });
}

/**
 * Resume from a decomposition previously returned as an artifact, e.g.
 * `DecompositionResult.artifact` or a `DecompositionTaskResult`
 */
export function fromArtifact(art: artmsgPb.Artifact | Artifact | DecompositionTaskResult): Decomp {
  const raw =
    art instanceof Artifact ? art.raw : art instanceof DecompositionTaskResult ? art.artifact.raw : art;
  return simplePb.DecomposeReqFull_Decomp.fromPartial({ fromArtifact: raw });
}

/** Merge two decompositions */
export function merge(d1: Decomp, d2: Decomp): Decomp {
  return simplePb.DecomposeReqFull_Decomp.fromPartial({ merge: { d1, d2 } });
}

/** Compound-merge two decompositions */
export function compoundMerge(d1: Decomp, d2: Decomp): Decomp {
  return simplePb.DecomposeReqFull_Decomp.fromPartial({ compoundMerge: { d1, d2 } });
}

/** Prune the regions of `d` */
export function prune(d: Decomp): Decomp {
  return simplePb.DecomposeReqFull_Decomp.fromPartial({ prune: { d } });
}

/** Combine the regions of `d` */
export function combine(d: Decomp): Decomp {
  return simplePb.DecomposeReqFull_Decomp.fromPartial({ combine: { d } });
}

/** Read back the decomposition bound to the local variable `name` */
export function get(name: string): Decomp {
  return simplePb.DecomposeReqFull_Decomp.fromPartial({ get: { name } });
}

/**
 * Bind each `[name, decomp]` pair, then evaluate `andThen` (Python's `let`, a reserved word in
 * JS)
 *
 * The bindings are evaluated simultaneously in the same environment, so one binding cannot
 * refer to another from the same `let_`; nest `let_` calls for that.
 */
export function let_(bindings: [string, Decomp][], andThen: Decomp): Decomp {
  return simplePb.DecomposeReqFull_Decomp.fromPartial({
    set: { bindings: bindings.map(([name, d]) => ({ name, d })), andThen },
  });
}
