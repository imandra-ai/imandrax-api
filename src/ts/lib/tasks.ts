/** Tasks run by the server, their data and their results */

import { NoClientError, UnexpectedResponseError } from "./errors.js";
import {
  DB,
  Decomposition,
  Model,
  Sequent,
  type Tactic,
  type Term,
  Uid,
  Variable,
  type VerifyKind,
  tacticOfLib,
  termOfLib,
  uidSet,
  uptoOfLib,
  verifyKindOfLib,
} from "./mir.js";
import { type ProofTerm, proofTermOfLib } from "./proof.js";
import * as taskPb from "./raw/proto/task.js";
import * as lib from "./raw/types.js";
import { Report } from "./report.js";
import { Artifact, ErrorCore, Statistics } from "./responses.js";
import type { CallOptions } from "./transport.js";
import { type Value, valueOfLib } from "./values.js";

/** What tasks fetch their artifacts with: the `Client` */
export interface ArtifactSource {
  getArtifact(task: Task, kind: string, options?: CallOptions): Promise<Artifact>;
}

/** A task identifier */
export class TaskID {
  private constructor(
    readonly id: string,
    readonly raw: taskPb.TaskID,
  ) {}

  static ofRaw(x: taskPb.TaskID): TaskID {
    return new TaskID(x.id, x);
  }

  equals(other: TaskID): boolean {
    return this.id === other.id;
  }

  toString(): string {
    return this.id;
  }
}

/**
 * A task run by the server, e.g. a proof obligation, evaluation or decomposition
 *
 * The task's artifacts (its data, its result, ...) are fetched from the server on first use,
 * with the client the task came from: `await task.result()`. Each artifact is fetched once:
 * concurrent first calls share one request, and a failed request is not cached, so the next
 * call retries. A task created without a client fetches nothing; its methods then reject with
 * `NoClientError`.
 *
 * `task.setClient(client)` sets the client to fetch with, e.g. after the original one is closed.
 *
 * Task ids are content-addressed, so tasks with equal ids describe the same work, even when they
 * come from different clients; compare them with `task.id.equals(other.id)`.
 */
export class Task {
  /** The artifact kind of the task's data, `undefined` if it is not known for the task's kind */
  protected static readonly artifactKind: string | undefined = undefined;
  /** The artifact kind of the task's result, `undefined` if it is not known for the task's kind */
  protected static readonly resultArtifactKind: string | undefined = undefined;

  #client: ArtifactSource | undefined;
  readonly #artifacts = new Map<string, Promise<Artifact>>();
  #result: Promise<TaskResult> | undefined;

  constructor(
    readonly raw: taskPb.Task,
    client?: ArtifactSource,
  ) {
    // A plain `Task` is only for task kinds without a subclass, whose artifact kinds are not
    // known; other kinds need their subclass, which `taskOfRaw` picks
    if (new.target === Task && raw.kind in SUBCLASSES) {
      throw new TypeError(
        `Tasks of kind ${taskPb.taskKindToJSON(raw.kind)} need their \`Task\` subclass; use \`taskOfRaw\``,
      );
    }
    this.#client = client;
  }

  /** The task's identifier */
  get id(): TaskID {
    return TaskID.ofRaw(this.raw.id ?? { id: "" });
  }

  get kind(): "eval" | "checkPo" | "proofCheck" | "decomp" | "unspecified" {
    switch (this.raw.kind) {
      case taskPb.TaskKind.TASK_EVAL:
        return "eval";
      case taskPb.TaskKind.TASK_CHECK_PO:
        return "checkPo";
      case taskPb.TaskKind.TASK_PROOF_CHECK:
        return "proofCheck";
      case taskPb.TaskKind.TASK_DECOMP:
        return "decomp";
      default:
        return "unspecified";
    }
  }

  toString(): string {
    return `${this.constructor.name}(id=${this.id})`;
  }

  /**
   * The task's data
   *
   * @throws {UnexpectedResponseError} for a task kind without a data artifact
   */
  artifact(): Promise<Artifact> {
    const kind = (this.constructor as typeof Task).artifactKind;
    if (kind === undefined) {
      return Promise.reject(
        new UnexpectedResponseError(`No known data artifact kind for tasks of kind ${this.raw.kind}`),
      );
    }
    return this.fetchArtifact(kind);
  }

  /**
   * The task's result
   *
   * @throws {UnexpectedResponseError} for a task kind without a result artifact
   */
  result(): Promise<TaskResult> {
    const kind = (this.constructor as typeof Task).resultArtifactKind;
    if (kind === undefined) {
      return Promise.reject(
        new UnexpectedResponseError(
          `No known result artifact kind for tasks of kind ${this.raw.kind}`,
        ),
      );
    }
    if (this.#result === undefined) {
      const p = this.fetchArtifact(kind).then(taskResultOfArtifact);
      this.#result = p;
      // a failed fetch is retried by the next call
      p.catch(() => {
        if (this.#result === p) this.#result = undefined;
      });
    }
    return this.#result;
  }

  /** Fetch all of the task's artifacts (its data and its result) */
  async fetchAll(): Promise<void> {
    const cls = this.constructor as typeof Task;
    const kinds = [cls.artifactKind, cls.resultArtifactKind].filter(
      (k): k is string => k !== undefined,
    );
    await Promise.all(kinds.map((k) => this.fetchArtifact(k)));
  }

  /** Fetch the task's artifacts with `client` from now on, e.g. after the original one is closed */
  setClient(client: ArtifactSource): void {
    this.#client = client;
  }

  /** The artifact of kind `kind`, fetched on first use */
  protected fetchArtifact(kind: string): Promise<Artifact> {
    let p = this.#artifacts.get(kind);
    if (p === undefined) {
      const client = this.#client;
      if (client === undefined) {
        return Promise.reject(
          new NoClientError(
            `task ${this.id} has no client to fetch its data with; set one with \`task.setClient(client)\``,
          ),
        );
      }
      p = client.getArtifact(this, kind);
      this.#artifacts.set(kind, p);
      // a failed request is not cached, so the next call retries
      p.catch(() => {
        if (this.#artifacts.get(kind) === p) this.#artifacts.delete(kind);
      });
    }
    return p;
  }
}

/** Memoize `f`, the decoding of a task's data artifact; a failure is retried by the next call */
function memo<T>(f: () => Promise<T>): () => Promise<T> {
  let p: Promise<T> | undefined;
  return () => {
    if (p === undefined) {
      const q = f();
      p = q;
      q.catch(() => {
        if (p === q) p = undefined;
      });
    }
    return p;
  };
}

/** A proof obligation */
export class ProofObligation {
  private constructor(
    readonly description: string,
    /** The goal, `fun variables -> body` */
    readonly goal: readonly [readonly Variable[], Term],
    readonly tactic: Tactic,
    /** Whether this is an instance query rather than a proof */
    readonly isInstance: boolean,
    /** The timeout, if any */
    readonly timeout: number | undefined,
    /** The bound for bounded verification, if any */
    readonly upto: number | undefined,
    /** The kind of verification, if any */
    readonly verifyKind: VerifyKind | undefined,
    /** Named hypotheses available for the proof */
    readonly namedHypotheses: readonly (readonly [string, Term])[],
    readonly raw: lib.Mir_Proof_obligation,
  ) {}

  static ofLib(po: lib.Mir_Proof_obligation): ProofObligation {
    const [vs, t] = po.goal;
    return new ProofObligation(
      po.descr,
      [vs.map((v) => Variable.ofLib(v)), termOfLib(t)],
      tacticOfLib(po.tactic),
      po.is_instance,
      po.timeout === undefined ? undefined : Number(po.timeout),
      po.upto === undefined ? undefined : uptoOfLib(po.upto),
      po.verify_kind === undefined ? undefined : verifyKindOfLib(po.verify_kind),
      po.named_hypotheses.map(([n, h]) => [n, termOfLib(h)] as const),
      po,
    );
  }

  /** The variables bound in the goal */
  get goalVariables(): readonly Variable[] {
    return this.goal[0];
  }

  /** The goal's body, the term to prove */
  get goalBody(): Term {
    return this.goal[1];
  }
}

/** A proof obligation task, from `verify`, `instance`, theorems, ... */
export class ProofObligationTask extends Task {
  protected static override readonly artifactKind = "po_task";
  protected static override readonly resultArtifactKind = "po_res";

  constructor(raw: taskPb.Task, client?: ArtifactSource) {
    if (raw.kind !== taskPb.TaskKind.TASK_CHECK_PO) {
      throw new TypeError(`Expected a task of kind TASK_CHECK_PO, got ${taskPb.taskKindToJSON(raw.kind)}`);
    }
    super(raw, client);
  }

  readonly #poTask = memo(async () =>
    (await this.artifact()).decodeAs<lib.Tasks_PO_task_Mir>(lib.Tasks_PO_task_t_poly),
  );

  override result(): Promise<ProofObligationTaskResult> {
    return super.result() as Promise<ProofObligationTaskResult>;
  }

  readonly #proofObligation = memo(async () => ProofObligation.ofLib((await this.#poTask()).po));
  readonly #db = memo(async () => new DB((await this.#poTask()).db, (await this.artifact()).storage));

  /** The proof obligation to check */
  proofObligation(): Promise<ProofObligation> {
    return this.#proofObligation();
  }

  /** The symbol the proof obligation was generated from */
  async fromSym(): Promise<string> {
    return (await this.#poTask()).from_sym;
  }

  /** Distinguishes proof obligations generated from the same symbol */
  async count(): Promise<number> {
    return Number((await this.#poTask()).count);
  }

  /** The database of declarations and rules the proof obligation is checked in */
  db(): Promise<DB> {
    return this.#db();
  }
}

/** An evaluation task, from `eval` */
export class EvaluationTask extends Task {
  protected static override readonly artifactKind = "eval_task";
  protected static override readonly resultArtifactKind = "eval_res";

  constructor(raw: taskPb.Task, client?: ArtifactSource) {
    if (raw.kind !== taskPb.TaskKind.TASK_EVAL) {
      throw new TypeError(`Expected a task of kind TASK_EVAL, got ${taskPb.taskKindToJSON(raw.kind)}`);
    }
    super(raw, client);
  }

  readonly #evalTask = memo(async () =>
    (await this.artifact()).decodeAs<lib.Tasks_Eval_task_Mir>(lib.Tasks_Eval_task_t_poly),
  );

  override result(): Promise<EvaluationTaskResult> {
    return super.result() as Promise<EvaluationTaskResult>;
  }

  readonly #variables = memo(async () => (await this.#evalTask()).term[0].map((v) => Variable.ofLib(v)));
  readonly #term = memo(async () => termOfLib((await this.#evalTask()).term[1]));
  readonly #db = memo(async () => new DB((await this.#evalTask()).db, (await this.artifact()).storage));

  /** The variables bound in the term */
  variables(): Promise<Variable[]> {
    return this.#variables();
  }

  /** The term to evaluate */
  term(): Promise<Term> {
    return this.#term();
  }

  /** The timeout, if any */
  async timeout(): Promise<number | undefined> {
    const t = (await this.#evalTask()).timeout;
    return t === undefined ? undefined : Number(t);
  }

  /** The database of declarations and rules the term is evaluated in */
  db(): Promise<DB> {
    return this.#db();
  }
}

/**
 * How Boolean subterms are lifted into region constraints
 *
 * - `default`: the rules `x1 && x2` --> `if x1 then x2 else false`, `x1 || x2` -->
 *   `if x1 then true else x2`, `x1 ==> x2` --> `if x1 then x2 else true`
 * - `nestedEqualities`: `default`, plus `(x = y) = z` --> `if x = y then z else not z` and
 *   `z = (x = y)` --> `if z then (x = y) else not (x = y)`
 * - `equalities`: `default`, plus `x = y` --> `if x = y then true else false`
 * - `all`: `default`, plus `(t : bool)` --> `if t then true else false`
 */
export type LiftBool = "default" | "nestedEqualities" | "equalities" | "all";

export function liftBoolOfLib(x: lib.Common_Decomp_lift_bool): LiftBool {
  if (x instanceof lib.Common_Decomp_lift_bool_Default) return "default";
  if (x instanceof lib.Common_Decomp_lift_bool_Nested_equalities) return "nestedEqualities";
  if (x instanceof lib.Common_Decomp_lift_bool_Equalities) return "equalities";
  if (x instanceof lib.Common_Decomp_lift_bool_All) return "all";
  throw new UnexpectedResponseError(`Unexpected lift_bool ${x}`);
}

export type EnumerationStyle = "additive" | "multiplicative";

export function enumerationStyleOfLib(x: lib.Tasks_Decomp_task_enumeration_style): EnumerationStyle {
  if (x instanceof lib.Tasks_Decomp_task_enumeration_style_Additive) return "additive";
  if (x instanceof lib.Tasks_Decomp_task_enumeration_style_Multiplicative) return "multiplicative";
  throw new UnexpectedResponseError(`Unexpected enumeration style ${x}`);
}

/**
 * A decomposition request, as resolved by the server for a task (`DecompositionTask.decomp`)
 *
 * Requests can be combined into trees, e.g. a merge of the decompositions of two functions.
 */
export type DecompositionRequest =
  | DecompositionRequest.Function
  | DecompositionRequest.Term
  | DecompositionRequest.Return
  | DecompositionRequest.Prune
  | DecompositionRequest.Merge
  | DecompositionRequest.CompoundMerge
  | DecompositionRequest.Combine
  | DecompositionRequest.Get
  | DecompositionRequest.Let
  | DecompositionRequest.Enumerate;

export namespace DecompositionRequest {
  type Raw = lib.Tasks_Decomp_task_Mir_decomp;

  /** Decompose a function */
  export class Function {
    readonly kind = "function";
    /** The function to decompose */
    readonly function: Uid;

    constructor(
      function_: Uid,
      /** The side condition the decomposition assumes, if any */
      readonly assuming: Uid | undefined,
      /** Functions not to unfold during decomposition */
      readonly basis: ReadonlySet<Uid>,
      /** Rule specs to use during decomposition */
      readonly ruleSpecs: ReadonlySet<Uid>,
      /** Whether to simplify regions in their context */
      readonly ctxSimp: boolean,
      /** How Boolean subterms are lifted into region constraints */
      readonly liftBool: LiftBool,
      /** Whether to prune infeasible regions */
      readonly prune: boolean,
      readonly raw: Raw,
    ) {
      this.function = function_;
    }

    toString(): string {
      const assuming = this.assuming === undefined ? "" : ` ~assuming:${this.assuming}`;
      const prune = this.prune ? " ~prune:true" : "";
      return `decomp ${this.function}${assuming}${prune}`;
    }
  }

  /** Decompose a term */
  export class Term {
    readonly kind = "term";
    constructor(
      /** The term to decompose */
      readonly term: import("./mir.js").Term,
      readonly raw: Raw,
    ) {}

    toString(): string {
      return `term ${this.term}`;
    }
  }

  /** An already computed decomposition, returned as is (e.g. as a base case of a merge) */
  export class Return {
    readonly kind = "return";
    constructor(
      readonly decomposition: Decomposition,
      readonly raw: Raw,
    ) {}

    toString(): string {
      return `return <decomposition of ${this.decomposition.id}>`;
    }
  }

  /** Prune the infeasible regions of a decomposition */
  export class Prune {
    readonly kind = "prune";
    constructor(
      /** The decomposition to prune */
      readonly request: DecompositionRequest,
      readonly raw: Raw,
    ) {}

    toString(): string {
      return `prune (${this.request})`;
    }
  }

  /** Merge two decompositions */
  export class Merge {
    readonly kind = "merge";
    constructor(
      /** The first decomposition */
      readonly left: DecompositionRequest,
      /** The second decomposition */
      readonly right: DecompositionRequest,
      readonly raw: Raw,
    ) {}

    toString(): string {
      return `merge (${this.left}) (${this.right})`;
    }
  }

  /** Compound-merge two decompositions */
  export class CompoundMerge {
    readonly kind = "compoundMerge";
    constructor(
      /** The first decomposition */
      readonly left: DecompositionRequest,
      /** The second decomposition */
      readonly right: DecompositionRequest,
      readonly raw: Raw,
    ) {}

    toString(): string {
      return `compound_merge (${this.left}) (${this.right})`;
    }
  }

  /** Combine the regions of a decomposition */
  export class Combine {
    readonly kind = "combine";
    constructor(
      /** The decomposition whose regions are combined */
      readonly request: DecompositionRequest,
      readonly raw: Raw,
    ) {}

    toString(): string {
      return `combine (${this.request})`;
    }
  }

  /** A decomposition bound by name in an enclosing `Let` */
  export class Get {
    readonly kind = "get";
    constructor(
      /** The name of the binding */
      readonly name: string,
      readonly raw: Raw,
    ) {}

    toString(): string {
      return `get ${this.name}`;
    }
  }

  /** Bind decompositions to names, for use (via `Get`) in `andThen` */
  export class Let {
    readonly kind = "let";
    constructor(
      /** The names and the decompositions bound to them */
      readonly bindings: readonly (readonly [string, DecompositionRequest])[],
      /** The decomposition computed with the bindings in scope */
      readonly andThen: DecompositionRequest,
      readonly raw: Raw,
    ) {}

    toString(): string {
      const bindings = this.bindings.map(([n, d]) => `${n} = ${d}`).join(" and ");
      return `let ${bindings} in ${this.andThen}`;
    }
  }

  /** Enumerate the decomposition `dF` over the decompositions `ds` */
  export class Enumerate {
    readonly kind = "enumerate";
    constructor(
      /** The decomposition to enumerate */
      readonly dF: DecompositionRequest,
      /** The decompositions to enumerate over */
      readonly ds: readonly DecompositionRequest[],
      /** Additive or multiplicative enumeration; `undefined` means additive */
      readonly style: EnumerationStyle | undefined,
      readonly raw: Raw,
    ) {}

    toString(): string {
      return `enumerate (${this.dF}) [${this.ds.join(", ")}]`;
    }
  }
}

export function decompRequestOfLib(d: lib.Tasks_Decomp_task_Mir_decomp): DecompositionRequest {
  const R = DecompositionRequest;
  if (d instanceof lib.Tasks_Decomp_task_decomp_poly_Decomp) {
    const a = d.arg;
    return new R.Function(
      new Uid(a.f_id),
      a.assuming === undefined ? undefined : new Uid(a.assuming),
      uidSet([...a.basis].map((u) => new Uid(u))),
      uidSet([...a.rule_specs].map((u) => new Uid(u))),
      a.ctx_simp,
      liftBoolOfLib(a.lift_bool),
      a.prune,
      d,
    );
  } else if (d instanceof lib.Tasks_Decomp_task_decomp_poly_Term) {
    return new R.Term(termOfLib(d.arg as lib.Mir_Term), d);
  } else if (d instanceof lib.Tasks_Decomp_task_decomp_poly_Return) {
    return new R.Return(
      Decomposition.ofLib(d.arg as lib.Common_Fun_decomp_t_poly<lib.Mir_Term, lib.Mir_Type>),
      d,
    );
  } else if (d instanceof lib.Tasks_Decomp_task_decomp_poly_Prune) {
    return new R.Prune(decompRequestOfLib(d.arg as lib.Tasks_Decomp_task_Mir_decomp), d);
  } else if (d instanceof lib.Tasks_Decomp_task_decomp_poly_Merge) {
    const [l, r] = d.args as [lib.Tasks_Decomp_task_Mir_decomp, lib.Tasks_Decomp_task_Mir_decomp];
    return new R.Merge(decompRequestOfLib(l), decompRequestOfLib(r), d);
  } else if (d instanceof lib.Tasks_Decomp_task_decomp_poly_Compound_merge) {
    const [l, r] = d.args as [lib.Tasks_Decomp_task_Mir_decomp, lib.Tasks_Decomp_task_Mir_decomp];
    return new R.CompoundMerge(decompRequestOfLib(l), decompRequestOfLib(r), d);
  } else if (d instanceof lib.Tasks_Decomp_task_decomp_poly_Combine) {
    return new R.Combine(decompRequestOfLib(d.arg as lib.Tasks_Decomp_task_Mir_decomp), d);
  } else if (d instanceof lib.Tasks_Decomp_task_decomp_poly_Get) {
    return new R.Get(d.arg, d);
  } else if (d instanceof lib.Tasks_Decomp_task_decomp_poly_Let) {
    const bindings = d.bindings as [string, lib.Tasks_Decomp_task_Mir_decomp][];
    return new R.Let(
      bindings.map(([n, b]) => [n, decompRequestOfLib(b)] as const),
      decompRequestOfLib(d.and_then as lib.Tasks_Decomp_task_Mir_decomp),
      d,
    );
  } else if (d instanceof lib.Tasks_Decomp_task_decomp_poly_Enumerate) {
    return new R.Enumerate(
      decompRequestOfLib(d.d_f as lib.Tasks_Decomp_task_Mir_decomp),
      (d.ds as lib.Tasks_Decomp_task_Mir_decomp[]).map(decompRequestOfLib),
      d.style === undefined ? undefined : enumerationStyleOfLib(d.style),
      d,
    );
  }
  throw new UnexpectedResponseError(`Unexpected decomposition request ${d}`);
}

/** A decomposition task, from `decompose` or `[@@decomp ...]` */
export class DecompositionTask extends Task {
  protected static override readonly artifactKind = "decomp_task";
  protected static override readonly resultArtifactKind = "decomp_res";

  constructor(raw: taskPb.Task, client?: ArtifactSource) {
    if (raw.kind !== taskPb.TaskKind.TASK_DECOMP) {
      throw new TypeError(`Expected a task of kind TASK_DECOMP, got ${taskPb.taskKindToJSON(raw.kind)}`);
    }
    super(raw, client);
  }

  readonly #decompTask = memo(async () =>
    (await this.artifact()).decodeAs<lib.Tasks_Decomp_task_Mir>(lib.Tasks_Decomp_task_t_poly),
  );

  override result(): Promise<DecompositionTaskResult> {
    return super.result() as Promise<DecompositionTaskResult>;
  }

  readonly #decomp = memo(async () => decompRequestOfLib((await this.#decompTask()).decomp));
  readonly #db = memo(
    async () => new DB((await this.#decompTask()).db, (await this.artifact()).storage),
  );

  /** The decomposition request */
  decomp(): Promise<DecompositionRequest> {
    return this.#decomp();
  }

  /** The timeout, if any */
  async timeout(): Promise<number | undefined> {
    const t = (await this.#decompTask()).timeout;
    return t === undefined ? undefined : Number(t);
  }

  /** The database of declarations and rules the decomposition is computed in */
  db(): Promise<DB> {
    return this.#db();
  }
}

/**
 * A proof checking task
 *
 * It has no data or result artifact: `artifact()` and `result()` reject with
 * `UnexpectedResponseError`.
 */
export class ProofCheckTask extends Task {
  // The API defines no artifact kinds for proof checking

  constructor(raw: taskPb.Task, client?: ArtifactSource) {
    if (raw.kind !== taskPb.TaskKind.TASK_PROOF_CHECK) {
      throw new TypeError(
        `Expected a task of kind TASK_PROOF_CHECK, got ${taskPb.taskKindToJSON(raw.kind)}`,
      );
    }
    super(raw, client);
  }
}

const SUBCLASSES: Partial<Record<taskPb.TaskKind, new (raw: taskPb.Task, client?: ArtifactSource) => Task>> = {
  [taskPb.TaskKind.TASK_CHECK_PO]: ProofObligationTask,
  [taskPb.TaskKind.TASK_EVAL]: EvaluationTask,
  [taskPb.TaskKind.TASK_DECOMP]: DecompositionTask,
  [taskPb.TaskKind.TASK_PROOF_CHECK]: ProofCheckTask,
};

/** Wrap a task in the matching `Task` subclass */
export function taskOfRaw(t: taskPb.Task, client?: ArtifactSource): Task {
  const cls = SUBCLASSES[t.kind];
  return cls === undefined ? new Task(t, client) : new cls(t, client);
}

/** Wrap a task that the response says is of the `Task` subclass `cls` */
export function taskOfRawAs<T extends Task>(
  t: taskPb.Task,
  cls: abstract new (...args: any[]) => T,
  client?: ArtifactSource,
): T {
  const task = taskOfRaw(t, client);
  if (!(task instanceof cls)) {
    throw new UnexpectedResponseError(
      `Expected a ${cls.name}, got a task of kind ${taskPb.taskKindToJSON(t.kind)}`,
    );
  }
  return task;
}

// Task results
// ============

/** The goal was proved */
export interface ProofFound {
  readonly kind: "proofFound";
  readonly proof: ProofTerm;
  readonly raw: lib.Tasks_PO_res_proof_found<lib.Mir_Term, lib.Mir_Type>;
}

/** The goal was verified up to a bound, which is not a proof */
export interface VerifiedUpto {
  readonly kind: "verifiedUpto";
  /** The number of steps the goal was verified up to */
  readonly upto: number;
  readonly raw: lib.Tasks_PO_res_verified_upto;
}

/** Success case for instance */
export interface Instance {
  readonly kind: "instance";
  readonly model: Model;
  readonly raw: lib.Tasks_PO_res_instance<lib.Mir_Term, lib.Mir_Type>;
}

/** Test didn't find a counter-example */
export interface TestOk {
  readonly kind: "testOk";
  readonly raw: lib.Tasks_PO_res_success_Test_ok<lib.Mir_Term, lib.Mir_Type>;
}

export type ProofObligationSuccess = ProofFound | Instance | VerifiedUpto | TestOk;

/** Error case for verify (the proof obligation failed) */
export interface NoProof {
  readonly kind: "noProof";
  readonly error: ErrorCore;
  readonly counterModel: Model | undefined;
  readonly subgoals: readonly Sequent[];
  readonly raw: lib.Tasks_PO_res_no_proof<lib.Mir_Term, lib.Mir_Type>;
}

/** Error case for instance */
export interface Unsat {
  readonly kind: "unsat";
  readonly error: ErrorCore;
  /** Proof term for unsat */
  readonly proof: ProofTerm;
  readonly raw: lib.Tasks_PO_res_unsat<lib.Mir_Term, lib.Mir_Type>;
}

/** Model validation failure */
export interface InvalidModel {
  readonly kind: "invalidModel";
  readonly error: ErrorCore;
  readonly model: Model;
  readonly raw: lib.Tasks_PO_res_error_Invalid_model<lib.Mir_Term, lib.Mir_Type>;
}

export interface ProofObligationError {
  readonly kind: "error";
  readonly error: ErrorCore;
  readonly raw: lib.Tasks_PO_res_error_Error<lib.Mir_Term, lib.Mir_Type>;
}

export type ProofObligationFailure = NoProof | Unsat | InvalidModel | ProofObligationError;

type MirModel = lib.Common_Model_t_poly<lib.Mir_Term, lib.Mir_Type>;
type MirProofTerm = lib.Proof_Proof_term_t_poly<lib.Mir_Term, lib.Mir_Type>;

export function proofObligationResultOfLib(
  x: lib.Tasks_PO_res_result<
    lib.Tasks_PO_res_success<lib.Mir_Term, lib.Mir_Type>,
    lib.Mir_Term,
    lib.Mir_Type
  >,
): ProofObligationSuccess | ProofObligationFailure {
  if (x instanceof lib.Tasks_PO_res_success_Proof) {
    const r = x.arg as lib.Tasks_PO_res_proof_found<lib.Mir_Term, lib.Mir_Type>;
    return { kind: "proofFound", proof: proofTermOfLib(r.proof as MirProofTerm), raw: r };
  } else if (x instanceof lib.Tasks_PO_res_success_Instance) {
    const r = x.arg as lib.Tasks_PO_res_instance<lib.Mir_Term, lib.Mir_Type>;
    return { kind: "instance", model: Model.ofLib(r.model as MirModel), raw: r };
  } else if (x instanceof lib.Tasks_PO_res_success_Verified_upto) {
    return { kind: "verifiedUpto", upto: uptoOfLib(x.arg.upto), raw: x.arg };
  } else if (x instanceof lib.Tasks_PO_res_success_Test_ok) {
    return { kind: "testOk", raw: x };
  } else if (x instanceof lib.Tasks_PO_res_error_No_proof) {
    const r = x.arg as lib.Tasks_PO_res_no_proof<lib.Mir_Term, lib.Mir_Type>;
    return {
      kind: "noProof",
      error: ErrorCore.ofLib(r.err),
      counterModel: r.counter_model === undefined ? undefined : Model.ofLib(r.counter_model as MirModel),
      subgoals: r.subgoals.map((sg) => Sequent.ofLib(sg)),
      raw: r,
    };
  } else if (x instanceof lib.Tasks_PO_res_error_Unsat) {
    const r = x.arg as lib.Tasks_PO_res_unsat<lib.Mir_Term, lib.Mir_Type>;
    return {
      kind: "unsat",
      error: ErrorCore.ofLib(r.err),
      proof: proofTermOfLib(r.proof as MirProofTerm),
      raw: r,
    };
  } else if (x instanceof lib.Tasks_PO_res_error_Invalid_model) {
    const [e, m] = x.args;
    return {
      kind: "invalidModel",
      error: ErrorCore.ofLib(e),
      model: Model.ofLib(m as MirModel),
      raw: x as lib.Tasks_PO_res_error_Invalid_model<lib.Mir_Term, lib.Mir_Type>,
    };
  } else if (x instanceof lib.Tasks_PO_res_error_Error) {
    return {
      kind: "error",
      error: ErrorCore.ofLib(x.arg),
      raw: x as lib.Tasks_PO_res_error_Error<lib.Mir_Term, lib.Mir_Type>,
    };
  }
  throw new UnexpectedResponseError(`Unexpected proof obligation result ${x}`);
}

/** Get `f()` once, then the same value */
function lazy<T>(f: () => T): () => T {
  let done = false;
  let v: T;
  return () => {
    if (!done) {
      v = f();
      done = true;
    }
    return v;
  };
}

/** The result of a proof obligation task */
export class ProofObligationTaskResult {
  readonly #data: lib.Tasks_PO_res_Shallow;
  readonly #result = lazy(() => proofObligationResultOfLib(this.#data.res));
  readonly #statistics = lazy(() => Statistics.ofLib(this.#data.stats));
  readonly #subresults = lazy(() =>
    this.#data.sub_res.map((sl) => sl.map((s) => ProofObligationTaskResult.Subresult.ofLib(s))),
  );
  #report: Promise<Report> | undefined;

  constructor(readonly artifact: Artifact) {
    if (artifact.kind !== "po_res") {
      throw new TypeError(`Expected an artifact of kind 'po_res', got '${artifact.kind}'`);
    }
    this.#data = artifact.decodeAs<lib.Tasks_PO_res_Shallow>(lib.Tasks_PO_res_shallow_poly);
  }

  /** The content-addressed storage key of the proof obligation this is the result for */
  get from(): string {
    return this.#data.from_.key;
  }

  get result(): ProofObligationSuccess | ProofObligationFailure {
    return this.#result();
  }

  /**
   * Whether the goal was proved
   *
   * Verifying up to a bound (`verifiedUpto`) or testing without finding a counter-example
   * (`testOk`) is not a proof.
   */
  get proved(): boolean {
    return this.result.kind === "proofFound";
  }

  /** Whether an instance was found, for instance queries */
  get found(): boolean {
    return this.result.kind === "instance";
  }

  /** The error, if the proof obligation failed */
  get error(): ErrorCore | undefined {
    const r = this.result;
    switch (r.kind) {
      case "noProof":
      case "unsat":
      case "invalidModel":
      case "error":
        return r.error;
      default:
        return undefined;
    }
  }

  /**
   * The counter-model if the proof failed, or the instance found, if any
   *
   * A model that failed validation (`invalidModel`) is not included; it is in `result`.
   */
  get model(): Model | undefined {
    const r = this.result;
    switch (r.kind) {
      case "noProof":
        return r.counterModel;
      case "instance":
        return r.model;
      default:
        return undefined;
    }
  }

  /** The remaining subgoals, if no proof was found */
  get subgoals(): Sequent[] | undefined {
    const r = this.result;
    return r.kind === "noProof" ? [...r.subgoals] : undefined;
  }

  /** The proof term, if any: of the goal, or for instance queries, of the goal having no instance */
  get proof(): ProofTerm | undefined {
    const r = this.result;
    return r.kind === "proofFound" || r.kind === "unsat" ? r.proof : undefined;
  }

  /** Statistics about the proof attempt */
  get statistics(): Statistics {
    return this.#statistics();
  }

  /** The report of the proof attempt */
  report(): Promise<Report> {
    this.#report ??= Report.ofArchive(this.#data.report);
    return this.#report;
  }

  /** The results for the individual subgoals */
  get subresults(): ProofObligationTaskResult.Subresult[][] {
    return this.#subresults();
  }

  toString(): string {
    return `proof: ${this.proof}\nsubgoals: ${this.subgoals}\nmodel: ${this.model}`;
  }
}

export namespace ProofObligationTaskResult {
  /** The result for one subgoal of a proof obligation */
  export class Subresult {
    private constructor(
      /** The subgoal */
      readonly goal: Sequent,
      /** The subgoals the goal was split into */
      readonly subGoals: readonly Sequent[],
      /** `undefined` if the subgoal was handled successfully, otherwise the error message */
      readonly res: string | undefined,
      readonly raw: lib.Tasks_PO_res_sub_res<lib.Mir_Term>,
    ) {}

    static ofLib(sr: lib.Tasks_PO_res_sub_res<lib.Mir_Term>): Subresult {
      return new Subresult(
        Sequent.ofLib(sr.goal),
        sr.sub_goals.map((sg) => Sequent.ofLib(sg)),
        sr.res ?? undefined,
        sr,
      );
    }
  }
}

/** Evaluation statistics for the whole task */
export class EvaluationStatistics {
  private constructor(
    /** Compilation time, in seconds */
    readonly compileTime: number,
    /** Execution time, in seconds */
    readonly execTime: number,
    readonly raw: lib.Tasks_Eval_res_stats,
  ) {}

  static ofLib(x: lib.Tasks_Eval_res_stats): EvaluationStatistics {
    return new EvaluationStatistics(x.compile_time, x.exec_time, x);
  }
}

/** The result of an evaluation task */
export class EvaluationTaskResult {
  readonly #data: lib.Tasks_Eval_res;
  readonly #value = lazy(() =>
    this.#data.res instanceof lib.Tasks_Eval_res_success ? valueOfLib(this.#data.res.v.v) : undefined,
  );
  readonly #error = lazy(() =>
    this.#data.res instanceof lib.Error_Error_core ? ErrorCore.ofLib(this.#data.res) : undefined,
  );

  constructor(readonly artifact: Artifact) {
    if (artifact.kind !== "eval_res") {
      throw new TypeError(`Expected an artifact of kind 'eval_res', got '${artifact.kind}'`);
    }
    this.#data = artifact.decodeAs(lib.Tasks_Eval_res);
  }

  /** Whether the evaluation succeeded */
  get success(): boolean {
    return this.#data.res instanceof lib.Tasks_Eval_res_success;
  }

  /** The value the term evaluated to, if the evaluation succeeded */
  get value(): Value | undefined {
    return this.#value();
  }

  /** The error, if the evaluation failed */
  get error(): ErrorCore | undefined {
    return this.#error();
  }

  /** Statistics about the evaluation */
  get statistics(): EvaluationStatistics {
    return EvaluationStatistics.ofLib(this.#data.stats);
  }

  toString(): string {
    return this.success ? String(this.value) : `Evaluation error: ${this.error}`;
  }
}

/** The result of a decomposition task */
export class DecompositionTaskResult {
  readonly #data: lib.Tasks_Decomp_res_Shallow;
  readonly #statistics = lazy(() => Statistics.ofLib(this.#data.stats));
  readonly #decomposition = lazy(() =>
    this.#data.res instanceof lib.Tasks_Decomp_res_success
      ? Decomposition.ofLib(this.#data.res.decomp as lib.Common_Fun_decomp_t_poly<lib.Mir_Term, lib.Mir_Type>)
      : undefined,
  );
  readonly #error = lazy(() =>
    this.#data.res instanceof lib.Tasks_Decomp_res_error_Error
      ? ErrorCore.ofLib(this.#data.res.arg)
      : undefined,
  );
  #report: Promise<Report> | undefined;

  constructor(readonly artifact: Artifact) {
    if (artifact.kind !== "decomp_res") {
      throw new TypeError(`Expected an artifact of kind 'decomp_res', got '${artifact.kind}'`);
    }
    this.#data = artifact.decodeAs<lib.Tasks_Decomp_res_Shallow>(lib.Tasks_Decomp_res_shallow_poly);
  }

  /** The content-addressed storage key of the decomposition request this is the result for */
  get from(): string {
    return this.#data.from_.key;
  }

  /** Statistics about the decomposition */
  get statistics(): Statistics {
    return this.#statistics();
  }

  /** The report of the decomposition */
  report(): Promise<Report> {
    this.#report ??= Report.ofArchive(this.#data.report);
    return this.#report;
  }

  /** Whether the decomposition succeeded */
  get success(): boolean {
    return this.#data.res instanceof lib.Tasks_Decomp_res_success;
  }

  /** The decomposition, if it succeeded */
  get decomposition(): Decomposition | undefined {
    return this.#decomposition();
  }

  /** The error, if the decomposition failed */
  get error(): ErrorCore | undefined {
    return this.#error();
  }

  toString(): string {
    return this.decomposition ? `${this.decomposition}` : `Decomposition error: ${this.error}`;
  }
}

export type TaskResult = ProofObligationTaskResult | EvaluationTaskResult | DecompositionTaskResult;

export function taskResultOfArtifact(artifact: Artifact): TaskResult {
  switch (artifact.kind) {
    case "po_res":
      return new ProofObligationTaskResult(artifact);
    case "eval_res":
      return new EvaluationTaskResult(artifact);
    case "decomp_res":
      return new DecompositionTaskResult(artifact);
    default:
      throw new UnexpectedResponseError(`Unexpected result artifact kind '${artifact.kind}'`);
  }
}
