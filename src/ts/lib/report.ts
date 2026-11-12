/**
 * Reports of the steps ImandraX took on a task
 *
 * A report is a flat sequence of timestamped events: instant events, and matching
 * enter/exit pairs that delimit spans such as a waterfall or tactic.
 * Events cover rewriting, instantiation, simplification, induction and SMT calls, and
 * free-form messages hold rich text.
 *
 * @module
 */

import { UnexpectedResponseError } from "./errors.js";
import {
  InstantiationRule,
  Model,
  RewriteRule,
  Sequent,
  type Term,
  Uid,
  Variable,
  termOfLib,
} from "./mir.js";
import * as twine from "./raw/twine.js";
import * as lib from "./raw/types.js";

/*
Rich text
=========
*/

type RawRtextItem = lib.Report_Rtext_item<lib.Mir_Term>;

export class PlainText {
  readonly kind = "plain";
  constructor(
    readonly text: string,
    readonly raw: RawRtextItem,
  ) {}

  toString(): string {
    return this.text;
  }
}

export class BoldText {
  readonly kind = "bold";
  constructor(
    readonly text: string,
    readonly raw: RawRtextItem,
  ) {}

  toString(): string {
    return this.text;
  }
}

export class ItalicText {
  readonly kind = "italic";
  constructor(
    readonly text: string,
    readonly raw: RawRtextItem,
  ) {}

  toString(): string {
    return this.text;
  }
}

export class Newline {
  readonly kind = "newline";
  constructor(readonly raw: RawRtextItem) {}

  toString(): string {
    return "\n";
  }
}

/** Insert a rtext inside another */
export class NestedText {
  readonly kind = "nested";
  constructor(
    readonly text: RichText,
    readonly raw: RawRtextItem,
  ) {}

  toString(): string {
    return `${this.text}`;
  }
}

/** List of items */
export class ListText {
  readonly kind = "list";
  constructor(
    readonly items: readonly RichText[],
    readonly raw: RawRtextItem,
  ) {}

  toString(): string {
    return `[${this.items.map((i) => `${i}`).join("; ")}]`;
  }
}

export class UidText {
  readonly kind = "uid";
  constructor(
    readonly uid: Uid,
    readonly raw: RawRtextItem,
  ) {}

  toString(): string {
    return `${this.uid}`;
  }
}

export class TermText {
  readonly kind = "term";
  constructor(
    readonly term: Term,
    readonly raw: RawRtextItem,
  ) {}

  toString(): string {
    return `${this.term}`;
  }
}

export class SequentText {
  readonly kind = "sequent";
  constructor(
    readonly sequent: Sequent,
    readonly raw: RawRtextItem,
  ) {}

  toString(): string {
    return `${this.sequent}`;
  }
}

export class SubstitutionText {
  readonly kind = "substitution";
  constructor(
    readonly substitution: readonly (readonly [Term, Term])[],
    readonly raw: RawRtextItem,
  ) {}

  toString(): string {
    return `[${this.substitution.map(([a, b]) => `(${a}, ${b})`).join("; ")}]`;
  }
}

export type RichTextItem =
  | PlainText
  | BoldText
  | ItalicText
  | Newline
  | NestedText
  | ListText
  | UidText
  | TermText
  | SequentText
  | SubstitutionText;

/** Rich text */
export class RichText {
  constructor(
    readonly items: readonly RichTextItem[],
    readonly raw: lib.Report_Rtext<lib.Mir_Term>,
  ) {}

  static ofLib(x: lib.Report_Rtext<lib.Mir_Term>): RichText {
    return new RichText(x.map(richTextItemOfLib), x);
  }

  toString(): string {
    return this.items.map((i) => `${i}`).join("");
  }
}

export function richTextItemOfLib(x: RawRtextItem): RichTextItem {
  if (x instanceof lib.Report_Rtext_item_S) return new PlainText(x.arg, x);
  if (x instanceof lib.Report_Rtext_item_B) return new BoldText(x.arg, x);
  if (x instanceof lib.Report_Rtext_item_I) return new ItalicText(x.arg, x);
  if (x instanceof lib.Report_Rtext_item_Newline) return new Newline(x);
  if (x instanceof lib.Report_Rtext_item_Sub) return new NestedText(RichText.ofLib(x.arg), x);
  if (x instanceof lib.Report_Rtext_item_L) return new ListText(x.arg.map((t) => RichText.ofLib(t)), x);
  if (x instanceof lib.Report_Rtext_item_Uid) return new UidText(new Uid(x.arg), x);
  if (x instanceof lib.Report_Rtext_item_Term) return new TermText(termOfLib(x.arg), x);
  if (x instanceof lib.Report_Rtext_item_Sequent) return new SequentText(Sequent.ofLib(x.arg), x);
  if (x instanceof lib.Report_Rtext_item_Subst) {
    return new SubstitutionText(
      x.arg.map(([a, b]) => [termOfLib(a), termOfLib(b)] as const),
      x,
    );
  }
  throw new UnexpectedResponseError(`unexpected rich text item: ${(x as object).constructor.name}`);
}

/*
SMT proofs
==========
*/

/**
 * Assertion that [lhs = rhs] because [lhs := f(...args)] and [rhs := body_f[...args]], by
 * definition of [f].
 */
export class Expansion {
  /** The expanded function [f] */
  readonly function: Uid;

  constructor(
    fn: Uid,
    /** The function call [f t1…tn] */
    readonly lhs: Term,
    /**
     * The expansion of [f]'s body with variables replaced with [t1…tn]. By definition of [f],
     * [f(t1…tn)@lhs := rhs]
     */
    readonly rhs: Term,
    readonly raw: lib.Report_Expansion<lib.Mir_Term>,
  ) {
    this.function = fn;
  }

  static ofLib(x: lib.Report_Expansion<lib.Mir_Term>): Expansion {
    return new Expansion(new Uid(x.f_name), termOfLib(x.lhs), termOfLib(x.rhs), x);
  }
}

export class Instantiation {
  constructor(
    /** New boolean term that is true and can be added to the context */
    readonly assertion: Term,
    /** Name of the rule used */
    readonly fromRule: Uid,
    readonly raw: lib.Report_Instantiation<lib.Mir_Term>,
  ) {}

  static ofLib(x: lib.Report_Instantiation<lib.Mir_Term>): Instantiation {
    return new Instantiation(termOfLib(x.assertion), new Uid(x.from_rule), x);
  }
}

/**
 * A logic fragment, one of the flags of `SmtProof.logic`
 *
 * - `datatypes`: Datatypes
 * - `recursiveFunctions`: Recursive functions
 * - `lra`: LRA
 * - `lia`: LIA
 * - `nra`: NRA
 * - `nia`: NIA
 */
export type LogicFragment = "datatypes" | "recursiveFunctions" | "lra" | "lia" | "nra" | "nia";

// A bit field; the bits are allocated in the order of the fields in `logic_fragment.ml`, starting
// from the lowest one.
const logicFragmentBits: readonly (readonly [LogicFragment, bigint])[] = [
  ["datatypes", 1n],
  ["recursiveFunctions", 2n],
  ["lra", 4n],
  ["lia", 8n],
  ["nra", 16n],
  ["nia", 32n],
];

/**
 * The fragments set in a logic bit field
 *
 * Python's `LogicFragment` flag keeps unknown bits; a set of names cannot, so they are only in
 * the raw bit field (`SmtProof.raw.logic`).
 */
function logicFragmentsOfLib(x: lib.Logic_fragment): ReadonlySet<LogicFragment> {
  return new Set(logicFragmentBits.filter(([, bit]) => (x & bit) !== 0n).map(([f]) => f));
}

/** A proof of [clauses /\ bool_terms /\ assumptions |- false], by deduction. */
export class SmtProof {
  constructor(
    /** The logic used */
    readonly logic: ReadonlySet<LogicFragment>,
    /** Subset of assumptions used in the proof */
    readonly unsatCore: readonly Term[],
    /** Set of function expansions used in the proof */
    readonly expansions: readonly Expansion[],
    /** Set of rule instantiations used in the proof */
    readonly instantiations: readonly Instantiation[],
    readonly raw: lib.Report_Smt_proof<lib.Mir_Term>,
  ) {}

  static ofLib(x: lib.Report_Smt_proof<lib.Mir_Term>): SmtProof {
    return new SmtProof(
      logicFragmentsOfLib(x.logic),
      x.unsat_core.map(termOfLib),
      x.expansions.map((e) => Expansion.ofLib(e)),
      x.instantiations.map((i) => Instantiation.ofLib(i)),
      x,
    );
  }
}

/*
Atomic events
=============
*/

type RawAtomicEvent = lib.Report_Atomic_event_Mir;

/** Regular message */
export class Message {
  readonly kind = "message";
  constructor(
    readonly text: RichText,
    readonly raw: RawAtomicEvent,
  ) {}
}

/** More heavy message */
export class Title {
  readonly kind = "title";
  constructor(
    readonly text: string,
    readonly raw: RawAtomicEvent,
  ) {}
}

export class EnterWaterfall {
  readonly kind = "enterWaterfall";
  constructor(
    readonly variables: readonly Variable[],
    readonly goal: Term,
    readonly raw: RawAtomicEvent,
  ) {}
}

/** Running the given tactic */
export class EnterTactic {
  readonly kind = "enterTactic";
  constructor(
    readonly tactic: string,
    readonly raw: RawAtomicEvent,
  ) {}
}

export class RewriteSuccess {
  readonly kind = "rewriteSuccess";
  constructor(
    readonly rule: RewriteRule,
    readonly term: Term,
    readonly result: Term,
    readonly raw: RawAtomicEvent,
  ) {}
}

export class RewriteFail {
  readonly kind = "rewriteFail";
  constructor(
    readonly rule: RewriteRule,
    readonly term: Term,
    readonly reason: string,
    readonly raw: RawAtomicEvent,
  ) {}
}

export class InstantiationSuccess {
  readonly kind = "instantiationSuccess";
  constructor(
    readonly rule: InstantiationRule,
    readonly term: Term,
    readonly raw: RawAtomicEvent,
  ) {}
}

export class WaterfallCheckpoint {
  readonly kind = "waterfallCheckpoint";
  constructor(
    readonly goals: readonly Sequent[],
    readonly raw: RawAtomicEvent,
  ) {}
}

export class InductionScheme {
  readonly kind = "inductionScheme";
  constructor(
    readonly scheme: Term,
    readonly raw: RawAtomicEvent,
  ) {}
}

export class AttackSubgoal {
  readonly kind = "attackSubgoal";
  constructor(
    readonly name: string,
    readonly goal: Sequent,
    readonly depth: number,
    readonly raw: RawAtomicEvent,
  ) {}
}

export class SimplifyTerm {
  readonly kind = "simplifyTerm";
  constructor(
    readonly term: Term,
    readonly result: Term,
    readonly raw: RawAtomicEvent,
  ) {}
}

export class SimplifyClause {
  readonly kind = "simplifyClause";
  constructor(
    readonly clause: Term,
    readonly result: readonly Term[],
    readonly raw: RawAtomicEvent,
  ) {}
}

export class ProvedBySmt {
  readonly kind = "provedBySmt";
  constructor(
    readonly goal: Term,
    readonly proof: SmtProof,
    readonly raw: RawAtomicEvent,
  ) {}
}

export class RefutedBySmt {
  readonly kind = "refutedBySmt";
  constructor(
    readonly goal: Term,
    readonly model: Model | undefined,
    readonly raw: RawAtomicEvent,
  ) {}
}

export class FunctionExpansion {
  readonly kind = "functionExpansion";
  constructor(
    readonly term: Term,
    readonly expansion: Term,
    readonly raw: RawAtomicEvent,
  ) {}
}

/** An atomic event, happening at a given point in time */
export type AtomicEvent =
  | Message
  | Title
  | EnterWaterfall
  | EnterTactic
  | RewriteSuccess
  | RewriteFail
  | InstantiationSuccess
  | WaterfallCheckpoint
  | InductionScheme
  | AttackSubgoal
  | SimplifyTerm
  | SimplifyClause
  | ProvedBySmt
  | RefutedBySmt
  | FunctionExpansion;

export function atomicEventOfLib(x: RawAtomicEvent): AtomicEvent {
  if (x instanceof lib.Report_Atomic_event_poly_E_message) return new Message(RichText.ofLib(x.arg), x);
  if (x instanceof lib.Report_Atomic_event_poly_E_title) return new Title(x.arg, x);
  if (x instanceof lib.Report_Atomic_event_poly_E_enter_waterfall) {
    return new EnterWaterfall(
      x.vars.map((v) => Variable.ofLib(v)),
      termOfLib(x.goal),
      x,
    );
  }
  if (x instanceof lib.Report_Atomic_event_poly_E_enter_tactic) return new EnterTactic(x.arg, x);
  if (x instanceof lib.Report_Atomic_event_poly_E_rw_success) {
    const [r, t, u] = x.args;
    return new RewriteSuccess(RewriteRule.ofLib(r), termOfLib(t), termOfLib(u), x);
  }
  if (x instanceof lib.Report_Atomic_event_poly_E_rw_fail) {
    const [r, t, s] = x.args;
    return new RewriteFail(RewriteRule.ofLib(r), termOfLib(t), s, x);
  }
  if (x instanceof lib.Report_Atomic_event_poly_E_inst_success) {
    const [r, t] = x.args;
    return new InstantiationSuccess(InstantiationRule.ofLib(r), termOfLib(t), x);
  }
  if (x instanceof lib.Report_Atomic_event_poly_E_waterfall_checkpoint) {
    return new WaterfallCheckpoint(
      x.arg.map((g) => Sequent.ofLib(g)),
      x,
    );
  }
  if (x instanceof lib.Report_Atomic_event_poly_E_induction_scheme) {
    return new InductionScheme(termOfLib(x.arg), x);
  }
  if (x instanceof lib.Report_Atomic_event_poly_E_attack_subgoal) {
    return new AttackSubgoal(x.name, Sequent.ofLib(x.goal), Number(x.depth), x);
  }
  if (x instanceof lib.Report_Atomic_event_poly_E_simplify_t) {
    const [t, u] = x.args;
    return new SimplifyTerm(termOfLib(t), termOfLib(u), x);
  }
  if (x instanceof lib.Report_Atomic_event_poly_E_simplify_clause) {
    const [t, us] = x.args;
    return new SimplifyClause(termOfLib(t), us.map(termOfLib), x);
  }
  if (x instanceof lib.Report_Atomic_event_poly_E_proved_by_smt) {
    const [t, p] = x.args;
    return new ProvedBySmt(termOfLib(t), SmtProof.ofLib(p), x);
  }
  if (x instanceof lib.Report_Atomic_event_poly_E_refuted_by_smt) {
    const [t, m] = x.args;
    return new RefutedBySmt(termOfLib(t), m === undefined ? undefined : Model.ofLib(m), x);
  }
  if (x instanceof lib.Report_Atomic_event_poly_E_fun_expansion) {
    const [t, u] = x.args;
    return new FunctionExpansion(termOfLib(t), termOfLib(u), x);
  }
  throw new UnexpectedResponseError(`unexpected report event: ${(x as object).constructor.name}`);
}

/*
Linear events
=============
*/

export class InstantEvent {
  readonly kind = "instant";
  constructor(
    /** Instant at which the event happened */
    readonly timestamp: number,
    readonly event: AtomicEvent,
    readonly raw: lib.Report_Report_event,
  ) {}
}

export class EnterSpan {
  readonly kind = "enterSpan";
  constructor(
    readonly timestamp: number,
    readonly event: AtomicEvent,
    readonly raw: lib.Report_Report_event,
  ) {}
}

export class ExitSpan {
  readonly kind = "exitSpan";
  constructor(
    readonly timestamp: number,
    readonly raw: lib.Report_Report_event,
  ) {}
}

/** An event in a linear report (ie an array of events) */
export type LinearEvent = InstantEvent | EnterSpan | ExitSpan;

export function linearEventOfLib(x: lib.Report_Report_event): LinearEvent {
  if (x instanceof lib.Report_Event_t_linear_EL_atomic) {
    return new InstantEvent(x.ts, atomicEventOfLib(x.ev), x);
  }
  if (x instanceof lib.Report_Event_t_linear_EL_enter_span) {
    return new EnterSpan(x.ts, atomicEventOfLib(x.ev), x);
  }
  if (x instanceof lib.Report_Event_t_linear_EL_exit_span) return new ExitSpan(x.ts, x);
  throw new UnexpectedResponseError(`unexpected report event: ${(x as object).constructor.name}`);
}

/*
Reports
=======
*/

/** Decompress raw deflate data (without a zlib header), as `zlib.decompress(data, -MAX_WBITS)` */
async function inflateRaw(data: Uint8Array): Promise<Uint8Array> {
  const ds = new DecompressionStream("deflate-raw");
  const writer = ds.writable.getWriter();
  // errors also surface on the reading side, where they are thrown
  writer.write(data).catch(() => {});
  writer.close().catch(() => {});
  const reader = ds.readable.getReader();
  const chunks: Uint8Array[] = [];
  let length = 0;
  for (;;) {
    const { done, value } = await reader.read();
    if (done) break;
    chunks.push(value);
    length += value.length;
  }
  const out = new Uint8Array(length);
  let off = 0;
  for (const c of chunks) {
    out.set(c, off);
    off += c.length;
  }
  return out;
}

/**
 * A (serializable) linear report, ie. a sequence of events. Nesting events (enter span/exit
 * span) need to be correctly balanced.
 */
export class Report {
  constructor(
    readonly events: readonly LinearEvent[],
    readonly raw: lib.Report_Report,
  ) {}

  static ofLib(x: lib.Report_Report): Report {
    return new Report(x.events.map(linearEventOfLib), x);
  }

  /**
   * Decode a report from the in-memory archive it is sent in
   *
   * Asynchronous, unlike Python's `of_archive`: decompressing uses the web-standard
   * `DecompressionStream`, which has no synchronous API.
   */
  static async ofArchive(x: lib.In_mem_archive<lib.Report_Report>): Promise<Report> {
    if (x.ty !== "report_ser.mir") {
      throw new UnexpectedResponseError(`Unexpected report archive type '${x.ty}'`);
    }
    // Compressed archives hold raw deflate data, without a zlib header
    const data = x.compressed ? await inflateRaw(x.data) : x.data;
    const d = new twine.Decoder(data);
    return Report.ofLib(lib.Report_Report_of_twine(d, d.entrypoint()));
  }
}
