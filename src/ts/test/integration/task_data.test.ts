/**
 * Test the validity of task data and task result data
 * - task data: matches the IML it comes from, and the uids it refers to are defined in the task's DB
 * - task result data: is consistent with the task data, e.g. a model gives values to the goal's
 *   variables, at their types
 */

import { assert, describe, expect, test } from "vitest";

import {
  Apply,
  type DB,
  DecompositionRequest,
  DecompositionTask,
  DecompositionTaskResult,
  DefaultTheoremTactic,
  EvaluationTask,
  EvaluationTaskResult,
  type Model,
  ProofObligationTask,
  ProofObligationTaskResult,
  Symbol,
  type Task,
  type Term,
  TermTactic,
  type Type,
  type Uid,
  Var,
  type Variable,
  uidMap,
  uidSet,
} from "../../lib/index.js";
import { noApiKey, once, sharedClient, theTask } from "./setup.js";

const SRC = `
let f (xs: int list) : int list = List.map (fun x -> x + 1) xs
[@@decomp top ~prune:false () |>> prune]

eval (1 + 2)
theorem thm1 (xs: int list) = f xs = List.map (fun x -> x + 1) xs
instance (fun (xs: int list) (y: int) -> f xs <> List.map (fun x -> x + y) xs)
`;

// Helpers
// ====================

/** `x` printed, with content hashes replaced by `<hash>` */
function str(x: unknown): string {
  return `${x}`.replace(/\/[A-Za-z0-9_-]{43}/g, "/<hash>");
}

async function thePo(tasks: readonly Task[], isInstance: boolean): Promise<ProofObligationTask> {
  const ts: ProofObligationTask[] = [];
  for (const t of tasks) {
    if (t instanceof ProofObligationTask && (await t.proofObligation()).isInstance === isInstance) {
      ts.push(t);
    }
  }
  expect(ts).toHaveLength(1);
  return ts[0]!;
}

/** The ids of the variables `t` uses */
function varsIn(t: Term): ReadonlySet<Uid> {
  return uidSet([...t].filter((x): x is Var => x instanceof Var).map((x) => x.var.id));
}

function idsOf(vs: Iterable<Variable>): ReadonlySet<Uid> {
  return uidSet([...vs].map((v) => v.id));
}

/** The types `model` gives its constants, and those of their values, by uid */
function modelTypes(model: Model): {
  constants: ReadonlyMap<Uid, Type>;
  values: ReadonlyMap<Uid, Type>;
} {
  return {
    constants: uidMap([...model.constants.keys()].map((s) => [s.id, s.type])),
    values: uidMap([...model.constants].map(([s, v]) => [s.id, v.type])),
  };
}

/** `t` refers to at least one symbol, all declared in `db` */
function expectSymbolsDeclaredIn(t: Term, db: DB): void {
  const uids = uidSet(
    [...t].filter((x): x is Symbol => x instanceof Symbol).map((x) => x.symbol.id),
  );
  expect(uids.size, "Term should refer to at least one symbol").toBeGreaterThan(0);
  expect([...uids].filter((u) => db.findDeclaration(u) === undefined).map(String)).toEqual([]);
}

describe.skipIf(noApiKey)("task data", () => {
  const client = sharedClient();

  const tasks = once(async (): Promise<readonly Task[]> => {
    const evalRes = await client().evalSrc(SRC);
    expect(evalRes.success, evalRes.errors.join("\n")).toBe(true);
    return evalRes.tasks;
  });

  test("task kinds", async () => {
    const counts = new Map<string, number>();
    for (const t of await tasks()) {
      counts.set(t.constructor.name, (counts.get(t.constructor.name) ?? 0) + 1);
    }
    expect(counts).toEqual(
      new Map([
        ["ProofObligationTask", 2],
        ["EvaluationTask", 1],
        ["DecompositionTask", 1],
      ]),
    );
  });

  // Evaluation
  // ==========

  test("evaluation task", async () => {
    // `eval (1 + 2)`
    const t = theTask(await tasks(), EvaluationTask);
    expect(await t.variables()).toEqual([]);

    const term = await t.term();
    assert.instanceOf(term, Apply);
    expect(str(term.type)).toBe("int");
    expect(str(term.function)).toBe("+");
    expect(term.arguments.map(str)).toEqual(["1", "2"]);

    const res = await t.result();
    assert.instanceOf(res, EvaluationTaskResult);
    expect(res.value).toMatchObject({ kind: "int", value: 3n });
  });

  // Proof obligations
  // =================

  test("theorem", async () => {
    // `theorem thm1 (xs: int list) = f xs = List.map (fun x -> x + 1) xs`
    const t = await thePo(await tasks(), false);
    expect(await t.fromSym()).toBe("thm1");

    const po = await t.proofObligation();
    expect(po).toMatchObject({
      description: "prove theorem thm1",
      isInstance: false,
      timeout: undefined,
      upto: undefined,
      verifyKind: "verify",
      namedHypotheses: [],
    });
    const [vars, goal] = po.goal;
    expect(vars.map(str)).toEqual(["xs"]);
    expect(str(goal)).toBe("(= (f/<hash> xs) (List.map/<hash> $lambda/<hash> xs))");
    assert.instanceOf(po.tactic, TermTactic);
    expect(po.tactic.variables.map(str)).toEqual(["_x_0"]);
    expect(str(po.tactic.term)).toBe("(Tactic.default _x_0)");

    expect(varsIn(goal), "PO goal should have no free or unused variables").toEqual(idsOf(vars));
    expectSymbolsDeclaredIn(goal, await t.db());

    const res = await t.result();
    assert.instanceOf(res, ProofObligationTaskResult);
    expect(res.result.kind).toBe("proofFound");
    expect(res.proved).toBe(true);
    expect(res.model, "A proved theorem should have no counter-model").toBeUndefined();
  });

  test("instance", async () => {
    // `instance (fun (xs: int list) (y: int) -> f xs <> List.map (fun x -> x + y) xs)`
    const t = await thePo(await tasks(), true);
    expect(await t.fromSym()).toBe("_instance_7_1");

    const po = await t.proofObligation();
    expect(po).toMatchObject({
      description: "prove verify statement _instance_7_1",
      isInstance: true,
      timeout: undefined,
      upto: undefined,
      verifyKind: "instance",
      namedHypotheses: [],
    });
    const [vars, goal] = po.goal;
    expect(vars.map(str)).toEqual(["xs", "y"]);
    expect(str(goal)).toBe("(<> (f/<hash> xs) (List.map/<hash> ($lambda/<hash> y) xs))");
    assert.instanceOf(po.tactic, DefaultTheoremTactic);
    expect(po.tactic).toMatchObject({ maxSteps: 100, upto: undefined });

    expect(varsIn(goal), "PO goal should have no free or unused variables").toEqual(idsOf(vars));
    expectSymbolsDeclaredIn(goal, await t.db());

    const res = await t.result();
    assert.instanceOf(res, ProofObligationTaskResult);
    expect(res.found).toBe(true);
    expect(res.proved).toBe(false);
    expect(res.result.kind).toBe("instance");

    assert.isDefined(res.model);
    const goalTypes = uidMap(vars.map((v) => [v.id, v.type]));
    const { constants, values } = modelTypes(res.model);
    expect(constants, "Model should give values to exactly the goal's variables").toEqual(
      goalTypes,
    );
    expect(values, "Each model value should have its variable's type").toEqual(goalTypes);
  });

  // Decomposition
  // =============

  test("decomposition", async () => {
    // `[@@decomp top ~prune:false () |>> prune]` on `f`
    const t = theTask(await tasks(), DecompositionTask);
    const db = await t.db();

    // A pipeline is requested as the term that computes it: `(top ...) |>> prune` applied to `f`
    const req = await t.decomp();
    assert.instanceOf(req, DecompositionRequest.Term);
    const term = req.term;
    assert.instanceOf(term, Apply);
    expect(str(term.type)).toBe("Decomp.t string result");
    expect(str(term.function)).toBe("Decomp.|>>/<hash>");
    expect(term.arguments.map(str)).toEqual([
      "(Decomp.top None None None Some false None None ())",
      "Decomp.prune",
      "f",
    ]);
    expectSymbolsDeclaredIn(term, db);

    const res = await t.result();
    assert.instanceOf(res, DecompositionTaskResult);
    expect(res.error, String(res.error)).toBeUndefined();
    const d = res.decomposition;
    assert.isDefined(d);
    expect(str(d.id)).toBe("f/<hash>");
    expect(d.arguments.map(str)).toEqual(["xs"]);
    // `List.map` is not unrolled: a single region, over `f`'s arguments
    expect(d.regions.map(str)).toEqual([
      "constraints: [true] invariant: (List.map/<hash> $lambda/<hash> xs) status: feasible",
    ]);

    const fDef = db.findFunction(d.id);
    assert.isDefined(fDef);
    expect(d.arguments, "Decomp arguments should be the decomposed function's arguments").toEqual(
      fDef.arguments,
    );

    const region = d.regions[0]!;
    expect(
      [...idsOf(d.arguments)],
      "Region invariant should only use the decomposition's arguments",
    ).toEqual(expect.arrayContaining([...varsIn(region.invariant)]));

    // A feasible region comes with a model of `f`'s arguments
    expect(region.status.kind).toBe("feasible");
    assert.isDefined(region.model);
    expect(
      modelTypes(region.model).constants,
      "Region model should give values to exactly f's arguments, at their types",
    ).toEqual(uidMap(d.arguments.map((a) => [a.id, a.type])));
  });

  // Across tasks
  // ============

  test("tasks agree on uids", async () => {
    // Within a session, `f` is the same uid in every task that refers to it
    const res = await theTask(await tasks(), DecompositionTask).result();
    assert.instanceOf(res, DecompositionTaskResult);
    assert.isDefined(res.decomposition);
    for (const isInstance of [false, true]) {
      const [, goal] = (await (await thePo(await tasks(), isInstance)).proofObligation()).goal;
      assert.instanceOf(goal, Apply);
      const fXs = goal.arguments[0];
      assert.instanceOf(fXs, Apply);
      assert.instanceOf(fXs.function, Symbol);
      expect(
        fXs.function.symbol.id,
        "f should have the same uid in the PO goal and in the decomposition",
      ).toEqual(res.decomposition.id);
    }
  });
});
