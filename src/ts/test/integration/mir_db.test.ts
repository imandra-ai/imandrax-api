/**
 * Test MIR DB
 * - type / function search features
 * - prelude declarations should be in the DB
 * - lifted lambdas can be told apart by their full uid names
 * - every uid declarations and rules refer to can be found in the DB
 *
 * Additionally, also test the raw-lib-type->lib-type conversion roundtrip for declarations in the DB
 */

import { describe, expect, test } from "vitest";

import {
  AlgebraicTypeKind,
  Apply,
  ArrowType,
  BuiltinFunctionKind,
  BuiltinTypeKind,
  ConstructedType,
  type DB,
  type Declaration,
  DefinedFunctionKind,
  FunctionDeclaration,
  type FunctionDefinition,
  ProofObligationTask,
  RecordTypeKind,
  RuleSpecDeclaration,
  Symbol,
  SymbolHead,
  type Task,
  type Term,
  TermBase,
  TheoremDeclaration,
  TupleType,
  type Type,
  TypeDeclaration,
  TypeDefinition,
  TypeVariable,
  Uid,
  ValueMap,
  ValueSet,
  VerifyDeclaration,
  declarationOfLib,
  termOfLib,
  uidSet,
} from "../../lib/index.js";
import { noApiKey, sharedClient } from "./setup.js";

const SRC = `
type shape = Circle of int | Rect of { w: int; h: int }
type point = { x: int; y: int }
type my_int = int

let add_one (x: my_int) : my_int = x + 1
let area (s: shape) : int = match s with Circle r -> 3 * r * r | Rect { w; h } -> w * h
let rec sum (xs: int list) : int = match xs with [] -> 0 | x :: tl -> x + sum tl
let g (x: int) = x + 1
let inc_all (xs: int list) : int list = List.map (fun x -> x + 1) xs
let add_all (y: int) (xs: int list) : int list = List.map (fun x -> x + y) xs

theorem g_gt x = g x > x [@@rw]
theorem sum_nonneg xs = List.for_all (fun x -> x >= 0) xs ==> sum xs >= 0 [@@by auto] [@@fc]
[@@@disable g]

eval (area (Circle 2))
let h (p: point) = p.x + p.y
[@@decomp top ()]

verify (fun x -> h { x; y = 1 } > x)
instance (fun (xs: int list) (y: int) -> inc_all xs <> List.map (fun x -> x * y) xs)

verify true
`;

// Setup
// ====================

/** `f()`, computed once, on first use (as a module-scoped pytest fixture) */
function once<T>(f: () => Promise<T>): () => Promise<T> {
  let p: Promise<T> | undefined;
  return () => (p ??= f());
}

/** The unique uid with this short name; throws unless there is exactly one */
function searchUidByShortName(db: DB, shortName: string): Uid {
  const uids = [...db.decls.keys()].filter((u) => u.shortName === shortName);
  expect(uids, `uids named ${shortName}`).toHaveLength(1);
  return uids[0]!;
}

function shortNames(uids: Iterable<Uid>): Set<string> {
  return new Set([...uids].map((u) => u.shortName));
}

/** Equal sets of uids, compared by value */
function sameUids(a: Iterable<Uid>, b: Iterable<Uid>): boolean {
  const [sa, sb] = [uidSet(a), uidSet(b)];
  return sa.size === sb.size && [...sa].every((u) => sb.has(u));
}

function isDeclaration(d: unknown): d is Declaration {
  return (
    d instanceof FunctionDeclaration ||
    d instanceof TypeDeclaration ||
    d instanceof TheoremDeclaration ||
    d instanceof RuleSpecDeclaration ||
    d instanceof VerifyDeclaration
  );
}

/**
 * Structural equality, as Python's dataclass `==`: the same class with equal fields, ignoring
 * `raw`; uids, types, variables and the other classes with an `equals` compare with it
 */
function structEq(a: unknown, b: unknown): boolean {
  if (Object.is(a, b)) return true;
  if (typeof a !== "object" || typeof b !== "object" || a === null || b === null) return false;
  if (Array.isArray(a) || Array.isArray(b)) {
    return Array.isArray(a) && Array.isArray(b) && a.length === b.length && a.every((x, i) => structEq(x, b[i]));
  }
  if (a instanceof Uint8Array || b instanceof Uint8Array) {
    return a instanceof Uint8Array && b instanceof Uint8Array && a.length === b.length && a.every((x, i) => x === b[i]);
  }
  if (a instanceof ValueSet || a instanceof Set) {
    const sb = b as ReadonlySet<unknown>;
    return (b instanceof ValueSet || b instanceof Set) && a.size === sb.size && [...a].every((x) => sb.has(x));
  }
  if (a instanceof ValueMap || a instanceof Map) {
    const mb = b as ReadonlyMap<unknown, unknown>;
    return (
      (b instanceof ValueMap || b instanceof Map) &&
      a.size === mb.size &&
      [...(a as ReadonlyMap<unknown, unknown>)].every(([k, v]) => mb.has(k) && structEq(v, mb.get(k)))
    );
  }
  if (Object.getPrototypeOf(a) !== Object.getPrototypeOf(b)) return false;
  const eq = (a as { equals?: (o: unknown) => boolean }).equals;
  if (typeof eq === "function") return eq.call(a, b);
  const keys = Object.keys(a).filter((k) => k !== "raw");
  return keys.every((k) => structEq((a as Record<string, unknown>)[k], (b as Record<string, unknown>)[k]));
}

describe.skipIf(noApiKey)("MIR DB", () => {
  const client = sharedClient();

  /** The tasks of `SRC` */
  const tasks = once(async (): Promise<readonly Task[]> => (await client().evalSrc(SRC)).tasks);

  /** The DB of the final `verify true` in `SRC` */
  const db = once(async (): Promise<DB> => {
    // Tasks come newest first
    const t = (await tasks())[0];
    expect(t).toBeInstanceOf(ProofObligationTask);
    return (t as ProofObligationTask).db();
  });

  // Declarations
  // ============

  test("declaration kinds", async () => {
    const d = await db();
    const kinds: Record<string, string> = {};
    for (const name of ["shape", "point", "area", "sum", "g", "g_gt", "sum_nonneg", "h"]) {
      const decl = d.findDeclaration(searchUidByShortName(d, name));
      if (decl !== undefined) kinds[name] = decl.kind;
    }
    expect(kinds).toEqual({
      shape: "type",
      point: "type",
      area: "function",
      sum: "function",
      g: "function",
      g_gt: "theorem",
      sum_nonneg: "theorem",
      h: "function",
    });
  });

  test("theorem declaration", async () => {
    const d = await db();
    // `theorem g_gt x = g x > x [@@rw]`
    const gGt: Uid = searchUidByShortName(d, "g_gt");
    const g: Uid = searchUidByShortName(d, "g");

    const decl: Declaration | undefined = d.findDeclaration(gGt);
    expect(decl).toBeInstanceOf(TheoremDeclaration);

    // A theorem is stored under the uid of its linked function, which is also
    // available through `findFunction`.
    const linked: FunctionDefinition = (decl as TheoremDeclaration).function;
    expect(linked.name.equals(gGt)).toBe(true);
    expect(d.findFunction(gGt)).toBeDefined();

    const body: Term = linked.body;
    expect(body).toBeInstanceOf(Apply);

    // `g` is applied in the body, under the uid it is declared under
    const applied = uidSet();
    for (const subterm of body) {
      if (subterm instanceof Apply) {
        const f = subterm.function;
        if (f instanceof Symbol) {
          applied.add(f.symbol.id);
        }
      }
    }
    expect(applied.has(g)).toBe(true);
  });

  test("type definitions", async () => {
    const d = await db();
    // shape variant
    const shape: TypeDefinition | undefined = d.findType(searchUidByShortName(d, "shape"));
    expect(shape).toBeDefined();
    expect(shape!.kind).toBeInstanceOf(AlgebraicTypeKind);
    expect((shape!.kind as AlgebraicTypeKind).constructors.map((c) => c.name.shortName)).toEqual(["Circle", "Rect"]);

    // point record
    const point: TypeDefinition | undefined = d.findType(searchUidByShortName(d, "point"));
    expect(point).toBeDefined();
    expect(point!.kind).toBeInstanceOf(RecordTypeKind);
    expect((point!.kind as RecordTypeKind).fields.map((f) => f.name.shortName)).toEqual(["x", "y"]);

    // Functions are not types and vice versa
    expect(d.findType(searchUidByShortName(d, "area"))).toBeUndefined();
    expect(d.findFunction(searchUidByShortName(d, "shape"))).toBeUndefined();
  });

  test("type aliases are expanded", async () => {
    const d = await db();
    // `type my_int = int` is not a declaration of its own...
    expect(shortNames(d.decls.keys()).has("my_int")).toBe(false);
    expect(d.findTypeRe("my_int").size).toBe(0);
    expect(d.findDeclarationRe("my_int").size).toBe(0);

    // ...and declarations using it see `int` instead
    const addOne = d.findFunction(searchUidByShortName(d, "add_one"));
    expect(addOne).toBeDefined();
    expect(`${addOne!.type}`).toBe("int -> int");
  });

  test("find re matches full name from start", async () => {
    const d = await db();
    // The full name is `<short name>/<content hash>`
    expect(sameUids(d.findFunctionRe("sum/").keys(), [searchUidByShortName(d, "sum")])).toBe(true);
    expect(sameUids(d.findTypeRe("point/").keys(), [searchUidByShortName(d, "point")])).toBe(true);
    expect(sameUids(d.findDeclarationRe("g_gt/").keys(), [searchUidByShortName(d, "g_gt")])).toBe(true);

    // `re.match` semantics: anchored at the start, not at the end
    expect(d.findFunctionRe("um/").size).toBe(0);
    expect(d.findFunctionRe("sum").has(searchUidByShortName(d, "sum_nonneg"))).toBe(true);
  });

  // Rules
  // =====

  test("theorem as rewrite rule", async () => {
    const d = await db();
    const gGt: Uid = searchUidByShortName(d, "g_gt");
    expect(d.thmAsRw.get(gGt)).toHaveLength(1);
    expect(d.ruleSpecRwRules.get(gGt)).toHaveLength(1);
  });

  test("theorem as forward chaining rule", async () => {
    // `theorem sum_nonneg xs = ... ==> sum xs >= 0 [@@by auto] [@@fc]`
    const d = await db();
    const sumNonneg: Uid = searchUidByShortName(d, "sum_nonneg");

    expect(d.thmAsFc.get(sumNonneg), "sum_nonneg should become a fc rule").toHaveLength(1);
    expect(d.instRules.has(sumNonneg), "sum_nonneg should be in inst rules").toBe(true);
    expect(d.ruleSpecFc.get(sumNonneg), "sum_nonneg should be in rule spec fc").toHaveLength(1);

    // The trigger is indexed by the head of its pattern, here `sum`
    const sum = searchUidByShortName(d, "sum");
    const sumHeads: SymbolHead[] = [...d.fc.keys()].filter(
      (h): h is SymbolHead => h instanceof SymbolHead && h.uid.equals(sum),
    );
    expect(sumHeads, "sum should be a fc trigger head").toHaveLength(1);
    expect(d.fc.get(sumHeads[0]!), "sum should trigger exactly one fc rule").toHaveLength(1);
  });

  // Lambdas
  // =======

  function lambdasOfTerm(t: Term): Uid[] {
    const lams: Uid[] = [];
    for (const term of t) {
      if (term instanceof Symbol && term.symbol.id.shortName === "$lambda") {
        lams.push(term.symbol.id);
      }
    }
    return lams;
  }

  function lambdasOfFuncBody(fun: FunctionDefinition): Uid[] {
    return lambdasOfTerm(fun.body);
  }

  test("lifted lambdas share short name but have distinct uids", async () => {
    const d = await db();
    // `repr` of a function definition is `<FunctionDefinition {str}>`; its `toString` is the part checked
    // 1. `fun x -> x + 1` in `inc_all`
    const incAll: Uid = searchUidByShortName(d, "inc_all");
    const incAllF = d.findFunction(incAll);
    expect(incAllF).toBeDefined();
    const lambdasInIncAll = lambdasOfFuncBody(incAllF!);
    expect(lambdasInIncAll).toHaveLength(1);

    const lambdaInc: FunctionDefinition | undefined = d.findFunction(lambdasInIncAll[0]!);
    expect(lambdaInc).toBeDefined();
    expect(`${lambdaInc}`).toContain("x = (+ x 1)");

    // 2. `fun x -> x + y` in `add_all`
    const addAll: Uid = searchUidByShortName(d, "add_all");
    const addAllF = d.findFunction(addAll);
    expect(addAllF).toBeDefined();
    const lambdasInAddAll = lambdasOfFuncBody(addAllF!);
    expect(lambdasInAddAll).toHaveLength(1);

    const lambdaAdd: FunctionDefinition | undefined = d.findFunction(lambdasInAddAll[0]!);
    expect(lambdaAdd).toBeDefined();
    expect(`${lambdaAdd}`).toContain("y x = (+ x y)");

    // 3. `fun x -> x * y` in the goal of the `instance`
    const instances: ProofObligationTask[] = [];
    for (const t of await tasks()) {
      if (t instanceof ProofObligationTask && (await t.proofObligation()).isInstance) instances.push(t);
    }
    expect(instances).toHaveLength(1);
    const [, goal] = (await instances[0]!.proofObligation()).goal;
    const lambdasInGoal = lambdasOfTerm(goal);
    expect(lambdasInGoal).toHaveLength(1);

    const lambdaMul: FunctionDefinition | undefined = d.findFunction(lambdasInGoal[0]!);
    expect(lambdaMul).toBeDefined();
    expect(`${lambdaMul}`).toContain("y x = (* x y)");

    expect(
      [lambdaInc!.name.shortName, lambdaAdd!.name.shortName, lambdaMul!.name.shortName],
      "Lambdas are ambiguous in short name",
    ).toEqual(["$lambda", "$lambda", "$lambda"]);
  });

  // Prelude
  // =======

  test("prelude builtin types", async () => {
    const d = await db();
    for (const name of ["int", "bool", "float", "real", "string"]) {
      const ty = d.findType(searchUidByShortName(d, name));
      expect(ty).toBeDefined();
      expect(ty!.kind).toBeInstanceOf(BuiltinTypeKind);
    }
  });

  test("prelude algebraic types", async () => {
    const d = await db();
    const constructors: Record<string, string[]> = {};
    for (const name of ["list", "option", "Ordinal.t", "Peano_nat.t"]) {
      const ty = d.findType(searchUidByShortName(d, name));
      if (ty !== undefined && ty.kind instanceof AlgebraicTypeKind) {
        constructors[name] = ty.kind.constructors.map((c) => c.name.shortName);
      }
    }
    expect(constructors).toEqual({
      list: ["[]", "::"],
      option: ["None", "Some"],
      "Ordinal.t": ["Ordinal.Int", "Ordinal.Cons"],
      "Peano_nat.t": ["Peano_nat.Z", "Peano_nat.S"],
    });
  });

  test("prelude builtin uids have no content hash", async () => {
    // Declarations marked `[@@builtin ...]` are referred to by name alone and the others by `<short name>/<content hash>`
    const d = await db();
    for (const name of ["int", "list", "List.hd", "Ordinal.<<"]) {
      expect(searchUidByShortName(d, name).fullName).toBe(name);
    }
    for (const name of ["either", "LChar.t", "List.length", "List.rev"]) {
      expect(searchUidByShortName(d, name).fullName.startsWith(`${name}/`)).toBe(true);
    }
  });

  test("prelude functions", async () => {
    const d = await db();
    // List.length
    const length = d.findFunction(searchUidByShortName(d, "List.length"));
    expect(length).toBeDefined();
    expect(length!.kind).toBeInstanceOf(DefinedFunctionKind);
    expect(length!.arguments.map((a) => `${a}`)).toEqual(["l"]);
    expect(`${length!.type}`.endsWith(" list -> int")).toBe(true);
    // A recursive function is in its own clique
    expect(sameUids(length!.clique!, [length!.name])).toBe(true);

    // List.hd
    const hd = d.findFunction(searchUidByShortName(d, "List.hd"));
    expect(hd).toBeDefined();
    expect(hd!.kind).toBeInstanceOf(BuiltinFunctionKind);

    // id
    const ident = d.findFunction(searchUidByShortName(d, "id"));
    expect(ident).toBeDefined();
    expect(ident!.clique).toBeUndefined();
  });

  test("prelude theorems and rules", async () => {
    const d = await db();
    const theorems = shortNames([...d.decls].filter(([, decl]) => decl instanceof TheoremDeclaration).map(([u]) => u));
    for (const name of [
      // `[@@imandra_axiom]`s are theorems too
      "Int.mod_eq_emod",
      "List.append_to_nil",
      "List.append_single",
      "List.len_nonnegative",
      "List.len_zero_is_empty",
      "List.len_append",
      "LString.len_pos",
      "LString.len_zero_inversion",
    ]) {
      expect(theorems).toContain(name);
    }

    // `[@@rw]` / `[@@rewrite]` theorems
    const rw = shortNames(d.thmAsRw.keys());
    for (const name of ["List.append_to_nil", "List.append_single", "List.len_zero_is_empty", "List.len_append"]) {
      expect(rw).toContain(name);
    }

    // `[@@fc]` theorems
    const fc = shortNames(d.thmAsFc.keys());
    for (const name of ["List.len_nonnegative", "LString.len_pos", "LString.len_zero_inversion"]) {
      expect(fc).toContain(name);
    }
  });

  // Disabled symbols
  // ====================

  test("disabled symbols", async () => {
    const d = await db();
    expect([...d.disabled].map((u) => u.shortName)).toEqual(["g"]);
  });

  // xfail (strict): disabled uids are generative (e.g. `g/19390`), not the content hashed uid `g` is declared under
  test.fails("disabled symbols resolve to declarations", async () => {
    const d = await db();
    expect(sameUids(d.disabled, [searchUidByShortName(d, "g")])).toBe(true);
  });

  // References
  // ==========

  test("lookups agree with declarations", async () => {
    // `findFunction` and `findType` find what each declaration declares
    const d = await db();
    for (const [uid, decl] of d.decls) {
      if (decl instanceof TypeDeclaration) {
        expect(structEq(d.findType(uid), decl.type), `${uid}`).toBe(true);
      } else {
        expect(structEq(d.findFunction(uid), decl.function), `${uid}`).toBe(true);
      }
    }
  });

  test("symbols resolve to declarations", async () => {
    const d = await db();
    const bodies = [...d.decls.values()].filter((x) => !(x instanceof TypeDeclaration)).map((x) => (x as Exclude<Declaration, TypeDeclaration>).function.body);
    const symbols = uidSet(bodies.flatMap((body) => [...body].filter((x): x is Symbol => x instanceof Symbol).map((x) => x.symbol.id)));
    expect(symbols.size).toBeGreaterThan(0);
    expect([...symbols].filter((u) => d.findDeclaration(u) === undefined).map((u) => `${u}`)).toEqual([]);
  });

  function* constructedTypes(ty: Type): Iterable<ConstructedType> {
    if (ty instanceof ArrowType) {
      yield* constructedTypes(ty.domain);
      yield* constructedTypes(ty.codomain);
    } else if (ty instanceof TupleType) {
      for (const t of ty.elements) yield* constructedTypes(t);
    } else if (ty instanceof ConstructedType) {
      yield ty;
      for (const t of ty.arguments) yield* constructedTypes(t);
    } else if (ty instanceof TypeVariable) {
      // no type constructors
    }
  }

  test("type constructors resolve to type definitions", async () => {
    // Every type constructor in a function's type or terms is defined in the DB
    const d = await db();
    const functions = [...d.decls.values()]
      .filter((x): x is Exclude<Declaration, TypeDeclaration> => !(x instanceof TypeDeclaration))
      .map((x) => x.function);
    const types = [...functions.map((f) => f.type), ...functions.flatMap((f) => [...f.body].map((x) => x.type))];
    const constructors = uidSet(types.flatMap((ty) => [...constructedTypes(ty)].map((t) => t.ctor)));
    expect(constructors.size).toBeGreaterThan(0);
    expect([...constructors].filter((u) => d.findType(u) === undefined).map((u) => `${u}`)).toEqual([]);
  });

  test("rules refer to theorems", async () => {
    // Rules and triggers are derived from theorems, which they refer to by uid
    const d = await db();
    const uids: Uid[] = [
      ...d.thmAsRw.keys(),
      ...d.thmAsFc.keys(),
      ...d.thmAsElim.keys(),
      ...d.thmAsGen.keys(),
      ...d.instRules.keys(),
    ];
    uids.push(...[...d.rwRules.values()].flatMap((rs) => rs.map((r) => r.name)));
    uids.push(...[...d.fc.values(), ...d.gen.values()].flatMap((ts) => ts.map((t) => t.instantiationRuleName)));
    expect(uids.length).toBeGreaterThan(0);
    for (const u of uids) {
      expect(d.findDeclaration(u), `${u}`).toBeInstanceOf(TheoremDeclaration);
    }
  });

  // ====================

  test("every declaration converts from raw lib types", async () => {
    const d = await db();
    expect(d.decls.size).toBeGreaterThan(100);
    for (const [uid, decl] of d.decls) {
      expect(isDeclaration(decl)).toBe(true);
      expect(decl.id.equals(uid)).toBe(true);
      // Declarations compare by structure: converting the same library declaration again gives
      // an equal declaration (JS has no `hash`, so Python's hash checks have no counterpart)
      const declAgain = declarationOfLib(decl.raw);
      expect(structEq(declAgain, decl)).toBe(true);

      if (decl instanceof TypeDeclaration) {
        const ty = decl.type;
        const tyAgain = TypeDefinition.ofLib(ty.raw);
        expect(structEq(tyAgain, ty)).toBe(true);
      } else {
        // Same for terms
        const body = decl.function.body;
        const again = termOfLib(body.raw);
        expect(structEq(again, body)).toBe(true);
        for (const t of body) {
          expect(t).toBeInstanceOf(TermBase);
        }
      }
    }
  });
});

