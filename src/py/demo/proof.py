"""Python views for `Imandrax_api_proof` OCaml module"""

from dataclasses import dataclass, field

from imandrax_api import lib

from .mir import Sequent, Term, Type, Uid, Variable, term_of_lib, type_of_lib


@dataclass(slots=True, frozen=True)
class TermArgument:
    term: Term
    _raw: lib.Proof_Arg[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class TypeArgument:
    type: Type
    _raw: lib.Proof_Arg[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class IntArgument:
    value: int
    _raw: lib.Proof_Arg[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class StringArgument:
    value: str
    _raw: lib.Proof_Arg[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class ListArgument:
    elements: tuple["ProofArgument", ...]
    _raw: lib.Proof_Arg[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class DictArgument:
    entries: tuple[tuple[str, "ProofArgument"], ...]
    _raw: lib.Proof_Arg[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class SequentArgument:
    sequent: Sequent
    _raw: lib.Proof_Arg[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


ProofArgument = (
    TermArgument
    | TypeArgument
    | IntArgument
    | StringArgument
    | ListArgument
    | DictArgument
    | SequentArgument
)


def proof_argument_of_lib(
    x: lib.Proof_Arg[lib.Mir_Term, lib.Mir_Type],
) -> ProofArgument:
    """Convert a library proof rule argument into the matching `ProofArgument` variant"""
    match x:
        case lib.Proof_Arg_A_term(arg=t):
            return TermArgument(term=term_of_lib(t), _raw=x)
        case lib.Proof_Arg_A_ty(arg=ty):
            return TypeArgument(type=type_of_lib(ty), _raw=x)
        case lib.Proof_Arg_A_int(arg=n):
            return IntArgument(value=n, _raw=x)
        case lib.Proof_Arg_A_string(arg=st):
            return StringArgument(value=st, _raw=x)
        case lib.Proof_Arg_A_list(arg=xs):
            return ListArgument(
                elements=tuple(proof_argument_of_lib(a) for a in xs), _raw=x
            )
        case lib.Proof_Arg_A_dict(arg=kvs):
            return DictArgument(
                entries=tuple((k, proof_argument_of_lib(v)) for k, v in kvs), _raw=x
            )
        case lib.Proof_Arg_A_seq(arg=sq):
            return SequentArgument(sequent=Sequent.of_lib(sq), _raw=x)


@dataclass(slots=True, frozen=True, kw_only=True)
class _ProofTerm:
    """A proof term"""

    id: int
    """unique generative id"""
    conclusion: Sequent
    _raw: lib.Proof_Proof_term_t_poly[lib.Mir_Term, lib.Mir_Type] = field(
        repr=False, compare=False
    )


@dataclass(slots=True, frozen=True)
class AssumeProof(_ProofTerm):
    """The rest of the proof is elsewhere. This can be replaced with the actual proof of this proof's
    goal."""


@dataclass(slots=True, frozen=True)
class SubstProof(_ProofTerm):
    """Instantiation of a previous step"""

    term_substitution: tuple[tuple[Variable, Term], ...]
    type_substitution: tuple[tuple[Uid, Type], ...]
    premise: "ProofTerm"


@dataclass(slots=True, frozen=True)
class DeductionProof(_ProofTerm):
    premises: tuple[tuple[str, tuple["ProofTerm", ...]], ...]
    """Groups of premises. The conclusion should be provable via QF_UF reasoning from the conjunction
    of all premises."""


@dataclass(slots=True, frozen=True)
class RuleProof(_ProofTerm):
    """A leaf rule, e.g. an axiom or a particular theory rule."""

    rule: str
    arguments: tuple[ProofArgument, ...]


ProofTerm = AssumeProof | SubstProof | DeductionProof | RuleProof
"""A proof term"""


def proof_term_of_lib(
    x: lib.Proof_Proof_term_t_poly[lib.Mir_Term, lib.Mir_Type],
) -> ProofTerm:
    """Convert a library proof term into the matching `ProofTerm` variant"""
    concl = Sequent.of_lib(x.concl)
    match x.view:
        case lib.Proof_View_T_assume():
            return AssumeProof(id=x.id, conclusion=concl, _raw=x)
        case lib.Proof_View_T_subst(t_subst=ts, ty_subst=tys, premise=p):
            return SubstProof(
                term_substitution=tuple(
                    (
                        Variable.of_lib(lib.Common_Var_t_poly(id=u, ty=ty)),
                        term_of_lib(t),
                    )
                    for (u, ty), t in ts
                ),
                type_substitution=tuple((Uid(u), type_of_lib(ty)) for u, ty in tys),
                premise=proof_term_of_lib(p),
                id=x.id,
                conclusion=concl,
                _raw=x,
            )
        case lib.Proof_View_T_deduction(premises=ps):
            return DeductionProof(
                premises=tuple(
                    (n, tuple(proof_term_of_lib(p) for p in group)) for n, group in ps
                ),
                id=x.id,
                conclusion=concl,
                _raw=x,
            )
        case lib.Proof_View_T_rule(rule=r, args=args):
            return RuleProof(
                rule=r,
                arguments=tuple(proof_argument_of_lib(a) for a in args),
                id=x.id,
                conclusion=concl,
                _raw=x,
            )
