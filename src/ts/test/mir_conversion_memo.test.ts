/**
 * Converting lib data keeps the sharing of MIR terms and types
 *
 * The twine decoder returns one lib object for every reference to a shared term or type, so the
 * lib data is a graph. Converting it should give one client object per lib object, instead of
 * expanding the graph into a tree.
 *
 * The lib data is built by hand, sharing objects the way the decoder does.
 */
import { describe, expect, test } from "vitest";

import { activeLibMemo } from "../lib/lib_memo.js";
import { Apply, ArrowType, Decomposition, termOfLib } from "../lib/mir.js";
import { DeductionProof, proofTermOfLib } from "../lib/proof.js";
import * as lib from "../lib/raw/types.js";

type RawTerm = lib.Mir_Term;
type RawType = lib.Mir_Type;
type RawProofTerm = lib.Proof_Proof_term_t_poly<RawTerm, RawType>;

function mkUid(name: string): lib.Uid {
  return new lib.Uid(name, new lib.Uid_view_Persistent());
}

function mkConstr(name: string): RawType {
  return new lib.Mir_Type(new lib.Ty_view_view_Constr([mkUid(name), []]));
}

function mkArrow(dom: RawType, cod: RawType): RawType {
  return new lib.Mir_Type(new lib.Ty_view_view_Arrow([null, dom, cod]));
}

function mkVar(v: lib.Mir_Var): RawTerm {
  return new lib.Mir_Term(new lib.Mir_Term_view_Var(v), v.ty, undefined);
}

function mkApp(f: RawTerm, args: RawTerm[], ty: RawType): RawTerm {
  return new lib.Mir_Term(new lib.Mir_Term_view_Apply(f, args), ty, undefined);
}

const INT = mkConstr("int");
const BOOL = mkConstr("bool");
const X_VAR: lib.Mir_Var = new lib.Common_Var_t_poly(mkUid("x"), INT);
const X = mkVar(X_VAR);
const LT = mkVar(new lib.Common_Var_t_poly(mkUid("<"), mkArrow(INT, mkArrow(INT, BOOL))));
/** `x < x`: `x` is referenced twice, and `int` four times */
const X_LT_X = mkApp(LT, [X, X], BOOL);

function mkRegion(...constraints: RawTerm[]): lib.Mir_Region_Region {
  return new lib.Common_Region_t_poly(
    constraints,
    X,
    [],
    new lib.Common_Region_status_Unknown(),
  );
}

function mkAssume(concl: RawTerm, id: bigint): RawProofTerm {
  return new lib.Proof_Proof_term_t_poly(
    id,
    new lib.Common_Sequent_t_poly([], [[undefined, concl]]),
    new lib.Proof_View_T_assume(),
  );
}

describe("terms", () => {
  test("a term shares its subterms and types", () => {
    const t = termOfLib(X_LT_X);
    expect(t).toBeInstanceOf(Apply);
    const [x1, x2] = (t as Apply).arguments;
    // `x` converts once
    expect(x1).toBe(x2);
    const ltType = (t as Apply).function.type;
    expect(ltType).toBeInstanceOf(ArrowType);
    // `int` converts once
    expect((ltType as ArrowType).domain).toBe(x1!.type);
  });

  test("separate conversions don't share", () => {
    // The memo is per conversion: converting the same lib term twice gives two client terms
    expect(termOfLib(X_LT_X)).not.toBe(termOfLib(X_LT_X));
  });
});

describe("decomposition", () => {
  test("a decomposition shares across regions", () => {
    const d = Decomposition.ofLib(
      new lib.Common_Fun_decomp_t_poly(mkUid("f"), [X_VAR], [
        mkRegion(X_LT_X),
        mkRegion(X_LT_X, X_LT_X),
      ]),
    );
    const [r1, r2] = d.regions;
    expect(r1!.constraints[0]).toBe(r2!.constraints[0]);
    expect(r2!.constraints[0]).toBe(r2!.constraints[1]);
    expect(r1!.invariant).toBe(r2!.invariant);
    expect(d.arguments[0]!.type).toBe(r1!.invariant.type);
  });
});

describe("proof term", () => {
  test("a proof term shares across steps", () => {
    const p = proofTermOfLib(
      new lib.Proof_Proof_term_t_poly(
        0n,
        new lib.Common_Sequent_t_poly([], [[undefined, X_LT_X]]),
        new lib.Proof_View_T_deduction([["p", [mkAssume(X_LT_X, 1n), mkAssume(X_LT_X, 2n)]]]),
      ),
    );
    expect(p).toBeInstanceOf(DeductionProof);
    const [[, [p1, p2]]] = (p as DeductionProof).premises as [[string, [unknown, unknown]]];
    const concls = [p, p1, p2].map(
      (q) => (q as DeductionProof).conclusion.conclusions[0]![1],
    );
    expect(concls[0]).toBe(concls[1]);
    expect(concls[1]).toBe(concls[2]);
  });
});

describe("memo lifetime", () => {
  test("the memo is released after a conversion", () => {
    // The memo lives only while a conversion runs, so it keeps no lib object alive
    expect(activeLibMemo()).toBeUndefined();
    termOfLib(X_LT_X);
    expect(activeLibMemo()).toBeUndefined();
    Decomposition.ofLib(new lib.Common_Fun_decomp_t_poly(mkUid("f"), [], [mkRegion()]));
    expect(activeLibMemo()).toBeUndefined();
  });

  test("the memo is released when a conversion throws", () => {
    const bad = new lib.Mir_Type({} as lib.Mir_Type["view"]);
    expect(() => termOfLib(new lib.Mir_Term(X.view, bad, undefined))).toThrow();
    expect(activeLibMemo()).toBeUndefined();
  });
});
