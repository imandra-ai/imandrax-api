/**
 * Test the validity of task data and task result data
 * - task data: matches the IML it comes from, and the uids it refers to are defined in the task's DB
 * - task result data: is consistent with the task data, e.g. a model gives values to the goal's
 *   variables, at their types
 */

import { describe, expect, test } from "vitest";

import {
  AppliedSymbol,
  Apply,
  BuiltinFunction,
  BuiltinSort,
  type DB,
  Decomposition,
  DecompositionRequest,
  DecompositionTask,
  DecompositionTaskResult,
  EvaluationTask,
  EvaluationTaskResult,
  FunctionDefinition,
  InstantiationRule,
  type Model,
  type ProofObligation,
  ProofObligationTask,
  ProofObligationTaskResult,
  Symbol,
  type Task,
  type Term,
  TermBase,
  type Type,
  TypeBase,
  TypeDefinition,
  Uid,
  Var,
  Variable,
  Verify,
  uidMap,
  uidSet,
} from "../../lib/index.js";
import { noApiKey, sharedClient } from "./setup.js";

const SRC = `
let f (xs: int list) : int list = List.map (fun x -> x + 1) xs
[@@decomp top ~prune:false () |>> prune]

eval (1 + 2)
theorem thm1 (xs: int list) = f xs = List.map (fun x -> x + 1) xs
instance (fun (xs: int list) (y: int) -> f xs <> List.map (fun x -> x + y) xs)
`;

// Setup
// ====================

/** `f()`, computed once, on first use (as a module-scoped pytest fixture) */
function once<T>(f: () => Promise<T>): () => Promise<T> {
  let p: Promise<T> | undefined;
  return () => (p ??= f());
}

function getTheTask<T extends Task>(tasks: readonly Task[], cls: abstract new (...args: any[]) => T): T {
  const ts = tasks.filter((t): t is T => t instanceof cls);
  expect(ts).toHaveLength(1);
  return ts[0]!;
}

async function getThePo(tasks: readonly Task[], isInstance: boolean): Promise<ProofObligationTask> {
  const ts: ProofObligationTask[] = [];
  for (const t of tasks) {
    if (t instanceof ProofObligationTask && (await t.proofObligation()).isInstance === isInstance) {
      ts.push(t);
    }
  }
  expect(ts).toHaveLength(1);
  return ts[0]!;
}

/** The variables of `t`'s subterms; a set of their ids, since variables are equal when their ids are */
function varsInSubterms(t: Term): ReadonlySet<Uid> {
  return uidSet([...t].filter((x): x is Var => x instanceof Var).map((x) => x.var.id));
}

function idsOf(vs: Iterable<Variable>): ReadonlySet<Uid> {
  return uidSet([...vs].map((v) => v.id));
}

function setEq(a: ReadonlySet<Uid>, b: ReadonlySet<Uid>): boolean {
  return a.size === b.size && [...a].every((x) => b.has(x));
}

function isSubset(a: ReadonlySet<Uid>, b: ReadonlySet<Uid>): boolean {
  return [...a].every((x) => b.has(x));
}

/** Equal maps of uids to types, as Python compares `dict[Uid, Type]` */
function sameTypes(a: ReadonlyMap<Uid, Type>, b: ReadonlyMap<Uid, Type>): boolean {
  return a.size === b.size && [...a].every(([u, t]) => b.get(u)?.equals(t) === true);
}

/** `t` refers to at least one symbol, all declared in `db` */
function assertSymbolsDefinedInDb(t: Term, db: DB): void {
  const uids = uidSet([...t].filter((x): x is Symbol => x instanceof Symbol).map((x) => x.symbol.id));
  expect(uids.size, "Term should refer to at least one symbol").toBeGreaterThan(0);
  for (const u of uids) {
    expect(db.findDeclaration(u), `${u} is not declared in the DB`).toBeDefined();
  }
}

/** Python's `repr` of a string */
function pyStrRepr(s: string): string {
  const q = s.includes("'") && !s.includes('"') ? '"' : "'";
  const body = s.replace(/\\/g, "\\\\").replace(/\n/g, "\\n").replace(new RegExp(q, "g"), `\\${q}`);
  return `${q}${body}${q}`;
}

/** Classes whose `kind` is a field of their own, not the TS-only discriminant of a union */
function kindIsField(x: object): boolean {
  return (
    x instanceof FunctionDefinition ||
    x instanceof TypeDefinition ||
    x instanceof Verify ||
    x instanceof InstantiationRule ||
    x instanceof BuiltinFunction ||
    x instanceof BuiltinSort
  );
}

/** The fields Python's dataclass repr shows: all but `raw`, and the TS-only `kind` discriminant */
function reprFields(x: object): [string, unknown][] {
  return Object.entries(x).filter(([k]) => k !== "raw" && (k !== "kind" || kindIsField(x)));
}

/** Whether `x` stands for a Python dataclass, whose fields `ctorRepr` can expand */
function isDataclass(x: unknown): x is object {
  return (
    typeof x === "object" &&
    x !== null &&
    !Array.isArray(x) &&
    !(x instanceof Map) &&
    !(x instanceof Set) &&
    !(x instanceof Uid) &&
    Object.getPrototypeOf(x) !== Object.prototype
  );
}

/**
 * Python's `repr`, for the values in these tests
 *
 * Uids, types, terms, variables, applied symbols, type and function definitions and regions have a
 * custom `repr`, `<Class str>`; other dataclasses show their fields.
 */
function pyRepr(x: unknown): string {
  if (x === undefined || x === null) return "None";
  if (typeof x === "boolean") return x ? "True" : "False";
  if (typeof x === "string") return pyStrRepr(x);
  if (typeof x === "number" || typeof x === "bigint") return `${x}`;
  if (Array.isArray(x)) {
    return x.length === 1 ? `(${pyRepr(x[0])},)` : `(${x.map(pyRepr).join(", ")})`;
  }
  if (
    x instanceof Uid ||
    x instanceof TypeBase ||
    x instanceof TermBase ||
    x instanceof Variable ||
    x instanceof AppliedSymbol ||
    x instanceof TypeDefinition ||
    x instanceof FunctionDefinition ||
    x instanceof Decomposition.Region
  ) {
    return `<${x.constructor.name} ${x}>`;
  }
  if (isDataclass(x)) {
    return `${x.constructor.name}(${reprFields(x)
      .map(([k, v]) => `${k}=${pyRepr(v)}`)
      .join(", ")})`;
  }
  return `${x}`;
}

/**
 * Constructor-style repr of a dataclass, expanding `depth` levels of fields
 *
 * Laid out like ruff format: a node stays on one line if it fits in `width` columns,
 * otherwise it gets one field per line. Unexpanded values are shown with `leaf`.
 */
function ctorRepr_(
  x: unknown,
  depth: number = 1,
  width: number = 80,
  leaf: (x: unknown) => string = pyRepr,
): string {
  if (Array.isArray(x)) {
    const elems = x.map((e) => ctorRepr_(e, depth, width - 4, leaf));
    return layout("(", elems, ")", width, x.length === 1);
  }
  if (depth <= 0 || !isDataclass(x)) {
    return leaf(x);
  }
  const elems = reprFields(x).map(
    ([name, v]) => `${name}=${ctorRepr_(v, depth - 1, width - 5 - name.length, leaf)}`,
  );
  return layout(`${x.constructor.name}(`, elems, ")", width);
}

function layout(open: string, elems: string[], close: string, width: number, singleton = false): string {
  if (elems.length === 0) {
    return open + close;
  }
  const flat = `${open}${elems.join(", ")}${singleton ? "," : ""}${close}`;
  if (flat.length <= width && !flat.includes("\n")) {
    return flat;
  }
  // as Python's `textwrap.indent`, which leaves blank lines alone
  const indent = (e: string) =>
    e
      .split("\n")
      .map((l) => (l.trim() === "" ? l : `    ${l}`))
      .join("\n");
  const body = elems.map(indent).join(",\n");
  return `${open}\n${body},\n${close}`;
}

const HASH = /\/[A-Za-z0-9_-]{43}/g;

/** `ctorRepr_` with hash normalized */
function ctorRepr(x: unknown, depth: number = 1): string {
  return ctorRepr_(x, depth, 80, (v) => pyRepr(v).replace(HASH, "/<hash>"));
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
    const t = getTheTask(await tasks(), EvaluationTask);
    expect(await t.variables()).toEqual([]);

    const term = await t.term();
    expect(term).toBeInstanceOf(Apply);
    expect(ctorRepr_(term)).toBe(
      `\
Apply(
    type=<ConstructedType int>,
    function=<Symbol +>,
    arguments=(<Constant 1>, <Constant 2>),
)`,
    );

    const res = await getTheTask(await tasks(), EvaluationTask).result();
    expect(res).toBeInstanceOf(EvaluationTaskResult);
    expect(pyRepr((res as EvaluationTaskResult).value)).toBe("Int(value=3)");
  });

  // Proof obligations
  // =================

  test("theorem", async () => {
    // `theorem thm1 (xs: int list) = f xs = List.map (fun x -> x + 1) xs`
    const t: ProofObligationTask = await getThePo(await tasks(), false);
    expect(await t.fromSym()).toBe("thm1");

    const po: ProofObligation = await t.proofObligation();
    // TS field names are camelCase, and `verifyKind` is the string `'verify'` where Python shows
    // `<VerifyKind.VERIFY: 'verify'>`
    expect(ctorRepr(po)).toBe(
      `\
ProofObligation(
    description='prove theorem thm1',
    goal=(
        (<Variable xs>,),
        <Apply (= (f/<hash> xs) (List.map/<hash> $lambda/<hash> xs))>,
    ),
    tactic=TermTactic(variables=(<Variable _x_0>,), term=<Apply (Tactic.default _x_0)>),
    isInstance=False,
    timeout=None,
    upto=None,
    verifyKind='verify',
    namedHypotheses=(),
)`,
    );

    const [vars, goal] = po.goal;
    expect(setEq(varsInSubterms(goal), idsOf(vars)), "PO goal should have no free or unused variables").toBe(
      true,
    );
    assertSymbolsDefinedInDb(goal, await t.db());

    const res = await t.result();
    expect(res).toBeInstanceOf(ProofObligationTaskResult);
    const r = res as ProofObligationTaskResult;
    expect(r.result.kind).toBe("proofFound");
    expect(r.proved).toBe(true);
    expect(r.model, "A proved theorem should have no counter-model").toBeUndefined();
  });

  test("instance", async () => {
    // `instance (fun (xs: int list) (y: int) -> f xs <> List.map (fun x -> x + y) xs)`
    const t = await getThePo(await tasks(), true);
    expect(await t.fromSym()).toBe("_instance_7_1");
    const po = await t.proofObligation();
    // TS field names are camelCase, and `verifyKind` is the string `'instance'` where Python shows
    // `<VerifyKind.INSTANCE: 'instance'>`
    expect(ctorRepr(po)).toBe(
      `\
ProofObligation(
    description='prove verify statement _instance_7_1',
    goal=(
        (<Variable xs>, <Variable y>),
        <Apply (<> (f/<hash> xs) (List.map/<hash> ($lambda/<hash> y) xs))>,
    ),
    tactic=DefaultTheoremTactic(maxSteps=100, upto=None),
    isInstance=True,
    timeout=None,
    upto=None,
    verifyKind='instance',
    namedHypotheses=(),
)`,
    );

    const [vars, goal] = po.goal;
    expect(setEq(varsInSubterms(goal), idsOf(vars)), "PO goal should have no free or unused variables").toBe(
      true,
    );
    assertSymbolsDefinedInDb(goal, await t.db());

    const res = await t.result();
    expect(res).toBeInstanceOf(ProofObligationTaskResult);
    const r = res as ProofObligationTaskResult;
    expect(r.found).toBe(true);
    expect(r.proved).toBe(false);
    expect(r.result.kind).toBe("instance");

    const model: Model | undefined = r.model;
    expect(model).toBeDefined();

    const goalVarTypes = uidMap<Type>(vars.map((v) => [v.id, v.type]));
    const modelVarTypes = uidMap<Type>([...model!.constants.keys()].map((sym) => [sym.id, sym.type]));
    const modelValueTypes = uidMap<Type>([...model!.constants].map(([sym, value]) => [sym.id, value.type]));
    expect(
      sameTypes(modelVarTypes, goalVarTypes),
      "Model should give values to exactly the goal's variables, at their types",
    ).toBe(true);
    expect(sameTypes(modelValueTypes, goalVarTypes), "Each model value should have its variable's type").toBe(
      true,
    );
  });

  // Decomposition
  // =============

  test("decomposition", async () => {
    // `[@@decomp top ~prune:false () |>> prune]` on `f`
    const t = getTheTask(await tasks(), DecompositionTask);
    const db = await t.db();

    // A pipeline is requested as the term that computes it: `(top ...) |>> prune` applied to `f`
    const req = await t.decomp();
    expect(req).toBeInstanceOf(DecompositionRequest.Term);
    const term = (req as DecompositionRequest.Term).term;
    expect(ctorRepr(term)).toBe(
      `\
Apply(
    type=<ConstructedType Decomp.t string result>,
    function=<Symbol Decomp.|>>/<hash>>,
    arguments=(
        <Apply (Decomp.top None None None Some false None None ())>,
        <Symbol Decomp.prune>,
        <Constant f>,
    ),
)`,
    );
    assertSymbolsDefinedInDb(term, db);

    const res = await t.result();
    expect(res).toBeInstanceOf(DecompositionTaskResult);
    const r = res as DecompositionTaskResult;
    expect(r.error, String(r.error)).toBeUndefined();

    const d: Decomposition | undefined = r.decomposition;
    expect(d).toBeDefined();
    expect(ctorRepr(d)).toBe(
      `\
Decomposition(
    id=<Uid f/<hash>>,
    arguments=(<Variable xs>,),
    regions=(
        <Region constraints: [true] invariant: (List.map/<hash> $lambda/<hash> xs) status: feasible>,
    ),
)`,
    );

    const fDef = db.findFunction(d!.id);
    expect(fDef).toBeDefined();
    expect(
      d!.arguments.length === fDef!.arguments.length && d!.arguments.every((a, i) => a.equals(fDef!.arguments[i])),
      "Decomp arguments should be the decomposed function's arguments in the task's DB",
    ).toBe(true);

    // `List.map` is not unrolled: a single region, over `f`'s arguments
    expect(d!.regions).toHaveLength(1);
    const region = d!.regions[0]!;
    expect(
      isSubset(varsInSubterms(region.invariant), idsOf(d!.arguments)),
      "Region invariant should only use the decomposition's arguments",
    ).toBe(true);

    // A feasible region comes with a model of `f`'s arguments
    expect(region.status.kind).toBe("feasible");
    const fArgTypes = uidMap<Type>(d!.arguments.map((a) => [a.id, a.type]));
    const regionModel = region.model!;
    const modelVarTypes = uidMap<Type>([...regionModel.constants.keys()].map((sym) => [sym.id, sym.type]));
    expect(
      sameTypes(modelVarTypes, fArgTypes),
      "Region model should give values to exactly f's arguments, at their types",
    ).toBe(true);
  });

  // Across tasks
  // ============

  test("tasks agree on uids", async () => {
    // Within a session, `f` is the same uid in every task that refers to it
    const res = await getTheTask(await tasks(), DecompositionTask).result();
    expect(res).toBeInstanceOf(DecompositionTaskResult);
    const d = (res as DecompositionTaskResult).decomposition;
    expect(d).toBeDefined();
    for (const isInstance of [false, true]) {
      const [, goal] = (await (await getThePo(await tasks(), isInstance)).proofObligation()).goal;
      expect(goal).toBeInstanceOf(Apply);
      const fXs = (goal as Apply).arguments[0];
      expect(fXs instanceof Apply && fXs.function instanceof Symbol).toBe(true);
      expect(
        ((fXs as Apply).function as Symbol).symbol.id.equals(d!.id),
        "f should have the same uid in the PO goal and in the decomposition",
      ).toBe(true);
    }
  });
});
