/**
 * Fetching task artifacts
 *
 * - artifacts are fetched on first use, once; what was fetched stays available after the client
 *   is closed, including what is derived from it
 * - fetching after the client is closed rejects with `ClientClosedError`, until the task gets
 *   another client with `setClient`
 */

import { describe, expect, test } from "vitest";

import {
  type Client,
  ClientClosedError,
  DB,
  type EvalSrcResponse,
  ProofObligationTask,
  ProofObligationTaskResult,
  type Task,
} from "../../lib/index.js";
import { mkClient, noApiKey } from "./setup.js";

const SRC = "theorem succ_gt x = x + 1 > x";

function theTask<T extends Task>(rsp: EvalSrcResponse, cls: abstract new (...args: any[]) => T): T {
  const ts = rsp.tasks.filter((t): t is T => t instanceof cls);
  expect(ts).toHaveLength(1);
  return ts[0]!;
}

/** Record the artifact kinds `client` fetches */
function recordFetches(client: Client): string[] {
  const fetched: string[] = [];
  const getArtifact = client.getArtifact.bind(client);
  client.getArtifact = (task, kind, options) => {
    fetched.push(kind);
    return getArtifact(task, kind, options);
  };
  return fetched;
}

describe.skipIf(noApiKey)("task fetching", () => {
  test("the same source in two sessions gives tasks with equal ids", async () => {
    await using c1 = await mkClient();
    await using c2 = await mkClient();
    const [r1, r2] = [await c1.evalSrc(SRC), await c2.evalSrc(SRC)];
    expect(r1.tasks.map((t) => String(t.id))).toEqual(r2.tasks.map((t) => String(t.id)));
    expect(r1.tasks[0]!.id.equals(r2.tasks[0]!.id)).toBe(true);

    const other = await c1.evalSrc("theorem other x = x + 2 > x");
    const ids = new Set(r1.tasks.map((t) => String(t.id)));
    expect(other.tasks.some((t) => ids.has(String(t.id)))).toBe(false);
  });

  test("fetching after the client is closed rejects", async () => {
    const client = await mkClient();
    const po = theTask(await client.evalSrc(SRC), ProofObligationTask);
    await client.close();
    await expect(po.proofObligation()).rejects.toBeInstanceOf(ClientClosedError);
    await expect(po.result()).rejects.toBeInstanceOf(ClientClosedError);
  });

  test("what was fetched stays available after the client is closed", async () => {
    const client = await mkClient();
    const po = theTask(await client.evalSrc(SRC), ProofObligationTask);
    const po_ = await po.proofObligation();
    const res = await po.result();
    await client.close();
    expect(await po.proofObligation()).toBe(po_);
    expect(await po.result()).toBe(res);
  });

  test("what is derived from a fetched artifact stays available", async () => {
    const client = await mkClient();
    const po = theTask(await client.evalSrc(SRC), ProofObligationTask);
    // fetches the `po_task` artifact, which `fromSym` and `db` are also decoded from
    await po.proofObligation();
    await client.close();
    expect(await po.fromSym()).toBe("succ_gt");
    expect(await po.db()).toBeInstanceOf(DB);
    // the result is in the `po_res` artifact, never fetched
    await expect(po.result()).rejects.toBeInstanceOf(ClientClosedError);
  });

  test("a task fetches with another client after setClient", async () => {
    let po: ProofObligationTask;
    {
      await using client = await mkClient();
      po = theTask(await client.evalSrc(SRC), ProofObligationTask);
    }
    const po_ = await po.proofObligation().catch(() => undefined);
    expect(po_).toBeUndefined();

    await using c2 = await mkClient();
    po.setClient(c2);
    const fetched = await po.proofObligation();
    expect(await po.proofObligation()).toBe(fetched);
    expect(await po.result()).toBeInstanceOf(ProofObligationTaskResult);
  });

  test("fetchAll fetches every artifact once", async () => {
    await using client = await mkClient();
    const po = theTask(await client.evalSrc(SRC), ProofObligationTask);
    const fetched = recordFetches(client);
    await po.fetchAll();
    await po.proofObligation();
    expect(await po.result()).toBeInstanceOf(ProofObligationTaskResult);
    expect(fetched.sort()).toEqual(["po_res", "po_task"]);
  });

  test("concurrent calls share one fetch", async () => {
    await using client = await mkClient();
    const po = theTask(await client.evalSrc(SRC), ProofObligationTask);
    const fetched = recordFetches(client);
    const [r1, r2] = await Promise.all([po.result(), po.result()]);
    expect(r1).toBe(r2);
    expect(fetched).toEqual(["po_res"]);
  });
});
