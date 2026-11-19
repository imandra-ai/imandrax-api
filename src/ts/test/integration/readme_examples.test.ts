/** Each README example, snapshotted in `test/readme/`, runs without throwing */

import { readdirSync } from "node:fs";

import { describe, test, vi } from "vitest";

import { apiKey, noApiKey } from "./setup.js";

const DIR = new URL("../readme/", import.meta.url);
const files = readdirSync(DIR).filter((f) => f.endsWith(".ts"));

describe.skipIf(noApiKey)("README examples", () => {
  test.each(files)("%s", async (file) => {
    // The examples read the key from the environment
    vi.stubEnv("IMANDRAX_API_KEY", apiKey);
    vi.spyOn(console, "log").mockImplementation(() => {});
    try {
      await import(new URL(file, DIR).href);
    } finally {
      vi.restoreAllMocks();
      vi.unstubAllEnvs();
    }
  });
});
