/** Each example in `examples/` runs without throwing */

import { readdirSync } from "node:fs";

import { describe, test, vi } from "vitest";

import { apiKey, noApiKey } from "./setup.js";

const EXAMPLES = new URL("../../examples/", import.meta.url);
const files = readdirSync(EXAMPLES).filter((f) => f.endsWith(".ts"));

describe.skipIf(noApiKey)("examples", () => {
  test.each(files)("%s", async (file) => {
    // Examples read the key from the environment
    vi.stubEnv("IMANDRAX_API_KEY", apiKey);
    vi.spyOn(console, "log").mockImplementation(() => {});
    try {
      await import(new URL(file, EXAMPLES).href);
    } finally {
      vi.restoreAllMocks();
      vi.unstubAllEnvs();
    }
  });
});
