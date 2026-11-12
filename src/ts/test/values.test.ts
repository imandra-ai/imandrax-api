import { describe, expect, test } from "vitest";

import { Rational, Uid as MirUid } from "../lib/mir.js";
import * as lib from "../lib/raw/types.js";
import * as values from "../lib/values.js";

type V = lib.Eval_Value_view<lib.Eval_Value, lib.Eval_Value_erased_closure>;

function uid(name: string): lib.Uid {
  return new lib.Uid(name, new lib.Uid_view_Persistent());
}

const box = (v: V) => new lib.Eval_Value(v);
const int = (n: bigint): V => new lib.Eval_Value_view_V_int(n);
const cstor = (name: string, idx: bigint, args: V[]): V =>
  new lib.Eval_Value_view_V_cstor([new lib.Eval_Value_cstor_descriptor(idx, uid(name)), args.map(box)]);

function list(xs: V[]): V {
  let acc = cstor("[]", 0n, []);
  for (const x of [...xs].reverse()) {
    acc = cstor("::", 1n, [x, acc]);
  }
  return acc;
}

describe("valueOfLib", () => {
  test("scalars", () => {
    expect(values.valueOfLib(new lib.Eval_Value_view_V_true()).kind).toBe("true");
    expect(`${values.valueOfLib(new lib.Eval_Value_view_V_false())}`).toBe("false");
    const n = values.valueOfLib(int(-7n));
    expect(n).toBeInstanceOf(values.Int);
    expect((n as values.Int).value).toBe(-7n);
    const r = values.valueOfLib(new lib.Eval_Value_view_V_real([6n, 4n]));
    expect(r.kind).toBe("real");
    expect((r as values.Real).value.equals(new Rational(3n, 2n))).toBe(true);
    expect(`${r}`).toBe("3/2");
    expect(`${values.valueOfLib(new lib.Eval_Value_view_V_real([4n, 2n]))}`).toBe("2");
    expect(`${values.valueOfLib(new lib.Eval_Value_view_V_string("hi"))}`).toBe('"hi"');
    const u = values.valueOfLib(new lib.Eval_Value_view_V_uid(uid("f")));
    expect(u.kind).toBe("uid");
    expect((u as values.Uid).uid).toBeInstanceOf(MirUid);
    expect(`${u}`).toBe("f");
    const c = values.valueOfLib(new lib.Eval_Value_view_V_closure(new lib.Eval_Value_erased_closure(2n)));
    expect((c as values.Closure).missing).toBe(2);
    expect(`${c}`).toBe("<closure missing=2>");
  });

  test("constructors, lists, tuples and records", () => {
    const some = values.valueOfLib(cstor("Some", 1n, [int(3n)]));
    expect(some.kind).toBe("constructor");
    expect((some as values.Constructor).index).toBe(1);
    expect(`${some}`).toBe("Some (3)");
    expect(`${values.valueOfLib(cstor("None", 0n, []))}`).toBe("None");
    expect(`${values.valueOfLib(list([int(1n), int(2n)]))}`).toBe("[1; 2]");
    expect(`${values.valueOfLib(list([]))}`).toBe("[]");
    // an improper list prints as constructors
    expect(`${values.valueOfLib(cstor("::", 1n, [int(1n), int(2n)]))}`).toBe(":: (1, 2)");

    const tup = values.valueOfLib(new lib.Eval_Value_view_V_tuple([box(int(1n)), box(new lib.Eval_Value_view_V_true())]));
    expect(`${tup}`).toBe("(1, true)");

    const rec = values.valueOfLib(
      new lib.Eval_Value_view_V_record([
        new lib.Eval_Value_record_descriptor(uid("r"), [uid("a"), uid("b"), uid("extra")]),
        [box(int(1n)), box(new lib.Eval_Value_view_V_string("s"))],
      ]),
    ) as values.Record;
    expect(rec.name).toBe("r");
    // as Python's `zip`: the extra field without a value is dropped
    expect([...rec.fields.keys()]).toEqual(["a", "b"]);
    expect(`${rec}`).toBe('{a = 1; b = "s"}');
  });

  test("quoted terms", () => {
    const ty = new lib.Mir_Type(new lib.Ty_view_view_Constr([uid("int"), []]));
    const body = new lib.Mir_Term(new lib.Mir_Term_view_Const(new lib.Const_Const_z(1n)), ty, undefined);
    const q = values.valueOfLib(
      new lib.Eval_Value_view_V_quoted_term([[new lib.Common_Var_t_poly(uid("x"), ty)], body]),
    ) as values.QuotedTerm;
    expect(q.variables.map((v) => `${v}`)).toEqual(["x"]);
    expect(`${q.body}`).toBe("1");
    expect(`${q}`).toBe("<quoted term>");
  });

  test("ordinals print in Cantor normal form", () => {
    const i = (n: bigint) => new lib.Eval_Ordinal_Int(n);
    const cons = (a: lib.Eval_Ordinal, n: bigint, b: lib.Eval_Ordinal) => new lib.Eval_Ordinal_Cons([a, n, b]);
    const ord = (o: lib.Eval_Ordinal) => `${values.valueOfLib(new lib.Eval_Value_view_V_ordinal(o))}`;
    expect(ord(i(5n))).toBe("5");
    expect(ord(cons(i(1n), 1n, i(0n)))).toBe("ω");
    expect(ord(cons(i(3n), 2n, cons(i(1n), 1n, i(5n))))).toBe("2·ω^3 + ω + 5");
    expect(ord(cons(cons(i(1n), 1n, i(0n)), 1n, i(0n)))).toBe("ω^(ω)");
  });
});
