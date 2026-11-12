import { deflateRawSync } from "node:zlib";

import { describe, expect, test } from "vitest";

import { UnexpectedResponseError } from "../lib/errors.js";
import { proofTermOfLib, type SubstProof } from "../lib/proof.js";
import * as lib from "../lib/raw/types.js";
import { Report, SmtProof, atomicEventOfLib, linearEventOfLib } from "../lib/report.js";

type RawTerm = lib.Mir_Term;
type RawType = lib.Mir_Type;

function uid(name: string): lib.Uid {
  return new lib.Uid(name, new lib.Uid_view_Persistent());
}

const BOOL = new lib.Mir_Type(new lib.Ty_view_view_Constr([uid("bool"), []]));
const tru = new lib.Mir_Term(new lib.Mir_Term_view_Const(new lib.Const_Const_bool(true)), BOOL, undefined);
const seq = new lib.Common_Sequent_t_poly<RawTerm>([], [[undefined, tru]]);

describe("proofTermOfLib", () => {
  test("converts steps and their premises", () => {
    const assume = new lib.Proof_Proof_term_t_poly<RawTerm, RawType>(1n, seq, new lib.Proof_View_T_assume());
    const subst = new lib.Proof_Proof_term_t_poly<RawTerm, RawType>(
      2n,
      seq,
      new lib.Proof_View_T_subst([[[uid("x"), BOOL], tru]], [[uid("a"), BOOL]], assume),
    );
    const rule = new lib.Proof_Proof_term_t_poly<RawTerm, RawType>(
      3n,
      seq,
      new lib.Proof_View_T_rule("axiom", [
        new lib.Proof_Arg_A_int(4n),
        new lib.Proof_Arg_A_list([new lib.Proof_Arg_A_string("s")]),
        new lib.Proof_Arg_A_dict([["k", new lib.Proof_Arg_A_term(tru)]]),
      ]),
    );
    const ded = new lib.Proof_Proof_term_t_poly<RawTerm, RawType>(
      4n,
      seq,
      new lib.Proof_View_T_deduction([["g", [subst, rule]]]),
    );
    const p = proofTermOfLib(ded);
    expect(p.kind).toBe("deduction");
    expect(p.id).toBe(4);
    expect(`${p.conclusion}`).toBe("|" + "-".repeat(70) + "\n true");
    if (p.kind !== "deduction") throw new Error("unreachable");
    const [name, group] = p.premises[0]!;
    expect(name).toBe("g");
    expect(group.map((q) => q.kind)).toEqual(["subst", "rule"]);
    const s = group[0] as SubstProof;
    expect(`${s.termSubstitution[0]![0]}`).toBe("x");
    expect(`${s.typeSubstitution[0]![1]}`).toBe("bool");
    expect(s.premise.kind).toBe("assume");
    const r = group[1]!;
    if (r.kind !== "rule") throw new Error("unreachable");
    expect(r.rule).toBe("axiom");
    expect(r.arguments.map((a) => a.kind)).toEqual(["int", "list", "dict"]);
  });
});

describe("report", () => {
  test("logic fragments", () => {
    const p = SmtProof.ofLib(new lib.Report_Smt_proof<RawTerm>(1n | 4n | 32n | 128n, [tru], [], []));
    expect([...p.logic]).toEqual(["datatypes", "lra", "nia"]);
    expect(p.unsatCore.length).toBe(1);
  });

  test("events", () => {
    const msg = new lib.Report_Atomic_event_poly_E_message<RawTerm, RawType, RawTerm, RawType>([
      new lib.Report_Rtext_item_S("a "),
      new lib.Report_Rtext_item_B("b"),
      new lib.Report_Rtext_item_Newline(),
      new lib.Report_Rtext_item_L([[new lib.Report_Rtext_item_I("x")], [new lib.Report_Rtext_item_Term(tru)]]),
      new lib.Report_Rtext_item_Subst([[tru, tru]]),
    ]);
    const e = atomicEventOfLib(msg);
    expect(e.kind).toBe("message");
    if (e.kind !== "message") throw new Error("unreachable");
    expect(`${e.text}`).toBe("a b\n[x; true][(true, true)]");
    const ev = linearEventOfLib(new lib.Report_Event_t_linear_EL_enter_span(1.5, msg));
    expect(ev.kind).toBe("enterSpan");
    expect(ev.timestamp).toBe(1.5);
    const sub = atomicEventOfLib(
      new lib.Report_Atomic_event_poly_E_attack_subgoal<RawTerm, RawType, RawTerm, RawType>("g", seq, 2n),
    );
    expect(sub.kind === "attackSubgoal" && sub.depth).toBe(2);
  });

  // an empty report: a twine array with no items, followed by the entrypoint offset
  const emptyReport = new Uint8Array([0x60, 0x00]);

  test("ofArchive decodes plain and compressed archives", async () => {
    const plain = await Report.ofArchive(new lib.In_mem_archive_raw("report_ser.mir", false, emptyReport));
    expect(plain.events).toEqual([]);
    const compressed = new Uint8Array(deflateRawSync(emptyReport));
    const r = await Report.ofArchive(new lib.In_mem_archive_raw("report_ser.mir", true, compressed));
    expect(r.events).toEqual([]);
  });

  test("ofArchive rejects other archive types and bad data", async () => {
    await expect(Report.ofArchive(new lib.In_mem_archive_raw("other", false, emptyReport))).rejects.toThrow(
      UnexpectedResponseError,
    );
    await expect(
      Report.ofArchive(new lib.In_mem_archive_raw("report_ser.mir", true, new Uint8Array([0xff, 0xff, 0xff]))),
    ).rejects.toThrow();
  });
});
