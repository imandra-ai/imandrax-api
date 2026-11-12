/**
 * Property tests for `Term.toJs`, without a server
 *
 * They build random values as raw MIR terms, in the shapes the server sends, and check what
 * `toJs` makes of them. `tests/api/py/test_to_python.py` checks fixed values against the server.
 */

import fc from "fast-check";
import { describe, expect, test } from "vitest";

import { Constructed, DB, type JsValue, Rational, Uid, termOfLib } from "../../lib/index.js";
import * as lib from "../../lib/raw/types.js";

/**
 * Equal and of the same JS types throughout: unlike `==`, `true` is not `1n`
 *
 * Python's tuples and lists are both arrays in JS, so unlike Python this cannot tell them apart.
 */
function same(a: JsValue | undefined, b: JsValue | undefined): boolean {
  if (typeof a !== typeof b) {
    return false;
  }
  if (Array.isArray(a) || Array.isArray(b)) {
    return (
      Array.isArray(a) &&
      Array.isArray(b) &&
      a.length === b.length &&
      a.every((x: JsValue, i: number) => same(x, (b as readonly JsValue[])[i]))
    );
  }
  if (a instanceof Map || b instanceof Map) {
    if (!(a instanceof Map && b instanceof Map) || a.size !== b.size) return false;
    return [...a.keys()].every((k) => b.has(k) && same(a.get(k), b.get(k)));
  }
  if (a instanceof Constructed || b instanceof Constructed) {
    return a instanceof Constructed && b instanceof Constructed && a.name === b.name && same(a.args, b.args);
  }
  if (a instanceof Rational || b instanceof Rational) {
    return a instanceof Rational && a.equals(b);
  }
  return a === b;
}

// Raw terms, as the server sends them

type RawTerm = lib.Mir_Term;
type RawType = lib.Mir_Type;

function uid(name: string): lib.Uid {
  return new lib.Uid(name, new lib.Uid_view_Persistent());
}

function ty(name: string, ...args: RawType[]): RawType {
  return new lib.Mir_Type(new lib.Ty_view_view_Constr([uid(name), args]));
}

/** `args[0] -> ... -> ret` */
function arrows(args: RawType[], ret: RawType): RawType {
  for (const a of [...args].reverse()) {
    ret = new lib.Mir_Type(new lib.Ty_view_view_Arrow([null, a, ret]));
  }
  return ret;
}

function sym(name: string, t: RawType): lib.Mir_Applied_symbol {
  return new lib.Common_Applied_symbol_t_poly(
    new lib.Common_Typed_symbol_t_poly(uid(name), new lib.Common_Type_schema_t_poly([], t)),
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

/** Constructor `c` of type `t` applied to `args` */
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

const [INT, BOOL, STRING, REAL, UNIT] = ["int", "bool", "string", "real", "unit"].map((n) => ty(n)) as [
  RawType,
  RawType,
  RawType,
  RawType,
  RawType,
];
const [REC_T, VAR_T, NEST_T] = [ty("rec_t"), ty("var_t"), ty("nest_t")];

/**
 * A DB with the definitions of `var_t` and `nest_t`, of these types the raw terms stand for:
 *
 *     type rec_t = { a: int; b: bool list }
 *     type var_t = A of { x: int; y: string } | B of int * string | C
 *     type nest_t = N of { inner: var_t; k: int } | M
 */
function rawDb(): DB {
  const db = new DB(new lib.Common_Db_ser_t_poly([]), new Map());
  const variants: [string, [string, string[] | undefined, RawType[]][]][] = [
    [
      "var_t",
      [
        ["A", ["x", "y"], [INT, STRING]],
        ["B", undefined, [INT, STRING]],
        ["C", undefined, []],
      ],
    ],
    [
      "nest_t",
      [
        ["N", ["inner", "k"], [VAR_T, INT]],
        ["M", undefined, []],
      ],
    ],
  ];
  for (const [name, rows] of variants) {
    // the raw types are private, as in Python (`db._raw_tys`)
    db["rawTys"].set(
      new Uid(uid(name)),
      new lib.Ty_view_def_poly(
        uid(name),
        [],
        new lib.Ty_view_decl_Algebraic(rows.map(([c, ls, ts]) => new lib.Ty_view_adt_row(uid(c), ls?.map(uid), ts, undefined))),
        undefined,
        undefined,
      ),
    );
  }
  return db;
}

/** One of the types above, or ["list" | "option" | "tuple", argument types] */
type Ty = string | readonly [string, readonly Ty[]];

const types: fc.Arbitrary<Ty> = fc.letrec<{ ty: Ty }>((tie) => ({
  ty: fc.oneof(
    { depthSize: "small", withCrossShrink: true },
    fc.constantFrom("int", "bool", "string", "real", "unit", "rec_t", "var_t", "nest_t"),
    fc.tuple(fc.constantFrom("list", "option"), fc.tuple(tie("ty"))),
    fc.tuple(fc.constant("tuple"), fc.array(tie("ty"), { minLength: 2, maxLength: 3 })),
  ),
})).ty;

function rawType(t: Ty): RawType {
  if (typeof t === "string") {
    return ty(t);
  }
  const [k, us] = t;
  if (k === "tuple") {
    return new lib.Mir_Type(new lib.Ty_view_view_Tuple(us.map(rawType)));
  }
  return ty(k, rawType(us[0]!));
}

type TV = [RawTerm, JsValue];

/**
 * Constructor `c` applied to an inline record of `fields`
 *
 * The arguments are in declaration order, with or without labels, as the server sends them.
 */
function inlineRecord(c: string, fields: [string, fc.Arbitrary<TV>][], t: RawType, dropLabels: boolean): fc.Arbitrary<TV> {
  return fc.tuple(fc.tuple(...fields.map(([, s]) => s)), fc.boolean()).map(([vs, drop]) => {
    const labels = dropLabels && drop ? undefined : fields.map(([k]) => k);
    return [
      construct(
        c,
        vs.map(([x]) => x),
        t,
        labels,
      ),
      new Constructed(c, [new Map(fields.map(([k], i) => [k, vs[i]![1]]))]),
    ];
  });
}

/**
 * Values of type `t`, as raw terms and as the JS value
 *
 * If `dropLabels`, inline records can lack their labels.
 */
function values(t: Ty, dropLabels: boolean): fc.Arbitrary<TV> {
  if (typeof t === "string") {
    switch (t) {
      case "int":
        return fc.bigInt().map((n): TV => [constTerm(new lib.Const_Const_z(n), INT), n]);
      case "bool":
        return fc.boolean().map((b): TV => [constTerm(new lib.Const_Const_bool(b), BOOL), b]);
      case "string":
        return fc.string().map((s): TV => [constTerm(new lib.Const_Const_string(s), STRING), s]);
      case "real":
        return fc.tuple(fc.bigInt(), fc.bigInt({ min: 1n })).map(([n, d]): TV => {
          const q = new Rational(n, d);
          return [constTerm(new lib.Const_Const_q([q.num, q.den]), REAL), q];
        });
      case "unit":
        return fc.constant<TV>([construct("()", [], UNIT), []]);
      case "rec_t":
        return fc.tuple(values("int", dropLabels), values(["list", ["bool"]], dropLabels)).map(
          ([a, b]): TV => [
            term(
              new lib.Mir_Term_view_Record(
                [
                  [sym("a", INT), a[0]],
                  [sym("b", b[0].ty), b[0]],
                ],
                undefined,
              ),
              REC_T,
            ),
            new Map([
              ["a", a[1]],
              ["b", b[1]],
            ]),
          ],
        );
      case "var_t":
        return fc.oneof(
          inlineRecord(
            "A",
            [
              ["x", values("int", dropLabels)],
              ["y", values("string", dropLabels)],
            ],
            VAR_T,
            dropLabels,
          ),
          fc
            .tuple(values("int", dropLabels), values("string", dropLabels))
            .map(([x, y]): TV => [construct("B", [x[0], y[0]], VAR_T), new Constructed("B", [x[1], y[1]])]),
          fc.constant<TV>([construct("C", [], VAR_T), new Constructed("C")]),
        );
      case "nest_t":
        return fc.oneof(
          inlineRecord(
            "N",
            [
              ["inner", values("var_t", dropLabels)],
              ["k", values("int", dropLabels)],
            ],
            NEST_T,
            dropLabels,
          ),
          fc.constant<TV>([construct("M", [], NEST_T), new Constructed("M")]),
        );
    }
    throw new Error(`unknown type ${t}`);
  }
  const [k, us] = t;
  switch (k) {
    case "list": {
      const lt = rawType(t);
      return fc.array(values(us[0]!, dropLabels), { maxLength: 4 }).map((xs): TV => {
        let out = construct("[]", [], lt);
        for (const [x] of [...xs].reverse()) {
          out = construct("::", [x, out], lt);
        }
        return [out, xs.map(([, v]) => v)];
      });
    }
    case "option":
      return fc.oneof(
        fc.constant<TV>([construct("None", [], rawType(t)), new Constructed("None")]),
        values(us[0]!, dropLabels).map((x): TV => [construct("Some", [x[0]], rawType(t)), new Constructed("Some", [x[1]])]),
      );
    case "tuple":
      return fc.tuple(...us.map((u) => values(u, dropLabels))).map((xs): TV => [
        term(
          new lib.Mir_Term_view_Tuple(xs.map(([x]) => x)),
          rawType(t),
        ),
        xs.map(([, v]) => v),
      ]);
  }
  throw new Error(`unknown type ${k}`);
}

describe("toJs", () => {
  test("toJs", () => {
    fc.assert(
      fc.property(
        types.chain((t) => values(t, false)),
        ([raw, expected]) => {
          expect(same(termOfLib(raw).toJs(), expected)).toBe(true);
        },
      ),
    );
  });

  test("toJs with db restores inline record labels", () => {
    fc.assert(
      fc.property(
        types.chain((t) => values(t, true)),
        ([raw, expected]) => {
          expect(same(termOfLib(raw).toJs(rawDb()), expected)).toBe(true);
        },
      ),
    );
  });

  test("toJs without db keeps unlabeled arguments", () => {
    const raw = construct(
      "A",
      [constTerm(new lib.Const_Const_z(1n), INT), constTerm(new lib.Const_Const_string("a"), STRING)],
      VAR_T,
    );
    expect(same(termOfLib(raw).toJs(), new Constructed("A", [1n, "a"]))).toBe(true);
  });
});
