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

export type {
  Position,
  Location,
  ErrorInfo,
  ErrorInfoMessage,
  Artifact,
  Statistics,
  ErrorMessage,
  ErrorCore,
  Origin,
  ModelOutput,
  ProofObligationResult,
  ProofObligationOutcome,
  DecompositionResult,
  EvalOutput,
  EvalSrcResponse,
  VerifyResponse,
  VerifyOutcome,
  InstanceResponse,
  InstanceOutcome,
  TestResponse,
  TestOutcome,
  TypecheckResponse,
  OneshotResponse,
  CodeSnippetResponse,
  ServerVersion,
} from "./internal/responses.js";
