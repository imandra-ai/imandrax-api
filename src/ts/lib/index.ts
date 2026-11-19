/**
 * The ImandraX API client
 *
 * `Client` connects to ImandraX, and its methods return the responses defined here. The
 * types of what is inside the responses are in their own modules:
 *
 * - `imandrax-api/tasks`: the tasks a request starts, and their data and results
 * - `imandrax-api/mir`: terms, types, declarations and models
 * - `imandrax-api/proof`: proofs
 * - `imandrax-api/report`: reports of proof attempts and decompositions
 * - `imandrax-api/decomp`: decomposition requests and their regions
 * - `imandrax-api/values`: the values of evaluated terms
 * - `imandrax-api/raw`: the generated layers the client is built on: `proto` (protobuf
 *   messages), `types` (artifact types and their decoders) and `twine` (the decoder)
 *
 * @module imandrax-api
 * @showGroups
 */

export { version } from "./version.js";

export * from "./client.js";
export * from "./errors.js";
export * from "./responses.js";
export type { CallOptions } from "./internal/transport.js";
