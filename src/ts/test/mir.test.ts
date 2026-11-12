import { describe, expect, test } from "vitest";

import {
  Cname,
  Constructed,
  DB,
  Decomposition,
  FloatConst,
  Model,
  Rational,
  Sequent,
  Uid,
  type JsValue,
  tacticOfLib,
  termOfLib,
  typeOfLib,
  uidMap,
  uidSet,
  uptoOfLib,
  verifyKindOfLib,
} from "../lib/mir.js";
import * as lib from "../lib/raw/types.js";

/*
Raw MIR builders
================
*/

type RawTerm = lib.Mir_Term;
type RawType = lib.Mir_Type;

function uid(name: string): lib.Uid {
  return new lib.Uid(name, new lib.Uid_view_Persistent());
}

function genUid(name: string, id: bigint): lib.Uid {
  return new lib.Uid(name, new lib.Uid_view_Generative(id, new lib.Uid_gen_kind_Local()));
}

function ty(name: string, ...args: RawType[]): RawType {
  return new lib.Mir_Type(new lib.Ty_view_view_Constr([uid(name), args]));
}

function arrows(args: RawType[], ret: RawType): RawType {
  for (const a of [...args].reverse()) {
    ret = new lib.Mir_Type(new lib.Ty_view_view_Arrow([null, a, ret]));
  }
  return ret;
}

function sym(name: string, t: RawType, u: lib.Uid = uid(name)): lib.Mir_Applied_symbol {
  return new lib.Common_Applied_symbol_t_poly(
    new lib.Common_Typed_symbol_t_poly(u, new lib.Common_Type_schema_t_poly([], t)),
    [],
    t,
  );
}

function term(view: lib.Mir_Term_view<RawTerm, RawType>, t: RawType): RawTerm {
  return new lib.Mir_Term(view, t, undefined);
}

function constTerm(c: lib.Const, t: RawType): RawTerm {
  return term(new lib.Mir_Term_view_Const(c), t);
}

function construct(c: string, args: RawTerm[], t: RawType, labels?: string[]): RawTerm {
  return term(
    new lib.Mir_Term_view_Construct(
      sym(
        c,
        arrows(
          args.map((a) => a.ty),
          t,
        ),
      ),
      args,
      labels?.map(uid),
    ),
    t,
  );
}

function variable(name: string, id: bigint, t: RawType): RawTerm {
  return term(new lib.Mir_Term_view_Var(new lib.Common_Var_t_poly(genUid(name, id), t)), t);
}

const INT = ty("int");
const BOOL = ty("bool");
const STRING = ty("string");
const REAL = ty("real");
const UNIT = ty("unit");

const int = (n: bigint) => constTerm(new lib.Const_Const_z(n), INT);
const bool = (b: boolean) => constTerm(new lib.Const_Const_bool(b), BOOL);
const str = (s: string) => constTerm(new lib.Const_Const_string(s), STRING);

function list(t: RawType, xs: RawTerm[]): RawTerm {
  const lt = ty("list", t);
  let acc = construct("[]", [], lt);
  for (const x of [...xs].reverse()) {
    acc = construct("::", [x, acc], lt);
  }
  return acc;
}

/*
Tests
=====
*/

describe("Uid", () => {
  test("short and full names", () => {
    const p = new Uid(uid("foo"));
    expect(p.shortName).toBe("foo");
    expect(p.fullName).toBe("foo");
    expect(`${p}`).toBe("foo");

    const g = new Uid(genUid("x", 42n));
    expect(g.shortName).toBe("x");
    expect(g.fullName).toBe("x/42");

    const t = new Uid(
      new lib.Uid("y", new lib.Uid_view_Generative(7n, new lib.Uid_gen_kind_To_be_rewritten())),
    );
    expect(t.fullName).toBe("y/7[temp]");

    const chash = new Uint8Array([0xfb, 0xff, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06]);
    const c = new Uid(new lib.Uid("f", new lib.Uid_view_Cname(new lib.Cname_t_("f", chash, true))));
    expect(c.fullName).toBe("f/-_8BAgMEBQY");
    expect(c.cname?.isKey).toBe(true);
    expect(c.cname?.abbrev).toBe("f/-_8BAgME");
    expect(`${c.cname}`).toBe("f/-_8BAgMEBQY");
    expect(p.cname).toBeUndefined();

    const b = new Uid(
      new lib.Uid("+", new lib.Uid_view_Builtin(new lib.Builtin_data_kind_Logic_core("plus"))),
    );
    expect(b.fullName).toBe("+");
    expect(b.builtinKind?.kind).toBe("logicCore");
    expect(p.builtinKind).toBeUndefined();
  });

  test("equality is by value", () => {
    expect(new Uid(uid("a")).equals(new Uid(uid("a")))).toBe(true);
    expect(new Uid(uid("a")).equals(new Uid(uid("b")))).toBe(false);
    expect(new Uid(genUid("a", 1n)).equals(new Uid(genUid("a", 1n)))).toBe(true);
    expect(new Uid(genUid("a", 1n)).equals(new Uid(genUid("a", 2n)))).toBe(false);
    // a persistent and a builtin uid with the same name differ
    const b = new Uid(
      new lib.Uid("a", new lib.Uid_view_Builtin(new lib.Builtin_data_kind_Special("a"))),
    );
    expect(new Uid(uid("a")).equals(b)).toBe(false);
    const cn = (h: number[], isKey: boolean) =>
      new Uid(new lib.Uid("f", new lib.Uid_view_Cname(new lib.Cname_t_("f", new Uint8Array(h), isKey))));
    expect(cn([1, 2], true).equals(cn([1, 2], true))).toBe(true);
    expect(cn([1, 2], true).equals(cn([1, 3], true))).toBe(false);
    expect(cn([1, 2], true).equals(cn([1, 2], false))).toBe(false);
  });

  test("uid sets and maps compare keys by value", () => {
    const s = uidSet([new Uid(uid("a")), new Uid(uid("a")), new Uid(uid("b"))]);
    expect(s.size).toBe(2);
    expect(s.has(new Uid(uid("a")))).toBe(true);
    expect(s.has(new Uid(uid("c")))).toBe(false);

    const first = new Uid(uid("a"));
    const m = uidMap<number>([
      [first, 1],
      [new Uid(uid("b")), 2],
      [new Uid(uid("a")), 3],
    ]);
    // as a Python dict: the first key and its position stay, the value is replaced
    expect([...m.keys()].map((u) => u.fullName)).toEqual(["a", "b"]);
    expect([...m.keys()][0]).toBe(first);
    expect(m.get(new Uid(uid("a")))).toBe(3);
  });
});

describe("Cname", () => {
  test("ofLib and equality", () => {
    const x = Cname.ofLib(new lib.Cname_t_("n", new Uint8Array([0xff, 0xff, 0xff]), false));
    expect(`${x}`).toBe("n/____");
    expect(x.equals(Cname.ofLib(new lib.Cname_t_("n", new Uint8Array([0xff, 0xff, 0xff]), false)))).toBe(
      true,
    );
  });
});

describe("Rational", () => {
  test("is reduced with a positive denominator", () => {
    const q = new Rational(6n, -4n);
    expect(q.num).toBe(-3n);
    expect(q.den).toBe(2n);
    expect(`${q}`).toBe("-3/2");
    expect(`${new Rational(4n, 2n)}`).toBe("2");
    expect(`${new Rational(0n, -5n)}`).toBe("0");
    expect(new Rational(1n, 2n).equals(new Rational(2n, 4n))).toBe(true);
    expect(() => new Rational(1n, 0n)).toThrow(RangeError);
  });
});

describe("constants", () => {
  test("floats print as Python does", () => {
    const f = (x: number) => `${new FloatConst(x, new lib.Const_Const_float(x))}`;
    expect(f(1)).toBe("1.0");
    expect(f(-2.5)).toBe("-2.5");
    expect(f(0.1)).toBe("0.1");
    expect(f(1e16)).toBe("1e+16");
    expect(f(1.5e16)).toBe("1.5e+16");
    expect(f(123456789012345.0)).toBe("123456789012345.0");
    expect(f(1e-5)).toBe("1e-05");
    expect(f(0.0001)).toBe("0.0001");
    expect(f(Infinity)).toBe("inf");
    expect(f(NaN)).toBe("nan");
  });

  test("rational constants print as num/den", () => {
    const t = termOfLib(constTerm(new lib.Const_Const_q([4n, 2n]), REAL));
    expect(`${t}`).toBe("2/1");
  });
});

describe("types", () => {
  test("toString and equality", () => {
    const t = typeOfLib(arrows([INT, ty("list", BOOL)], new lib.Mir_Type(new lib.Ty_view_view_Tuple([INT, STRING]))));
    expect(t.kind).toBe("arrow");
    expect(`${t}`).toBe("int -> bool list -> int * string");
    const u = typeOfLib(arrows([INT, ty("list", BOOL)], new lib.Mir_Type(new lib.Ty_view_view_Tuple([INT, STRING]))));
    expect(t.equals(u)).toBe(true);
    expect(t.equals(typeOfLib(INT))).toBe(false);
    expect(`${typeOfLib(new lib.Mir_Type(new lib.Ty_view_view_Var(genUid("a", 3n))))}`).toBe("a/3");
  });
});

describe("terms", () => {
  test("toString", () => {
    const x = variable("x", 1n, INT);
    const f = term(new lib.Mir_Term_view_Sym(sym("f", arrows([INT], INT), genUid("f", 9n))), arrows([INT], INT));
    const app = term(new lib.Mir_Term_view_Apply(f, [x]), INT);
    expect(`${termOfLib(app)}`).toBe("(f/9 x)");
    expect(`${termOfLib(term(new lib.Mir_Term_view_Apply(f, []), INT))}`).toBe("f/9");

    const ite = term(new lib.Mir_Term_view_If([bool(true), int(1n), int(-2n)]), INT);
    expect(`${termOfLib(ite)}`).toBe("if true then 1 else -2");

    expect(`${termOfLib(construct("Some", [int(3n)], ty("option", INT)))}`).toBe("Some 3");
    expect(`${termOfLib(construct("B", [int(3n), str("s")], ty("t")))}`).toBe('B (3, "s")');
    expect(`${termOfLib(construct("A", [int(3n), str("s")], ty("t"), ["x", "y"]))}`).toBe(
      'A {x = 3; y = "s"}',
    );
    expect(`${termOfLib(construct("C", [], ty("t")))}`).toBe("C");

    const tup = term(new lib.Mir_Term_view_Tuple([int(1n), bool(false)]), INT);
    expect(`${termOfLib(tup)}`).toBe("(1, false)");

    const rec = term(
      new lib.Mir_Term_view_Record(
        [
          [sym("a", INT), int(1n)],
          [sym("b", BOOL), bool(true)],
        ],
        undefined,
      ),
      ty("r"),
    );
    expect(`${termOfLib(rec)}`).toBe("{a = 1; b = true}");
    const upd = term(new lib.Mir_Term_view_Record([[sym("a", INT), int(2n)]], variable("r", 4n, ty("r"))), ty("r"));
    expect(`${termOfLib(upd)}`).toBe("{r with a = 2}");

    const cs = term(
      new lib.Mir_Term_view_Case(x, [[sym("A", INT), int(1n)]], int(0n)),
      INT,
    );
    expect(`${termOfLib(cs)}`).toBe("match x with | A -> 1 | _ -> 0");

    const fld = term(new lib.Mir_Term_view_Field(sym("a", INT), variable("r", 4n, ty("r"))), INT);
    expect(`${termOfLib(fld)}`).toBe("r.a");
    const tf = term(new lib.Mir_Term_view_Tuple_field(1n, x), INT);
    expect(`${termOfLib(tf)}`).toBe("x.1");
    const ds = term(new lib.Mir_Term_view_Destruct(sym("Some", INT), 0n, x), INT);
    expect(`${termOfLib(ds)}`).toBe("Destruct(Some, 0, x)");
    const isa = term(new lib.Mir_Term_view_Is_a(sym("Some", INT), x), BOOL);
    expect(`${termOfLib(isa)}`).toBe("Is_a(Some, x)");
    const seq = term(new lib.Mir_Term_view_Sequence([[int(1n), int(2n)], int(3n)]), INT);
    expect(`${termOfLib(seq)}`).toBe("1; 2; 3");
  });

  test("iteration visits parents before children, left to right", () => {
    const t = termOfLib(term(new lib.Mir_Term_view_If([bool(true), construct("Some", [int(1n)], INT), int(2n)]), INT));
    expect([...t].map((u) => u.kind)).toEqual(["if", "constant", "construct", "constant", "constant"]);
    const seen: string[] = [];
    t.iter((u) => seen.push(`${u}`));
    expect(seen).toEqual(["if true then Some 1 else 2", "true", "Some 1", "1", "2"]);
  });
});

describe("toJs", () => {
  const js = (t: RawTerm, db?: DB): JsValue => termOfLib(t).toJs(db);

  test("scalars", () => {
    expect(js(int(-12345678901234567890n))).toBe(-12345678901234567890n);
    expect(js(bool(true))).toBe(true);
    expect(js(str("hi"))).toBe("hi");
    expect(js(constTerm(new lib.Const_Const_float(1.5), ty("float")))).toBe(1.5);
    const q = js(constTerm(new lib.Const_Const_q([3n, 6n]), REAL));
    expect(q).toBeInstanceOf(Rational);
    expect(`${q}`).toBe("1/2");
    const u = js(constTerm(new lib.Const_Const_uid(uid("u")), ty("uid")));
    expect(u).toBeInstanceOf(Uid);
  });

  test("containers", () => {
    expect(js(construct("()", [], UNIT))).toEqual([]);
    expect(js(list(INT, [int(1n), int(2n)]))).toEqual([1n, 2n]);
    expect(js(term(new lib.Mir_Term_view_Tuple([int(1n), str("a")]), INT))).toEqual([1n, "a"]);
    const rec = term(
      new lib.Mir_Term_view_Record(
        [
          [sym("a", INT), int(1n)],
          [sym("b", ty("list", BOOL)), list(BOOL, [bool(false)])],
        ],
        undefined,
      ),
      ty("rec_t"),
    );
    expect(js(rec)).toEqual(
      new Map<string, JsValue>([
        ["a", 1n],
        ["b", [false]],
      ]),
    );
    expect(js(construct("Some", [int(3n)], ty("option", INT)))).toEqual(new Constructed("Some", [3n]));
    expect(js(construct("A", [int(3n), str("s")], ty("var_t"), ["x", "y"]))).toEqual(
      new Constructed("A", [
        new Map<string, JsValue>([
          ["x", 3n],
          ["y", "s"],
        ]),
      ]),
    );
  });

  test("inline records are restored with a db", () => {
    const db = new DB(new lib.Common_Db_ser_t_poly([]), new Map());
    db["rawTys"].set(
      new Uid(uid("var_t")),
      new lib.Ty_view_def_poly(
        uid("var_t"),
        [],
        new lib.Ty_view_decl_Algebraic([
          new lib.Ty_view_adt_row(uid("A"), [uid("x"), uid("y")], [INT, STRING], undefined),
          new lib.Ty_view_adt_row(uid("B"), undefined, [INT, STRING], undefined),
        ]),
        undefined,
        undefined,
      ),
    );
    const a = construct("A", [int(3n), str("s")], ty("var_t"));
    expect(js(a)).toEqual(new Constructed("A", [3n, "s"]));
    expect(js(a, db)).toEqual(
      new Constructed("A", [
        new Map<string, JsValue>([
          ["x", 3n],
          ["y", "s"],
        ]),
      ]),
    );
    expect(js(construct("B", [int(3n), str("s")], ty("var_t")), db)).toEqual(new Constructed("B", [3n, "s"]));
    expect(db.findType(new Uid(uid("var_t")))?.kind.kind).toBe("algebraic");
    expect(`${db.findType(new Uid(uid("var_t")))}`).toBe("type var_t = A of {x : int; y : string} | B of int * string");
    expect([...db.findTypeRe("var").keys()].map((u) => u.shortName)).toEqual(["var_t"]);
    expect(db.findTypeRe("ar").size).toBe(0);
  });

  test("non-values throw", () => {
    expect(() => js(variable("x", 1n, INT))).toThrow(RangeError);
    expect(() => js(constTerm(new lib.Const_Const_real_approx("1.414?"), REAL))).toThrow(RangeError);
    const bad = construct("::", [int(1n), variable("xs", 2n, ty("list", INT))], ty("list", INT));
    expect(() => js(bad)).toThrow(/the list ends with xs/);
  });
});

describe("Sequent", () => {
  test("toString and lookups", () => {
    const s = Sequent.ofLib(
      new lib.Common_Sequent_t_poly<RawTerm>(
        [
          ["h", bool(true)],
          [undefined, bool(false)],
        ],
        [[undefined, int(1n)]],
      ),
    );
    expect(`${s}`).toBe(["h: true", "H1. false", "|" + "-".repeat(70), " 1"].join("\n"));
    expect(s.findTerm("h")?.[1].kind).toBe("constant");
    expect(s.findTerm("nope")).toBeUndefined();
    expect(s.hypothesisTerms.length).toBe(2);
    const empty = Sequent.ofLib(new lib.Common_Sequent_t_poly<RawTerm>([], []));
    expect(`${empty}`).toBe("|" + "-".repeat(70) + "\n false");
  });
});

describe("tactics and kinds", () => {
  test("tacticOfLib", () => {
    const t = tacticOfLib(
      new lib.Common_Tactic_t_poly_Default_termination(10n, new Set([uid("b"), uid("a"), uid("a")])),
    );
    expect(t.kind).toBe("defaultTermination");
    expect(`${t}`).toBe("DefaultTerminationTactic(max_steps=10, basis={a, b})");
    const thm = tacticOfLib(new lib.Common_Tactic_t_poly_Default_thm(5n, new lib.Upto_N_steps(3n)));
    expect(`${thm}`).toBe("DefaultTheoremTactic(max_steps=5, upto=3 steps)");
    const tst = tacticOfLib(new lib.Common_Tactic_t_poly_Default_test(undefined, 7n));
    expect(`${tst}`).toBe("DefaultTestTactic(num_steps=None, seed=7)");
    expect(uptoOfLib(new lib.Upto_N_steps(12n))).toBe(12);
    expect(verifyKindOfLib(new lib.Common_Verify_kind_K_instance())).toBe("instance");
  });
});

describe("Model", () => {
  test("toJs keys clashing short names by full name", () => {
    const raw = new lib.Common_Model_t_poly<RawTerm, RawType>(
      [],
      [
        [sym("x", INT, genUid("x", 1n)), int(1n)],
        [sym("x", INT, genUid("x", 2n)), int(2n)],
        [sym("y", INT, genUid("y", 3n)), list(INT, [])],
      ],
      [],
      true,
      false,
      [],
    );
    const m = Model.ofLib(raw);
    expect(m.toJs()).toEqual(
      new Map<string, JsValue>([
        ["x/1", 1n],
        ["x/2", 2n],
        ["y", []],
      ]),
    );
    // constants are keyed by value
    const key = [...m.constants.keys()][0]!;
    expect(m.constants.get(key)).toBeDefined();
    const again = Model.ofLib(raw);
    expect(m.constants.get([...again.constants.keys()][0]!)).toBeDefined();
  });
});

describe("Decomposition", () => {
  test("region metadata", () => {
    const xsym = sym("x", INT, genUid("x", 1n));
    const model = new lib.Common_Model_t_poly<RawTerm, RawType>([], [[xsym, int(5n)]], [], true, true, []);
    const region = new lib.Common_Region_t_poly<RawTerm, RawType>(
      [bool(true)],
      int(6n),
      [
        ["model_eval", new lib.Common_Region_meta_Term(int(6n))],
        [
          "str",
          new lib.Common_Region_meta_Assoc([
            [
              "constraints",
              new lib.Common_Region_meta_List([new lib.Common_Region_meta_String("x > 0")]),
            ],
            ["invariant", new lib.Common_Region_meta_String("x + 1")],
          ]),
        ],
        ["q", new lib.Common_Region_meta_Real([2n, 4n])],
        ["n", new lib.Common_Region_meta_Null()],
      ],
      new lib.Common_Region_status_Feasible(model),
    );
    const d = Decomposition.ofLib(
      new lib.Common_Fun_decomp_t_poly(uid("f"), [new lib.Common_Var_t_poly(genUid("x", 1n), INT)], [region]),
    );
    const r = d.regions[0]!;
    expect(r.constraintsStr).toEqual(["x > 0"]);
    expect(r.invariantStr).toBe("x + 1");
    expect(`${r.modelEval}`).toBe("6");
    expect(r.sampleOutput()).toBe(6n);
    const sample = r.sample()!;
    expect(sample.get(new Uid(genUid("x", 1n)))).toBe(5n);
    expect(`${r.meta.get("q")}`).toBe("1/2");
    expect(r.meta.get("n")).toBeNull();
    expect(`${d}`).toBe("[<Region constraints: [true] invariant: 6 status: feasible>]");

    const bad = Decomposition.Region.ofLib(
      new lib.Common_Region_t_poly<RawTerm, RawType>(
        [],
        int(0n),
        [
          ["model_eval", new lib.Common_Region_meta_Int(3n)],
          ["str", new lib.Common_Region_meta_Assoc([["invariant", new lib.Common_Region_meta_Int(1n)]])],
        ],
        new lib.Common_Region_status_Unknown(),
      ),
    );
    expect(bad.model).toBeUndefined();
    expect(bad.sample()).toBeUndefined();
    expect(bad.constraintsStr).toBeUndefined();
    expect(() => bad.modelEval).toThrow(/expected a term/);
    expect(() => bad.invariantStr).toThrow(/as a string/);
  });
});

describe("DB", () => {
  test("an empty database", () => {
    const db = new DB(new lib.Common_Db_ser_t_poly([]), new Map());
    expect(db.decls.size).toBe(0);
    expect(db.findDeclaration(new Uid(uid("f")))).toBeUndefined();
    expect(`${db}`.split("\n")[0]).toBe("decls: 0");
    expect(`${db}`).toContain("rule_spec_rw_rules: {}");
  });

  test("a missing storage entry is an unexpected response", () => {
    expect(
      () => new DB(new lib.Common_Db_ser_t_poly([new lib.Ca_store_Ca_ptr_Raw("k")]), new Map()),
    ).toThrow(/missing storage entry/);
  });
});

