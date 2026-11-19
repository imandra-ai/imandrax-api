/**
 * Each `ts` block of the README is a copy of a file in `examples/`, named by the
 * `<!-- example: examples/<file> -->` line before it
 *
 * The examples are typechecked with the rest of the package, and run by the integration tests.
 */

import { readdirSync, readFileSync } from "node:fs";

import { describe, expect, test } from "vitest";

const ROOT = new URL("../", import.meta.url);
const README = readFileSync(new URL("README.md", ROOT), "utf8");

/** The README's `ts` blocks, with the example file each one is marked with, if any */
const blocks = [...README.matchAll(/(?:<!-- example: (\S+) -->\n)?```ts\n([\s\S]*?)```/g)].map((m) => ({
  file: m[1],
  code: m[2]!,
}));

describe("README examples", () => {
  test("every ts block names its example file", () => {
    expect(blocks.filter((b) => b.file === undefined).map((b) => b.code)).toEqual([]);
  });

  test("every example is in the README", () => {
    const files = readdirSync(new URL("examples/", ROOT))
      .filter((f) => f.endsWith(".ts"))
      .map((f) => `examples/${f}`);
    expect(blocks.map((b) => b.file).sort()).toEqual(files.sort());
  });

  test.each(blocks.filter((b) => b.file !== undefined))("$file matches the README", ({ file, code }) => {
    expect(code, `copy ${file} into the README`).toBe(readFileSync(new URL(file!, ROOT), "utf8"));
  });
});
