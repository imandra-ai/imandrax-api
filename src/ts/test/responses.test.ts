import { describe, expect, test } from "vitest";

import {
  Artifact,
  CodeSnippetResponse,
  DecompositionTask,
  ErrorInfo,
  EvalSrcResponse,
  EvaluationTask,
  InstanceResponse,
  NoClientError,
  ProofCheckTask,
  ProofObligationTask,
  Task,
  TestResponse,
  UnexpectedResponseError,
  VerifyResponse,
  taskOfRaw,
  type ArtifactSource,
} from "../lib/index.js";
import * as apiPb from "../lib/raw/proto/api.js";
import * as simplePb from "../lib/raw/proto/simple_api.js";
import * as taskPb from "../lib/raw/proto/task.js";

const { TaskKind } = taskPb;

function rawTask(id: string, kind: taskPb.TaskKind): taskPb.Task {
  return { id: { id }, kind };
}

const PO_TASK = rawTask("po1", TaskKind.TASK_CHECK_PO);

function model(src: string): simplePb.Model {
  return simplePb.Model.fromPartial({ mType: simplePb.ModelType.Counter_example, src });
}

describe("ErrorInfo", () => {
  test("unwraps the kind printed as an OCaml record", () => {
    const e = ErrorInfo.ofRaw({
      kind: '{ Kind.name = "TypeErr" }',
      msg: {
        msg: "bad type",
        locs: [{ file: "a.iml", start: { line: 1, col: 2 }, stop: { line: 3, col: 4 } }],
        backtrace: undefined,
      },
      stack: [{ msg: "context", locs: [] }],
      process: undefined,
    });
    expect(e.kind).toBe("TypeErr");
    expect(String(e)).toBe("TypeErr: bad type");
    expect(String(e.message.locations[0])).toBe("a.iml:1:2-3:4");
    expect(e.stack.map(String)).toEqual(["context"]);
    expect(e.process).toBeUndefined();
  });

  test("keeps other kinds as they are", () => {
    expect(ErrorInfo.ofRaw({ kind: "Other", msg: undefined, stack: [] }).kind).toBe("Other");
  });
});

describe("VerifyResponse", () => {
  test.each([
    [{ proved: { proofPp: "pp" } }, "proved", { proved: true, refuted: false, proofPp: "pp" }],
    [{ proved: {} }, "proved", { proved: true, proofPp: undefined }],
    [{ refuted: { model: model("x = 1") } }, "refuted", { proved: false, refuted: true }],
    [{ unknown: { msg: "?" } }, "unknown", { message: "?" }],
    [{ verifiedUpto: { msg: "up to 10" } }, "verifiedUpto", { message: "up to 10" }],
    [{ err: {} }, "err", { proved: false, refuted: false, message: undefined }],
    [{}, undefined, { proved: false, refuted: false }],
  ] as const)("%j is %s", (res, outcome, getters) => {
    const r = VerifyResponse.ofRaw(simplePb.VerifyRes.fromPartial({ ...res, task: PO_TASK }));
    expect(r.outcome).toBe(outcome);
    expect(r).toMatchObject(getters);
    expect(r.task).toBeInstanceOf(ProofObligationTask);
  });

  test("the counter-example", () => {
    const r = VerifyResponse.ofRaw(simplePb.VerifyRes.fromPartial({ refuted: { model: model("x = 1") } }));
    expect(r.counterExample?.kind).toBe("counterExample");
    expect(String(r.counterExample)).toBe("x = 1");
    expect(r.counterExample?.model).toBeUndefined();
    expect(r.task).toBeUndefined();
  });

  test("a task of the wrong kind is an UnexpectedResponseError", () => {
    expect(() =>
      VerifyResponse.ofRaw(
        simplePb.VerifyRes.fromPartial({ task: rawTask("e", TaskKind.TASK_EVAL) }),
      ),
    ).toThrow(UnexpectedResponseError);
  });
});

describe("InstanceResponse and TestResponse", () => {
  test("sat", () => {
    const r = InstanceResponse.ofRaw(
      simplePb.InstanceRes.fromPartial({
        sat: { model: { ...model("x = 2"), mType: simplePb.ModelType.Instance } },
      }),
    );
    expect([r.outcome, r.found, r.instance?.kind, r.instance?.src]).toEqual(["sat", true, "instance", "x = 2"]);
  });

  test("unsat", () => {
    const r = InstanceResponse.ofRaw(simplePb.InstanceRes.fromPartial({ unsat: { proofPp: "pp" } }));
    expect([r.outcome, r.found, r.proofPp, r.instance]).toEqual(["unsat", false, "pp", undefined]);
  });

  test("counter-example", () => {
    const r = TestResponse.ofRaw(
      simplePb.TestRes.fromPartial({ counterExample: { model: model("x = 0") } }),
    );
    expect([r.outcome, r.refuted, r.counterExample?.src]).toEqual(["counterExample", true, "x = 0"]);
  });

  test("no counter-example is reported as err", () => {
    const r = TestResponse.ofRaw(simplePb.TestRes.fromPartial({ err: {} }));
    expect([r.outcome, r.refuted, r.counterExample]).toEqual(["err", false, undefined]);
  });

  test("an unknown model type is an UnexpectedResponseError", () => {
    expect(() =>
      TestResponse.ofRaw(
        simplePb.TestRes.fromPartial({ counterExample: { model: { src: "", mType: 7 as simplePb.ModelType } } }),
      ),
    ).toThrow(UnexpectedResponseError);
  });
});

describe("EvalSrcResponse", () => {
  test("maps tasks to their subclasses, and proof obligation results", () => {
    const r = EvalSrcResponse.ofRaw(
      simplePb.EvalRes.fromPartial({
        success: true,
        messages: ["m"],
        tasks: [
          PO_TASK,
          rawTask("e", TaskKind.TASK_EVAL),
          rawTask("d", TaskKind.TASK_DECOMP),
          rawTask("p", TaskKind.TASK_PROOF_CHECK),
          rawTask("u", TaskKind.TASK_UNSPECIFIED),
        ],
        poResults: [
          { proof: { proofPp: "pp" }, task: PO_TASK, origin: { fromSym: "thm", count: 2 } },
          { instance: { model: model("x = 1") }, task: PO_TASK },
          { testOk: {}, task: PO_TASK },
        ],
        evalResults: [{ success: true, valueAsOcaml: "3", errors: [] }],
        decompResults: [{ task: rawTask("d", TaskKind.TASK_DECOMP) }],
      }),
    );
    expect(r.messages).toEqual(["m"]);
    expect(r.tasks.map((t) => t.constructor)).toEqual([
      ProofObligationTask,
      EvaluationTask,
      DecompositionTask,
      ProofCheckTask,
      Task,
    ]);
    expect(r.tasks.map((t) => t.kind)).toEqual(["checkPo", "eval", "decomp", "proofCheck", "unspecified"]);

    const [proof, instance, testOk] = r.poResults;
    expect([proof!.outcome, proof!.proved, proof!.proofPp]).toEqual(["proof", true, "pp"]);
    expect([proof!.origin.fromSym, proof!.origin.count]).toEqual(["thm", 2]);
    expect([instance!.outcome, instance!.found, instance!.model?.src]).toEqual(["instance", true, "x = 1"]);
    expect([testOk!.outcome, testOk!.proved, testOk!.found]).toEqual(["testOk", false, false]);

    expect(r.evalResults[0]).toMatchObject({ success: true, asOcaml: "3" });
    expect(r.decompResults[0]!.task).toBeInstanceOf(DecompositionTask);
    expect(r.decompResults[0]!.success).toBe(false);
    expect(r.decompResults[0]!.decomposition).toBeUndefined();
  });

  test("a proof obligation result without a task is an UnexpectedResponseError", () => {
    expect(() =>
      EvalSrcResponse.ofRaw(simplePb.EvalRes.fromPartial({ poResults: [{ proof: {} }] })),
    ).toThrow(UnexpectedResponseError);
  });
});

test("CodeSnippetResponse", () => {
  const r = CodeSnippetResponse.ofRaw(
    apiPb.CodeSnippetEvalResult.fromPartial({ res: apiPb.EvalResult.EVAL_ERRORS, durationS: 0.5 }),
  );
  expect([r.res, r.durationS]).toEqual(["errors", 0.5]);
  expect(() =>
    CodeSnippetResponse.ofRaw(apiPb.CodeSnippetEvalResult.fromPartial({ res: 5 as apiPb.EvalResult })),
  ).toThrow(UnexpectedResponseError);
});

describe("Artifact", () => {
  test("decodeAs rejects unknown kinds", () => {
    const a = Artifact.ofRaw({ kind: "nope", data: new Uint8Array(), apiVersion: "v", storage: [] });
    expect(() => a.decodeAs(Object)).toThrow(UnexpectedResponseError);
  });

  test("keeps the storage by key", () => {
    const a = Artifact.ofRaw({
      kind: "show",
      data: new Uint8Array(),
      apiVersion: "v21",
      storage: [{ key: "k", value: new Uint8Array([1]) }],
    });
    expect([...a.storage.keys()]).toEqual(["k"]);
  });
});

describe("Task fetching", () => {
  /** An `ArtifactSource` answering from `answers`, counting the requests */
  function source(answers: (kind: string) => Promise<Artifact>) {
    const calls: string[] = [];
    const s: ArtifactSource = {
      getArtifact(_task, kind) {
        calls.push(kind);
        return answers(kind);
      },
    };
    return { s, calls };
  }

  const art = (kind: string) =>
    Artifact.ofRaw({ kind, data: new Uint8Array(), apiVersion: "v21", storage: [] });

  test("concurrent first calls share one request", async () => {
    const { s, calls } = source(async (kind) => art(kind));
    const t = taskOfRaw(PO_TASK, s);
    const [a, b] = await Promise.all([t.artifact(), t.artifact()]);
    expect(a).toBe(b);
    expect(await t.artifact()).toBe(a);
    expect(calls).toEqual(["po_task"]);
  });

  test("a failed request is retried by the next call", async () => {
    let fail = true;
    const { s, calls } = source(async (kind) => {
      if (fail) throw new Error("flaky");
      return art(kind);
    });
    const t = taskOfRaw(PO_TASK, s);
    await expect(t.artifact()).rejects.toThrow("flaky");
    fail = false;
    expect((await t.artifact()).kind).toBe("po_task");
    expect(calls).toEqual(["po_task", "po_task"]);
  });

  test("fetchAll fetches the data and the result", async () => {
    const { s, calls } = source(async (kind) => art(kind));
    await taskOfRaw(rawTask("e", TaskKind.TASK_EVAL), s).fetchAll();
    expect(calls.sort()).toEqual(["eval_res", "eval_task"]);
  });

  test("a task without a client rejects with NoClientError, until it gets one", async () => {
    const t = taskOfRaw(PO_TASK);
    await expect(t.artifact()).rejects.toBeInstanceOf(NoClientError);
    const { s } = source(async (kind) => art(kind));
    t.setClient(s);
    expect((await t.artifact()).kind).toBe("po_task");
  });

  test("a proof check task has no artifacts", async () => {
    const { s, calls } = source(async (kind) => art(kind));
    const t = taskOfRaw(rawTask("p", TaskKind.TASK_PROOF_CHECK), s);
    await expect(t.artifact()).rejects.toBeInstanceOf(UnexpectedResponseError);
    await expect(t.result()).rejects.toBeInstanceOf(UnexpectedResponseError);
    await t.fetchAll();
    expect(calls).toEqual([]);
  });

  test("a result of an unexpected kind is an UnexpectedResponseError", async () => {
    const { s } = source(async () => art("show"));
    await expect(taskOfRaw(PO_TASK, s).result()).rejects.toBeInstanceOf(UnexpectedResponseError);
  });

  test("a plain Task needs a kind without a subclass", () => {
    expect(() => new Task(PO_TASK)).toThrow(TypeError);
    expect(new Task(rawTask("u", TaskKind.TASK_UNSPECIFIED)).kind).toBe("unspecified");
  });

  test("tasks compare by id", () => {
    const a = taskOfRaw(PO_TASK);
    const b = taskOfRaw({ ...PO_TASK });
    expect(a.id.equals(b.id)).toBe(true);
    expect(String(a.id)).toBe("po1");
  });
});
