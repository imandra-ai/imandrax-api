/**
 * Test the invariants of MIR data: relationships between MIR objects that must hold
 *
 * 1. Typing: every term is well-typed, e.g. an application's arguments have the types its
 *    function expects, and a match's arms all have the match's type
 * 2. Polymorphism: an applied symbol's type is its type schema instantiated at its type
 *    arguments, and a type constructor gets as many type arguments as it has parameters
 * 3. Scoping: functions, goals and model function interpretations only use the variables they
 *    bind; a function's type is that of its arguments and body; theorems and verify statements
 *    are bool
 * 4. Agreement with type definitions: constructors and fields belong to the type of the term
 *    they apply to; cliques of mutually recursive functions are symmetric
 * 5. Rules: rewrite rules relate two terms of the same type, under bool guards, and their
 *    variables are bound by their left-hand side
 * 6. Uids: declarations never have generative uids; a function's uid is builtin, content-addressed
 *    or persistent, as its kind requires; only top-level functions and types are content-addressed
 *    keys
 * 7. Models and regions: model values are ground and typed; function interpretations, region
 *    constraints and invariants agree with the functions they interpret or decompose
 *
 * Whether the uids MIR refers to can be found in the DB is tested in `mir_db.test.ts`.
 *
 * Each check runs over everything of its kind: every declaration in the task's DB, prelude
 * included, and the terms in task data and results.
 */
// ai-disclosure: ai-generated

import { describe, expect, test } from "vitest";

import {
  AlgebraicTypeKind,
  type AppliedSymbol,
  Apply,
  ApplyPattern,
  ArrowType,
  BoolConst,
  BuiltinFunctionKind,
  Case,
  Constant,
  Construct,
  ConstructedType,
  type ConstructorDefinition,
  ConstructPattern,
  type DB,
  type Declaration,
  type Decomposition,
  DecompositionTask,
  DecompositionTaskResult,
  DefinedFunctionKind,
  Destruct,
  DestructPattern,
  Field,
  type FoPattern,
  type FunctionDefinition,
  type FunctionInterpretation,
  If,
  IntConst,
  IsA,
  IsAPattern,
  OpaqueFunctionKind,
  ProofObligationTask,
  ProofObligationTaskResult,
  RationalConst,
  Record,
  RecordTypeKind,
  type RewriteRule,
  Sequence,
  StringConst,
  Symbol,
  type Task,
  type Term,
  TheoremDeclaration,
  Tuple,
  TupleField,
  TupleType,
  type Type,
  TypeDeclaration,
  TypeVariable,
  Uid,
  Var,
  type Variable,
  VarPattern,
  VerifyDeclaration,
  raw,
  uidMap,
  uidSet,
} from "../../lib/index.js";
import { noApiKey, sharedClient } from "./setup.js";

const lib = raw.types;

const SRC = `
type shape = Circle of int | Rect of { w: int; h: int }
type point = { x: int; y: int }
type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree

let area (s: shape) : int = match s with Circle r -> 3 * r * r | Rect { w; h } -> w * h
let move (p: point) = { p with x = p.x + 1 }
let rec size (t: 'a tree) : int = match t with Leaf -> 0 | Node (l, _, r) -> size l + 1 + size r
let swap (p: int * bool) : bool * int = let (a, b) = p in (b, a)
let rec even n = if n <= 0 then true else odd (n - 1)
and odd n = if n <= 0 then false else even (n - 1)
let add_all (y: int) (xs: int list) : int list = List.map (fun x -> x + y) xs
let ext : int -> int = fun x -> x [@@opaque]

theorem add_comm x y = x + y = y + x [@@rw]
theorem size_nonneg (t: int tree) = size t >= 0 [@@by auto] [@@fc]

let h (p: point) = if p.x > 0 then p.x else p.y
[@@decomp top ()]
let get_or (d: int) (o: int option) = match o with Some x -> x | None -> d
[@@decomp top ()]

verify (fun x -> h { x; y = 1 } > x)
instance (fun () -> ext 1 = 5 && ext 2 = 7)
verify true
`;

// Setup
// ====================

/** `f()`, computed once, on first use (as a module-scoped pytest fixture) */
function once<T>(f: () => Promise<T>): () => Promise<T> {
  let p: Promise<T> | undefined;
  return () => (p ??= f());
}

type NonTypeDeclaration = Exclude<Declaration, TypeDeclaration>;

/** A proof obligation task, with the data the checks read from it */
interface PoTask {
  task: ProofObligationTask;
  fromSym: string;
  goalVariables: readonly Variable[];
  goalBody: Term;
}

function assertNoFailures(failures: string[]): void {
  expect(failures, `${failures.length} failures, e.g.:\n` + failures.slice(0, 10).join("\n")).toEqual([]);
}

/** Variables as a set: variables are equal when their ids are, so it is the set of their ids */
type VarSet = ReadonlySet<Uid>;

function varSet(vs: Iterable<Variable>): VarSet {
  return uidSet([...vs].map((v) => v.id));
}

function isSubset(a: VarSet, b: VarSet): boolean {
  return [...a].every((x) => b.has(x));
}

function setEq(a: VarSet, b: VarSet): boolean {
  return a.size === b.size && isSubset(a, b);
}

function minus(a: VarSet, b: VarSet): string {
  return `{${[...a]
    .filter((x) => !b.has(x))
    .map((x) => `${x}`)
    .join(", ")}}`;
}

function show(xs: Iterable<unknown>): string {
  return `[${[...xs].map((x) => `${x}`).join(", ")}]`;
}

function typesEq(a: readonly Type[], b: readonly Type[]): boolean {
  return a.length === b.length && a.every((t, i) => t.equals(b[i]));
}

/** `parts` is `[domains, result]` */
function partsEq(parts: [Type[], Type] | undefined, domains: readonly Type[], result: Type): boolean {
  return parts !== undefined && typesEq(parts[0], domains) && parts[1].equals(result);
}

function isBool(ty: Type): boolean {
  return ty instanceof ConstructedType && ty.ctor.shortName === "bool" && ty.arguments.length === 0;
}

/** `ty` as `d1 -> ... -> dn -> result`, `[[d1, ..., dn], result]`; `undefined` if it has fewer arrows */
function arrowParts(ty: Type, n: number): [Type[], Type] | undefined {
  const domains: Type[] = [];
  for (let i = 0; i < n; i++) {
    if (!(ty instanceof ArrowType)) {
      return undefined;
    }
    domains.push(ty.domain);
    ty = ty.codomain;
  }
  return [domains, ty];
}

/** `ty` as `d1 -> ... -> dn -> result`, with all of its arrows */
function allArrowParts(ty: Type): [Type[], Type] {
  const domains: Type[] = [];
  while (ty instanceof ArrowType) {
    domains.push(ty.domain);
    ty = ty.codomain;
  }
  return [domains, ty];
}

/** `ty` with its type variables replaced as in `s` */
function substitute(ty: Type, s: ReadonlyMap<Uid, Type>): Type {
  if (ty instanceof TypeVariable) {
    return s.get(ty.name) ?? ty;
  } else if (ty instanceof ArrowType) {
    return new ArrowType(substitute(ty.domain, s), substitute(ty.codomain, s), ty.raw);
  } else if (ty instanceof TupleType) {
    return new TupleType(
      ty.elements.map((e) => substitute(e, s)),
      ty.raw,
    );
  } else {
    return new ConstructedType(
      ty.ctor,
      ty.arguments.map((a) => substitute(a, s)),
      ty.raw,
    );
  }
}

/** `ty` and all of the types it is built from */
function* typesIn(ty: Type): Iterable<Type> {
  yield ty;
  if (ty instanceof ArrowType) {
    yield* typesIn(ty.domain);
    yield* typesIn(ty.codomain);
  } else if (ty instanceof TupleType || ty instanceof ConstructedType) {
    const ts = ty instanceof TupleType ? ty.elements : ty.arguments;
    for (const t of ts) yield* typesIn(t);
  }
}

function freeVars(ts: Iterable<Term>): VarSet {
  return uidSet([...ts].flatMap((t) => [...t].filter((x): x is Var => x instanceof Var).map((x) => x.var.id)));
}

function patternVars(p: FoPattern): VarSet {
  if (p instanceof VarPattern) {
    return varSet([p.variable]);
  } else if (p instanceof ApplyPattern || p instanceof ConstructPattern) {
    return uidSet(p.arguments.flatMap((q) => [...patternVars(q)]));
  } else if (p instanceof DestructPattern || p instanceof IsAPattern) {
    return patternVars(p.pattern);
  } else {
    return uidSet();
  }
}

/** The definition of constructor `c` in the algebraic type `ty`, if it is one of its constructors */
function constructorDefinition(db: DB, ty: Type, c: Uid): ConstructorDefinition | undefined {
  if (!(ty instanceof ConstructedType)) return undefined;
  const td = db.findType(ty.ctor);
  if (td === undefined || !(td.kind instanceof AlgebraicTypeKind)) return undefined;
  return td.kind.constructors.find((cd) => cd.name.equals(c));
}

/** Whether `f` is a field of the record type `ty` */
function isFieldOf(db: DB, ty: Type, f: Uid): boolean {
  if (!(ty instanceof ConstructedType)) return false;
  const td = db.findType(ty.ctor);
  if (td === undefined) return false;
  return td.kind instanceof RecordTypeKind && td.kind.fields.some((fd) => fd.name.equals(f));
}

/** The subterms of class `cls`; asserts there is at least one, so checks on them are not vacuous */
function subtermsOf<T>(subterms: [string, Term][], cls: abstract new (...args: any[]) => T): [string, T][] {
  const xs = subterms.filter((e): e is [string, Term & T] => e[1] instanceof cls);
  expect(xs.length, `No ${cls.name} subterm to check`).toBeGreaterThan(0);
  return xs;
}

function appliedSymbols(x: Term): AppliedSymbol[] {
  if (x instanceof Symbol) return [x.symbol];
  if (x instanceof Construct || x instanceof Destruct || x instanceof IsA) return [x.ctor];
  if (x instanceof Field) return [x.field];
  if (x instanceof Record) return x.rows.map(([f]) => f);
  if (x instanceof Case) return x.cases.map(([c]) => c);
  return [];
}

/** The uids that declarations introduce: functions, types, constructors and fields */
function declaredUids(db: DB): [string, Uid][] {
  const uids: [string, Uid][] = [];
  for (const d of db.decls.values()) {
    if (d instanceof TypeDeclaration) {
      const td = d.type;
      uids.push(["type", td.name]);
      if (td.kind instanceof AlgebraicTypeKind) {
        uids.push(...td.kind.constructors.map((cd): [string, Uid] => ["constructor", cd.name]));
      } else if (td.kind instanceof RecordTypeKind) {
        uids.push(...td.kind.fields.map((fd): [string, Uid] => ["field", fd.name]));
      }
    } else {
      uids.push(["function", d.function.name]);
    }
  }
  return uids;
}

// Uses variables of the function it was lifted from; see the failing test below
const LIFTED_WITH_FREE_VARS = "$sub.Decomp.enumerate_all.lift";

describe.skipIf(noApiKey)("MIR invariants", () => {
  const client = sharedClient();

  const tasks = once(async (): Promise<readonly Task[]> => {
    const evalRes = await client().evalSrc(SRC);
    expect(evalRes.success && evalRes.errors.length === 0, evalRes.errors.join("\n")).toBe(true);
    return evalRes.tasks;
  });

  /** The DB of the final `verify true` in `SRC` */
  const db = once(async (): Promise<DB> => {
    // Tasks come newest first
    const t = (await tasks())[0];
    expect(t).toBeInstanceOf(ProofObligationTask);
    return (t as ProofObligationTask).db();
  });

  /** Every function in the DB, including those linked to theorems and verify statements */
  const functions = once(async (): Promise<FunctionDefinition[]> =>
    [...(await db()).decls.values()]
      .filter((d): d is NonTypeDeclaration => !(d instanceof TypeDeclaration))
      .map((d) => d.function),
  );

  const rewriteRules = once(async (): Promise<RewriteRule[]> => {
    const d = await db();
    return [
      ...[...d.rwRules.values()].flat(),
      ...[...d.thmAsRw.values()].flat(),
      ...[...d.ruleSpecRwRules.values()].flat(),
    ];
  });

  const poTasks = once(async (): Promise<PoTask[]> => {
    const ts: PoTask[] = [];
    for (const t of await tasks()) {
      if (t instanceof ProofObligationTask) {
        const po = await t.proofObligation();
        ts.push({ task: t, fromSym: await t.fromSym(), goalVariables: po.goalVariables, goalBody: po.goalBody });
      }
    }
    return ts;
  });

  const poResults = once(async (): Promise<[string, ProofObligationTaskResult][]> => {
    const results: [string, ProofObligationTaskResult][] = [];
    for (const t of await poTasks()) {
      const res = await t.task.result();
      expect(res).toBeInstanceOf(ProofObligationTaskResult);
      results.push([`PO ${t.fromSym}`, res as ProofObligationTaskResult]);
    }
    return results;
  });

  const decompositions = once(async (): Promise<[DecompositionTask, Decomposition][]> => {
    const ds: [DecompositionTask, Decomposition][] = [];
    for (const t of await tasks()) {
      if (t instanceof DecompositionTask) {
        const res = await t.result();
        expect(res).toBeInstanceOf(DecompositionTaskResult);
        const r = res as DecompositionTaskResult;
        expect(r.decomposition, String(r.error)).toBeDefined();
        ds.push([t, r.decomposition!]);
      }
    }
    return ds;
  });

  /**
   * Every top-level term, with where it comes from: function bodies, rewrite rules, PO goals,
   * subgoals, models and regions
   */
  const terms = once(async (): Promise<[string, Term][]> => {
    const ts: [string, Term][] = [];
    for (const f of await functions()) {
      if (f.kind instanceof DefinedFunctionKind) {
        ts.push([`function ${f.name}`, f.body]);
      }
    }
    for (const r of await rewriteRules()) {
      ts.push(...[r.rhs, ...r.guard].map((t): [string, Term] => [`rewrite rule ${r.name}`, t]));
    }
    for (const t of await poTasks()) {
      ts.push([`PO ${t.fromSym}`, t.goalBody]);
    }
    for (const [where, res] of await poResults()) {
      for (const sr of res.subresults.flat()) {
        for (const sq of [sr.goal, ...sr.subGoals]) {
          ts.push(
            ...[...sq.hypothesisTerms, ...sq.conclusionTerms].map((t): [string, Term] => [`${where} subgoal`, t]),
          );
        }
      }
      const m = res.model;
      if (m !== undefined) {
        ts.push(...[...m.constants.values()].map((t): [string, Term] => [`${where} model`, t]));
        for (const fi of m.functions.values()) {
          ts.push(
            ...fi.cases.flatMap((c) => [...c.guards, c.rhs]).map((t): [string, Term] => [`${where} model`, t]),
          );
          ts.push([`${where} model`, fi.else]);
        }
      }
    }
    for (const [, d] of await decompositions()) {
      for (const region of d.regions) {
        ts.push(
          ...[...region.constraints, region.invariant].map((t): [string, Term] => [`region of ${d.id}`, t]),
        );
      }
    }
    return ts;
  });

  /** Every subterm of `terms`, with where its top-level term comes from */
  const subterms = once(async (): Promise<[string, Term][]> =>
    (await terms()).flatMap(([where, t]) => [...t].map((x): [string, Term] => [where, x])),
  );

  // Terms are well-typed
  // ====================

  test("variables and symbols have their types", async () => {
    const st = await subterms();
    const failures = subtermsOf(st, Var)
      .filter(([, x]) => !x.type.equals(x.var.type))
      .map(([where, x]) => `${where}: ${x} : ${x.type}, but its variable is : ${x.var.type}`);
    failures.push(
      ...subtermsOf(st, Symbol)
        .filter(([, x]) => !x.type.equals(x.symbol.type))
        .map(([where, x]) => `${where}: ${x} : ${x.type}, but its symbol is : ${x.symbol.type}`),
    );
    assertNoFailures(failures);
  });

  test("applications are well-typed", async () => {
    // Applying `f : d1 -> ... -> dn -> r` to arguments of types `d1, ..., dn` gives an `r`
    //
    // Functions are curried, so `r` can itself be a function type.
    const failures: string[] = [];
    for (const [where, x] of subtermsOf(await subterms(), Apply)) {
      const parts = arrowParts(x.function.type, x.arguments.length);
      if (parts === undefined) {
        failures.push(`${where}: ${x}: ${x.function.type} takes fewer than ${x.arguments.length} arguments`);
        continue;
      }
      const [domains, result] = parts;
      if (
        !typesEq(
          x.arguments.map((a) => a.type),
          domains,
        ) ||
        !result.equals(x.type)
      ) {
        failures.push(`${where}: ${x} : ${x.type}, with function : ${x.function.type}`);
      }
    }
    assertNoFailures(failures);
  });

  test("conditionals are well-typed", async () => {
    const failures = subtermsOf(await subterms(), If)
      .filter(
        ([, x]) => !isBool(x.condition.type) || !x.thenBranch.type.equals(x.type) || !x.elseBranch.type.equals(x.type),
      )
      .map(([where, x]) => `${where}: ${x}`);
    assertNoFailures(failures);
  });

  test("tuples are well-typed", async () => {
    const st = await subterms();
    const failures = subtermsOf(st, Tuple)
      .filter(
        ([, x]) =>
          !(
            x.type instanceof TupleType &&
            typesEq(
              x.type.elements,
              x.elements.map((e) => e.type),
            )
          ),
      )
      .map(([where, x]) => `${where}: ${x} : ${x.type}`);
    for (const [where, x] of subtermsOf(st, TupleField)) {
      const ty = x.term.type;
      if (!(ty instanceof TupleType && x.index < ty.elements.length && ty.elements[x.index]!.equals(x.type))) {
        failures.push(`${where}: ${x} : ${x.type}, of a tuple : ${ty}`);
      }
    }
    assertNoFailures(failures);
  });

  test("constructions are well-typed", async () => {
    // A constructor applied to its arguments builds a value of its type, which defines it
    const d = await db();
    const failures: string[] = [];
    for (const [where, x] of subtermsOf(await subterms(), Construct)) {
      const parts = arrowParts(x.ctor.type, x.arguments.length);
      if (
        !partsEq(
          parts,
          x.arguments.map((a) => a.type),
          x.type,
        )
      ) {
        failures.push(`${where}: ${x} : ${x.type}, with constructor : ${x.ctor.type}`);
      }
      const cd = constructorDefinition(d, x.type, x.ctor.id);
      if (cd === undefined) {
        failures.push(`${where}: ${x}: ${x.ctor.id} is not a constructor of ${x.type}`);
      } else if (cd.arguments.length !== x.arguments.length) {
        failures.push(`${where}: ${x}: ${x.ctor.id} takes ${cd.arguments.length} arguments`);
      }
    }
    assertNoFailures(failures);
  });

  test("destructions are well-typed", async () => {
    // `Destruct(c, i, t)` is the `i`-th argument of `t`, a value of the type that defines `c`
    const d = await db();
    const failures: string[] = [];
    for (const [where, x] of subtermsOf(await subterms(), Destruct)) {
      const [domains, result] = allArrowParts(x.ctor.type);
      if (!(x.index < domains.length && domains[x.index]!.equals(x.type) && result.equals(x.term.type))) {
        failures.push(`${where}: ${x} : ${x.type}, with constructor : ${x.ctor.type}`);
      }
      if (constructorDefinition(d, x.term.type, x.ctor.id) === undefined) {
        failures.push(`${where}: ${x}: ${x.ctor.id} is not a constructor of ${x.term.type}`);
      }
    }
    assertNoFailures(failures);
  });

  test("constructor tests are well-typed", async () => {
    // `IsA(c, t)` is bool, and `c` is a constructor of `t`'s type
    //
    // These occur in region constraints, e.g. `Is_a(Some, o)`, not in function bodies, where matches
    // are `Case` terms.
    const d = await db();
    const failures = subtermsOf(await subterms(), IsA)
      .filter(([, x]) => !isBool(x.type) || constructorDefinition(d, x.term.type, x.ctor.id) === undefined)
      .map(([where, x]) => `${where}: ${x}`);
    assertNoFailures(failures);
  });

  test("records are well-typed", async () => {
    // A field `f : record -> ty` of a record type is read from, and set in, values of that type
    const d = await db();
    const st = await subterms();
    const failures: string[] = [];
    for (const [where, x] of subtermsOf(st, Field)) {
      const f = x.field;
      if (!partsEq(arrowParts(f.type, 1), [x.term.type], x.type)) {
        failures.push(`${where}: ${x} : ${x.type}, with field : ${f.type}`);
      }
      if (!isFieldOf(d, x.term.type, f.id)) {
        failures.push(`${where}: ${x}: ${f.id} is not a field of ${x.term.type}`);
      }
    }
    for (const [where, x] of subtermsOf(st, Record)) {
      if (x.rest !== undefined && !x.rest.type.equals(x.type)) {
        failures.push(`${where}: ${x}: updates a ${x.rest.type} into a ${x.type}`);
      }
      for (const [f, v] of x.rows) {
        if (!partsEq(arrowParts(f.type, 1), [x.type], v.type)) {
          failures.push(`${where}: ${x}: ${f.id} = ${v} : ${v.type}, with field : ${f.type}`);
        }
        if (!isFieldOf(d, x.type, f.id)) {
          failures.push(`${where}: ${x}: ${f.id} is not a field of ${x.type}`);
        }
      }
    }
    assertNoFailures(failures);
  });

  test("matches are well-typed", async () => {
    // Every arm of a match has the match's type, and matches a constructor of the scrutinee's type
    const d = await db();
    const failures: string[] = [];
    for (const [where, x] of subtermsOf(await subterms(), Case)) {
      for (const [c, arm] of x.cases) {
        if (!arm.type.equals(x.type)) {
          failures.push(`${where}: ${x}: arm ${c.id} : ${arm.type}, but the match is : ${x.type}`);
        }
        if (constructorDefinition(d, x.scrutinee.type, c.id) === undefined) {
          failures.push(`${where}: ${x}: ${c.id} is not a constructor of ${x.scrutinee.type}`);
        }
      }
      if (x.default !== undefined && !x.default.type.equals(x.type)) {
        failures.push(`${where}: ${x}: default : ${x.default.type}, but the match is : ${x.type}`);
      }
    }
    assertNoFailures(failures);
  });

  test("sequences are well-typed", async () => {
    const failures = subtermsOf(await subterms(), Sequence)
      .filter(([, x]) => !x.last.type.equals(x.type))
      .map(([where, x]) => `${where}: ${x} : ${x.type}, but its last term is : ${x.last.type}`);
    assertNoFailures(failures);
  });

  test("constants have their types", async () => {
    const expected = new Map<Function, string>([
      [IntConst, "int"],
      [BoolConst, "bool"],
      [StringConst, "string"],
      [RationalConst, "real"],
    ]);
    const failures: string[] = [];
    for (const [where, x] of subtermsOf(await subterms(), Constant)) {
      const name = expected.get(x.value.constructor);
      if (name === undefined) {
        continue;
      }
      if (!(x.type instanceof ConstructedType && x.type.ctor.shortName === name)) {
        failures.push(`${where}: ${x} : ${x.type}, expected ${name}`);
      }
    }
    assertNoFailures(failures);
  });

  // Applied symbols and types
  // =========================

  test("applied symbols instantiate their schemas", async () => {
    // An applied symbol's type is its type schema, with its parameters replaced by its type arguments
    const failures: string[] = [];
    for (const [where, x] of await subterms()) {
      for (const s of appliedSymbols(x)) {
        const schema = s.symbol.typeSchema;
        if (s.typeArguments.length !== schema.parameters.length) {
          failures.push(`${where}: ${s}: ${s.typeArguments.length} type arguments for ${show(schema.parameters)}`);
          continue;
        }
        const subst = uidMap(schema.parameters.map((p, i): [Uid, Type] => [p, s.typeArguments[i]!]));
        const expectedType = substitute(schema.type, subst);
        if (!expectedType.equals(s.type)) {
          failures.push(`${where}: ${s}, expected : ${expectedType}`);
        }
      }
    }
    assertNoFailures(failures);
  });

  test("constructed types have their arity", async () => {
    // A type constructor is applied to as many type arguments as its definition has parameters
    const d = await db();
    const types: [string, Type][] = (await subterms()).map(([where, x]) => [where, x.type]);
    types.push(...(await functions()).map((f): [string, Type] => [`function ${f.name}`, f.type]));
    for (const decl of d.decls.values()) {
      if (!(decl instanceof TypeDeclaration)) continue;
      const td = decl.type;
      if (td.kind instanceof AlgebraicTypeKind) {
        types.push(...td.kind.constructors.flatMap((cd) => cd.arguments.map((t): [string, Type] => [`type ${td.name}`, t])));
      } else if (td.kind instanceof RecordTypeKind) {
        types.push(...td.kind.fields.map((fd): [string, Type] => [`type ${td.name}`, fd.type]));
      }
    }
    const failures: string[] = [];
    for (const [where, ty] of types) {
      for (const t of typesIn(ty)) {
        if (!(t instanceof ConstructedType)) continue;
        const td = d.findType(t.ctor);
        if (td === undefined) continue;
        if (t.arguments.length !== td.parameters.length) {
          failures.push(`${where}: ${t}, but ${td.name} has parameters ${show(td.parameters)}`);
        }
      }
    }
    assertNoFailures(failures);
  });

  // Functions and declarations
  // ==========================

  test("function arguments are distinct", async () => {
    const failures = (await functions())
      .filter((f) => varSet(f.arguments).size !== f.arguments.length)
      .map((f) => `${f.name}: ${show(f.arguments)}`);
    assertNoFailures(failures);
  });

  test("function bodies only use their arguments", async () => {
    const failures = (await functions())
      .filter(
        (f) =>
          f.kind instanceof DefinedFunctionKind &&
          f.name.shortName !== LIFTED_WITH_FREE_VARS &&
          !isSubset(freeVars([f.body]), varSet(f.arguments)),
      )
      .map((f) => `${f.name}: uses ${minus(freeVars([f.body]), varSet(f.arguments))}`);
    assertNoFailures(failures);
  });

  // xfail (strict): `$sub.Decomp.enumerate_all.lift` uses `d0`, `des` and `style` of
  // `Decomp.enumerate_all`, which are not among its arguments
  test.fails("lifted function only uses its arguments", async () => {
    const fs = (await functions()).filter((f) => f.name.shortName === LIFTED_WITH_FREE_VARS);
    expect(fs).toHaveLength(1);
    const f = fs[0]!;
    expect(isSubset(freeVars([f.body]), varSet(f.arguments))).toBe(true);
  });

  test("function types match arguments and body", async () => {
    // A function `f x1 ... xn = body` has type `type(x1) -> ... -> type(xn) -> type(body)`
    const failures = (await functions())
      .filter(
        (f) =>
          f.kind instanceof DefinedFunctionKind &&
          !partsEq(
            arrowParts(f.type, f.arguments.length),
            f.arguments.map((a) => a.type),
            f.body.type,
          ),
      )
      .map(
        (f) =>
          `${f.name} : ${f.type}, with arguments ${show(f.arguments.map((a) => a.type))} and body : ${f.body.type}`,
      );
    assertNoFailures(failures);
  });

  test("function type variables are its type parameters", async () => {
    const failures: string[] = [];
    for (const f of await functions()) {
      const typeVars = uidSet([...typesIn(f.type)].filter((t): t is TypeVariable => t instanceof TypeVariable).map((t) => t.name));
      const params = uidSet(f.typeParameters);
      if (![...typeVars].every((v) => params.has(v))) {
        failures.push(`${f.name} : ${f.type}, with type parameters ${show(f.typeParameters)}`);
      }
    }
    assertNoFailures(failures);
  });

  test("theorems and verify statements are bool", async () => {
    const decls = [...(await db()).decls.values()].filter(
      (d): d is TheoremDeclaration | VerifyDeclaration => d instanceof TheoremDeclaration || d instanceof VerifyDeclaration,
    );
    expect(decls.length).toBeGreaterThan(0);
    const failures = decls.filter((d) => !isBool(d.function.body.type)).map((d) => `${d.id}: ${d.function.body.type}`);
    assertNoFailures(failures);
  });

  test("cliques are symmetric", async () => {
    // Every function of a clique of mutually recursive functions has the same clique, itself included
    const d = await db();
    const cliques = (await functions()).filter((f) => f.clique !== undefined);
    expect(cliques.length).toBeGreaterThan(0);
    const failures: string[] = [];
    for (const f of cliques) {
      const clique = f.clique!;
      if (!clique.has(f.name)) {
        failures.push(`${f.name} is not in its clique ${show(clique)}`);
      }
      for (const g of clique) {
        const gd = d.findFunction(g);
        if (gd === undefined || gd.clique === undefined || !setEq(gd.clique, clique)) {
          failures.push(`${f.name} has ${g} in its clique, but not the other way around`);
        }
      }
    }
    assertNoFailures(failures);
  });

  // Uids
  // ====

  test("declared uids are not generative", async () => {
    // Generative uids, e.g. `x/123`, are for local variables only
    const failures = declaredUids(await db())
      .filter(([, u]) => u.raw.view instanceof lib.Uid_view_Generative)
      .map(([kind, u]) => `${kind} ${u}`);
    assertNoFailures(failures);
  });

  test("content-addressed uids name their declaration", async () => {
    // A content-addressed uid has its name; it is a key for a top-level function or type, not for
    // a constructor or a field, which are defined as part of their type
    const failures: string[] = [];
    for (const [kind, u] of declaredUids(await db())) {
      const cname = u.cname;
      if (cname === undefined) {
        continue;
      }
      if (cname.name !== u.shortName) {
        failures.push(`${kind} ${u}: content-addressed as ${cname.name}`);
      }
      if (cname.isKey !== (kind === "function" || kind === "type")) {
        failures.push(`${kind} ${u}: isKey=${cname.isKey}`);
      }
    }
    assertNoFailures(failures);
  });

  test("function uids match their kind", async () => {
    // Builtin functions have builtin uids; defined functions are builtin or content-addressed;
    // opaque functions, with no definition to hash, have persistent uids
    const failures: string[] = [];
    for (const f of await functions()) {
      const u = f.name;
      const view = u.raw.view;
      let ok: boolean;
      if (f.kind instanceof BuiltinFunctionKind) {
        ok = u.builtinKind !== undefined;
      } else if (f.kind instanceof DefinedFunctionKind) {
        ok = u.builtinKind !== undefined || u.cname !== undefined;
      } else if (f.kind instanceof OpaqueFunctionKind) {
        ok = view instanceof lib.Uid_view_Persistent;
      } else {
        ok = false;
      }
      if (!ok) {
        failures.push(`${u}: a ${f.kind.constructor.name} with a ${view.constructor.name} uid`);
      }
    }
    assertNoFailures(failures);
  });

  // Rules
  // =====

  test("rewrite rules are well-formed", async () => {
    // `lhs = rhs if guard`: both sides have the same type, the guards are bool, and the rule's
    // variables are those of `lhs`, which bind all the variables of `rhs`
    const rules = await rewriteRules();
    expect(rules.length).toBeGreaterThan(0);
    const failures: string[] = [];
    for (const r of rules) {
      const lhsVars = patternVars(r.lhs);
      if (!r.lhs.type.equals(r.rhs.type)) {
        failures.push(`${r.name}: lhs : ${r.lhs.type}, but rhs : ${r.rhs.type}`);
      }
      if (!setEq(varSet(r.variables), lhsVars)) {
        failures.push(`${r.name}: variables ${show(r.variables)}, but lhs binds ${show(lhsVars)}`);
      }
      if (!isSubset(freeVars([r.rhs]), lhsVars)) {
        failures.push(`${r.name}: rhs uses ${minus(freeVars([r.rhs]), lhsVars)}, which lhs does not bind`);
      }
      failures.push(...r.guard.filter((g) => !isBool(g.type)).map((g) => `${r.name}: guard ${g} : ${g.type}`));
    }
    assertNoFailures(failures);
  });

  // Task data and results
  // =====================

  test("goals are bool and only use their variables", async () => {
    // A goal can leave variables unused, e.g. a termination goal `terminates f` for `f x`
    const failures: string[] = [];
    for (const t of await poTasks()) {
      if (!isBool(t.goalBody.type)) {
        failures.push(`PO ${t.fromSym}: goal : ${t.goalBody.type}`);
      }
      if (!isSubset(freeVars([t.goalBody]), varSet(t.goalVariables))) {
        failures.push(`PO ${t.fromSym}: goal uses ${minus(freeVars([t.goalBody]), varSet(t.goalVariables))}`);
      }
    }
    assertNoFailures(failures);
  });

  test("subgoals are bool", async () => {
    const failures: string[] = [];
    for (const [where, res] of await poResults()) {
      for (const sr of res.subresults.flat()) {
        for (const sq of [sr.goal, ...sr.subGoals]) {
          for (const t of [...sq.hypothesisTerms, ...sq.conclusionTerms]) {
            if (!isBool(t.type)) failures.push(`${where}: ${t} : ${t.type}`);
          }
        }
      }
    }
    assertNoFailures(failures);
  });

  test("model constants are ground values of their types", async () => {
    const constants: [string, AppliedSymbol, Term][] = [];
    for (const [where, res] of await poResults()) {
      if (res.model) {
        for (const [s, v] of res.model.constants) constants.push([where, s, v]);
      }
    }
    expect(constants.length).toBeGreaterThan(0);
    const failures = constants
      .filter(([, , v]) => freeVars([v]).size > 0)
      .map(([where, s, v]) => `${where}: ${s} = ${v} uses variables`);
    failures.push(
      ...constants.filter(([, s, v]) => !v.type.equals(s.type)).map(([where, s, v]) => `${where}: ${s} = ${v} : ${v.type}`),
    );
    assertNoFailures(failures);
  });

  test("model function interpretations are well-typed", async () => {
    // A function `f : d1 -> ... -> dn -> r` is interpreted over arguments of types `d1, ..., dn`,
    // by cases with bool guards and values of type `r`, which only use those arguments
    const interpretations: [string, AppliedSymbol, FunctionInterpretation][] = [];
    for (const [where, res] of await poResults()) {
      if (res.model) {
        for (const [s, fi] of res.model.functions) interpretations.push([where, s, fi]);
      }
    }
    expect(interpretations.length).toBeGreaterThan(0);
    const failures: string[] = [];
    for (const [where, s, fi] of interpretations) {
      if (
        !partsEq(
          arrowParts(s.type, fi.arguments.length),
          fi.arguments.map((a) => a.type),
          fi.returnType,
        )
      ) {
        failures.push(`${where}: ${s}, interpreted over ${show(fi.arguments)} returning ${fi.returnType}`);
      }
      for (const c of fi.cases) {
        failures.push(...c.guards.filter((g) => !isBool(g.type)).map((g) => `${where}: ${s}: guard ${g} : ${g.type}`));
      }
      const values = [...fi.cases.map((c) => c.rhs), fi.else];
      failures.push(
        ...values.filter((v) => !v.type.equals(fi.returnType)).map((v) => `${where}: ${s}: value ${v} : ${v.type}`),
      );
      const used = freeVars([...values, ...fi.cases.flatMap((c) => c.guards)]);
      if (!isSubset(used, varSet(fi.arguments))) {
        failures.push(`${where}: ${s}: uses ${minus(used, varSet(fi.arguments))}`);
      }
    }
    assertNoFailures(failures);
  });

  test("regions are consistent with their function", async () => {
    // A region's constraints are bool conditions on the function's arguments, and its invariant is
    // the function's result
    const ds = await decompositions();
    expect(ds.length).toBeGreaterThan(0);
    const failures: string[] = [];
    for (const [t, d] of ds) {
      const f = (await t.db()).findFunction(d.id);
      expect(f).toBeDefined();
      expect(d.regions.length).toBeGreaterThan(0);
      for (const region of d.regions) {
        for (const c of region.constraints) {
          if (!isBool(c.type)) {
            failures.push(`${d.id}: constraint ${c} : ${c.type}`);
          }
        }
        if (!isSubset(freeVars(region.constraints), varSet(d.arguments))) {
          failures.push(`${d.id}: constraints use ${minus(freeVars(region.constraints), varSet(d.arguments))}`);
        }
        if (!region.invariant.type.equals(f!.body.type)) {
          failures.push(`${d.id}: invariant : ${region.invariant.type}, but ${f!.name} returns ${f!.body.type}`);
        }
      }
    }
    assertNoFailures(failures);
  });
});
