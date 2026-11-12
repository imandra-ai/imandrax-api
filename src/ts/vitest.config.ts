import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    projects: [
      {
        test: {
          name: "unit",
          include: ["test/**/*.test.ts"],
          exclude: ["test/integration/**"],
        },
      },
      {
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
