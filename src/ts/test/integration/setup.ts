/**
 * Clients shared by the integration tests
 *
 * They run against `urlProd` with the API key in `IMANDRAX_API_KEY` (or `IMANDRA_UNI_KEY`), and
 * are skipped without one.
 */

import { afterAll, beforeAll } from "vitest";

import { Client, urlProd } from "../../lib/index.js";

export const apiKey: string | undefined =
  process.env.IMANDRAX_API_KEY || process.env.IMANDRA_UNI_KEY || undefined;

/** Whether the integration tests have no API key to run with */
export const noApiKey = apiKey === undefined;

export function mkClient(): Promise<Client> {
  return Client.connect(apiKey === undefined ? { url: urlProd } : { url: urlProd, apiKey });
}

/**
 * A client shared by the tests of a file, with `src` loaded, if given
 *
 * Call it at the top level of a test file; the returned getter gives the client inside tests.
 */
export function sharedClient(src?: string): () => Client {
  let client: Client | undefined;
  beforeAll(async () => {
    if (noApiKey) return;
    client = await mkClient();
    if (src !== undefined) {
      const res = await client.evalSrc(src);
      if (!res.success) throw new Error(`loading the test source failed: ${res.errors.join("\n")}`);
    }
  });
  afterAll(async () => {
    await client?.close();
  });
  return () => {
    if (client === undefined) throw new Error("no client: is IMANDRAX_API_KEY set?");
    return client;
  };
}
