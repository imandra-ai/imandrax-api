/**
 * The ImandraX API client
 *
 * `Client` connects to ImandraX. This package also defines the types of what the client
 * exchanges with ImandraX: requests, responses, tasks and their results, and the terms, types,
 * models, proofs and reports inside them.
 *
 * The generated layers the client is built on are exported as `raw`: `raw.proto` (protobuf
 * messages), `raw.types` (artifact types and their decoders) and `raw.twine` (the decoder).
 */

export { version } from "./version.js";

export * from "./client.js";
export * from "./errors.js";
export * from "./responses.js";
export * from "./tasks.js";
export * from "./mir.js";
export * from "./proof.js";
export * from "./report.js";
export { type Value, valueOfLib } from "./values.js";
export type { CallOptions } from "./transport.js";
export * as decomp from "./decomp.js";
/** The value classes of `Value`, some named like built-ins (`String`, `Record`) */
export * as values from "./values.js";

export * as raw from "./raw/index.js";
