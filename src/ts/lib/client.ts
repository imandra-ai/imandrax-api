/** The ImandraX API client */

import type { Decomp } from "./decomp.js";
import {
  ApiVersionMismatchError,
  ClientClosedError,
  EndSessionError,
  TwirpError,
} from "./errors.js";
import { liftBoolToPb } from "./internal/lift_bool.js";
import { type Term, type Type, termOfLib, typeOfLib } from "./internal/mir.js";
import * as apiPb from "./raw/proto/api.js";
import * as sessionPb from "./raw/proto/session.js";
import * as simplePb from "./raw/proto/simple_api.js";
import * as systemPb from "./raw/proto/system.js";
import * as utilsPb from "./raw/proto/utils.js";
import * as lib from "./raw/types.js";
import {
  type Artifact,
  CodeSnippetResponse,
  DecompositionResult,
  EvalSrcResponse,
  InstanceResponse,
  OneshotResponse,
  ServerVersion,
  TestResponse,
  TypecheckResponse,
  VerifyResponse,
  artifactKindsOfResult,
  artifactOfResult,
  artifactZipOfResult,
} from "./internal/responses.js";
import type { LiftBool, Task } from "./internal/tasks.js";
import {
  type CallOptions,
  type MessageType,
  Transport,
  isSessionNotFound,
} from "./internal/transport.js";
import { version as apiTypesVersion } from "./version.js";

/** @group Client */
export const urlDev = "https://api.dev.imandracapital.com/internal/imandrax/";
/** @group Client */
export const urlProd = "https://api.imandra.ai/internal/imandrax/";

/** @group Client */
export interface ConnectOptions {
  /** The server's URL; `urlProd` by default */
  url?: string | undefined;
  /** The path of the API on the server; `"/api/v1"` by default */
  serverPathPrefix?: string | undefined;
  /** The token to authenticate with; `apiKey` takes precedence if both are given */
  authToken?: string | undefined;
  /** The API key to authenticate with */
  apiKey?: string | undefined;
  /** The HTTP request timeout, in milliseconds, of calls without their own; 30s by default */
  timeoutMs?: number | undefined;
  /** The session to reopen; a new one is created if not given */
  sessionId?: string | undefined;
  /** Whether to create a new session if `sessionId` is not found, instead of throwing */
  createIfNotFound?: boolean | undefined;
  /** Aborts connecting */
  signal?: AbortSignal | undefined;
}

/** @group Method options */
export interface EvalSrcOptions extends CallOptions {
  /** Whether to return without waiting for task results */
  asyncOnly?: boolean | undefined;
  /**
   * Glob patterns (`*`, `?`, `[...]`) selecting the tasks to start; all tasks by default. Tasks
   * without names are matched as `anonymous`.
   */
  taskFilter?: readonly string[] | undefined;
}

/** @group Method options */
export interface DecomposeOptions extends CallOptions {
  /** The side condition function the decomposition assumes */
  assuming?: string | undefined;
  /** Functions not to unfold during decomposition */
  basis?: readonly string[] | undefined;
  /** Rule specs to use during decomposition */
  ruleSpecs?: readonly string[] | undefined;
  /** Whether to prune infeasible regions */
  prune?: boolean | undefined;
  /** Whether to simplify regions in their context */
  ctxSimp?: boolean | undefined;
  /** How Boolean subterms are lifted into region constraints */
  liftBool?: LiftBool | undefined;
  /**
   * Whether to also return each region's constraints and invariant in IML syntax, as
   * `Region.constraintsStr` and `Region.invariantStr`
   */
  stringResults?: boolean | undefined;
  /** The server-side compute timeout */
  computeTimeout?: number | undefined;
}

/** @group Method options */
export interface DecomposeFullOptions extends CallOptions {
  /**
   * Whether to also return each region's constraints and invariant in IML syntax, as
   * `Region.constraintsStr` and `Region.invariantStr`
   */
  stringResults?: boolean | undefined;
  /** The server-side compute timeout */
  computeTimeout?: number | undefined;
}

/** @group Method options */
export interface GoalOptions extends CallOptions {
  /** IML attribute text for the goal, e.g. `[@@by auto]` */
  hints?: string | undefined;
}

/** @group Method options */
export interface TestOptions extends CallOptions {
  /** The random seed */
  seed?: number | undefined;
}

/** @group Method options */
export interface OneshotOptions extends CallOptions {
  /** The server-side compute timeout */
  computeTimeout?: number | undefined;
}

/** @group Method options */
export interface CodeSnippetOptions extends CallOptions {
  /**
   * Glob patterns (`*`, `?`, `[...]`) selecting the tasks to start; all tasks by default. Tasks
   * without names are matched as `anonymous`.
   */
  taskFilter?: readonly string[] | undefined;
}

const SIMPLE = "imandrax.simple.Simple";
const EVAL = "imandrax.api.Eval";
const SESSION_MANAGER = "imandrax.session.SessionManager";
const SYSTEM = "imandrax.system.System";

/** The transport options of `options`, dropping the method-specific ones */
function callOptions({ timeoutMs, signal }: CallOptions): CallOptions {
  return { timeoutMs, signal };
}

/**
 * A client for the ImandraX API
 *
 * Connect with `Client.connect`, which creates a session (or reopens one), and close it with
 * `close()` to end the session, or with `await using`:
 *
 * ```ts
 * await using client = await Client.connect({ apiKey });
 * const res = await client.evalSrc("let f x = x + 1");
 * ```
 *
 * @group Client
 */
export class Client {
  readonly #transport: Transport;
  readonly #session: sessionPb.Session;
  #closed = false;
  /** The `end_session` request of `close()`, once it started; shared by concurrent calls */
  #closing: Promise<void> | undefined = undefined;

  private constructor(transport: Transport, session: sessionPb.Session) {
    this.#transport = transport;
    this.#session = session;
  }

  /**
   * Connect to the server: create a session, or reopen `sessionId`
   *
   * @throws {ApiVersionMismatchError} if the server rejects this client's API version
   */
  static async connect(options: ConnectOptions = {}): Promise<Client> {
    const transport = new Transport({
      url: options.url ?? urlProd,
      serverPathPrefix: options.serverPathPrefix ?? "/api/v1",
      authToken: options.apiKey || options.authToken,
      timeoutMs: options.timeoutMs ?? 30_000,
    });
    const callOpts: CallOptions = { signal: options.signal };

    const createSession = async (): Promise<sessionPb.Session> => {
      try {
        return await transport.call(
          SIMPLE,
          "create_session",
          simplePb.SessionCreateReq,
          sessionPb.Session,
          simplePb.SessionCreateReq.fromPartial({ apiVersion: apiTypesVersion }),
          callOpts,
        );
      } catch (e) {
        if (e instanceof TwirpError && e.code === "invalid_argument") {
          throw new ApiVersionMismatchError(
            "API version mismatch. Try upgrading the imandrax-api package.",
            { cause: e },
          );
        }
        throw e;
      }
    };

    if (options.sessionId === undefined) {
      return new Client(transport, await createSession());
    }
    // Reopen the session; if the server reports it missing or expired, create a fresh one
    const session = sessionPb.Session.fromPartial({ id: options.sessionId });
    try {
      await transport.call(
        SESSION_MANAGER,
        "open_session",
        sessionPb.SessionOpen,
        utilsPb.Empty,
        sessionPb.SessionOpen.fromPartial({ id: session, apiVersion: apiTypesVersion }),
        callOpts,
      );
      return new Client(transport, session);
    } catch (e) {
      if (isSessionNotFound(e) && options.createIfNotFound) {
        return new Client(transport, await createSession());
      }
      throw e;
    }
  }

  /** The ID of the client's session */
  get sessionId(): string {
    return this.#session.id;
  }

  /** Whether the client is closed */
  get closed(): boolean {
    return this.#closed;
  }

  /**
   * End the session; later calls throw `ClientClosedError`
   *
   * Does nothing if the client is already closed. Calls to `close()` made while one is in
   * progress wait for it, so the session is ended once; other calls throw `ClientClosedError`.
   *
   * If the request never got an answer from the server (it was aborted, timed out or failed to
   * connect), the client stays open, and `close()` can be called again.
   *
   * @throws {EndSessionError} if the server reported an error ending the session
   */
  close(options: CallOptions = {}): Promise<void> {
    if (this.#closed) return Promise.resolve();
    this.#closing ??= this.#endSession(options);
    return this.#closing;
  }

  async #endSession(options: CallOptions): Promise<void> {
    try {
      await this.#transport.call(
        SIMPLE,
        "end_session",
        sessionPb.Session,
        utilsPb.Empty,
        this.#session,
        callOptions(options),
      );
    } catch (e) {
      // a Twirp error with an HTTP status is an answer: the server or an intermediary got the request
      if (e instanceof TwirpError && e.status !== undefined) {
        this.#closed = true;
        throw new EndSessionError(this.#session.id, { cause: e });
      }
      this.#closing = undefined;
      throw e instanceof TwirpError ? new EndSessionError(this.#session.id, { cause: e }) : e;
    }
    this.#closed = true;
  }

  /** `close()`, for `await using` */
  async [Symbol.asyncDispose](): Promise<void> {
    await this.close();
  }

  #call<Req, Res>(
    service: string,
    method: string,
    reqType: MessageType<Req>,
    resType: MessageType<Res>,
    request: Req,
    options: CallOptions,
  ): Promise<Res> {
    if (this.#closed || this.#closing !== undefined) {
      return Promise.reject(
        new ClientClosedError("the client is closed; create a new one with `Client.connect`"),
      );
    }
    return this.#transport.call(service, method, reqType, resType, request, callOptions(options));
  }

  // Service Simple
  // ==============

  /** The server's status message */
  async status(options: CallOptions = {}): Promise<string> {
    const res = await this.#call(SIMPLE, "status", utilsPb.Empty, utilsPb.StringMsg, {}, options);
    return res.msg;
  }

  /** Evaluate IML source */
  async evalSrc(src: string, options: EvalSrcOptions = {}): Promise<EvalSrcResponse> {
    const req = simplePb.EvalSrcReq.fromPartial({
      src,
      session: this.#session,
      taskFilter: [...(options.taskFilter ?? [])],
      asyncOnly: options.asyncOnly,
    });
    const res = await this.#call(
      SIMPLE,
      "eval_src",
      simplePb.EvalSrcReq,
      simplePb.EvalRes,
      req,
      options,
    );
    return EvalSrcResponse.ofRaw(res, this);
  }

  /** Decompose the function `name` */
  async decompose(name: string, options: DecomposeOptions = {}): Promise<DecompositionResult> {
    const req = simplePb.DecomposeReq.fromPartial({
      session: this.#session,
      name,
      assuming: options.assuming,
      basis: [...(options.basis ?? [])],
      ruleSpecs: [...(options.ruleSpecs ?? [])],
      prune: options.prune,
      ctxSimp: options.ctxSimp,
      liftBool: liftBoolToPb(options.liftBool),
      stringResults: options.stringResults,
      timeout: options.computeTimeout,
    });
    const res = await this.#call(
      SIMPLE,
      "decompose",
      simplePb.DecomposeReq,
      simplePb.DecomposeRes,
      req,
      options,
    );
    return DecompositionResult.ofRaw(res, this);
  }

  /**
   * A more expressive `decompose`: run a tree of decomposition operations, e.g. a merge of
   * decompositions of several functions
   *
   * @param d The decomposition request, built with the constructors in `decomp`
   */
  async decomposeFull(d: Decomp, options: DecomposeFullOptions = {}): Promise<DecompositionResult> {
    const req = simplePb.DecomposeReqFull.fromPartial({
      session: this.#session,
      decomp: d,
      stringResults: options.stringResults,
      timeout: options.computeTimeout,
    });
    const res = await this.#call(
      SIMPLE,
      "decompose_full",
      simplePb.DecomposeReqFull,
      simplePb.DecomposeRes,
      req,
      options,
    );
    return DecompositionResult.ofRaw(res, this);
  }

  /** Verify the goal given as IML source */
  async verifySrc(src: string, options: GoalOptions = {}): Promise<VerifyResponse> {
    const req = simplePb.VerifySrcReq.fromPartial({
      session: this.#session,
      src,
      hints: options.hints,
    });
    const res = await this.#call(
      SIMPLE,
      "verify_src",
      simplePb.VerifySrcReq,
      simplePb.VerifyRes,
      req,
      options,
    );
    return VerifyResponse.ofRaw(res, this);
  }

  /** Verify the predicate `name` */
  async verifyName(name: string, options: GoalOptions = {}): Promise<VerifyResponse> {
    const req = simplePb.VerifyNameReq.fromPartial({
      session: this.#session,
      name,
      hints: options.hints,
    });
    const res = await this.#call(
      SIMPLE,
      "verify_name",
      simplePb.VerifyNameReq,
      simplePb.VerifyRes,
      req,
      options,
    );
    return VerifyResponse.ofRaw(res, this);
  }

  /** Search for an instance of the goal given as IML source */
  async instanceSrc(src: string, options: GoalOptions = {}): Promise<InstanceResponse> {
    const req = simplePb.InstanceSrcReq.fromPartial({
      session: this.#session,
      src,
      hints: options.hints,
    });
    const res = await this.#call(
      SIMPLE,
      "instance_src",
      simplePb.InstanceSrcReq,
      simplePb.InstanceRes,
      req,
      options,
    );
    return InstanceResponse.ofRaw(res, this);
  }

  /** Search for an instance of the predicate `name` */
  async instanceName(name: string, options: GoalOptions = {}): Promise<InstanceResponse> {
    const req = simplePb.InstanceNameReq.fromPartial({
      session: this.#session,
      name,
      hints: options.hints,
    });
    const res = await this.#call(
      SIMPLE,
      "instance_name",
      simplePb.InstanceNameReq,
      simplePb.InstanceRes,
      req,
      options,
    );
    return InstanceResponse.ofRaw(res, this);
  }

  /** Test the goal given as IML source with random inputs */
  async testSrc(src: string, options: TestOptions = {}): Promise<TestResponse> {
    const req = simplePb.TestSrcReq.fromPartial({
      session: this.#session,
      src,
      // proto3 has no unset int: 0 is what an unset seed is sent as
      seed: options.seed ?? 0,
    });
    const res = await this.#call(
      SIMPLE,
      "test_src",
      simplePb.TestSrcReq,
      simplePb.TestRes,
      req,
      options,
    );
    return TestResponse.ofRaw(res, this);
  }

  /** Test the predicate `name` with random inputs */
  async testName(name: string, options: TestOptions = {}): Promise<TestResponse> {
    const req = simplePb.TestNameReq.fromPartial({
      session: this.#session,
      name,
      // proto3 has no unset int: 0 is what an unset seed is sent as
      seed: options.seed ?? 0,
    });
    const res = await this.#call(
      SIMPLE,
      "test_name",
      simplePb.TestNameReq,
      simplePb.TestRes,
      req,
      options,
    );
    return TestResponse.ofRaw(res, this);
  }

  /** Typecheck IML source, adding its definitions to the session */
  async typecheck(src: string, options: CallOptions = {}): Promise<TypecheckResponse> {
    const req = simplePb.TypecheckReq.fromPartial({ session: this.#session, src });
    const res = await this.#call(
      SIMPLE,
      "typecheck",
      simplePb.TypecheckReq,
      simplePb.TypecheckRes,
      req,
      options,
    );
    return TypecheckResponse.ofRaw(res);
  }

  /** Evaluate IML code in a sessionless, self-contained request */
  async oneshot(input: string, options: OneshotOptions = {}): Promise<OneshotResponse> {
    const req = simplePb.OneshotReq.fromPartial({ input, timeout: options.computeTimeout });
    const res = await this.#call(
      SIMPLE,
      "oneshot",
      simplePb.OneshotReq,
      simplePb.OneshotRes,
      req,
      options,
    );
    return OneshotResponse.ofRaw(res);
  }

  // Service Eval
  // ============

  /** Evaluate a code snippet */
  async evalCodeSnippet(
    code: string,
    options: CodeSnippetOptions = {},
  ): Promise<CodeSnippetResponse> {
    const req = apiPb.CodeSnippet.fromPartial({
      session: this.#session,
      code,
      taskFilter: [...(options.taskFilter ?? [])],
    });
    const res = await this.#call(
      EVAL,
      "eval_code_snippet",
      apiPb.CodeSnippet,
      apiPb.CodeSnippetEvalResult,
      req,
      options,
    );
    return CodeSnippetResponse.ofRaw(res, this);
  }

  /** Parse and typecheck a term */
  async parseTerm(code: string, options: CallOptions = {}): Promise<Term> {
    const req = apiPb.CodeSnippet.fromPartial({ session: this.#session, code });
    const res = await this.#call(
      EVAL,
      "parse_term",
      apiPb.CodeSnippet,
      apiPb.ArtifactResult,
      req,
      options,
    );
    return termOfLib(artifactOfResult(res).decodeAs(lib.Mir_Term));
  }

  /** Parse and typecheck a type */
  async parseType(code: string, options: CallOptions = {}): Promise<Type> {
    const req = apiPb.CodeSnippet.fromPartial({ session: this.#session, code });
    const res = await this.#call(
      EVAL,
      "parse_type",
      apiPb.CodeSnippet,
      apiPb.ArtifactResult,
      req,
      options,
    );
    return typeOfLib(artifactOfResult(res).decodeAs(lib.Mir_Type));
  }

  /** The kinds of the artifacts available for `task` */
  async listArtifacts(task: Task, options: CallOptions = {}): Promise<string[]> {
    const req = apiPb.ArtifactListQuery.fromPartial({ taskId: task.raw.id });
    const res = await this.#call(
      EVAL,
      "list_artifacts",
      apiPb.ArtifactListQuery,
      apiPb.ArtifactListResult,
      req,
      options,
    );
    return artifactKindsOfResult(res);
  }

  /**
   * The artifact of kind `kind` of `task`
   *
   * @param kind The artifact kind, one of `listArtifacts(task)`
   */
  async getArtifact(task: Task, kind: string, options: CallOptions = {}): Promise<Artifact> {
    const req = apiPb.ArtifactGetQuery.fromPartial({ taskId: task.raw.id, kind });
    const res = await this.#call(
      EVAL,
      "get_artifact",
      apiPb.ArtifactGetQuery,
      apiPb.ArtifactResult,
      req,
      options,
    );
    return artifactOfResult(res);
  }

  /**
   * The artifact of kind `kind` of `task`, as a zip file
   *
   * @param kind The artifact kind, one of `listArtifacts(task)`
   */
  async getArtifactZip(task: Task, kind: string, options: CallOptions = {}): Promise<Uint8Array> {
    const req = apiPb.ArtifactGetQuery.fromPartial({ taskId: task.raw.id, kind });
    const res = await this.#call(
      EVAL,
      "get_artifact_zip",
      apiPb.ArtifactGetQuery,
      apiPb.ArtifactZipResult,
      req,
      options,
    );
    return artifactZipOfResult(res);
  }

  // Service SessionManager
  // ======================

  /** Make sure the session remains active */
  async keepSessionAlive(options: CallOptions = {}): Promise<void> {
    await this.#call(
      SESSION_MANAGER,
      "keep_session_alive",
      sessionPb.Session,
      utilsPb.Empty,
      this.#session,
      options,
    );
  }

  // Service System
  // ==============

  /** The server's version */
  async version(options: CallOptions = {}): Promise<ServerVersion> {
    const res = await this.#call(
      SYSTEM,
      "version",
      utilsPb.Empty,
      systemPb.VersionResponse,
      {},
      options,
    );
    return ServerVersion.ofRaw(res);
  }
}
