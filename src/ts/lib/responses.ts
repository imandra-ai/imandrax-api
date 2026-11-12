/**
 * What client methods return, and the per-item results inside those responses
 *
 * There are 3 layers of "result":
 * 1. Responses: what a client method returns, wrapping the protobuf reply, named `*Response`
 * 2. Per-item results in an `EvalSrcResponse`: one per proof obligation, `eval` and
 *    `[@@decomp top ...]`, named `*Result` / `*Output`
 * 3. Task results: a task's result artifact (see `tasks.ts`), named `*TaskResult`
 *
 * Exception: `DecompositionResult` is both the `decompose` response (layer 1) and an item of
 * `EvalSrcResponse` (layer 2). It is the only client-method return type not named `*Response`.
 */

import { ServerError, UnexpectedResponseError } from "./errors.js";
import { Decomposition, Model } from "./mir.js";
import * as apiPb from "./raw/proto/api.js";
import * as artmsgPb from "./raw/proto/artmsg.js";
import * as errorPb from "./raw/proto/error.js";
import * as locsPb from "./raw/proto/locs.js";
import * as simplePb from "./raw/proto/simple_api.js";
import * as systemPb from "./raw/proto/system.js";
import * as taskPb from "./raw/proto/task.js";
import * as twine from "./raw/twine.js";
import * as lib from "./raw/types.js";
import {
  DecompositionTask,
  ProofObligationTask,
  type ArtifactSource,
  type Task,
  taskOfRaw,
  taskOfRawAs,
} from "./tasks.js";

/** A source location */
export class Location {
  private constructor(
    readonly file: string | undefined,
    /** The start, as `[line, column]` */
    readonly start: readonly [number, number],
    /** The end, as `[line, column]` */
    readonly stop: readonly [number, number],
    readonly raw: locsPb.Location,
  ) {}

  static ofRaw(x: locsPb.Location): Location {
    return new Location(
      x.file,
      [x.start?.line ?? 0, x.start?.col ?? 0],
      [x.stop?.line ?? 0, x.stop?.col ?? 0],
      x,
    );
  }

  toString(): string {
    const [[l1, c1], [l2, c2]] = [this.start, this.stop];
    return `${this.file || "<none>"}:${l1}:${c1}-${l2}:${c2}`;
  }
}

/**
 * An error reported by the server
 *
 * Python's `Error`, renamed so it does not shadow the global `Error`
 */
export class ErrorInfo {
  private constructor(
    /** The kind of error, e.g. `TypeErr` */
    readonly kind: string,
    /** The main error message */
    readonly message: ErrorInfo.Message,
    /** Further messages giving context for the error */
    readonly stack: readonly ErrorInfo.Message[],
    /** The process in which the error occurred, if known */
    readonly process: string | undefined,
    readonly raw: errorPb.Error,
  ) {}

  static ofRaw(x: errorPb.Error): ErrorInfo {
    // The server sends the kind printed as an OCaml record, `{ Kind.name = "TypeErr" }`
    const m = /^\{ Kind\.name = "(.*)" \}$/s.exec(x.kind);
    return new ErrorInfo(
      m === null ? x.kind : m[1]!,
      ErrorInfo.Message.ofRaw(x.msg ?? { msg: "", locs: [] }),
      x.stack.map((s) => ErrorInfo.Message.ofRaw(s)),
      x.process,
      x,
    );
  }

  toString(): string {
    return `${this.kind}: ${this.message}`;
  }
}

export namespace ErrorInfo {
  /** An error message, with source locations and an optional backtrace */
  export class Message {
    private constructor(
      /** The message text */
      readonly message: string,
      /** The source locations the message refers to */
      readonly locations: readonly Location[],
      /** The backtrace, if any */
      readonly backtrace: string | undefined,
      readonly raw: errorPb.Error_Message,
    ) {}

    static ofRaw(x: errorPb.Error_Message): Message {
      return new Message(
        x.msg,
        x.locs.map((l) => Location.ofRaw(l)),
        x.backtrace,
        x,
      );
    }

    toString(): string {
      return this.message;
    }
  }
}

/** A serialized artifact (task data or a task result) fetched from the server */
export class Artifact {
  private constructor(
    /** The artifact kind, e.g. `po_task` or `eval_res` */
    readonly kind: string,
    /** The serialized artifact data */
    readonly data: Uint8Array,
    /** The API version the artifact was produced with */
    readonly apiVersion: string,
    /** Additional stored data the artifact refers to, by key */
    readonly storage: ReadonlyMap<string, Uint8Array>,
    readonly raw: artmsgPb.Artifact,
  ) {}

  static ofRaw(x: artmsgPb.Artifact): Artifact {
    return new Artifact(
      x.kind,
      x.data,
      x.apiVersion,
      new Map(x.storage.map((s) => [s.key, s.value])),
      x,
    );
  }

  /**
   * Decode the data as an instance of `expectedClass`
   *
   * @param expectedClass The class the data should decode to, e.g. `raw.types.Mir_Term`. Pass the
   *   type arguments of a generic class as the type parameter to get a fully typed result, e.g.
   *   `decodeAs<raw.types.Common_Model_t_poly<Mir_Term, Mir_Type>>(Common_Model_t_poly)`. Only the
   *   class is checked; the type arguments are not.
   * @throws {UnexpectedResponseError} if the artifact kind is unknown, or the data does not decode
   *   to an `expectedClass`
   * @throws {twine.TwineError} if the data is malformed
   */
  decodeAs<T>(expectedClass: abstract new (...args: any[]) => T): T;
  decodeAs<T>(expectedClass: abstract new (...args: any[]) => unknown): T;
  decodeAs<T>(expectedClass: abstract new (...args: any[]) => unknown): T {
    const decoder = (lib.artifact_decoders as Record<string, (d: twine.Decoder, off: number) => unknown>)[
      this.kind
    ];
    if (decoder === undefined) {
      throw new UnexpectedResponseError(`Unknown artifact kind '${this.kind}'`);
    }
    const d = new twine.Decoder(this.data);
    let x: unknown;
    try {
      x = decoder(d, d.entrypoint());
    } catch (e) {
      if (e instanceof RangeError) {
        throw new twine.TwineError({ msg: "artifact data is cyclic or nested too deeply", offset: 0 });
      }
      throw e;
    }
    if (!(x instanceof expectedClass)) {
      const got = typeof x === "object" && x !== null ? x.constructor.name : typeof x;
      throw new UnexpectedResponseError(
        `Artifact of kind '${this.kind}' decoded to unexpected type '${got}'`,
      );
    }
    return x as T;
  }
}

/** Tactic execution statistics */
export class Statistics {
  private constructor(
    /** Execution time, in seconds */
    readonly timeS: number,
    /** Tactic-level statistics */
    readonly tactic: readonly (readonly [string, string])[] | undefined,
    readonly raw: lib.Statistics,
  ) {}

  static ofLib(x: lib.Statistics): Statistics {
    return new Statistics(
      x.time_s,
      x.tactic === undefined ? undefined : x.tactic.map(([k, v]) => [k, v] as const),
      x,
    );
  }
}

export class ErrorMessage {
  private constructor(
    readonly message: string,
    readonly backtrace: string | undefined,
    readonly raw: lib.Error_Error_core_message,
  ) {}

  static ofLib(x: lib.Error_Error_core_message): ErrorMessage {
    return new ErrorMessage(x.msg, x.bt, x);
  }

  toString(): string {
    return this.message;
  }
}

export class ErrorCore {
  private constructor(
    readonly process: string,
    readonly kind: string,
    readonly message: ErrorMessage,
    readonly stack: readonly ErrorMessage[],
    readonly raw: lib.Error_Error_core,
  ) {}

  static ofLib(x: lib.Error_Error_core): ErrorCore {
    return new ErrorCore(
      x.process,
      x.kind.name,
      ErrorMessage.ofLib(x.msg),
      x.stack.map((m) => ErrorMessage.ofLib(m)),
      x,
    );
  }

  toString(): string {
    return `${this.kind}: ${this.message}`;
  }
}

/** Where a task came from */
export class Origin {
  private constructor(
    /** The symbol the task was generated from */
    readonly fromSym: string,
    /** Distinguishes tasks generated from the same symbol */
    readonly count: number,
    readonly raw: taskPb.Origin,
  ) {}

  static ofRaw(x: taskPb.Origin): Origin {
    return new Origin(x.fromSym, x.count, x);
  }
}

/** A model returned by `verify*`, `instance*` or `test*` */
export class ModelOutput {
  #model: Model | undefined | null = null;

  private constructor(
    /** Whether the model is a counter-example or an instance */
    readonly kind: "counterExample" | "instance",
    /** The model as IML source */
    readonly src: string,
    readonly raw: simplePb.Model,
  ) {}

  static ofRaw(x: simplePb.Model): ModelOutput {
    let kind: "counterExample" | "instance";
    switch (x.mType) {
      case simplePb.ModelType.Counter_example:
        kind = "counterExample";
        break;
      case simplePb.ModelType.Instance:
        kind = "instance";
        break;
      default:
        throw new UnexpectedResponseError(`Unexpected model type '${x.mType}'`);
    }
    return new ModelOutput(kind, x.src, x);
  }

  toString(): string {
    return this.src;
  }

  /** The model, decoded from its artifact on first access, if the server sent one */
  get model(): Model | undefined {
    if (this.#model === null) {
      this.#model =
        this.raw.artifact === undefined
          ? undefined
          : Model.ofLib(
              Artifact.ofRaw(this.raw.artifact).decodeAs<lib.Common_Model_t_poly<lib.Mir_Term, lib.Mir_Type>>(
                lib.Common_Model_t_poly,
              ),
            );
    }
    return this.#model;
  }
}

/** A proof obligation result in an `evalSrc` response */
export class ProofObligationResult {
  private constructor(
    /** The outcome of the proof obligation, `undefined` if the server sent none */
    readonly res: ProofObligationResult.Res | undefined,
    /** Errors reported while checking the proof obligation */
    readonly errors: readonly ErrorInfo[],
    /** The proof obligation's task */
    readonly task: ProofObligationTask,
    /** Where the proof obligation came from */
    readonly origin: Origin,
    readonly raw: simplePb.PORes,
  ) {}

  static ofRaw(x: simplePb.PORes, client?: ArtifactSource): ProofObligationResult {
    let res: ProofObligationResult.Res | undefined;
    if (x.unknown !== undefined) {
      res = { kind: "unknown", message: x.unknown.msg };
    } else if (x.err !== undefined) {
      res = { kind: "err" };
    } else if (x.proof !== undefined) {
      res = { kind: "proof", proofPp: x.proof.proofPp };
    } else if (x.instance !== undefined) {
      res = {
        kind: "instance",
        model: x.instance.model === undefined ? undefined : ModelOutput.ofRaw(x.instance.model),
      };
    } else if (x.verifiedUpto !== undefined) {
      res = { kind: "verifiedUpto", message: x.verifiedUpto.msg };
    } else if (x.testOk !== undefined) {
      res = { kind: "testOk" };
    }
    return new ProofObligationResult(
      res,
      x.errors.map((e) => ErrorInfo.ofRaw(e)),
      taskOfRawAs(requireTask(x.task), ProofObligationTask, client),
      Origin.ofRaw(x.origin ?? { fromSym: "", count: 0 }),
      x,
    );
  }

  /** The kind of `res`, or `undefined` if the server sent none */
  get outcome(): ProofObligationResult.Res["kind"] | undefined {
    return this.res?.kind;
  }

  /** Whether the goal was proved */
  get proved(): boolean {
    return this.res?.kind === "proof";
  }

  /** Whether a model was found: an instance, or a counter-example to a theorem or `verify` goal */
  get found(): boolean {
    return this.res?.kind === "instance";
  }

  /** The pretty-printed proof, if the goal was proved and the server sent it */
  get proofPp(): string | undefined {
    return this.res?.kind === "proof" ? this.res.proofPp : undefined;
  }

  /** The model, if one was found and the server sent it */
  get model(): ModelOutput | undefined {
    return this.res?.kind === "instance" ? this.res.model : undefined;
  }

  /** The message for an `unknown` or `verifiedUpto` outcome, if any */
  get message(): string | undefined {
    return this.res?.kind === "unknown" || this.res?.kind === "verifiedUpto"
      ? this.res.message
      : undefined;
  }
}

export namespace ProofObligationResult {
  /** The outcome of a proof obligation */
  export type Res =
    /** The proof obligation could not be decided */
    | { readonly kind: "unknown"; readonly message: string }
    /** Checking failed; the errors are in `ProofObligationResult.errors` */
    | { readonly kind: "err" }
    /** The goal was proved; `proofPp` is the pretty-printed proof, if the server sent it */
    | { readonly kind: "proof"; readonly proofPp: string | undefined }
    /**
     * A model was found: an instance of an `instance` goal, or a counter-example to a theorem or
     * `verify` goal (reported with an error); `model` is `undefined` if the server did not send it
     */
    | { readonly kind: "instance"; readonly model: ModelOutput | undefined }
    /** The goal was verified up to a bound */
    | { readonly kind: "verifiedUpto"; readonly message: string | undefined }
    /** Testing found no counter-example */
    | { readonly kind: "testOk" };
}

/** The result of a decomposition request */
export class DecompositionResult {
  #decomposition: Decomposition | undefined | null = null;

  private constructor(
    /** The decomposition artifact, `undefined` if the decomposition failed */
    readonly artifact: Artifact | undefined,
    /** The decomposition task, `undefined` if the request failed before one was created */
    readonly task: DecompositionTask | undefined,
    /** Errors reported during decomposition */
    readonly errors: readonly ErrorInfo[],
    readonly raw: simplePb.DecomposeRes,
  ) {}

  static ofRaw(x: simplePb.DecomposeRes, client?: ArtifactSource): DecompositionResult {
    return new DecompositionResult(
      x.artifact === undefined ? undefined : Artifact.ofRaw(x.artifact),
      x.task === undefined ? undefined : taskOfRawAs(x.task, DecompositionTask, client),
      x.errors.map((e) => ErrorInfo.ofRaw(e)),
      x,
    );
  }

  /** Whether the decomposition succeeded */
  get success(): boolean {
    return this.artifact !== undefined;
  }

  /** The decomposition, decoded from `artifact` on first access, if the request succeeded */
  get decomposition(): Decomposition | undefined {
    if (this.#decomposition === null) {
      this.#decomposition =
        this.artifact === undefined
          ? undefined
          : Decomposition.ofLib(
              this.artifact.decodeAs<lib.Common_Fun_decomp_t_poly<lib.Mir_Term, lib.Mir_Type>>(
                lib.Common_Fun_decomp_t_poly,
              ),
            );
    }
    return this.#decomposition;
  }
}

/** The output of an `eval` in evaluated source */
export class EvalOutput {
  private constructor(
    /** Whether evaluation succeeded */
    readonly success: boolean,
    /** The value printed as OCaml, if available */
    readonly asOcaml: string | undefined,
    /** Errors reported during evaluation */
    readonly errors: readonly ErrorInfo[],
    readonly raw: simplePb.EvalOutput,
  ) {}

  static ofRaw(x: simplePb.EvalOutput): EvalOutput {
    return new EvalOutput(
      x.success,
      x.valueAsOcaml,
      x.errors.map((e) => ErrorInfo.ofRaw(e)),
      x,
    );
  }
}

/** The response to an `evalSrc` request */
export class EvalSrcResponse {
  private constructor(
    /** Whether the request succeeded; errors in the source are reported in `errors` */
    readonly success: boolean,
    /** Messages printed while processing the source */
    readonly messages: readonly string[],
    /** Errors reported while processing the source */
    readonly errors: readonly ErrorInfo[],
    /** The tasks created while processing the source */
    readonly tasks: readonly Task[],
    /** The results of the source's proof obligations */
    readonly poResults: readonly ProofObligationResult[],
    /** The outputs of the source's `eval` statements */
    readonly evalResults: readonly EvalOutput[],
    /** The results of the source's decompositions */
    readonly decompResults: readonly DecompositionResult[],
    readonly raw: simplePb.EvalRes,
  ) {}

  static ofRaw(x: simplePb.EvalRes, client?: ArtifactSource): EvalSrcResponse {
    return new EvalSrcResponse(
      x.success,
      x.messages,
      x.errors.map((e) => ErrorInfo.ofRaw(e)),
      x.tasks.map((t) => taskOfRaw(t, client)),
      x.poResults.map((r) => ProofObligationResult.ofRaw(r, client)),
      x.evalResults.map((r) => EvalOutput.ofRaw(r)),
      x.decompResults.map((r) => DecompositionResult.ofRaw(r, client)),
      x,
    );
  }
}

/** The result of a `verifySrc` or `verifyName` request */
export class VerifyResponse {
  private constructor(
    /** The outcome of verification, `undefined` if the server sent none */
    readonly res: VerifyResponse.Res | undefined,
    /** Errors reported during verification */
    readonly errors: readonly ErrorInfo[],
    /** The verification task, `undefined` if the request failed before one was created */
    readonly task: ProofObligationTask | undefined,
    readonly raw: simplePb.VerifyRes,
  ) {}

  static ofRaw(x: simplePb.VerifyRes, client?: ArtifactSource): VerifyResponse {
    let res: VerifyResponse.Res | undefined;
    if (x.unknown !== undefined) {
      res = { kind: "unknown", message: x.unknown.msg };
    } else if (x.err !== undefined) {
      res = { kind: "err" };
    } else if (x.proved !== undefined) {
      res = { kind: "proved", proofPp: x.proved.proofPp };
    } else if (x.refuted !== undefined) {
      res = {
        kind: "refuted",
        counterExample:
          x.refuted.model === undefined ? undefined : ModelOutput.ofRaw(x.refuted.model),
      };
    } else if (x.verifiedUpto !== undefined) {
      res = { kind: "verifiedUpto", message: x.verifiedUpto.msg };
    }
    return new VerifyResponse(
      res,
      x.errors.map((e) => ErrorInfo.ofRaw(e)),
      x.task === undefined ? undefined : taskOfRawAs(x.task, ProofObligationTask, client),
      x,
    );
  }

  /** The kind of `res`, or `undefined` if the server sent none */
  get outcome(): VerifyResponse.Res["kind"] | undefined {
    return this.res?.kind;
  }

  /** Whether the goal was proved */
  get proved(): boolean {
    return this.res?.kind === "proved";
  }

  /** Whether a counter-example was found */
  get refuted(): boolean {
    return this.res?.kind === "refuted";
  }

  /** The pretty-printed proof, if the goal was proved and the server sent it */
  get proofPp(): string | undefined {
    return this.res?.kind === "proved" ? this.res.proofPp : undefined;
  }

  /** The counter-example, if the goal was refuted */
  get counterExample(): ModelOutput | undefined {
    return this.res?.kind === "refuted" ? this.res.counterExample : undefined;
  }

  /** The message for an `unknown` or `verifiedUpto` outcome, if any */
  get message(): string | undefined {
    return this.res?.kind === "unknown" || this.res?.kind === "verifiedUpto"
      ? this.res.message
      : undefined;
  }
}

export namespace VerifyResponse {
  /** The outcome of verification */
  export type Res =
    /** Verification could not decide the goal */
    | { readonly kind: "unknown"; readonly message: string }
    /** Verification failed; the errors are in `VerifyResponse.errors` */
    | { readonly kind: "err" }
    /** The goal was proved; `proofPp` is the pretty-printed proof, if the server sent it */
    | { readonly kind: "proved"; readonly proofPp: string | undefined }
    /** A counter-example was found; `undefined` if the server did not send it */
    | { readonly kind: "refuted"; readonly counterExample: ModelOutput | undefined }
    /** The goal was verified up to a bound */
    | { readonly kind: "verifiedUpto"; readonly message: string | undefined };
}

/** The result of an `instanceSrc` or `instanceName` request */
export class InstanceResponse {
  private constructor(
    /** The outcome of the instance search, `undefined` if the server sent none */
    readonly res: InstanceResponse.Res | undefined,
    /** Errors reported during the instance search */
    readonly errors: readonly ErrorInfo[],
    /** The instance task, `undefined` if the request failed before one was created */
    readonly task: ProofObligationTask | undefined,
    readonly raw: simplePb.InstanceRes,
  ) {}

  static ofRaw(x: simplePb.InstanceRes, client?: ArtifactSource): InstanceResponse {
    let res: InstanceResponse.Res | undefined;
    if (x.unknown !== undefined) {
      res = { kind: "unknown", message: x.unknown.msg };
    } else if (x.err !== undefined) {
      res = { kind: "err" };
    } else if (x.unsat !== undefined) {
      res = { kind: "unsat", proofPp: x.unsat.proofPp };
    } else if (x.sat !== undefined) {
      res = {
        kind: "sat",
        instance: x.sat.model === undefined ? undefined : ModelOutput.ofRaw(x.sat.model),
      };
    }
    return new InstanceResponse(
      res,
      x.errors.map((e) => ErrorInfo.ofRaw(e)),
      x.task === undefined ? undefined : taskOfRawAs(x.task, ProofObligationTask, client),
      x,
    );
  }

  /** The kind of `res`, or `undefined` if the server sent none */
  get outcome(): InstanceResponse.Res["kind"] | undefined {
    return this.res?.kind;
  }

  /** Whether an instance was found */
  get found(): boolean {
    return this.res?.kind === "sat";
  }

  /** The instance, if one was found */
  get instance(): ModelOutput | undefined {
    return this.res?.kind === "sat" ? this.res.instance : undefined;
  }

  /** The pretty-printed proof of unsatisfiability, if any */
  get proofPp(): string | undefined {
    return this.res?.kind === "unsat" ? this.res.proofPp : undefined;
  }

  /** The message for an `unknown` outcome */
  get message(): string | undefined {
    return this.res?.kind === "unknown" ? this.res.message : undefined;
  }
}

export namespace InstanceResponse {
  /** The outcome of an instance search */
  export type Res =
    /** The instance search could not decide the goal */
    | { readonly kind: "unknown"; readonly message: string }
    /** The instance search failed; the errors are in `InstanceResponse.errors` */
    | { readonly kind: "err" }
    /** The goal has no instance; `proofPp` is the proof of unsatisfiability, if the server sent it */
    | { readonly kind: "unsat"; readonly proofPp: string | undefined }
    /** An instance was found; `undefined` if the server did not send it */
    | { readonly kind: "sat"; readonly instance: ModelOutput | undefined };
}

/** The result of a `testSrc` or `testName` request */
export class TestResponse {
  private constructor(
    /** The outcome of testing, `undefined` if the server sent none */
    readonly res: TestResponse.Res | undefined,
    /** Errors reported during testing */
    readonly errors: readonly ErrorInfo[],
    /** The test task, `undefined` if the request failed before one was created */
    readonly task: ProofObligationTask | undefined,
    readonly raw: simplePb.TestRes,
  ) {}

  static ofRaw(x: simplePb.TestRes, client?: ArtifactSource): TestResponse {
    let res: TestResponse.Res | undefined;
    if (x.err !== undefined) {
      res = { kind: "err" };
    } else if (x.counterExample !== undefined) {
      res = {
        kind: "counterExample",
        counterExample:
          x.counterExample.model === undefined
            ? undefined
            : ModelOutput.ofRaw(x.counterExample.model),
      };
    }
    return new TestResponse(
      res,
      x.errors.map((e) => ErrorInfo.ofRaw(e)),
      x.task === undefined ? undefined : taskOfRawAs(x.task, ProofObligationTask, client),
      x,
    );
  }

  /**
   * The kind of `res`, or `undefined` if the server sent none
   *
   * Testing that finds no counter-example is reported as `err`, with an error of kind
   * `NoCounterExample`
   */
  get outcome(): TestResponse.Res["kind"] | undefined {
    return this.res?.kind;
  }

  /** Whether a counter-example was found */
  get refuted(): boolean {
    return this.res?.kind === "counterExample";
  }

  /** The counter-example, if one was found */
  get counterExample(): ModelOutput | undefined {
    return this.res?.kind === "counterExample" ? this.res.counterExample : undefined;
  }
}

export namespace TestResponse {
  /** The outcome of testing */
  export type Res =
    /**
     * Testing failed, or found no counter-example; the errors are in `TestResponse.errors`.
     * Testing that finds no counter-example is reported this way, with an error of kind
     * `NoCounterExample`
     */
    | { readonly kind: "err" }
    /** A counter-example was found; `undefined` if the server did not send it */
    | { readonly kind: "counterExample"; readonly counterExample: ModelOutput | undefined };
}

/** The result of a `typecheck` request */
export class TypecheckResponse {
  private constructor(
    /** Whether the source typechecked */
    readonly success: boolean,
    /** The inferred types, decoded from JSON */
    readonly types: unknown,
    /** Errors reported during typechecking */
    readonly errors: readonly ErrorInfo[],
    readonly raw: simplePb.TypecheckRes,
  ) {}

  static ofRaw(x: simplePb.TypecheckRes): TypecheckResponse {
    return new TypecheckResponse(
      x.success,
      x.types ? JSON.parse(x.types) : undefined,
      x.errors.map((e) => ErrorInfo.ofRaw(e)),
      x,
    );
  }
}

/** The result of a `oneshot` request */
export class OneshotResponse {
  private constructor(
    /** The results, as strings */
    readonly results: readonly string[],
    /** The results, in more detail */
    readonly detailedResults: readonly string[],
    /** The errors, as strings */
    readonly errors: readonly string[],
    /** The time the request took on the server, in seconds */
    readonly timeS: number,
    readonly raw: simplePb.OneshotRes,
  ) {}

  static ofRaw(x: simplePb.OneshotRes): OneshotResponse {
    return new OneshotResponse(x.results, x.detailedResults, x.errors, x.stats?.time ?? 0, x);
  }
}

/** The result of an `evalCodeSnippet` request */
export class CodeSnippetResponse {
  private constructor(
    /**
     * The evaluation status reported by the server; `errors` can be non-empty even when it is
     * `"ok"`
     */
    readonly res: "ok" | "errors",
    /** The time evaluation took, in seconds */
    readonly durationS: number,
    /** The tasks created during evaluation */
    readonly tasks: readonly Task[],
    /** Errors reported during evaluation */
    readonly errors: readonly ErrorInfo[],
    readonly raw: apiPb.CodeSnippetEvalResult,
  ) {}

  static ofRaw(x: apiPb.CodeSnippetEvalResult, client?: ArtifactSource): CodeSnippetResponse {
    let res: "ok" | "errors";
    switch (x.res) {
      case apiPb.EvalResult.EVAL_OK:
        res = "ok";
        break;
      case apiPb.EvalResult.EVAL_ERRORS:
        res = "errors";
        break;
      default:
        throw new UnexpectedResponseError(`Unexpected eval result '${x.res}'`);
    }
    return new CodeSnippetResponse(
      res,
      x.durationS,
      x.tasks.map((t) => taskOfRaw(t, client)),
      x.errors.map((e) => ErrorInfo.ofRaw(e)),
      x,
    );
  }
}

/** The server's version */
export class ServerVersion {
  private constructor(
    readonly version: string,
    readonly gitVersion: string | undefined,
    readonly raw: systemPb.VersionResponse,
  ) {}

  static ofRaw(x: systemPb.VersionResponse): ServerVersion {
    return new ServerVersion(x.version, x.gitVersion, x);
  }
}

// Unwrapping `ok` / `error` results
// =================================

export function artifactOfResult(res: apiPb.ArtifactResult): Artifact {
  if (res.error !== undefined) throw new ServerError(ErrorInfo.ofRaw(res.error));
  if (res.ok !== undefined) return Artifact.ofRaw(res.ok);
  throw new UnexpectedResponseError("Artifact result has neither `error` nor `ok`");
}

export function artifactKindsOfResult(res: apiPb.ArtifactListResult): string[] {
  if (res.error !== undefined) throw new ServerError(ErrorInfo.ofRaw(res.error));
  if (res.ok !== undefined) return [...res.ok.kinds];
  throw new UnexpectedResponseError("Artifact list result has neither `error` nor `ok`");
}

export function artifactZipOfResult(res: apiPb.ArtifactZipResult): Uint8Array {
  if (res.error !== undefined) throw new ServerError(ErrorInfo.ofRaw(res.error));
  if (res.ok !== undefined) return res.ok.artZip;
  throw new UnexpectedResponseError("Artifact zip result has neither `error` nor `ok`");
}

/** `t`, which the response must have */
function requireTask(t: taskPb.Task | undefined): taskPb.Task {
  if (t === undefined) throw new UnexpectedResponseError("Response has no task");
  return t;
}
