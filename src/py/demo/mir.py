import base64
import dataclasses
import re

from collections.abc import Callable, Iterable, Iterator, Sized
from dataclasses import dataclass, field
from functools import cached_property
from typing import ClassVar, Never, assert_never, override

from imandrax_api import lib

# Note: all __str__ in there are purely for debugging purposes. There is no MIR
# text format; MIR is only exchanged in byte-serialized form and there is no
# parser that would turn text into MIR data structures. The reason is that
# during the transition from IML to MIR there are a number of processes that
# ensure the resulting MIR has the right properties (e.g. content hashed
# functions, lifted lambdas, correct types, inferred type variables, ...), and
# those processes are not replicated on the client side.


class Uid:
    """A unique identifier"""

    def __init__(self, x: lib.Uid):
        self._raw = x

    @property
    def short_name(self) -> str:
        """The name without its disambiguating suffix"""
        return self._raw.name

    @property
    def full_name(self) -> str:
        """The name with its disambiguating suffix (generative id or content hash), if any"""
        match self._raw.view:
            case lib.Uid_view_Generative(id, gen_kind):
                suffix = ""
                match gen_kind:
                    case lib.Uid_gen_kind_To_be_rewritten():
                        suffix = "[temp]"
                    case lib.Uid_gen_kind_Local():
                        pass
                return f"{self._raw.name}/{id}{suffix}"
            case lib.Uid_view_Cname(cname):
                return f"{self._raw.name}/{base64.b64encode(cname.chash).decode()}"
            case lib.Uid_view_Persistent():
                return self._raw.name
            case lib.Uid_view_Builtin():
                return self._raw.name
            case _:
                return self._raw.name

    def __str__(self) -> str:
        return self.full_name

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Uid) and self._raw == other._raw

    def __hash__(self) -> int:
        return hash(self._raw)

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


class Type:
    """A type"""

    __slots__ = ()
    _raw: lib.Mir_Type

    def __str__(self) -> str:
        return "<type>"

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


def type_of_lib(x: lib.Mir_Type) -> Type:
    """Convert a library type into the matching `Type` subclass"""
    match x.view:
        case lib.Ty_view_view_Var(arg=v):
            return TypeVariable(name=Uid(v), _raw=x)
        case lib.Ty_view_view_Arrow(args=(_, tl, tr)):
            return ArrowType(domain=type_of_lib(tl), codomain=type_of_lib(tr), _raw=x)
        case lib.Ty_view_view_Tuple(arg=ts):
            return TupleType(elements=tuple(type_of_lib(t) for t in ts), _raw=x)
        case lib.Ty_view_view_Constr(args=(c, ts)):
            return ConstructedType(constructor=Uid(c), arguments=tuple(type_of_lib(t) for t in ts), _raw=x)
        case _:
            assert_never(x.view)


@dataclass(slots=True, frozen=True, repr=False)
class TypeVariable(Type):
    """A type variable"""

    name: Uid
    _raw: lib.Mir_Type = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return str(self.name)


@dataclass(slots=True, frozen=True, repr=False)
class ArrowType(Type):
    """A function type `a -> b`"""

    domain: Type
    codomain: Type
    _raw: lib.Mir_Type = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return f"{self.domain} -> {self.codomain}"


@dataclass(slots=True, frozen=True, repr=False)
class TupleType(Type):
    """A tuple type `a * b * ...`"""

    elements: tuple[Type, ...]
    """The component types"""
    _raw: lib.Mir_Type = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return " * ".join(str(t) for t in self.elements)


@dataclass(slots=True, frozen=True, repr=False)
class ConstructedType(Type):
    """A type constructor applied to type arguments, e.g. `int list`"""

    constructor: Uid
    arguments: tuple[Type, ...]
    _raw: lib.Mir_Type = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        elems = " ".join([f"{t}" for t in self.arguments])
        if len(elems) > 0:
            elems += " "
        return f"{elems}{self.constructor}"


@dataclass(slots=True, frozen=True, repr=False)
class TypeDefinition:
    """A type definition"""

    name: Uid
    """The type's name"""
    parameters: tuple[Uid, ...]
    """The type variables the type is parameterized over"""
    declaration: lib.Ty_view_decl[lib.Uid, lib.Mir_Type, Never]
    """How the type is defined: algebraic, record, skolem, builtin, ..."""
    clique: frozenset[Uid] | None
    """The mutually recursive types this type belongs to, if any"""
    timeout: int | None
    """The timeout for checking the definition, if any"""
    _raw: lib.Mir_Type_def = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Type_def) -> "TypeDefinition":
        return cls(
            name=Uid(x.name),
            parameters=tuple(Uid(p) for p in x.params),
            declaration=x.decl,
            clique=None if x.clique is None else frozenset(Uid(u) for u in x.clique),
            timeout=x.timeout,
            _raw=x,
        )

    def __str__(self) -> str:
        def constructor(r: lib.Ty_view_adt_row[lib.Uid, lib.Mir_Type]) -> str:
            if not r.args:
                return str(Uid(r.c))
            if r.labels is not None:
                fs = "; ".join(f"{Uid(l)} : {type_of_lib(t)}" for l, t in zip(r.labels, r.args))
                return f"{Uid(r.c)} of {{{fs}}}"
            return f"{Uid(r.c)} of {' * '.join(str(type_of_lib(t)) for t in r.args)}"

        params = "".join(f"{p} " for p in self.parameters)
        head = f"type {params}{self.name}"
        match self.declaration:
            case lib.Ty_view_decl_Algebraic(arg=rows):
                return f"{head} = {' | '.join(constructor(r) for r in rows)}"
            case lib.Ty_view_decl_Record(arg=rows):
                fs = "; ".join(f"{Uid(r.f)} : {type_of_lib(r.ty)}" for r in rows)
                return f"{head} = {{{fs}}}"
            case _:
                return head

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


@dataclass(slots=True, frozen=True)
class TypedSymbol:
    """A symbol together with its type schema"""

    id: Uid
    """The symbol's unique identifier"""
    type_schema: lib.Mir_Type_schema = field(hash=False)
    """The symbol's type schema"""
    _raw: lib.Mir_Typed_symbol = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Typed_symbol) -> "TypedSymbol":
        return cls(id=Uid(x.id), type_schema=x.ty, _raw=x)


@dataclass(slots=True, frozen=True, repr=False)
class AppliedSymbol:
    """A symbol instantiated at a concrete type"""

    symbol: TypedSymbol
    """The underlying typed symbol"""
    type_arguments: tuple[Type, ...]
    type: Type
    """The type at which the symbol is used"""
    _raw: lib.Mir_Applied_symbol = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Applied_symbol) -> "AppliedSymbol":
        return cls(
            symbol=TypedSymbol.of_lib(x.sym),
            type_arguments=tuple(type_of_lib(t) for t in x.args),
            type=type_of_lib(x.ty),
            _raw=x,
        )

    @property
    def id(self) -> Uid:
        """The symbol's unique identifier"""
        return self.symbol.id

    def __str__(self) -> str:
        return f"{self.id} : {self.type}"

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


class Term:
    """A term"""

    __slots__ = ()
    _raw: lib.Mir_Term

    @property
    def subterms(self) -> list["Term"]:
        """The immediate subterms of this term"""
        return []

    def __iter__(self) -> Iterator["Term"]:
        """Iterate over this term and all of its subterms, recursively, parents before children"""
        stack: list[Term] = [self]
        while stack:
            t = stack.pop()
            yield t
            stack.extend(reversed(t.subterms))

    def iter(self, f: Callable[["Term"], None]) -> None:
        """Call `f` on this term and on all of its subterms, recursively, parents before children"""
        for t in self:
            f(t)

    def __str__(self) -> str:
        return "<term>"

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


def term_of_lib(x: lib.Mir_Term) -> Term:
    """Convert a library term into the matching `Term` subclass, including all its subterms"""
    match x.view:
        case lib.Mir_Term_view_Const(arg=c):
            return Constant(value=c, _raw=x)
        case lib.Mir_Term_view_If(args=(c, a, b)):
            return If(condition=term_of_lib(c), then_branch=term_of_lib(a), else_branch=term_of_lib(b), _raw=x)
        case lib.Mir_Term_view_Apply(f=f, l=l):
            return Apply(function=term_of_lib(f), arguments=tuple(term_of_lib(t) for t in l), _raw=x)
        case lib.Mir_Term_view_Var(arg=v):
            return Var(var=v, _raw=x)
        case lib.Mir_Term_view_Sym(arg=s):
            return Symbol(symbol=AppliedSymbol.of_lib(s), _raw=x)
        case lib.Mir_Term_view_Construct(c=c, args=args, labels=labels):
            return Construct(
                constructor=AppliedSymbol.of_lib(c),
                arguments=tuple(term_of_lib(t) for t in args),
                labels=None if labels is None else tuple(Uid(l) for l in labels),
                _raw=x,
            )
        case lib.Mir_Term_view_Destruct(c=c, i=i, t=t):
            return Destruct(constructor=AppliedSymbol.of_lib(c), index=i, term=term_of_lib(t), _raw=x)
        case lib.Mir_Term_view_Is_a(c=c, t=t):
            return IsA(constructor=AppliedSymbol.of_lib(c), term=term_of_lib(t), _raw=x)
        case lib.Mir_Term_view_Tuple(l=l):
            return Tuple(elements=tuple(term_of_lib(t) for t in l), _raw=x)
        case lib.Mir_Term_view_Field(f=f, t=t):
            return Field(field=AppliedSymbol.of_lib(f), term=term_of_lib(t), _raw=x)
        case lib.Mir_Term_view_Tuple_field(i=i, t=t):
            return TupleField(index=i, term=term_of_lib(t), _raw=x)
        case lib.Mir_Term_view_Record(rows=rows, rest=rest):
            return Record(
                rows=tuple((AppliedSymbol.of_lib(f), term_of_lib(t)) for f, t in rows),
                rest=None if rest is None else term_of_lib(rest),
                _raw=x,
            )
        case lib.Mir_Term_view_Case(u=u, cases=cases, default=default):
            return Case(
                scrutinee=term_of_lib(u),
                cases=tuple((AppliedSymbol.of_lib(c), term_of_lib(t)) for c, t in cases),
                default=None if default is None else term_of_lib(default),
                _raw=x,
            )
        case lib.Mir_Term_view_Sequence(args=(prefix, last)):
            return Sequence(prefix=tuple(term_of_lib(t) for t in prefix), last=term_of_lib(last), _raw=x)
        case _:
            assert_never(x.view)


@dataclass(slots=True, frozen=True, repr=False)
class Constant(Term):
    """A constant"""

    value: lib.Const
    """The constant's value"""
    _raw: lib.Mir_Term = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        match self.value:
            case lib.Const_Const_float(arg=f):
                return str(f)
            case lib.Const_Const_string(arg=s):
                return f'"{s}"'
            case lib.Const_Const_z(arg=n):
                return str(n)
            case lib.Const_Const_q(arg=(num, den)):
                return f"{num}/{den}"
            case lib.Const_Const_real_approx(arg=s):
                return s
            case lib.Const_Const_uid(arg=u):
                return u.name
            case lib.Const_Const_bool(arg=b):
                return "true" if b else "false"


@dataclass(slots=True, frozen=True, repr=False)
class If(Term):
    """A conditional `if c then a else b`"""

    condition: Term
    """The condition"""
    then_branch: Term
    """The term evaluated if the condition is true"""
    else_branch: Term
    """The term evaluated if the condition is false"""
    _raw: lib.Mir_Term = field(repr=False, compare=False)

    @property
    @override
    def subterms(self) -> list[Term]:
        return [self.condition, self.then_branch, self.else_branch]

    @override
    def __str__(self) -> str:
        return f"if {self.condition} then {self.then_branch} else {self.else_branch}"


@dataclass(slots=True, frozen=True, repr=False)
class Apply(Term):
    """A function application"""

    function: Term
    """The function being applied"""
    arguments: tuple[Term, ...]
    """The arguments the function is applied to"""
    _raw: lib.Mir_Term = field(repr=False, compare=False)

    @property
    @override
    def subterms(self) -> list[Term]:
        return [self.function, *self.arguments]

    @override
    def __str__(self) -> str:
        elems = " ".join(str(t) for t in [self.function, *self.arguments])
        if len(self.arguments) == 0:
            return elems
        else:
            return f"({elems})"


@dataclass(slots=True, frozen=True, repr=False)
class Var(Term):
    """A variable"""

    var: lib.Mir_Var = field(hash=False)
    """The variable, with its type"""
    _raw: lib.Mir_Term = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return self.var.id.name


def var_term_of_var(x: lib.Mir_Var) -> Var:
    """Turn a library variable into a `Var` term"""
    return Var(var=x, _raw=lib.Mir_Term(view=(lib.Mir_Term_view_Var(arg=x)), ty=x.ty, sub_anchor=None))


@dataclass(slots=True, frozen=True, repr=False)
class Symbol(Term):
    """A symbol"""

    symbol: AppliedSymbol
    """The symbol, instantiated at its type"""
    _raw: lib.Mir_Term = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return self.symbol.id.full_name


@dataclass(slots=True, frozen=True, repr=False)
class Construct(Term):
    """A constructor applied to arguments"""

    constructor: AppliedSymbol
    """The constructor"""
    arguments: tuple[Term, ...]
    """The constructor's arguments"""
    labels: tuple[Uid, ...] | None
    """The argument labels, if the constructor takes labeled (record) arguments"""
    _raw: lib.Mir_Term = field(repr=False, compare=False)

    @property
    @override
    def subterms(self) -> list[Term]:
        return list(self.arguments)

    @override
    def __str__(self) -> str:
        name = self.constructor.id.short_name
        args = self.arguments
        if not args:
            return name
        if (labels := self.labels) is not None:
            fields = "; ".join(f"{l.full_name} = {a}" for l, a in zip(labels, args))
            return f"{name} {{{fields}}}"
        if len(args) == 1:
            return f"{name} {str(args[0])}"
        return f"{name} ({', '.join(str(a) for a in args)})"


@dataclass(slots=True, frozen=True, repr=False)
class Destruct(Term):
    """A destructor term. (The `index`-th argument of a term built with `constructor`.)"""

    constructor: AppliedSymbol
    """The constructor whose argument is extracted"""
    index: int
    """The position of the extracted argument"""
    term: Term
    """The term the argument is extracted from"""
    _raw: lib.Mir_Term = field(repr=False, compare=False)

    @property
    @override
    def subterms(self) -> list[Term]:
        return [self.term]

    @override
    def __str__(self) -> str:
        return f"Destruct({self.constructor.id.short_name}, {self.index}, {self.term})"


@dataclass(slots=True, frozen=True, repr=False)
class IsA(Term):
    """A test whether a term was built with `constructor`"""

    constructor: AppliedSymbol
    """The constructor tested for"""
    term: Term
    """The term being tested"""
    _raw: lib.Mir_Term = field(repr=False, compare=False)

    @property
    @override
    def subterms(self) -> list[Term]:
        return [self.term]

    @override
    def __str__(self) -> str:
        return f"Is_a({self.constructor.id.short_name}, {self.term})"


@dataclass(slots=True, frozen=True, repr=False)
class Tuple(Term):
    """A tuple"""

    elements: tuple[Term, ...]
    """The tuple's elements"""
    _raw: lib.Mir_Term = field(repr=False, compare=False)

    def __len__(self) -> int:
        return len(self.elements)

    @property
    @override
    def subterms(self) -> list[Term]:
        return list(self.elements)

    @override
    def __str__(self) -> str:
        return f"({', '.join(str(e) for e in self.elements)})"


@dataclass(slots=True, frozen=True, repr=False)
class Field(Term):
    """A record field"""

    field: AppliedSymbol
    """The field being accessed"""
    term: Term
    """The record whose field is accessed"""
    # `dataclasses.field` since `field` is shadowed by the field above
    _raw: lib.Mir_Term = dataclasses.field(repr=False, compare=False)

    @property
    @override
    def subterms(self) -> list[Term]:
        return [self.term]

    @override
    def __str__(self) -> str:
        return f"{str(self.term)}.{self.field.id.short_name}"


@dataclass(slots=True, frozen=True, repr=False)
class TupleField(Term):
    """A tuple field"""

    index: int
    """The position of the accessed component"""
    term: Term
    """The tuple whose component is accessed"""
    _raw: lib.Mir_Term = field(repr=False, compare=False)

    @property
    @override
    def subterms(self) -> list[Term]:
        return [self.term]

    @override
    def __str__(self) -> str:
        return f"{str(self.term)}.{self.index}"


@dataclass(slots=True, frozen=True, repr=False)
class Record(Term):
    """A record"""

    rows: tuple[tuple[AppliedSymbol, Term], ...]
    """The record's fields and their values"""
    rest: Term | None
    """The record being updated in `{rest with ...}`, if any"""
    _raw: lib.Mir_Term = field(repr=False, compare=False)

    @property
    @override
    def subterms(self) -> list[Term]:
        ts = [] if (rest := self.rest) is None else [rest]
        return ts + [t for _, t in self.rows]

    @override
    def __str__(self) -> str:
        fields = "; ".join(f"{f.id.short_name} = {t}" for f, t in self.rows)
        if (rest := self.rest) is not None:
            return f"{{{str(rest)} with {fields}}}"
        return f"{{{fields}}}"


@dataclass(slots=True, frozen=True, repr=False)
class Case(Term):
    """A pattern match on `scrutinee`"""

    scrutinee: Term
    """The term being matched on"""
    cases: tuple[tuple[AppliedSymbol, Term], ...]
    """The match arms, each a constructor and the term for that case"""
    default: Term | None
    """The term for the wildcard case `_`, if any"""
    _raw: lib.Mir_Term = field(repr=False, compare=False)

    @property
    @override
    def subterms(self) -> list[Term]:
        ts = [self.scrutinee, *(t for _, t in self.cases)]
        if (default := self.default) is not None:
            ts.append(default)
        return ts

    @override
    def __str__(self) -> str:
        arms = [f"| {c.id.short_name} -> {t}" for c, t in self.cases]
        if (default := self.default) is not None:
            arms.append(f"| _ -> {default}")
        return f"match {self.scrutinee} with {' '.join(arms)}"


@dataclass(slots=True, frozen=True, repr=False)
class Sequence(Term):
    """A sequence `t1; ...; tn; last`"""

    prefix: tuple[Term, ...]
    """The terms evaluated before `last`"""
    last: Term
    """The final term, whose value is the value of the sequence"""
    _raw: lib.Mir_Term = field(repr=False, compare=False)

    @property
    @override
    def subterms(self) -> list[Term]:
        return [*self.prefix, self.last]

    @override
    def __str__(self) -> str:
        return "; ".join(str(t) for t in [*self.prefix, self.last])


@dataclass(slots=True, frozen=True)
class Sequent:
    """A sequent"""

    hypotheses: tuple[tuple[str | None, Term], ...]
    """The hypotheses, each with an optional name"""
    conclusions: tuple[tuple[str | None, Term], ...]
    """The conclusions, each with an optional name"""
    _raw: lib.Mir_Sequent = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Sequent) -> "Sequent":
        return cls(
            hypotheses=tuple((n, term_of_lib(t)) for (n, t) in x.hyps),
            conclusions=tuple((n, term_of_lib(t)) for (n, t) in x.concls),
            _raw=x,
        )


@dataclass(slots=True, frozen=True, repr=False)
class FunctionDefinition:
    """A function definition"""

    name: Uid
    """The function's name"""
    type_parameters: tuple[Uid, ...]
    """The type variables the function's type is generic over"""
    type: Type
    """The function's type"""
    arguments: tuple[Var, ...]
    """The function's parameters"""
    body: Term
    """The function's body"""
    clique: frozenset[Uid] | None
    """The mutually recursive functions this function belongs to, if any"""
    kind: lib.Common_Fun_def_fun_kind
    """Whether the function is defined, builtin or opaque"""
    hints: lib.Mir_Hints
    """Prover hints attached to the definition"""
    _raw: lib.Mir_Fun_def = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Fun_def) -> "FunctionDefinition":
        return cls(
            name=Uid(x.f_name),
            type_parameters=tuple(Uid(p) for p in x.f_ty.params),
            type=type_of_lib(x.f_ty.ty),
            arguments=tuple(var_term_of_var(a) for a in x.f_args),
            body=term_of_lib(x.f_body),
            clique=None if x.f_clique is None else frozenset(Uid(u) for u in x.f_clique),
            kind=x.f_kind,
            hints=x.f_hints,
            _raw=x,
        )

    def __str__(self) -> str:
        return _definition_str("let", self)

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


def _definition_str(keyword: str, f: FunctionDefinition) -> str:
    """`<keyword> <name> <args> = <body>`"""
    args = "".join(f" {a}" for a in f.arguments)
    return f"{keyword} {f.name}{args} = {f.body}"


class Declaration:
    """A declaration: a function, type, theorem, rule spec or verify declaration"""

    __slots__ = ()
    _raw: lib.Mir_Decl

    kind: ClassVar[str]
    """The kind of declaration: `function`, `type`, `theorem`, `rule_spec` or `verify`"""

    @property
    def id(self) -> Uid:
        """The identifier of the declaration (for theorems etc., the linked function's)"""
        return _decl_uid(self._raw)

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


def declaration_of_lib(x: lib.Mir_Decl) -> Declaration:
    """Convert a library declaration into the matching `Declaration` subclass"""
    match x:
        case lib.Common_Decl_t_poly_Fun(arg=f):
            return FunctionDeclaration(function=FunctionDefinition.of_lib(f), _raw=x)
        case lib.Common_Decl_t_poly_Ty(arg=ty):
            return TypeDeclaration(type=TypeDefinition.of_lib(ty), _raw=x)
        case lib.Common_Decl_t_poly_Theorem(arg=thm):
            return TheoremDeclaration(theorem=thm, function=FunctionDefinition.of_lib(thm.thm_link), _raw=x)
        case lib.Common_Decl_t_poly_Rule_spec(arg=rs):
            return RuleSpecDeclaration(rule_spec=rs, function=FunctionDefinition.of_lib(rs.rule_spec_link), _raw=x)
        case lib.Common_Decl_t_poly_Verify(arg=v):
            return VerifyDeclaration(verify=v, function=FunctionDefinition.of_lib(v.verify_link), _raw=x)


@dataclass(slots=True, frozen=True, repr=False)
class FunctionDeclaration(Declaration):
    kind: ClassVar[str] = "function"

    function: FunctionDefinition
    """The function defined"""
    _raw: lib.Mir_Decl = field(repr=False, compare=False)

    def __str__(self) -> str:
        return str(self.function)


@dataclass(slots=True, frozen=True, repr=False)
class TypeDeclaration(Declaration):
    kind: ClassVar[str] = "type"

    type: TypeDefinition
    """The type defined"""
    _raw: lib.Mir_Decl = field(repr=False, compare=False)

    def __str__(self) -> str:
        return str(self.type)


@dataclass(slots=True, frozen=True, repr=False)
class TheoremDeclaration(Declaration):
    kind: ClassVar[str] = "theorem"

    theorem: lib.Mir_Theorem
    """The theorem"""
    function: FunctionDefinition
    """The linked function"""
    _raw: lib.Mir_Decl = field(repr=False, compare=False)

    def __str__(self) -> str:
        return _definition_str(self.kind, self.function)


@dataclass(slots=True, frozen=True, repr=False)
class RuleSpecDeclaration(Declaration):
    kind: ClassVar[str] = "rule_spec"

    rule_spec: lib.Common_Rule_spec_t_poly[lib.Mir_Term, lib.Mir_Type]
    """The rule spec"""
    function: FunctionDefinition
    """The linked function"""
    _raw: lib.Mir_Decl = field(repr=False, compare=False)

    def __str__(self) -> str:
        return _definition_str(self.kind, self.function)


@dataclass(slots=True, frozen=True, repr=False)
class VerifyDeclaration(Declaration):
    kind: ClassVar[str] = "verify"

    verify: lib.Common_Verify_t_poly[lib.Mir_Term, lib.Mir_Type]
    """The verify declaration"""
    function: FunctionDefinition
    """The linked function"""
    _raw: lib.Mir_Decl = field(repr=False, compare=False)

    def __str__(self) -> str:
        return _definition_str(self.kind, self.function)


def _decl_uid(d: lib.Mir_Decl) -> Uid:
    """The uid a declaration is stored under (for theorems etc., the linked function's)"""
    match d:
        case lib.Common_Decl_t_poly_Fun(arg=f):
            return Uid(f.f_name)
        case lib.Common_Decl_t_poly_Ty(arg=ty):
            return Uid(ty.name)
        case lib.Common_Decl_t_poly_Theorem(arg=thm):
            return Uid(thm.thm_link.f_name)
        case lib.Common_Decl_t_poly_Rule_spec(arg=rs):
            return Uid(rs.rule_spec_link.f_name)
        case lib.Common_Decl_t_poly_Verify(arg=v):
            return Uid(v.verify_link.f_name)


class PatternHead:
    """The head of a rule pattern: a symbol, a type, or a datatype operation"""

    __slots__ = ()
    _raw: lib.Mir_Pattern_head

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


def pattern_head_of_lib(x: lib.Mir_Pattern_head) -> PatternHead:
    """Convert a library pattern head into the matching `PatternHead` subclass"""
    match x:
        case lib.Common_Pattern_head_t_poly_PH_id(arg=uid):
            return SymbolHead(uid=Uid(uid), _raw=x)
        case lib.Common_Pattern_head_t_poly_PH_ty(arg=ty):
            return TypeHead(type=type_of_lib(ty), _raw=x)
        case lib.Common_Pattern_head_t_poly_PH_datatype_op():
            return DatatypeOpHead(_raw=x)


@dataclass(slots=True, frozen=True, repr=False)
class SymbolHead(PatternHead):
    uid: Uid
    """The symbol's uid"""
    _raw: lib.Mir_Pattern_head = field(repr=False, compare=False)

    def __str__(self) -> str:
        return str(self.uid)


@dataclass(slots=True, frozen=True, repr=False)
class TypeHead(PatternHead):
    type: Type
    """The type"""
    _raw: lib.Mir_Pattern_head = field(repr=False, compare=False)

    def __str__(self) -> str:
        return str(self.type)


@dataclass(slots=True, frozen=True, repr=False)
class DatatypeOpHead(PatternHead):
    _raw: lib.Mir_Pattern_head = field(repr=False, compare=False)

    def __str__(self) -> str:
        return "<datatype op>"


class DB:
    """A database of symbols

    Declarations, functions and types are each converted on first access.
    """

    def __init__(self, ds: lib.Mir_Db_ser, storage: dict[str, bytes]):
        # ds is a series of serialized DB operations; we reconstruct a concrete
        # database by replaying all the operations.

        self._raw = ds
        self._storage = storage
        self._disabled: set[Uid] = set()
        self._raw_tys: dict[Uid, lib.Mir_Type_def] = {}
        self._raw_funs: dict[Uid, lib.Mir_Fun_def] = {}
        self._raw_decls: dict[Uid, lib.Mir_Decl] = {}
        self._theorems: dict[Uid, lib.Mir_Theorem] = {}
        self._rule_specs: dict[Uid, lib.Common_Rule_spec_t_poly[lib.Mir_Term, lib.Mir_Type]] = {}
        self._rw_rules: dict[PatternHead, list[lib.Mir_Rewrite_rule]] = {}
        self._fc: dict[PatternHead, list[lib.Mir_Trigger]] = {}
        self._elim: dict[PatternHead, list[lib.Mir_Elimination_rule]] = {}
        self._gen: dict[PatternHead, list[lib.Mir_Trigger]] = {}
        self._admission: dict[Uid, lib.Common_Admission] = {}
        self._thm_as_rw: dict[Uid, list[lib.Mir_Rewrite_rule]] = {}
        self._thm_as_fc: dict[Uid, list[lib.Mir_Instantiation_rule]] = {}
        self._thm_as_elim: dict[Uid, list[lib.Mir_Elimination_rule]] = {}
        self._thm_as_gen: dict[Uid, lib.Mir_Instantiation_rule] = {}
        self._inst_rules: dict[Uid, lib.Mir_Instantiation_rule] = {}
        self._rule_spec_fc: dict[Uid, list[lib.Mir_Trigger]] = {}
        self._rule_spec_rw_rules: dict[Uid, list[lib.Mir_Rewrite_rule]] = {}
        for op in ds.ops:
            bs = storage[op.key]
            rw = lib.twine.Decoder(bs)
            instruction = lib.Common_Db_op_t_poly_of_twine(
                d=rw,
                off=rw.entrypoint(),
                d0=(lambda d, off: lib.Mir_Term_of_twine(d=d, off=off)),
                d1=(lambda d, off: lib.Mir_Type_of_twine(d=d, off=off)),
            )
            match instruction:
                case lib.Common_Db_op_t_poly_Op_enable(uids):
                    for uid in uids:
                        self._disabled.discard(Uid(uid))
                case lib.Common_Db_op_t_poly_Op_disable(uids):
                    for uid in uids:
                        self._disabled.add(Uid(uid))
                case lib.Common_Db_op_t_poly_Op_add_decls(decls):
                    for d in decls:
                        uid = _decl_uid(d)
                        self._raw_decls[uid] = d
                        match d:
                            case lib.Common_Decl_t_poly_Fun(arg=f):
                                self._raw_funs[uid] = f
                            case lib.Common_Decl_t_poly_Ty(arg=ty):
                                self._raw_tys[uid] = ty
                            case lib.Common_Decl_t_poly_Theorem(arg=thm):
                                self._theorems[uid] = thm
                                self._raw_funs[uid] = thm.thm_link
                            case lib.Common_Decl_t_poly_Rule_spec(arg=rs):
                                self._rule_specs[uid] = rs
                            case lib.Common_Decl_t_poly_Verify(arg=v):
                                self._raw_funs[uid] = v.verify_link
                case lib.Common_Db_op_t_poly_Op_add_rw((head, rule)):
                    self._rw_rules.setdefault(pattern_head_of_lib(head), []).append(rule)
                case lib.Common_Db_op_t_poly_Op_add_fc_trigger((head, trigger)):
                    self._fc.setdefault(pattern_head_of_lib(head), []).append(trigger)
                case lib.Common_Db_op_t_poly_Op_add_elim((head, rule)):
                    self._elim.setdefault(pattern_head_of_lib(head), []).append(rule)
                case lib.Common_Db_op_t_poly_Op_add_gen_trigger((head, trigger)):
                    self._gen.setdefault(pattern_head_of_lib(head), []).append(trigger)
                case lib.Common_Db_op_t_poly_Op_add_count_fun():
                    pass  # ignored in imandrax
                case lib.Common_Db_op_t_poly_Op_set_admission((uid, adm)):
                    self._admission[Uid(uid)] = adm
                case lib.Common_Db_op_t_poly_Op_set_thm_as_rw((uid, rules)):
                    self._thm_as_rw[Uid(uid)] = rules
                case lib.Common_Db_op_t_poly_Op_set_thm_as_fc((uid, rules)):
                    self._thm_as_fc[Uid(uid)] = rules
                case lib.Common_Db_op_t_poly_Op_set_thm_as_elim((uid, rules)):
                    self._thm_as_elim[Uid(uid)] = rules
                case lib.Common_Db_op_t_poly_Op_set_thm_as_gen((uid, rule)):
                    self._thm_as_gen[Uid(uid)] = rule
                case lib.Common_Db_op_t_poly_Op_add_instantiation_rule(rule):
                    self._inst_rules[Uid(rule.ir_from.f_name)] = rule
                case lib.Common_Db_op_t_poly_Op_add_rule_spec_fc_triggers((uid, triggers)):
                    self._rule_spec_fc.setdefault(Uid(uid), []).extend(triggers)
                case lib.Common_Db_op_t_poly_Op_add_rule_spec_rw((uid, rules)):
                    self._rule_spec_rw_rules.setdefault(Uid(uid), []).extend(rules)
                case _:
                    raise Exception("unknown MIR database operation")

    @cached_property
    def _tys(self) -> dict[Uid, TypeDefinition]:
        return {uid: TypeDefinition.of_lib(ty) for uid, ty in self._raw_tys.items()}

    @cached_property
    def _funs(self) -> dict[Uid, FunctionDefinition]:
        return {uid: FunctionDefinition.of_lib(f) for uid, f in self._raw_funs.items()}

    @cached_property
    def _decls(self) -> dict[Uid, Declaration]:
        return {uid: declaration_of_lib(d) for uid, d in self._raw_decls.items()}

    @property
    def disabled(self) -> set[Uid]:
        """Uids of disabled symbols"""
        return self._disabled

    @property
    def decls(self) -> dict[Uid, Declaration]:
        """All declarations, by uid"""
        return self._decls

    @property
    def rw_rules(self) -> dict[PatternHead, list[lib.Mir_Rewrite_rule]]:
        """Rewrite rules, by the uid of their pattern head"""
        return self._rw_rules

    @property
    def fc(self) -> dict[PatternHead, list[lib.Mir_Trigger]]:
        """Forward-chaining triggers, by the uid of their pattern head"""
        return self._fc

    @property
    def elim(self) -> dict[PatternHead, list[lib.Mir_Elimination_rule]]:
        """Elimination rules, by the uid of their pattern head"""
        return self._elim

    @property
    def gen(self) -> dict[PatternHead, list[lib.Mir_Trigger]]:
        """Generalization triggers, by the uid of their pattern head"""
        return self._gen

    @property
    def admission(self) -> dict[Uid, lib.Common_Admission]:
        """Admission information, by function uid"""
        return self._admission

    @property
    def thm_as_rw(self) -> dict[Uid, list[lib.Mir_Rewrite_rule]]:
        """Rewrite rules derived from each theorem, by theorem uid"""
        return self._thm_as_rw

    @property
    def thm_as_fc(self) -> dict[Uid, list[lib.Mir_Instantiation_rule]]:
        """Forward-chaining rules derived from each theorem, by theorem uid"""
        return self._thm_as_fc

    @property
    def thm_as_elim(self) -> dict[Uid, list[lib.Mir_Elimination_rule]]:
        """Elimination rules derived from each theorem, by theorem uid"""
        return self._thm_as_elim

    @property
    def thm_as_gen(self) -> dict[Uid, lib.Mir_Instantiation_rule]:
        """The generalization rule derived from each theorem, by theorem uid"""
        return self._thm_as_gen

    @property
    def inst_rules(self) -> dict[Uid, lib.Mir_Instantiation_rule]:
        """Instantiation rules, by the uid of the function they come from"""
        return self._inst_rules

    @property
    def rule_spec_fc(self) -> dict[Uid, list[lib.Mir_Trigger]]:
        """Forward-chaining triggers of each rule spec, by uid"""
        return self._rule_spec_fc

    @property
    def rule_spec_rw_rules(self) -> dict[Uid, list[lib.Mir_Rewrite_rule]]:
        """Rewrite rules of each rule spec, by uid"""
        return self._rule_spec_rw_rules

    def __str__(self) -> str:
        def uids(us: Iterable[Uid]) -> str:
            return "{" + ", ".join(sorted(str(u) for u in us)) + "}"

        def counts(entries: Iterable[tuple[Uid | PatternHead, Sized]]) -> str:
            return "{" + ", ".join(f"{u}: {len(xs)}" for u, xs in entries) + "}"

        return ", ".join(
            [
                f"decls: {len(self.decls)}",
                f"disabled: {uids(self.disabled)}",
                f"rw_rules: {counts(self.rw_rules.items())}",
                f"fc: {counts(self.fc.items())}",
                f"elim: {counts(self.elim.items())}",
                f"gen: {counts(self.gen.items())}",
                f"admission: {uids(self.admission.keys())}",
                f"thm_as_rw: {counts(self.thm_as_rw.items())}",
                f"thm_as_fc: {counts(self.thm_as_fc.items())}",
                f"thm_as_elim: {counts(self.thm_as_elim.items())}",
                f"thm_as_gen: {uids(self.thm_as_gen.keys())}",
                f"inst_rules: {uids(self.inst_rules.keys())}",
                f"rule_spec_fc: {counts(self.rule_spec_fc.items())}",
                f"rule_spec_rw_rules: {counts(self.rule_spec_rw_rules.items())}",
            ]
        )

    def find_declaration(self, x: Uid) -> Declaration | None:
        """The declaration with uid `x`, or `None`"""
        return self._decls.get(x)

    def find_declaration_re(self, regex: str) -> dict[Uid, Declaration]:
        """All declarations whose full name matches `regex`"""
        rx = re.compile(regex)
        return {id: d for id, d in self._decls.items() if rx.match(id.full_name)}

    def find_type(self, x: Uid) -> TypeDefinition | None:
        """The type definition with uid `x`, or `None`"""
        return self._tys.get(x)

    def find_type_re(self, regex: str) -> dict[Uid, TypeDefinition]:
        """All types whose full name matches `regex`"""
        rx = re.compile(regex)
        return {id: t for id, t in self._tys.items() if rx.match(id.full_name)}

    def find_function(self, x: Uid) -> FunctionDefinition | None:
        """The function definition with uid `x`, or `None`"""
        return self._funs.get(x)

    def find_function_re(self, regex: str) -> dict[Uid, FunctionDefinition]:
        """All functions whose full name matches `regex`"""
        rx = re.compile(regex)
        return {id: f for id, f in self._funs.items() if rx.match(id.full_name)}
