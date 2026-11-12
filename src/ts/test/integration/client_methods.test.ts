import { describe, expect, test } from "vitest";

import {
  ArrowType,
  DecompositionTask,
  DecompositionTaskResult,
  ProofObligationTask,
  ServerError,
  decomp,
} from "../../lib/index.js";
import { noApiKey, sharedClient } from "./setup.js";

const SRC = `
let f x = if x > 0 then x + 1 else 0
let nonneg x = f x >= 0
`;

describe.skipIf(noApiKey)("client methods", () => {
  const client = sharedClient(SRC);

  // Session and server
  // ==================

  test("session and system", async () => {
    const c = client();
    expect(c.sessionId).toBeTruthy();
    expect(await c.keepSessionAlive()).toBeUndefined();
    expect((await c.version()).version).toBeTruthy();
    expect(await c.status()).toBe("OK");
  });

  // evalSrc
  // =======

  test("evalSrc with asyncOnly and taskFilter", async () => {
    const rsp = await client().evalSrc("theorem t1 x = x + 1 > x\ntheorem t2 x = x * 1 = x", {
      asyncOnly: true,
      taskFilter: ["t1"],
    });
    expect(rsp.success).toBe(true);
    const pos = rsp.tasks.filter((t) => t instanceof ProofObligationTask);
    expect(pos).toHaveLength(1);
    expect(await Promise.all(pos.map((po) => po.fromSym()))).toEqual(["t1"]);
    // not waited for with asyncOnly
    expect(rsp.poResults).toEqual([]);
  });

  test("evalSrc proof obligation results", async () => {
    const src = "theorem good x = x + 1 > x\ntheorem bad x = x > 0";
    const [good, bad] = (await client().evalSrc(src)).poResults;

    expect(good!.origin.fromSym).toBe("good");
    expect(good!.res?.kind).toBe("proof");
    expect(good!.outcome).toBe("proof");
    expect(good!.errors).toEqual([]);

    expect(bad!.origin.fromSym).toBe("bad");
    expect(bad!.outcome).toBe("instance");
    const cx = bad!.model;
    expect(cx?.kind).toBe("counterExample");
    expect(cx?.src).toContain("x = 0");
    expect(bad!.errors).toHaveLength(1);
    expect(String(bad!.errors[0])).toContain("counter-satisfiable");
  });

  // Verify, instance and test
  // =========================

  test("verifyName proved", async () => {
    const r = await client().verifyName("nonneg");
    expect(r.outcome).toBe("proved");
    expect([r.proved, r.refuted]).toEqual([true, false]);
    expect(r.counterExample).toBeUndefined();
    expect(r.errors).toEqual([]);
  });

  test("verifySrc refuted", async () => {
    const r = await client().verifySrc("fun x -> f x > 0");
    expect(r.outcome).toBe("refuted");
    expect([r.refuted, r.proved]).toEqual([true, false]);
    expect(r.proofPp).toBeUndefined();
    const cx = r.counterExample;
    expect(cx?.kind).toBe("counterExample");
    expect(cx?.src).toContain("x = 0");
    expect(cx?.model).toBeDefined();
  });

  test("instanceSrc sat", async () => {
    const r = await client().instanceSrc("fun x -> f x = 5");
    expect(r.outcome).toBe("sat");
    expect(r.found).toBe(true);
    expect(r.instance?.kind).toBe("instance");
    expect(r.instance?.src).toContain("x = 4");
    expect(r.instance?.model).toBeDefined();
  });

  test("instanceSrc unsat", async () => {
    const r = await client().instanceSrc("fun x -> f x < 0");
    expect(r.outcome).toBe("unsat");
    expect(r.found).toBe(false);
    expect(r.instance).toBeUndefined();
  });

  test("instanceName", async () => {
    expect((await client().instanceName("nonneg")).found).toBe(true);
  });

  test("testSrc counter-example", async () => {
    const r = await client().testSrc("fun x -> f x > 0", { seed: 1 });
    expect(r.outcome).toBe("counterExample");
    expect(r.counterExample?.src).toContain("x = 0");
  });

  test("testName without a counter-example", async () => {
    const r = await client().testName("nonneg", { seed: 1 });
    expect(r.res).toEqual({ kind: "err" });
    expect(r.outcome).toBe("err");
    expect(r.counterExample).toBeUndefined();
    expect(r.errors.map((e) => e.kind)).toEqual(["NoCounterExample"]);
  });

  test("verifySrc of ill-typed source creates no task", async () => {
    const r = await client().verifySrc("fun x -> f x + true");
    expect(r.task).toBeUndefined();
    expect(r.errors.map((e) => e.kind)).toEqual(["TypeErr"]);
  });

  // Decomposition
  // =============

  test("decompose", async () => {
    const r = await client().decompose("f");
    expect(r.errors).toEqual([]);
    expect(r.task).toBeDefined();
    expect(r.artifact?.kind).toBe("mir.fun_decomp");
    // two regions for `if x > 0 then x + 1 else 0`
    expect(r.decomposition?.regions).toHaveLength(2);
  });

  test("decompose an unknown name creates no task", async () => {
    const r = await client().decompose("no_such_fn");
    expect(r.task).toBeUndefined();
    expect(r.artifact).toBeUndefined();
    expect(r.errors.map((e) => e.kind)).toEqual(["DecompError"]);
  });

  test("decomposeFull", async () => {
    const r = await client().decomposeFull(decomp.prune(decomp.byName("f")));
    expect(r.errors).toEqual([]);
    expect(r.artifact).toBeDefined();
  });

  test("decomposeFull from an artifact", async () => {
    const c = client();
    const art = (await c.decompose("f")).artifact!;
    const tasks = (await c.evalSrc("let g x = if x > 0 then 1 else 2\n[@@decomp top ()]")).tasks;
    const [task] = tasks.filter((t) => t instanceof DecompositionTask);
    const res = await task!.result();
    expect(res).toBeInstanceOf(DecompositionTaskResult);

    for (const a of [art.raw, art, res]) {
      const r = await c.decomposeFull(decomp.fromArtifact(a));
      expect(r.errors).toEqual([]);
      expect(r.artifact).toBeDefined();
    }
  });

  // Source and lookups
  // ==================

  test("typecheck", async () => {
    const r = await client().typecheck("let g y = y + 1");
    expect(r.success).toBe(true);
    expect(r.types).toEqual([{ name: "g", ty: "int -> int", line: 1, column: 1 }]);
  });

  test("typecheck error", async () => {
    const r = await client().typecheck("let g y = y + true");
    expect(r.success).toBe(false);
    expect(r.errors.length).toBeGreaterThan(0);
  });

  test("oneshot", async () => {
    const r = await client().oneshot("let h = 1");
    expect(r.errors).toEqual([]);
    expect(r.results).toHaveLength(1);
    expect(r.timeS).toBeGreaterThanOrEqual(0);
  });

  test("evalCodeSnippet", async () => {
    const r = await client().evalCodeSnippet("theorem snippet_thm x = f x >= 0");
    expect(r.res).toBe("ok");
    expect(r.errors).toEqual([]);
    // its result may not be available yet, as with asyncOnly
    const pos = r.tasks.filter((t) => t instanceof ProofObligationTask);
    expect(pos).toHaveLength(1);
    expect(await pos[0]!.fromSym()).toBe("snippet_thm");
  });

  test.each([
    ["syntax error", "let = ", "errors", "SyntaxErr"],
    // the server reports type errors with status "ok", but a non-empty error list
    ["type error", "let bad = 1 + true", "ok", "TypeErr"],
  ] as const)("evalCodeSnippet with a %s", async (_name, code, res, kind) => {
    const r = await client().evalCodeSnippet(code);
    expect(r.res).toBe(res);
    expect(r.errors).toHaveLength(1);
    expect(String(r.errors[0])).toContain(kind);
  });

  test("parseTerm", async () => {
    const t = await client().parseTerm("f 3 + 1");
    expect(t.kind).toBe("apply");
  });

  test("parseType", async () => {
    expect(await client().parseType("int -> bool")).toBeInstanceOf(ArrowType);
  });

  test("parseTerm of an ill-typed term throws", async () => {
    const err = await client().parseTerm("1 + true").catch((e: unknown) => e);
    expect(err).toBeInstanceOf(ServerError);
    expect(String(err)).toContain("expected argument of type `int`");
  });

  // Artifacts
  // =========

  test("list and get artifacts", async () => {
    const c = client();
    const task = (await c.verifyName("nonneg")).task!;
    expect(new Set(await c.listArtifacts(task))).toEqual(new Set(["po_res", "po_task", "report", "show"]));

    const art = await c.getArtifact(task, "po_res");
    expect(art.kind).toBe("po_res");

    const zip = await c.getArtifactZip(task, "po_res");
    // a zip archive (`PK` signature) naming its manifest
    expect([zip[0], zip[1]]).toEqual([0x50, 0x4b]);
    expect(new TextDecoder().decode(zip)).toContain("manifest.json");
  });
});
