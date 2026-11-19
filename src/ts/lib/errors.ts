/**
 * Errors thrown by the client, all subclasses of `ImandraXError`
 *
 * Malformed artifact data is the exception: decoding it throws `raw.twine.TwineError`, the
 * decoder's own error, which is not an `ImandraXError`.
 */

import type { ErrorCore, ErrorInfo } from "./responses.js";

/**
 * Base class for errors from ImandraX requests
 *
 * @group Errors
 */
export class ImandraXError extends Error {
  override name = "ImandraXError";
}

/**
 * The server's response did not have the expected shape
 *
 * @group Errors
 */
export class UnexpectedResponseError extends ImandraXError {
  override name = "UnexpectedResponseError";
}

/**
 * The server reported an error
 *
 * @group Errors
 */
export class ServerError extends ImandraXError {
  override name = "ServerError";

  constructor(readonly error: ErrorInfo | ErrorCore) {
    super(String(error));
  }
}

/**
 * Task data was fetched on a task created without a client
 *
 * @group Errors
 */
export class NoClientError extends ImandraXError {
  override name = "NoClientError";
}

/**
 * A request was made on a client that has already been closed
 *
 * @group Errors
 */
export class ClientClosedError extends ImandraXError {
  override name = "ClientClosedError";
}

/**
 * Ending the session failed when the client was closed
 *
 * @group Errors
 */
export class EndSessionError extends ImandraXError {
  override name = "EndSessionError";

  constructor(
    readonly sessionId: string,
    options?: { cause?: unknown },
  ) {
    super(`error while ending session ${sessionId}`, options);
  }
}

/**
 * The server rejected the client's API version
 *
 * @group Errors
 */
export class ApiVersionMismatchError extends ImandraXError {
  override name = "ApiVersionMismatchError";
}

/**
 * A Twirp error response, or a failure to get any response
 *
 * `code` is the Twirp error code (e.g. `not_found`, `internal`), or `"unavailable"` when the
 * request failed without a Twirp response
 *
 * @group Errors
 */
export class TwirpError extends ImandraXError {
  override name = "TwirpError";

  constructor(
    readonly code: string,
    readonly msg: string,
    readonly status: number | undefined,
    readonly meta: Readonly<Record<string, string>> = {},
    options?: { cause?: unknown },
  ) {
    super(status === undefined ? `${code}: ${msg}` : `${code} (HTTP ${status}): ${msg}`, options);
  }
}
