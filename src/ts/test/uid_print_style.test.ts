import { afterEach, describe, expect, test } from "vitest";

import { Uid, termOfLib } from "../lib/internal/mir.js";
import * as lib from "../lib/raw/types.js";
import { getUidStyle, setUidStyle, type UidStyle, withUidStyle } from "../lib/uid_print_style.js";

/*
Raw terms whose uids all have a suffix
======================================
*/

type RawTerm = lib.Mir_Term;
type RawType = lib.Mir_Type;

const HASH = new Uint8Array([0, 1, 2, 3, 4, 5, 6, 7]);
const HASH_STR = "AAECAwQFBgc";

function cnameUid(name: string): lib.Uid {
  return new lib.Uid(name, new lib.Uid_view_Cname(new lib.Cname_t_(name, HASH, false)));
}

function localUid(name: string, id: bigint): lib.Uid {
  return new lib.Uid(name, new lib.Uid_view_Generative(id, new lib.Uid_gen_kind_Local()));
}

const T: RawType = new lib.Mir_Type(new lib.Ty_view_view_Constr([cnameUid("t"), []]));
const INT: RawType = new lib.Mir_Type(
  new lib.Ty_view_view_Constr([new lib.Uid("int", new lib.Uid_view_Persistent()), []]),
);

function sym(id: lib.Uid, t: RawType): lib.Mir_Applied_symbol {
  return new lib.Common_Applied_symbol_t_poly(
    new lib.Common_Typed_symbol_t_poly(id, new lib.Common_Type_schema_t_poly([], t)),
    [],
    t,
  );
}

function term(view: lib.Mir_Term_view<RawTerm, RawType>, t: RawType): RawTerm {
  return new lib.Mir_Term(view, t, undefined);
}

const ONE = term(new lib.Mir_Term_view_Const(new lib.Const_Const_z(1n)), INT);

// `A {x = 1}`, of type `t`
const CONSTRUCT = term(
  new lib.Mir_Term_view_Construct(sym(cnameUid("A"), T), [ONE], [cnameUid("x")]),
  T,
);
// `f.y`, where `f` is a local variable
const FIELD = term(
  new lib.Mir_Term_view_Field(
    sym(cnameUid("y"), INT),
    term(new lib.Mir_Term_view_Var(new lib.Common_Var_t_poly(localUid("f", 3n), T)), T),
  ),
  INT,
);

const printed = (t: RawTerm): string => `${termOfLib(t)}`;

/*
Tests
=====
*/

describe("uid print style", () => {
  afterEach(() => setUidStyle("full"));

  test("default is full", () => {
    expect(getUidStyle()).toBe("full");
    expect(printed(CONSTRUCT)).toBe(`A/${HASH_STR} {x/${HASH_STR} = 1}`);
    expect(printed(FIELD)).toBe(`f/3.y/${HASH_STR}`);
  });

  test("short names drop every suffix", () => {
    withUidStyle("short", () => {
      expect(printed(CONSTRUCT)).toBe("A {x = 1}");
      expect(printed(FIELD)).toBe("f.y");
    });
  });

  test("a uid follows the style", () => {
    const u = new Uid(cnameUid("g"));
    expect(`${u}`).toBe(`g/${HASH_STR}`);
    expect(withUidStyle("short", () => `${u}`)).toBe("g");
  });

  test("setUidStyle is global", () => {
    setUidStyle("short");
    expect(printed(FIELD)).toBe("f.y");
    setUidStyle("full");
    expect(printed(FIELD)).toBe(`f/3.y/${HASH_STR}`);
  });

  test("the scoped style wins and is restored", () => {
    setUidStyle("short");
    withUidStyle("full", () => {
      expect(getUidStyle()).toBe("full");
      withUidStyle("short", () => expect(getUidStyle()).toBe("short"));
      expect(getUidStyle()).toBe("full");
    });
    expect(getUidStyle()).toBe("short");
  });

  test("setUidStyle inside withUidStyle holds after it", () => {
    withUidStyle("full", () => setUidStyle("short"));
    expect(getUidStyle()).toBe("short");
  });

  test("the scoped style is restored on error", () => {
    expect(() =>
      withUidStyle("short", () => {
        throw new Error("boom");
      }),
    ).toThrow("boom");
    expect(getUidStyle()).toBe("full");
  });

  test("an invalid style is rejected", () => {
    expect(() => setUidStyle("long" as UidStyle)).toThrow(RangeError);
    expect(() => withUidStyle("long" as UidStyle, () => undefined)).toThrow(RangeError);
    expect(getUidStyle()).toBe("full");
  });

  test("a function returning a promise is rejected, by type and at run time", () => {
    // @ts-expect-error: an async function returns a promise
    expect(() => withUidStyle("short", async () => undefined)).toThrow(TypeError);
    // Not a `PromiseLike` to the type checker, so only caught at run time
    const thenable = { then: () => undefined };
    expect(() => withUidStyle("short", () => thenable)).toThrow(TypeError);
    expect(getUidStyle()).toBe("full");
  });

  test("native values do not depend on the style", () => {
    const t = termOfLib(CONSTRUCT);
    const full = t.toJs();
    const short = withUidStyle("short", () => t.toJs());
    expect(short).toEqual(full);
  });
});
