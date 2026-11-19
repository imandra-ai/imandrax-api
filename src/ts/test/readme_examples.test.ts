/**
 * Each `ts` block of the README is snapshotted to `readme/<name>.ts`, named by the
 * `<!-- example: <name> -->` line before it
 *
 * The snapshots are typechecked with the rest of the package, and run by the integration tests.
 * Run `npx vitest -u` to update them after editing the README.
 */

import { readdirSync, readFileSync } from "node:fs";

import { describe, expect, test } from "vitest";

const README = readFileSync(new URL("../README.md", import.meta.url), "utf8");

/** The README's `ts` blocks, with the name each one is marked with, if any */
const blocks = [...README.matchAll(/(?:<!-- example: (\S+) -->\n)?```ts\n([\s\S]*?)```/g)].map(
  (m) => ({
    name: m[1],
    code: m[2]!,
  }),
);

describe("README examples", () => {
  test("every ts block is named", () => {
    expect(blocks.filter((b) => b.name === undefined).map((b) => b.code)).toEqual([]);
  });

  test("every snapshot has a ts block", () => {
    const snapshots = readdirSync(new URL("readme/", import.meta.url)).map((f) =>
      f.replace(/\.ts$/, ""),
    );
    expect(snapshots.sort()).toEqual(blocks.map((b) => b.name).sort());
  });

  test.each(blocks.filter((b) => b.name !== undefined))("$name", async ({ name, code }) => {
    await expect(code).toMatchFileSnapshot(`readme/${name}.ts`);
  });
});
