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

export type {
  PlainText,
  BoldText,
  ItalicText,
  Newline,
  NestedText,
  ListText,
  UidText,
  TermText,
  SequentText,
  SubstitutionText,
  RichTextItem,
  RichText,
  Expansion,
  Instantiation,
  LogicFragment,
  SmtProof,
  Message,
  Title,
  EnterWaterfall,
  EnterTactic,
  RewriteSuccess,
  RewriteFail,
  InstantiationSuccess,
  WaterfallCheckpoint,
  InductionScheme,
  AttackSubgoal,
  SimplifyTerm,
  SimplifyClause,
  ProvedBySmt,
  RefutedBySmt,
  FunctionExpansion,
  AtomicEvent,
  InstantEvent,
  EnterSpan,
  ExitSpan,
  LinearEvent,
  Report,
} from "./internal/report.js";
