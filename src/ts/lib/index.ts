/**
 * The ImandraX API client
 *
 * `Client` connects to ImandraX, and its methods return the responses defined here. The
 * types of what is inside the responses are in their own modules:
 *
 * - `@imandra/imandrax-api/tasks`: the tasks a request starts, and their data and results
 * - `@imandra/imandrax-api/mir`: terms, types, declarations and models
 * - `@imandra/imandrax-api/proof`: proofs
 * - `@imandra/imandrax-api/report`: reports of proof attempts and decompositions
 * - `@imandra/imandrax-api/decomp`: decomposition requests and their regions
 * - `@imandra/imandrax-api/values`: the values of evaluated terms
 * - `@imandra/imandrax-api/uid_print_style`: whether uids print by short or full name
 * - `@imandra/imandrax-api/raw`: the generated layers the client is built on: `proto` (protobuf
 *   messages), `types` (artifact types and their decoders) and `twine` (the decoder)
 *
 * @module @imandra/imandrax-api
 * @showGroups
 */

export { version } from "./version.js";

export * from "./client.js";
export * from "./errors.js";
export * from "./responses.js";
export type { CallOptions } from "./internal/transport.js";
