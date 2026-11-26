import { fileURLToPath } from "node:url";

import { defineConfig } from "vitest/config";

export default defineConfig({
  resolve: {
    // The README examples (test/readme) import the package by name, as users do
    alias: { "@imandra/imandrax-api": fileURLToPath(new URL("./lib/index.ts", import.meta.url)) },
  },
  test: {
    // `toEqual` compares library objects by value
    setupFiles: ["test/equality.ts"],
    projects: [
      {
        extends: true,
        test: {
          name: "unit",
          include: ["test/**/*.test.ts"],
          exclude: ["test/integration/**"],
        },
      },
      {
        extends: true,
        test: {
          // run against the ImandraX server; needs IMANDRAX_API_KEY (or IMANDRA_UNI_KEY)
          name: "integration",
          include: ["test/integration/**/*.test.ts"],
          testTimeout: 120_000,
          hookTimeout: 120_000,
        },
      },
    ],
  },
});
