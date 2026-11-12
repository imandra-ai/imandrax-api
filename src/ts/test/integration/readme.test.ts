/** The README's example runs, and prints what its comments say */

import { mkdtempSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

import { describe, expect, test, vi } from "vitest";

import { noApiKey } from "./setup.js";

const README = fileURLToPath(new URL("../../README.md", import.meta.url));
const LIB = pathToFileURL(fileURLToPath(new URL("../../lib/index.js", import.meta.url))).href;

/** The first `ts` code block of the README */
function example(): string {
  const m = /```ts\n([\s\S]*?)```/.exec(readFileSync(README, "utf8"));
  if (m === null) throw new Error("no ts example in the README");
  return m[1]!;
}

describe.skipIf(noApiKey)("README", () => {
  test("the example runs", async () => {
    const dir = mkdtempSync(join(tmpdir(), "imandrax-readme-"));
    const file = join(dir, "example.ts");
    writeFileSync(file, `${example().replaceAll('"imandrax-api"', JSON.stringify(LIB))}\nexport {};\n`);

    const logged: unknown[][] = [];
    const log = vi.spyOn(console, "log").mockImplementation((...args) => {
      logged.push(args);
    });
    try {
      await import(pathToFileURL(file).href);
    } finally {
      log.mockRestore();
    }

    expect(logged[0]).toEqual(["f_nonneg", "proof"]);
    expect(logged[1]![0]).toBe("refuted");
    expect(logged[1]![1]).toContain("x = 0");
    expect(logged[2]).toEqual([2]);
    expect(logged[3]).toEqual([true]);
  });
});
