"""Serializable report"""

from __future__ import annotations

import zlib
from dataclasses import dataclass, field
from enum import KEEP, Flag

from imandrax_api import lib
from mir import (
    InstantiationRule,
    Model,
    RewriteRule,
    Sequent,
    Term,
    Uid,
    Variable,
    term_of_lib,
)


@dataclass(slots=True, frozen=True)
class PlainText:
    text: str
    _raw: lib.Report_Rtext_item[lib.Mir_Term] = field(repr=False, compare=False)

    def __str__(self) -> str:
        return self.text


@dataclass(slots=True, frozen=True)
class BoldText:
    text: str
    _raw: lib.Report_Rtext_item[lib.Mir_Term] = field(repr=False, compare=False)

    def __str__(self) -> str:
        return self.text


@dataclass(slots=True, frozen=True)
class ItalicText:
    text: str
    _raw: lib.Report_Rtext_item[lib.Mir_Term] = field(repr=False, compare=False)

    def __str__(self) -> str:
        return self.text


@dataclass(slots=True, frozen=True)
class Newline:
    _raw: lib.Report_Rtext_item[lib.Mir_Term] = field(repr=False, compare=False)

    def __str__(self) -> str:
        return "\n"


@dataclass(slots=True, frozen=True)
class NestedText:
    """Insert a rtext inside another"""

    text: RichText
    _raw: lib.Report_Rtext_item[lib.Mir_Term] = field(repr=False, compare=False)

    def __str__(self) -> str:
        return str(self.text)


@dataclass(slots=True, frozen=True)
class ListText:
    """List of items"""

    items: tuple[RichText, ...]
    _raw: lib.Report_Rtext_item[lib.Mir_Term] = field(repr=False, compare=False)

    def __str__(self) -> str:
        return f"[{'; '.join(str(i) for i in self.items)}]"


@dataclass(slots=True, frozen=True)
class UidText:
    uid: Uid
    _raw: lib.Report_Rtext_item[lib.Mir_Term] = field(repr=False, compare=False)

    def __str__(self) -> str:
        return str(self.uid)


@dataclass(slots=True, frozen=True)
class TermText:
    term: Term
    _raw: lib.Report_Rtext_item[lib.Mir_Term] = field(repr=False, compare=False)

    def __str__(self) -> str:
        return str(self.term)


@dataclass(slots=True, frozen=True)
class SequentText:
    sequent: Sequent
    _raw: lib.Report_Rtext_item[lib.Mir_Term] = field(repr=False, compare=False)

    def __str__(self) -> str:
        return str(self.sequent)


@dataclass(slots=True, frozen=True)
class SubstitutionText:
    substitution: tuple[tuple[Term, Term], ...]
    _raw: lib.Report_Rtext_item[lib.Mir_Term] = field(repr=False, compare=False)

    def __str__(self) -> str:
        return f"[{'; '.join(f'({a}, {b})' for a, b in self.substitution)}]"


RichTextItem = (
    PlainText
    | BoldText
    | ItalicText
    | Newline
    | NestedText
    | ListText
    | UidText
    | TermText
    | SequentText
    | SubstitutionText
)


@dataclass(slots=True, frozen=True)
class RichText:
    """Rich text"""

    items: tuple[RichTextItem, ...]
    _raw: lib.Report_Rtext[lib.Mir_Term] = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Report_Rtext[lib.Mir_Term]) -> RichText:
        return cls(items=tuple(rich_text_item_of_lib(i) for i in x), _raw=x)

    def __str__(self) -> str:
        return "".join(str(i) for i in self.items)


def rich_text_item_of_lib(x: lib.Report_Rtext_item[lib.Mir_Term]) -> RichTextItem:
    """Convert a library rich text item into the matching `RichTextItem` variant"""
    match x:
        case lib.Report_Rtext_item_S(arg=s):
            return PlainText(text=s, _raw=x)
        case lib.Report_Rtext_item_B(arg=s):
            return BoldText(text=s, _raw=x)
        case lib.Report_Rtext_item_I(arg=s):
            return ItalicText(text=s, _raw=x)
        case lib.Report_Rtext_item_Newline():
            return Newline(_raw=x)
        case lib.Report_Rtext_item_Sub(arg=t):
            return NestedText(text=RichText.of_lib(t), _raw=x)
        case lib.Report_Rtext_item_L(arg=ts):
            return ListText(items=tuple(RichText.of_lib(t) for t in ts), _raw=x)
        case lib.Report_Rtext_item_Uid(arg=u):
            return UidText(uid=Uid(u), _raw=x)
        case lib.Report_Rtext_item_Term(arg=t):
            return TermText(term=term_of_lib(t), _raw=x)
        case lib.Report_Rtext_item_Sequent(arg=s):
            return SequentText(sequent=Sequent.of_lib(s), _raw=x)
        case lib.Report_Rtext_item_Subst(arg=s):
            return SubstitutionText(
                substitution=tuple((term_of_lib(a), term_of_lib(b)) for a, b in s),
                _raw=x,
            )


@dataclass(slots=True, frozen=True)
class Expansion:
    """Assertion that [lhs = rhs] because [lhs := f(...args)] and [rhs := body_f[...args]], by
    definition of [f]."""

    function: Uid
    lhs: Term
    """The function call [f t1…tn]"""
    rhs: Term
    """The expansion of [f]'s body with variables replaced with [t1…tn]. By definition of [f],
    [f(t1…tn)@lhs := rhs]"""
    _raw: lib.Report_Expansion[lib.Mir_Term] = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Report_Expansion[lib.Mir_Term]) -> Expansion:
        return cls(
            function=Uid(x.f_name),
            lhs=term_of_lib(x.lhs),
            rhs=term_of_lib(x.rhs),
            _raw=x,
        )


@dataclass(slots=True, frozen=True)
class Instantiation:
    assertion: Term
    """New boolean term that is true and can be added to the context"""
    from_rule: Uid
    """Name of the rule used"""
    _raw: lib.Report_Instantiation[lib.Mir_Term] = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Report_Instantiation[lib.Mir_Term]) -> Instantiation:
        return cls(
            assertion=term_of_lib(x.assertion), from_rule=Uid(x.from_rule), _raw=x
        )


# A bit field; the bits are allocated in the order of the fields in `logic_fragment.ml`, starting
# from the lowest one. Unknown bits are kept.


class LogicFragment(Flag, boundary=KEEP):
    DATATYPES = 1
    """Datatypes"""
    RECURSIVE_FUNCTIONS = 2
    """Recursive functions"""
    LRA = 4
    """LRA"""
    LIA = 8
    """LIA"""
    NRA = 16
    """NRA"""
    NIA = 32
    """NIA"""


@dataclass(slots=True, frozen=True)
class SmtProof:
    """A proof of [clauses /\\ bool_terms /\\ assumptions |- false], by deduction."""

    logic: LogicFragment
    """The logic used"""
    unsat_core: tuple[Term, ...]
    """Subset of assumptions used in the proof"""
    expansions: tuple[Expansion, ...]
    """Set of function expansions used in the proof"""
    instantiations: tuple[Instantiation, ...]
    """Set of rule instantiations used in the proof"""
    _raw: lib.Report_Smt_proof[lib.Mir_Term] = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Report_Smt_proof[lib.Mir_Term]) -> SmtProof:
        return cls(
            logic=LogicFragment(x.logic),
            unsat_core=tuple(term_of_lib(t) for t in x.unsat_core),
            expansions=tuple(Expansion.of_lib(e) for e in x.expansions),
            instantiations=tuple(Instantiation.of_lib(i) for i in x.instantiations),
            _raw=x,
        )


@dataclass(slots=True, frozen=True)
class Message:
    """Regular message"""

    text: RichText
    _raw: lib.Report_Atomic_event_Mir = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class Title:
    """More heavy message"""

    text: str
    _raw: lib.Report_Atomic_event_Mir = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class EnterWaterfall:
    variables: tuple[Variable, ...]
    goal: Term
    _raw: lib.Report_Atomic_event_Mir = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class EnterTactic:
    """Running the given tactic"""

    tactic: str
    _raw: lib.Report_Atomic_event_Mir = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class RewriteSuccess:
    rule: RewriteRule
    term: Term
    result: Term
    _raw: lib.Report_Atomic_event_Mir = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class RewriteFail:
    rule: RewriteRule
    term: Term
    reason: str
    _raw: lib.Report_Atomic_event_Mir = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class InstantiationSuccess:
    rule: InstantiationRule
    term: Term
    _raw: lib.Report_Atomic_event_Mir = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class WaterfallCheckpoint:
    goals: tuple[Sequent, ...]
    _raw: lib.Report_Atomic_event_Mir = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class InductionScheme:
    scheme: Term
    _raw: lib.Report_Atomic_event_Mir = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class AttackSubgoal:
    name: str
    goal: Sequent
    depth: int
    _raw: lib.Report_Atomic_event_Mir = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class SimplifyTerm:
    term: Term
    result: Term
    _raw: lib.Report_Atomic_event_Mir = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class SimplifyClause:
    clause: Term
    result: tuple[Term, ...]
    _raw: lib.Report_Atomic_event_Mir = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class ProvedBySmt:
    goal: Term
    proof: SmtProof
    _raw: lib.Report_Atomic_event_Mir = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class RefutedBySmt:
    goal: Term
    model: Model | None
    _raw: lib.Report_Atomic_event_Mir = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class FunctionExpansion:
    term: Term
    expansion: Term
    _raw: lib.Report_Atomic_event_Mir = field(repr=False, compare=False)


AtomicEvent = (
    Message
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
    | FunctionExpansion
)
"""An atomic event, happening at a given point in time"""


def atomic_event_of_lib(x: lib.Report_Atomic_event_Mir) -> AtomicEvent:
    """Convert a library atomic event into the matching `AtomicEvent` variant"""
    match x:
        case lib.Report_Atomic_event_poly_E_message(arg=t):
            return Message(text=RichText.of_lib(t), _raw=x)
        case lib.Report_Atomic_event_poly_E_title(arg=s):
            return Title(text=s, _raw=x)
        case lib.Report_Atomic_event_poly_E_enter_waterfall(vars=vs, goal=g):
            return EnterWaterfall(
                variables=tuple(Variable.of_lib(v) for v in vs),
                goal=term_of_lib(g),
                _raw=x,
            )
        case lib.Report_Atomic_event_poly_E_enter_tactic(arg=s):
            return EnterTactic(tactic=s, _raw=x)
        case lib.Report_Atomic_event_poly_E_rw_success(args=(r, t, u)):
            return RewriteSuccess(
                rule=RewriteRule.of_lib(r),
                term=term_of_lib(t),
                result=term_of_lib(u),
                _raw=x,
            )
        case lib.Report_Atomic_event_poly_E_rw_fail(args=(r, t, s)):
            return RewriteFail(
                rule=RewriteRule.of_lib(r), term=term_of_lib(t), reason=s, _raw=x
            )
        case lib.Report_Atomic_event_poly_E_inst_success(args=(r, t)):
            return InstantiationSuccess(
                rule=InstantiationRule.of_lib(r), term=term_of_lib(t), _raw=x
            )
        case lib.Report_Atomic_event_poly_E_waterfall_checkpoint(arg=gs):
            return WaterfallCheckpoint(
                goals=tuple(Sequent.of_lib(g) for g in gs), _raw=x
            )
        case lib.Report_Atomic_event_poly_E_induction_scheme(arg=t):
            return InductionScheme(scheme=term_of_lib(t), _raw=x)
        case lib.Report_Atomic_event_poly_E_attack_subgoal(name=n, goal=g, depth=d):
            return AttackSubgoal(name=n, goal=Sequent.of_lib(g), depth=d, _raw=x)
        case lib.Report_Atomic_event_poly_E_simplify_t(args=(t, u)):
            return SimplifyTerm(term=term_of_lib(t), result=term_of_lib(u), _raw=x)
        case lib.Report_Atomic_event_poly_E_simplify_clause(args=(t, us)):
            return SimplifyClause(
                clause=term_of_lib(t), result=tuple(term_of_lib(u) for u in us), _raw=x
            )
        case lib.Report_Atomic_event_poly_E_proved_by_smt(args=(t, p)):
            return ProvedBySmt(goal=term_of_lib(t), proof=SmtProof.of_lib(p), _raw=x)
        case lib.Report_Atomic_event_poly_E_refuted_by_smt(args=(t, m)):
            return RefutedBySmt(
                goal=term_of_lib(t),
                model=None if m is None else Model.of_lib(m),
                _raw=x,
            )
        case lib.Report_Atomic_event_poly_E_fun_expansion(args=(t, u)):
            return FunctionExpansion(
                term=term_of_lib(t), expansion=term_of_lib(u), _raw=x
            )


@dataclass(slots=True, frozen=True)
class InstantEvent:
    timestamp: float
    """Instant at which the event happened"""
    event: AtomicEvent
    _raw: lib.Report_Report_event = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class EnterSpan:
    timestamp: float
    event: AtomicEvent
    _raw: lib.Report_Report_event = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class ExitSpan:
    timestamp: float
    _raw: lib.Report_Report_event = field(repr=False, compare=False)


LinearEvent = InstantEvent | EnterSpan | ExitSpan
"""An event in a linear report (ie an array of events)"""


def linear_event_of_lib(x: lib.Report_Report_event) -> LinearEvent:
    """Convert a library linear report event into the matching `LinearEvent` variant"""
    match x:
        case lib.Report_Event_t_linear_EL_atomic(ts=ts, ev=ev):
            return InstantEvent(timestamp=ts, event=atomic_event_of_lib(ev), _raw=x)
        case lib.Report_Event_t_linear_EL_enter_span(ts=ts, ev=ev):
            return EnterSpan(timestamp=ts, event=atomic_event_of_lib(ev), _raw=x)
        case lib.Report_Event_t_linear_EL_exit_span(ts=ts):
            return ExitSpan(timestamp=ts, _raw=x)


@dataclass(slots=True, frozen=True)
class Report:
    """A (serializable) linear report, ie. a sequence of events. Nesting events (enter span/exit
    span) need to be correctly balanced."""

    events: tuple[LinearEvent, ...]
    _raw: lib.Report_Report = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Report_Report) -> Report:
        return cls(events=tuple(linear_event_of_lib(e) for e in x.events), _raw=x)

    @classmethod
    def of_archive(cls, x: lib.In_mem_archive[lib.Report_Report]) -> Report:
        """Decode a report from the in-memory archive it is sent in"""
        if x.ty != "report_ser.mir":
            raise Exception(f"Unexpected report archive type '{x.ty}'")
        # Compressed archives hold raw deflate data, without a zlib header
        data = zlib.decompress(x.data, -zlib.MAX_WBITS) if x.compressed else x.data
        d = lib.twine.Decoder(data)
        return cls.of_lib(lib.Report_Report_of_twine(d=d, off=d.entrypoint()))
