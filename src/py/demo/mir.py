"""Python view of MIR, the intermediate representation ImandraX produces from IML

Types, terms, declarations, rules, models and the symbol database (`DB`) that
tasks and their results refer to.

Each class is converted from the matching `imandrax_api.lib` value, which it keeps in
the hidden `_raw` field.
"""

# Note: general transformation rules:
# - use more readable and _Pythonic_ names
# - variants without fields -> enum
# - variant -> union of dataclasses
# - records wrapping a variant -> one base class for the record's fields, dataclasses subclassing the base class, plus the union
# - `'term` / `'ty` type parameters are specialized with MIR term and type
# - Some classes irrelvant to users are skipped, e.g.: Anchor, SubAnchor

from __future__ import annotations

import base64
import re

from collections import Counter
from collections.abc import Callable, Iterable, Iterator, Sized
from dataclasses import dataclass, field
from enum import StrEnum
from fractions import Fraction
from functools import cached_property
from typing import ClassVar, Never, assert_never, cast, override

from imandrax_api import lib

from ._utils import FrozenMap
from .errors import UnexpectedResponseError

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

    @property
    def builtin_kind(self) -> BuiltinDataKind | None:
        """What a builtin uid stands for, e.g. a logic core symbol or a tactic; `None` for other uids"""
        match self._raw.view:
            case lib.Uid_view_Builtin(kind=kind):
                return builtin_data_kind_of_lib(kind)
            case _:
                return None

    def __str__(self) -> str:
        return self.full_name

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Uid) and self._raw == other._raw

    def __hash__(self) -> int:
        return hash(self._raw)

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


@dataclass(slots=True, frozen=True)
class Cname:
    name: str
    chash: bytes
    is_key: bool
    """Is this cname a key (ie a toplevel definition)? Or, if [false], is it just a symbol defined
    as part of another symbol (cstor, label, etc)"""
    _raw: lib.Cname = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Cname) -> Cname:
        return cls(name=x.name, chash=x.chash, is_key=x.is_key, _raw=x)


# `Upto.t` has the single constructor `N_steps of int`, so it is represented by that number of
# steps.


def upto_of_lib(x: lib.Upto) -> int:
    """The number of steps of a library `Upto`"""
    match x:
        case lib.Upto_N_steps(arg=n):
            return n


@dataclass(slots=True, frozen=True)
class FloatConst:
    value: float
    _raw: lib.Const = field(repr=False, compare=False)

    def __str__(self) -> str:
        return str(self.value)


@dataclass(slots=True, frozen=True)
class StringConst:
    value: str
    _raw: lib.Const = field(repr=False, compare=False)

    def __str__(self) -> str:
        return f'"{self.value}"'


@dataclass(slots=True, frozen=True)
class IntConst:
    value: int
    _raw: lib.Const = field(repr=False, compare=False)

    def __str__(self) -> str:
        return str(self.value)


@dataclass(slots=True, frozen=True)
class RationalConst:
    value: Fraction
    _raw: lib.Const = field(repr=False, compare=False)

    def __str__(self) -> str:
        return f"{self.value.numerator}/{self.value.denominator}"


@dataclass(slots=True, frozen=True)
class RealApproxConst:
    value: str
    _raw: lib.Const = field(repr=False, compare=False)

    def __str__(self) -> str:
        return self.value


@dataclass(slots=True, frozen=True)
class UidConst:
    uid: Uid
    _raw: lib.Const = field(repr=False, compare=False)

    def __str__(self) -> str:
        return self.uid.short_name


@dataclass(slots=True, frozen=True)
class BoolConst:
    value: bool
    _raw: lib.Const = field(repr=False, compare=False)

    def __str__(self) -> str:
        return "true" if self.value else "false"


Const = FloatConst | StringConst | IntConst | RationalConst | RealApproxConst | UidConst | BoolConst


def const_of_lib(x: lib.Const) -> Const:
    """Convert a library constant into the matching `Const` variant"""
    match x:
        case lib.Const_Const_float(arg=f):
            return FloatConst(value=f, _raw=x)
        case lib.Const_Const_string(arg=s):
            return StringConst(value=s, _raw=x)
        case lib.Const_Const_z(arg=n):
            return IntConst(value=n, _raw=x)
        case lib.Const_Const_q(arg=(num, den)):
            return RationalConst(value=Fraction(num, den), _raw=x)
        case lib.Const_Const_real_approx(arg=s):
            return RealApproxConst(value=s, _raw=x)
        case lib.Const_Const_uid(arg=u):
            return UidConst(uid=Uid(u), _raw=x)
        case lib.Const_Const_bool(arg=b):
            return BoolConst(value=b, _raw=x)


@dataclass(slots=True, frozen=True)
class LogicCoreBuiltin:
    name: str
    _raw: lib.Builtin_data_kind = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class SpecialBuiltin:
    tag: str
    _raw: lib.Builtin_data_kind = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class TacticBuiltin:
    name: str
    _raw: lib.Builtin_data_kind = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class DecompBuiltin:
    name: str
    _raw: lib.Builtin_data_kind = field(repr=False, compare=False)


BuiltinDataKind = LogicCoreBuiltin | SpecialBuiltin | TacticBuiltin | DecompBuiltin


def builtin_data_kind_of_lib(x: lib.Builtin_data_kind) -> BuiltinDataKind:
    """Convert a library builtin kind into the matching `BuiltinDataKind` variant"""
    match x:
        case lib.Builtin_data_kind_Logic_core(logic_core_name=n):
            return LogicCoreBuiltin(name=n, _raw=x)
        case lib.Builtin_data_kind_Special(tag=t):
            return SpecialBuiltin(tag=t, _raw=x)
        case lib.Builtin_data_kind_Tactic(tac_name=n):
            return TacticBuiltin(name=n, _raw=x)
        case lib.Builtin_data_kind_Decomp(decomp_name=n):
            return DecompBuiltin(name=n, _raw=x)


@dataclass(slots=True, frozen=True)
class BuiltinFunction:
    """Builtin functions"""

    id: Uid
    kind: BuiltinDataKind
    left_associative: bool
    commutative: bool
    connective: bool
    _raw: lib.Builtin_Fun = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Builtin_Fun) -> BuiltinFunction:
        return cls(
            id=Uid(x.id),
            kind=builtin_data_kind_of_lib(x.kind),
            left_associative=x.lassoc,
            commutative=x.commutative,
            connective=x.connective,
            _raw=x,
        )


@dataclass(slots=True, frozen=True)
class BuiltinSort:
    """Builtin sorts"""

    id: Uid
    kind: BuiltinDataKind
    _raw: lib.Builtin_Ty = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Builtin_Ty) -> BuiltinSort:
        return cls(id=Uid(x.id), kind=builtin_data_kind_of_lib(x.kind), _raw=x)


@dataclass(slots=True, frozen=True)
class NoTrigger:
    _raw: lib.As_trigger = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class AnonymousTrigger:
    _raw: lib.As_trigger = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class NamedTrigger:
    index: int
    _raw: lib.As_trigger = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class RewriteTrigger:
    _raw: lib.As_trigger = field(repr=False, compare=False)


AsTrigger = NoTrigger | AnonymousTrigger | NamedTrigger | RewriteTrigger


def as_trigger_of_lib(x: lib.As_trigger) -> AsTrigger:
    """Convert a library `As_trigger` into the matching `AsTrigger` variant"""
    match x:
        case lib.As_trigger_Trig_none():
            return NoTrigger(_raw=x)
        case lib.As_trigger_Trig_anon():
            return AnonymousTrigger(_raw=x)
        case lib.As_trigger_Trig_named(arg=n):
            return NamedTrigger(index=n, _raw=x)
        case lib.As_trigger_Trig_rw():
            return RewriteTrigger(_raw=x)


@dataclass(slots=True, frozen=True, kw_only=True, repr=False)
class _Type:
    """A type"""

    _raw: lib.Mir_Type = field(repr=False, compare=False)

    def __str__(self) -> str:
        return "<type>"

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


def type_of_lib(x: lib.Mir_Type) -> Type:
    """Convert a library type into the matching `Type` variant"""
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
class TypeVariable(_Type):
    """A type variable"""

    name: Uid

    @override
    def __str__(self) -> str:
        return str(self.name)


@dataclass(slots=True, frozen=True, repr=False)
class ArrowType(_Type):
    """A function type `a -> b`"""

    domain: Type
    codomain: Type

    @override
    def __str__(self) -> str:
        return f"{self.domain} -> {self.codomain}"


@dataclass(slots=True, frozen=True, repr=False)
class TupleType(_Type):
    """A tuple type `a * b * ...`"""

    elements: tuple[Type, ...]
    """The component types"""

    @override
    def __str__(self) -> str:
        return " * ".join(str(t) for t in self.elements)


@dataclass(slots=True, frozen=True, repr=False)
class ConstructedType(_Type):
    """A type constructor applied to type arguments, e.g. `int list`"""

    constructor: Uid
    arguments: tuple[Type, ...]

    @override
    def __str__(self) -> str:
        elems = " ".join([f"{t}" for t in self.arguments])
        if len(elems) > 0:
            elems += " "
        return f"{elems}{self.constructor}"


Type = TypeVariable | ArrowType | TupleType | ConstructedType
"""A type"""


@dataclass(slots=True, frozen=True)
class ConstructorDefinition:
    name: Uid
    labels: tuple[Uid, ...] | None
    """for inline records; same length as [args]"""
    arguments: tuple[Type, ...]
    doc: str | None
    _raw: lib.Ty_view_adt_row[lib.Uid, lib.Mir_Type] = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Ty_view_adt_row[lib.Uid, lib.Mir_Type]) -> ConstructorDefinition:
        return cls(
            name=Uid(x.c),
            labels=None if x.labels is None else tuple(Uid(l) for l in x.labels),
            arguments=tuple(type_of_lib(t) for t in x.args),
            doc=x.doc,
            _raw=x,
        )

    def __str__(self) -> str:
        if not self.arguments:
            return str(self.name)
        if self.labels is not None:
            fs = "; ".join(f"{l} : {t}" for l, t in zip(self.labels, self.arguments))
            return f"{self.name} of {{{fs}}}"
        return f"{self.name} of {' * '.join(str(t) for t in self.arguments)}"


@dataclass(slots=True, frozen=True)
class FieldDefinition:
    name: Uid
    type: Type
    doc: str | None
    _raw: lib.Ty_view_rec_row[lib.Uid, lib.Mir_Type] = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Ty_view_rec_row[lib.Uid, lib.Mir_Type]) -> FieldDefinition:
        return cls(name=Uid(x.f), type=type_of_lib(x.ty), doc=x.doc, _raw=x)

    def __str__(self) -> str:
        return f"{self.name} : {self.type}"


@dataclass(slots=True, frozen=True)
class AlgebraicTypeKind:
    constructors: tuple[ConstructorDefinition, ...]
    _raw: lib.Ty_view_decl[lib.Uid, lib.Mir_Type, Never] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class RecordTypeKind:
    fields: tuple[FieldDefinition, ...]
    _raw: lib.Ty_view_decl[lib.Uid, lib.Mir_Type, Never] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class SkolemTypeKind:
    _raw: lib.Ty_view_decl[lib.Uid, lib.Mir_Type, Never] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class BuiltinTypeKind:
    sort: BuiltinSort
    _raw: lib.Ty_view_decl[lib.Uid, lib.Mir_Type, Never] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class OtherTypeKind:
    _raw: lib.Ty_view_decl[lib.Uid, lib.Mir_Type, Never] = field(repr=False, compare=False)


# `Alias` is left out: its target has the empty type `Void.t` in type definitions
TypeKind = AlgebraicTypeKind | RecordTypeKind | SkolemTypeKind | BuiltinTypeKind | OtherTypeKind


def type_kind_of_lib(x: lib.Ty_view_decl[lib.Uid, lib.Mir_Type, Never]) -> TypeKind:
    """Convert a library type declaration into the matching `TypeKind` variant"""
    match x:
        case lib.Ty_view_decl_Algebraic(arg=rows):
            return AlgebraicTypeKind(constructors=tuple(ConstructorDefinition.of_lib(r) for r in rows), _raw=x)
        case lib.Ty_view_decl_Record(arg=rows):
            return RecordTypeKind(fields=tuple(FieldDefinition.of_lib(r) for r in rows), _raw=x)
        case lib.Ty_view_decl_Alias():
            raise UnexpectedResponseError("unexpected alias in a type definition")
        case lib.Ty_view_decl_Skolem():
            return SkolemTypeKind(_raw=x)
        case lib.Ty_view_decl_Builtin(arg=b):
            return BuiltinTypeKind(sort=BuiltinSort.of_lib(b), _raw=x)
        case lib.Ty_view_decl_Other():
            return OtherTypeKind(_raw=x)


@dataclass(slots=True, frozen=True, repr=False)
class TypeDefinition:
    """A type definition"""

    name: Uid
    """The type's name"""
    parameters: tuple[Uid, ...]
    """The type variables the type is parameterized over"""
    kind: TypeKind
    """How the type is defined: algebraic, record, skolem, builtin, ..."""
    clique: frozenset[Uid] | None
    """The mutually recursive types this type belongs to, if any"""
    timeout: int | None
    """The timeout for checking the definition, if any"""
    _raw: lib.Mir_Type_def = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Type_def) -> TypeDefinition:
        return cls(
            name=Uid(x.name),
            parameters=tuple(Uid(p) for p in x.params),
            kind=type_kind_of_lib(x.decl),
            clique=None if x.clique is None else frozenset(Uid(u) for u in x.clique),
            timeout=x.timeout,
            _raw=x,
        )

    def __str__(self) -> str:
        params = "".join(f"{p} " for p in self.parameters)
        head = f"type {params}{self.name}"
        match self.kind:
            case AlgebraicTypeKind(constructors=cs):
                return f"{head} = {' | '.join(str(c) for c in cs)}"
            case RecordTypeKind(fields=fs):
                return f"{head} = {{{'; '.join(str(f) for f in fs)}}}"
            case _:
                return head

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


@dataclass(slots=True, frozen=True)
class Variable:
    # class name collide with Var of term, thus it's called Variable
    id: Uid
    type: Type
    _raw: lib.Mir_Var = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Var) -> Variable:
        return cls(id=Uid(x.id), type=type_of_lib(x.ty), _raw=x)

    def __str__(self) -> str:
        return self.id.short_name


@dataclass(slots=True, frozen=True)
class TypeSchema:
    parameters: tuple[Uid, ...]
    type: Type
    _raw: lib.Mir_Type_schema = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Type_schema) -> TypeSchema:
        return cls(parameters=tuple(Uid(p) for p in x.params), type=type_of_lib(x.ty), _raw=x)


@dataclass(slots=True, frozen=True)
class TypedSymbol:
    """A symbol together with its type schema"""

    id: Uid
    """The symbol's unique identifier"""
    type_schema: TypeSchema
    """The symbol's type schema"""
    _raw: lib.Mir_Typed_symbol = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Typed_symbol) -> TypedSymbol:
        return cls(id=Uid(x.id), type_schema=TypeSchema.of_lib(x.ty), _raw=x)


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
    def of_lib(cls, x: lib.Mir_Applied_symbol) -> AppliedSymbol:
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


@dataclass(slots=True, frozen=True, kw_only=True, repr=False)
class _Term:
    """A term"""

    type: Type
    _raw: lib.Mir_Term = field(repr=False, compare=False)

    @property
    def subterms(self) -> list[Term]:
        """The immediate subterms of this term"""
        return []

    def __iter__(self) -> Iterator[Term]:
        """Iterate over this term and all of its subterms, recursively, parents before children"""
        stack: list[Term] = [cast(Term, self)]
        while stack:
            t = stack.pop()
            yield t
            stack.extend(reversed(t.subterms))

    def iter(self, f: Callable[[Term], None]) -> None:
        """Call `f` on this term and on all of its subterms, recursively, parents before children"""
        for t in self:
            f(t)

    def to_python(self) -> PyValue:
        """This term as a plain Python value, e.g. the value of a constant in a model

        Integers, booleans and strings map to themselves, reals to `Fraction`, floats to `float`,
        lists to `list`, tuples to `tuple` (unit to `()`), records to `dict` by field name, uid
        constants to their `Uid`, and other constructors to `Constructed`, including the elements
        a model makes up for abstract types.

        Raises:
            ValueError: if the term is not a value, e.g. a variable, a function application
                (which is how `Map.t` and `Set.t` values look), or an irrational real
        """
        return _to_python(cast(Term, self))

    def __str__(self) -> str:
        return "<term>"

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


def term_of_lib(x: lib.Mir_Term) -> Term:
    """Convert a library term into the matching `Term` variant, including all its subterms"""
    ty = type_of_lib(x.ty)
    match x.view:
        case lib.Mir_Term_view_Const(arg=c):
            return Constant(value=const_of_lib(c), type=ty, _raw=x)
        case lib.Mir_Term_view_If(args=(c, a, b)):
            return If(
                condition=term_of_lib(c),
                then_branch=term_of_lib(a),
                else_branch=term_of_lib(b),
                type=ty,
                _raw=x,
            )
        case lib.Mir_Term_view_Apply(f=f, l=l):
            return Apply(
                function=term_of_lib(f),
                arguments=tuple(term_of_lib(t) for t in l),
                type=ty,
                _raw=x,
            )
        case lib.Mir_Term_view_Var(arg=v):
            return Var(var=Variable.of_lib(v), type=ty, _raw=x)
        case lib.Mir_Term_view_Sym(arg=s):
            return Symbol(symbol=AppliedSymbol.of_lib(s), type=ty, _raw=x)
        case lib.Mir_Term_view_Construct(c=c, args=args, labels=labels):
            return Construct(
                constructor=AppliedSymbol.of_lib(c),
                arguments=tuple(term_of_lib(t) for t in args),
                labels=None if labels is None else tuple(Uid(l) for l in labels),
                type=ty,
                _raw=x,
            )
        case lib.Mir_Term_view_Destruct(c=c, i=i, t=t):
            return Destruct(
                constructor=AppliedSymbol.of_lib(c), index=i, term=term_of_lib(t), type=ty, _raw=x
            )
        case lib.Mir_Term_view_Is_a(c=c, t=t):
            return IsA(constructor=AppliedSymbol.of_lib(c), term=term_of_lib(t), type=ty, _raw=x)
        case lib.Mir_Term_view_Tuple(l=l):
            return Tuple(elements=tuple(term_of_lib(t) for t in l), type=ty, _raw=x)
        case lib.Mir_Term_view_Field(f=f, t=t):
            return Field(field=AppliedSymbol.of_lib(f), term=term_of_lib(t), type=ty, _raw=x)
        case lib.Mir_Term_view_Tuple_field(i=i, t=t):
            return TupleField(index=i, term=term_of_lib(t), type=ty, _raw=x)
        case lib.Mir_Term_view_Record(rows=rows, rest=rest):
            return Record(
                rows=tuple((AppliedSymbol.of_lib(f), term_of_lib(t)) for f, t in rows),
                rest=None if rest is None else term_of_lib(rest),
                type=ty,
                _raw=x,
            )
        case lib.Mir_Term_view_Case(u=u, cases=cases, default=default):
            return Case(
                scrutinee=term_of_lib(u),
                cases=tuple((AppliedSymbol.of_lib(c), term_of_lib(t)) for c, t in cases),
                default=None if default is None else term_of_lib(default),
                type=ty,
                _raw=x,
            )
        case lib.Mir_Term_view_Sequence(args=(prefix, last)):
            return Sequence(
                prefix=tuple(term_of_lib(t) for t in prefix), last=term_of_lib(last), type=ty, _raw=x
            )
        case _:
            assert_never(x.view)


@dataclass(slots=True, frozen=True, repr=False)
class Constant(_Term):
    """A constant"""

    value: Const
    """The constant's value"""

    @override
    def __str__(self) -> str:
        return str(self.value)


@dataclass(slots=True, frozen=True, repr=False)
class If(_Term):
    """A conditional `if c then a else b`"""

    condition: Term
    """The condition"""
    then_branch: Term
    """The term evaluated if the condition is true"""
    else_branch: Term
    """The term evaluated if the condition is false"""

    @property
    @override
    def subterms(self) -> list[Term]:
        return [self.condition, self.then_branch, self.else_branch]

    @override
    def __str__(self) -> str:
        return f"if {self.condition} then {self.then_branch} else {self.else_branch}"


@dataclass(slots=True, frozen=True, repr=False)
class Apply(_Term):
    """A function application"""

    function: Term
    """The function being applied"""
    arguments: tuple[Term, ...]
    """The arguments the function is applied to"""

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
class Var(_Term):
    """A variable"""

    var: Variable
    """The variable, with its type"""

    @override
    def __str__(self) -> str:
        return self.var.id.short_name


def var_term_of_var(x: lib.Mir_Var) -> Var:
    """Turn a library variable into a `Var` term"""
    raw = lib.Mir_Term(view=(lib.Mir_Term_view_Var(arg=x)), ty=x.ty, sub_anchor=None)
    return Var(var=Variable.of_lib(x), type=type_of_lib(x.ty), _raw=raw)


@dataclass(slots=True, frozen=True, repr=False)
class Symbol(_Term):
    """A symbol"""

    symbol: AppliedSymbol
    """The symbol, instantiated at its type"""

    @override
    def __str__(self) -> str:
        return self.symbol.id.full_name


@dataclass(slots=True, frozen=True, repr=False)
class Construct(_Term):
    """A constructor applied to arguments"""

    constructor: AppliedSymbol
    """The constructor"""
    arguments: tuple[Term, ...]
    """The constructor's arguments"""
    labels: tuple[Uid, ...] | None
    """The argument labels, if the constructor takes labeled (record) arguments"""

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
class Destruct(_Term):
    """A destructor term. (The `index`-th argument of a term built with `constructor`.)"""

    constructor: AppliedSymbol
    """The constructor whose argument is extracted"""
    index: int
    """The position of the extracted argument"""
    term: Term
    """The term the argument is extracted from"""

    @property
    @override
    def subterms(self) -> list[Term]:
        return [self.term]

    @override
    def __str__(self) -> str:
        return f"Destruct({self.constructor.id.short_name}, {self.index}, {self.term})"


@dataclass(slots=True, frozen=True, repr=False)
class IsA(_Term):
    """A test whether a term was built with `constructor`"""

    constructor: AppliedSymbol
    """The constructor tested for"""
    term: Term
    """The term being tested"""

    @property
    @override
    def subterms(self) -> list[Term]:
        return [self.term]

    @override
    def __str__(self) -> str:
        return f"Is_a({self.constructor.id.short_name}, {self.term})"


@dataclass(slots=True, frozen=True, repr=False)
class Tuple(_Term):
    """A tuple"""

    elements: tuple[Term, ...]
    """The tuple's elements"""

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
class Field(_Term):
    """A record field"""

    field: AppliedSymbol
    """The field being accessed"""
    term: Term
    """The record whose field is accessed"""

    @property
    @override
    def subterms(self) -> list[Term]:
        return [self.term]

    @override
    def __str__(self) -> str:
        return f"{str(self.term)}.{self.field.id.short_name}"


@dataclass(slots=True, frozen=True, repr=False)
class TupleField(_Term):
    """A tuple field"""

    index: int
    """The position of the accessed component"""
    term: Term
    """The tuple whose component is accessed"""

    @property
    @override
    def subterms(self) -> list[Term]:
        return [self.term]

    @override
    def __str__(self) -> str:
        return f"{str(self.term)}.{self.index}"


@dataclass(slots=True, frozen=True, repr=False)
class Record(_Term):
    """A record"""

    rows: tuple[tuple[AppliedSymbol, Term], ...]
    """The record's fields and their values"""
    rest: Term | None
    """The record being updated in `{rest with ...}`, if any"""

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
class Case(_Term):
    """A pattern match on `scrutinee`"""

    scrutinee: Term
    """The term being matched on"""
    cases: tuple[tuple[AppliedSymbol, Term], ...]
    """The match arms, each a constructor and the term for that case"""
    default: Term | None
    """The term for the wildcard case `_`, if any"""

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
class Sequence(_Term):
    """A sequence `t1; ...; tn; last`"""

    prefix: tuple[Term, ...]
    """The terms evaluated before `last`"""
    last: Term
    """The final term, whose value is the value of the sequence"""

    @property
    @override
    def subterms(self) -> list[Term]:
        return [*self.prefix, self.last]

    @override
    def __str__(self) -> str:
        return "; ".join(str(t) for t in [*self.prefix, self.last])


Term = (
    Constant | If | Apply | Var | Symbol | Construct | Destruct | IsA | Tuple | Field | TupleField | Record | Case | Sequence
)
"""A term"""


@dataclass(slots=True, frozen=True)
class Constructed:
    """A constructor applied to arguments, as a Python value: `Some 3` is `Constructed("Some", (3,))`

    The arguments of a constructor with an inline record, as in `A {x = 1}`, are that one record,
    as a `dict`, if the server sent the record's labels. (Region samples can lack them.)"""

    name: str
    """The constructor's name"""
    args: tuple[PyValue, ...] = ()
    """The constructor's arguments"""


type PyValue = (
    bool | int | Fraction | float | str | Uid | Constructed | list[PyValue] | tuple[PyValue, ...] | dict[str, PyValue]
)
"""A term's value as plain Python data, see `Term.to_python`"""


def _to_python(t: Term) -> PyValue:
    match t:
        case Constant(value=BoolConst(value=b)):
            return b
        case Constant(value=IntConst(value=n)):
            return n
        case Constant(value=RationalConst(value=q)):
            return q
        case Constant(value=FloatConst(value=f)):
            return f
        case Constant(value=StringConst(value=s)):
            return s
        case Constant(value=UidConst(uid=u)):
            return u
        case Constant(value=RealApproxConst(value=s)):
            raise ValueError(f"The irrational real {s} has no exact Python value")
        case Construct(constructor=c, arguments=()) if c.id.short_name == "()":
            return ()
        case Construct(constructor=c) if c.id.short_name in ("::", "[]"):
            # A list is a chain of `::` as deep as it is long: walk it in a loop, not a call per element
            xs: list[PyValue] = []
            while isinstance(t, Construct) and t.constructor.id.short_name == "::":
                xs.append(_to_python(t.arguments[0]))
                t = t.arguments[1]
            if not (isinstance(t, Construct) and t.constructor.id.short_name == "[]"):
                raise ValueError(f"Not a value: the list ends with {t}")
            return xs
        case Construct(constructor=c, arguments=args, labels=None):
            return Constructed(c.id.short_name, tuple(_to_python(a) for a in args))
        case Construct(constructor=c, arguments=args, labels=tuple() as labels):
            return Constructed(c.id.short_name, ({l.short_name: _to_python(a) for l, a in zip(labels, args, strict=True)},))
        case Tuple(elements=es):
            return tuple(_to_python(e) for e in es)
        case Record(rows=rows, rest=None):
            return {f.id.short_name: _to_python(v) for f, v in rows}
        case _:
            raise ValueError(f"Not a value: {t}")


def _binder_of_lib(x: tuple[list[lib.Mir_Var], lib.Mir_Term]) -> tuple[tuple[Variable, ...], Term]:
    """Convert a library `fun vars -> body` pair"""
    vs, t = x
    return (tuple(Variable.of_lib(v) for v in vs), term_of_lib(t))


@dataclass(slots=True, frozen=True)
class Sequent:
    """A sequent"""

    hypotheses: tuple[tuple[str | None, Term], ...]
    """The hypotheses, each with an optional name"""
    conclusions: tuple[tuple[str | None, Term], ...]
    """The conclusions, each with an optional name"""
    _raw: lib.Mir_Sequent = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Sequent) -> Sequent:
        return cls(
            hypotheses=tuple((n, term_of_lib(t)) for (n, t) in x.hyps),
            conclusions=tuple((n, term_of_lib(t)) for (n, t) in x.concls),
            _raw=x,
        )


PreTrigger = tuple[Term, AsTrigger]
"""A single item in a trigger"""


def _pre_trigger_of_lib(x: lib.Mir_Pre_trigger) -> PreTrigger:
    t, a = x
    return (term_of_lib(t), as_trigger_of_lib(a))


@dataclass(slots=True, frozen=True)
class Admission:
    """The admission data for a particular function."""

    measured_subset: tuple[str, ...]
    """Subset of variables that participate in termination."""
    measure_function: Uid | None
    """Name of the measure function (takes subset of arguments, returns an ordinal)"""
    _raw: lib.Common_Admission = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Common_Admission) -> Admission:
        return cls(
            measured_subset=tuple(x.measured_subset),
            measure_function=None if x.measure_fun is None else Uid(x.measure_fun),
            _raw=x,
        )


@dataclass(slots=True, frozen=True)
class Validate:
    """Validate using this tactic for POs"""

    tactic: tuple[tuple[Variable, ...], Term] | None
    _raw: lib.Common_Hints_validation_strategy[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class NoValidate:
    """Admitted, or builtin."""

    _raw: lib.Common_Hints_validation_strategy[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


ValidationStrategy = Validate | NoValidate
"""How to validate a function"""


def validation_strategy_of_lib(
    x: lib.Common_Hints_validation_strategy[lib.Mir_Term, lib.Mir_Type],
) -> ValidationStrategy:
    """Convert a library validation strategy into the matching `ValidationStrategy` variant"""
    match x:
        case lib.Common_Hints_validation_strategy_VS_validate(tactic=t):
            return Validate(tactic=None if t is None else _binder_of_lib(t), _raw=x)
        case lib.Common_Hints_validation_strategy_VS_no_validate():
            return NoValidate(_raw=x)


@dataclass(slots=True, frozen=True)
class Hints:
    validation_strategy: ValidationStrategy
    unroll_definition: int | None
    enable: tuple[Uid, ...]
    """local enables"""
    disable: tuple[Uid, ...]
    """local disables"""
    timeout: int | None
    """timeout for POs"""
    admission: Admission | None
    decomp: Term | None
    _raw: lib.Mir_Hints = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Hints) -> Hints:
        return cls(
            validation_strategy=validation_strategy_of_lib(x.f_validate_strat),
            unroll_definition=x.f_unroll_def,
            enable=tuple(Uid(u) for u in x.f_enable),
            disable=tuple(Uid(u) for u in x.f_disable),
            timeout=x.f_timeout,
            admission=None if x.f_admission is None else Admission.of_lib(x.f_admission),
            decomp=None if x.f_decomp is None else term_of_lib(x.f_decomp),
            _raw=x,
        )


@dataclass(slots=True, frozen=True)
class DefaultTerminationTactic:
    """The default tactic for termination proofs"""

    max_steps: int
    """The maximum number of proof steps"""
    basis: frozenset[Uid]
    """The function basis of the termination proof"""
    _raw: lib.Mir_Tactic = field(repr=False, compare=False)

    def __str__(self) -> str:
        basis = "{" + ", ".join(sorted(u.full_name for u in self.basis)) + "}"
        return f"DefaultTerminationTactic(max_steps={self.max_steps}, basis={basis})"


@dataclass(slots=True, frozen=True)
class DefaultTheoremTactic:
    """The default tactic for theorems"""

    max_steps: int
    """The maximum number of proof steps"""
    upto: int | None
    """The bound for bounded verification, if any"""
    _raw: lib.Mir_Tactic = field(repr=False, compare=False)

    def __str__(self) -> str:
        upto = "None" if self.upto is None else f"{self.upto} steps"
        return f"DefaultTheoremTactic(max_steps={self.max_steps}, upto={upto})"


@dataclass(slots=True, frozen=True)
class DefaultTestTactic:
    """The default tactic for tests"""

    num_steps: int | None
    """The number of test steps, if limited"""
    seed: int | None
    """The random seed, if fixed"""
    _raw: lib.Mir_Tactic = field(repr=False, compare=False)

    def __str__(self) -> str:
        return f"DefaultTestTactic(num_steps={self.num_steps}, seed={self.seed})"


@dataclass(slots=True, frozen=True)
class TermTactic:
    """A tactic given as a term"""

    variables: tuple[Var, ...]
    """The variables bound in the tactic term"""
    term: Term
    """The tactic term"""
    _raw: lib.Mir_Tactic = field(repr=False, compare=False)

    def __str__(self) -> str:
        return str(self.term)


Tactic = DefaultTerminationTactic | DefaultTheoremTactic | DefaultTestTactic | TermTactic
"""A tactic used to discharge a proof obligation"""


def tactic_of_lib(t: lib.Mir_Tactic) -> Tactic:
    """Convert a library tactic into the matching `Tactic` variant"""
    match t:
        case lib.Common_Tactic_t_poly_Default_termination(max_steps=max_steps, basis=basis):
            return DefaultTerminationTactic(max_steps=max_steps, basis=frozenset(Uid(f) for f in basis), _raw=t)
        case lib.Common_Tactic_t_poly_Default_thm(max_steps=max_steps, upto=upto):
            return DefaultTheoremTactic(
                max_steps=max_steps, upto=None if upto is None else upto_of_lib(upto), _raw=t
            )
        case lib.Common_Tactic_t_poly_Default_test(num_steps=num_steps, seed=seed):
            return DefaultTestTactic(num_steps=num_steps, seed=seed, _raw=t)
        case lib.Common_Tactic_t_poly_Term(arg=(vs, term)):
            return TermTactic(variables=tuple(var_term_of_var(v) for v in vs), term=term_of_lib(term), _raw=t)
        case _:
            assert_never(t)


@dataclass(slots=True, frozen=True)
class DefinedFunctionKind:
    is_macro: bool
    from_lambda: bool
    _raw: lib.Common_Fun_def_fun_kind = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class BuiltinFunctionKind:
    builtin: BuiltinFunction
    _raw: lib.Common_Fun_def_fun_kind = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class OpaqueFunctionKind:
    _raw: lib.Common_Fun_def_fun_kind = field(repr=False, compare=False)


FunctionKind = DefinedFunctionKind | BuiltinFunctionKind | OpaqueFunctionKind


def function_kind_of_lib(x: lib.Common_Fun_def_fun_kind) -> FunctionKind:
    """Convert a library function kind into the matching `FunctionKind` variant"""
    match x:
        case lib.Common_Fun_def_fun_kind_Fun_defined(is_macro=m, from_lambda=l):
            return DefinedFunctionKind(is_macro=m, from_lambda=l, _raw=x)
        case lib.Common_Fun_def_fun_kind_Fun_builtin(arg=b):
            return BuiltinFunctionKind(builtin=BuiltinFunction.of_lib(b), _raw=x)
        case lib.Common_Fun_def_fun_kind_Fun_opaque():
            return OpaqueFunctionKind(_raw=x)


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
    kind: FunctionKind
    """Whether the function is defined, builtin or opaque"""
    hints: Hints
    """Prover hints attached to the definition"""
    _raw: lib.Mir_Fun_def = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Fun_def) -> FunctionDefinition:
        return cls(
            name=Uid(x.f_name),
            type_parameters=tuple(Uid(p) for p in x.f_ty.params),
            type=type_of_lib(x.f_ty.ty),
            arguments=tuple(var_term_of_var(a) for a in x.f_args),
            body=term_of_lib(x.f_body),
            clique=None if x.f_clique is None else frozenset(Uid(u) for u in x.f_clique),
            kind=function_kind_of_lib(x.f_kind),
            hints=Hints.of_lib(x.f_hints),
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


@dataclass(slots=True, frozen=True)
class Theorem:
    """A theorem, entered with [theorem foo x y = <formula using x,y>]"""

    function: FunctionDefinition
    """corresponding (boolean) function"""
    rewriting: bool
    """rewrite rule?"""
    perm_restrict: bool
    """apply permutative rewrite rule restrictions?"""
    forward_chaining: bool
    """forward chaining rule?"""
    elimination: bool
    """elimination rule?"""
    generalization: bool
    """generalization rule?"""
    triggers: tuple[PreTrigger, ...]
    is_axiom: bool
    by: tuple[tuple[Variable, ...], Term]
    named_hypotheses: tuple[tuple[str, Term], ...]
    _raw: lib.Mir_Theorem = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Theorem) -> Theorem:
        return cls(
            function=FunctionDefinition.of_lib(x.thm_link),
            rewriting=x.thm_rewriting,
            perm_restrict=x.thm_perm_restrict,
            forward_chaining=x.thm_fc,
            elimination=x.thm_elim,
            generalization=x.thm_gen,
            triggers=tuple(_pre_trigger_of_lib(t) for t in x.thm_triggers),
            is_axiom=x.thm_is_axiom,
            by=_binder_of_lib(x.thm_by),
            named_hypotheses=tuple((n, term_of_lib(t)) for n, t in x.thm_named_hypotheses),
            _raw=x,
        )


@dataclass(slots=True, frozen=True)
class RuleSpec:
    """A rule_spec_spec, entered with [rule_spec_spec foo x y = <formula using x,y>]"""

    forward_chaining: bool
    """forward chaining rule?"""
    rewriting: bool
    """rewrite rule?"""
    perm_restrict: bool
    """apply permutative rewrite rule restrictions?"""
    function: FunctionDefinition
    """corresponding (boolean) function"""
    triggers: tuple[PreTrigger, ...]
    """explicit rule triggers"""
    _raw: lib.Common_Rule_spec_t_poly[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Common_Rule_spec_t_poly[lib.Mir_Term, lib.Mir_Type]) -> RuleSpec:
        return cls(
            forward_chaining=x.rule_spec_fc,
            rewriting=x.rule_spec_rewriting,
            perm_restrict=x.rule_spec_perm_restrict,
            function=FunctionDefinition.of_lib(x.rule_spec_link),
            triggers=tuple(_pre_trigger_of_lib(t) for t in x.rule_spec_triggers),
            _raw=x,
        )


class VerifyKind(StrEnum):
    VERIFY = "verify"
    INSTANCE = "instance"
    TEST = "test"


def verify_kind_of_lib(x: lib.Common_Verify_kind) -> VerifyKind:
    """Convert a library verify kind into the matching `VerifyKind`"""
    match x:
        case lib.Common_Verify_kind_K_verify():
            return VerifyKind.VERIFY
        case lib.Common_Verify_kind_K_instance():
            return VerifyKind.INSTANCE
        case lib.Common_Verify_kind_K_test():
            return VerifyKind.TEST


@dataclass(slots=True, frozen=True)
class Verify:
    """A [verify (fun x y -> <formula using x,y>)] event, for nameless theorems."""

    function: FunctionDefinition
    """nameless function representing the property to check"""
    simplify: bool
    """simplify first?"""
    nonlinear: bool
    """nonlinear real arithmetic?"""
    upto: int | None
    kind: VerifyKind
    minimize: tuple[Term, ...]
    """arithmetic terms to minimize in models"""
    by: tuple[tuple[Variable, ...], Term] | None
    _raw: lib.Common_Verify_t_poly[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Common_Verify_t_poly[lib.Mir_Term, lib.Mir_Type]) -> Verify:
        return cls(
            function=FunctionDefinition.of_lib(x.verify_link),
            simplify=x.verify_simplify,
            nonlinear=x.verify_nonlin,
            upto=None if x.verify_upto is None else upto_of_lib(x.verify_upto),
            kind=verify_kind_of_lib(x.verify_kind),
            minimize=tuple(term_of_lib(t) for t in x.verify_minimize),
            by=None if x.verify_by is None else _binder_of_lib(x.verify_by),
            _raw=x,
        )


def declaration_of_lib(x: lib.Mir_Decl) -> Declaration:
    """Convert a library declaration into the matching `Declaration` variant"""
    match x:
        case lib.Common_Decl_t_poly_Fun(arg=f):
            return FunctionDeclaration(function=FunctionDefinition.of_lib(f), _raw=x)
        case lib.Common_Decl_t_poly_Ty(arg=ty):
            return TypeDeclaration(type=TypeDefinition.of_lib(ty), _raw=x)
        case lib.Common_Decl_t_poly_Theorem(arg=thm):
            return TheoremDeclaration(theorem=Theorem.of_lib(thm), _raw=x)
        case lib.Common_Decl_t_poly_Rule_spec(arg=rs):
            return RuleSpecDeclaration(rule_spec=RuleSpec.of_lib(rs), _raw=x)
        case lib.Common_Decl_t_poly_Verify(arg=v):
            return VerifyDeclaration(verify=Verify.of_lib(v), _raw=x)


@dataclass(slots=True, frozen=True)
class FunctionDeclaration:
    kind: ClassVar[str] = "function"

    function: FunctionDefinition
    """The function defined"""
    _raw: lib.Mir_Decl = field(repr=False, compare=False)

    @property
    def id(self) -> Uid:
        return self.function.name

    def __str__(self) -> str:
        return str(self.function)


@dataclass(slots=True, frozen=True)
class TypeDeclaration:
    kind: ClassVar[str] = "type"

    type: TypeDefinition
    """The type defined"""
    _raw: lib.Mir_Decl = field(repr=False, compare=False)

    @property
    def id(self) -> Uid:
        return self.type.name

    def __str__(self) -> str:
        return str(self.type)


@dataclass(slots=True, frozen=True)
class TheoremDeclaration:
    kind: ClassVar[str] = "theorem"

    theorem: Theorem
    """The theorem"""
    _raw: lib.Mir_Decl = field(repr=False, compare=False)

    @property
    def function(self) -> FunctionDefinition:
        """The linked function"""
        return self.theorem.function

    @property
    def id(self) -> Uid:
        return self.function.name

    def __str__(self) -> str:
        return _definition_str(self.kind, self.function)


@dataclass(slots=True, frozen=True)
class RuleSpecDeclaration:
    kind: ClassVar[str] = "rule_spec"

    rule_spec: RuleSpec
    """The rule spec"""
    _raw: lib.Mir_Decl = field(repr=False, compare=False)

    @property
    def function(self) -> FunctionDefinition:
        """The linked function"""
        return self.rule_spec.function

    @property
    def id(self) -> Uid:
        return self.function.name

    def __str__(self) -> str:
        return _definition_str(self.kind, self.function)


@dataclass(slots=True, frozen=True)
class VerifyDeclaration:
    kind: ClassVar[str] = "verify"

    verify: Verify
    """The verify declaration"""
    _raw: lib.Mir_Decl = field(repr=False, compare=False)

    @property
    def function(self) -> FunctionDefinition:
        """The linked function"""
        return self.verify.function

    @property
    def id(self) -> Uid:
        return self.function.name

    def __str__(self) -> str:
        return _definition_str(self.kind, self.function)


Declaration = FunctionDeclaration | TypeDeclaration | TheoremDeclaration | RuleSpecDeclaration | VerifyDeclaration
"""A declaration: a function, type, theorem, rule spec or verify declaration

Every variant has `id`, the identifier of the declaration (for theorems etc., the linked
function's), and `kind`, the kind of declaration: `function`, `type`, `theorem`, `rule_spec` or
`verify`.
"""


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


def pattern_head_of_lib(x: lib.Mir_Pattern_head) -> PatternHead:
    """Convert a library pattern head into the matching `PatternHead` variant"""
    match x:
        case lib.Common_Pattern_head_t_poly_PH_id(arg=uid):
            return SymbolHead(uid=Uid(uid), _raw=x)
        case lib.Common_Pattern_head_t_poly_PH_ty(arg=ty):
            return TypeHead(type=type_of_lib(ty), _raw=x)
        case lib.Common_Pattern_head_t_poly_PH_datatype_op():
            return DatatypeOpHead(_raw=x)


@dataclass(slots=True, frozen=True)
class SymbolHead:
    """starts with function symbol"""

    uid: Uid
    """The symbol's uid"""
    _raw: lib.Mir_Pattern_head = field(repr=False, compare=False)

    def __str__(self) -> str:
        return str(self.uid)


@dataclass(slots=True, frozen=True)
class TypeHead:
    """is just a variable"""

    type: Type
    """The type"""
    _raw: lib.Mir_Pattern_head = field(repr=False, compare=False)

    def __str__(self) -> str:
        return str(self.type)


@dataclass(slots=True, frozen=True)
class DatatypeOpHead:
    """starts with destruct/is-a"""

    _raw: lib.Mir_Pattern_head = field(repr=False, compare=False)

    def __str__(self) -> str:
        return "<datatype op>"


PatternHead = SymbolHead | TypeHead | DatatypeOpHead
"""The head of a rule pattern: a symbol, a type, or a datatype operation"""


@dataclass(slots=True, frozen=True, kw_only=True)
class _FoPattern:
    """A first-order pattern"""

    type: Type
    _raw: lib.Mir_Fo_pattern = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class AnyPattern(_FoPattern):
    pass


@dataclass(slots=True, frozen=True)
class BoolPattern(_FoPattern):
    value: bool


@dataclass(slots=True, frozen=True)
class ConstPattern(_FoPattern):
    value: Const


@dataclass(slots=True, frozen=True)
class VarPattern(_FoPattern):
    """free variable to match"""

    variable: Variable


@dataclass(slots=True, frozen=True)
class ApplyPattern(_FoPattern):
    """function applied to args"""

    function: AppliedSymbol
    arguments: tuple[FoPattern, ...]


@dataclass(slots=True, frozen=True)
class ConstructPattern(_FoPattern):
    """constructor, tuple, record…"""

    constructor: AppliedSymbol | None
    arguments: tuple[FoPattern, ...]
    labels: tuple[Uid, ...] | None


@dataclass(slots=True, frozen=True)
class DestructPattern(_FoPattern):
    constructor: AppliedSymbol | None
    index: int
    pattern: FoPattern


@dataclass(slots=True, frozen=True)
class IsAPattern(_FoPattern):
    constructor: AppliedSymbol
    pattern: FoPattern


FoPattern = (
    AnyPattern
    | BoolPattern
    | ConstPattern
    | VarPattern
    | ApplyPattern
    | ConstructPattern
    | DestructPattern
    | IsAPattern
)
"""A first-order pattern"""


def fo_pattern_of_lib(x: lib.Mir_Fo_pattern) -> FoPattern:
    """Convert a library first-order pattern into the matching `FoPattern` variant"""
    ty = type_of_lib(x.ty)
    match x.view:
        case lib.Common_Fo_pattern_view_FO_any():
            return AnyPattern(type=ty, _raw=x)
        case lib.Common_Fo_pattern_view_FO_bool(arg=b):
            return BoolPattern(value=b, type=ty, _raw=x)
        case lib.Common_Fo_pattern_view_FO_const(arg=c):
            return ConstPattern(value=const_of_lib(c), type=ty, _raw=x)
        case lib.Common_Fo_pattern_view_FO_var(arg=v):
            return VarPattern(variable=Variable.of_lib(v), type=ty, _raw=x)
        case lib.Common_Fo_pattern_view_FO_app(args=(f, args)):
            return ApplyPattern(
                function=AppliedSymbol.of_lib(f), arguments=tuple(fo_pattern_of_lib(a) for a in args), type=ty, _raw=x
            )
        case lib.Common_Fo_pattern_view_FO_cstor(c=c, args=args, labels=labels):
            return ConstructPattern(
                constructor=None if c is None else AppliedSymbol.of_lib(c),
                arguments=tuple(fo_pattern_of_lib(a) for a in args),
                labels=None if labels is None else tuple(Uid(l) for l in labels),
                type=ty,
                _raw=x,
            )
        case lib.Common_Fo_pattern_view_FO_destruct(c=c, i=i, u=u):
            return DestructPattern(
                constructor=None if c is None else AppliedSymbol.of_lib(c),
                index=i,
                pattern=fo_pattern_of_lib(u),
                type=ty,
                _raw=x,
            )
        case lib.Common_Fo_pattern_view_FO_is_a(c=c, u=u):
            return IsAPattern(constructor=AppliedSymbol.of_lib(c), pattern=fo_pattern_of_lib(u), type=ty, _raw=x)


@dataclass(slots=True, frozen=True)
class RewriteRule:
    """A rewrite rule"""

    name: Uid
    """name of theorem that gives this rewrite rule"""
    head: PatternHead
    """head symbol of LHS"""
    lhs: FoPattern
    rhs: Term
    guard: tuple[Term, ...]
    variables: tuple[Variable, ...]
    """all variables of the rule (LHS + triggers)"""
    triggers: tuple[FoPattern, ...]
    """additional triggers"""
    perm_restrict: bool
    """should we apply `permutative rule` restrictions?"""
    loop_break: FoPattern | None
    """if this matches scrutinee term, rewrite aborts"""
    _raw: lib.Mir_Rewrite_rule = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Rewrite_rule) -> RewriteRule:
        return cls(
            name=Uid(x.rw_name),
            head=pattern_head_of_lib(x.rw_head),
            lhs=fo_pattern_of_lib(x.rw_lhs),
            rhs=term_of_lib(x.rw_rhs),
            guard=tuple(term_of_lib(t) for t in x.rw_guard),
            variables=tuple(Variable.of_lib(v) for v in x.rw_vars),
            triggers=tuple(fo_pattern_of_lib(p) for p in x.rw_triggers),
            perm_restrict=x.rw_perm_restrict,
            loop_break=None if x.rw_loop_break is None else fo_pattern_of_lib(x.rw_loop_break),
            _raw=x,
        )


@dataclass(slots=True, frozen=True)
class Trigger:
    head: PatternHead
    """Root of the pattern"""
    patterns: tuple[FoPattern, ...]
    instantiation_rule_name: Uid
    """Name of the instantiation rule"""
    _raw: lib.Mir_Trigger = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Trigger) -> Trigger:
        return cls(
            head=pattern_head_of_lib(x.trigger_head),
            patterns=tuple(fo_pattern_of_lib(p) for p in x.trigger_patterns),
            instantiation_rule_name=Uid(x.trigger_instantiation_rule_name),
            _raw=x,
        )


class InstantiationRuleKind(StrEnum):
    FORWARD_CHAINING = "forward_chaining"
    GENERALIZATION = "generalization"


def instantiation_rule_kind_of_lib(x: lib.Common_Instantiation_rule_kind) -> InstantiationRuleKind:
    """Convert a library instantiation rule kind into the matching `InstantiationRuleKind`"""
    match x:
        case lib.Common_Instantiation_rule_kind_IR_forward_chaining():
            return InstantiationRuleKind.FORWARD_CHAINING
        case lib.Common_Instantiation_rule_kind_IR_generalization():
            return InstantiationRuleKind.GENERALIZATION


@dataclass(slots=True, frozen=True)
class InstantiationRule:
    function: FunctionDefinition
    triggers: tuple[Trigger, ...]
    kind: InstantiationRuleKind
    _raw: lib.Mir_Instantiation_rule = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Instantiation_rule) -> InstantiationRule:
        return cls(
            function=FunctionDefinition.of_lib(x.ir_from),
            triggers=tuple(Trigger.of_lib(t) for t in x.ir_triggers),
            kind=instantiation_rule_kind_of_lib(x.ir_kind),
            _raw=x,
        )


@dataclass(slots=True, frozen=True)
class EliminationRule:
    name: Uid
    """name of theorem giving rise to this elim rule"""
    guard: tuple[Term, ...]
    """elimination hypotheses"""
    lhs: Term
    """the `body' of the rule, at the theorem level"""
    rhs: Variable
    """the RHS / elimination variable"""
    destructors: tuple[FoPattern, ...]
    """destructor terms of the rule, as patterns"""
    destructor_terms: tuple[Term, ...]
    """destructor terms of the rule, as terms"""
    _raw: lib.Mir_Elimination_rule = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Elimination_rule) -> EliminationRule:
        return cls(
            name=Uid(x.er_name),
            guard=tuple(term_of_lib(t) for t in x.er_guard),
            lhs=term_of_lib(x.er_lhs),
            rhs=Variable.of_lib(x.er_rhs),
            destructors=tuple(fo_pattern_of_lib(p) for p in x.er_dests),
            destructor_terms=tuple(term_of_lib(t) for t in x.er_dest_tms),
            _raw=x,
        )


@dataclass(slots=True, frozen=True)
class FunctionInterpretation:
    """The interpretation of a function in a model: a table of cases"""

    arguments: tuple[Var, ...]
    """The function's parameters"""
    return_type: Type
    """The function's return type"""
    cases: FrozenMap[tuple[Term, ...], Term]
    """The function's value for specific arguments"""
    else_: Term
    """The function's value for all other arguments"""
    _raw: lib.Common_Model_fi[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Common_Model_fi[lib.Mir_Term, lib.Mir_Type]) -> "FunctionInterpretation":
        return cls(
            arguments=tuple(var_term_of_var(a) for a in x.fi_args),
            return_type=type_of_lib(x.fi_ty_ret),
            cases=FrozenMap((tuple(term_of_lib(k) for k in ks), term_of_lib(v)) for (ks, v) in x.fi_cases),
            else_=term_of_lib(x.fi_else),
            _raw=x,
        )


@dataclass(slots=True, frozen=True)
class FiniteTypeInterpretation:
    """interpretation of the type as a finite domain"""

    elements: tuple[Term, ...]
    _raw: lib.Common_Model_ty_def[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class UnitAliasTypeInterpretation:
    """Interpretation of the type as an alias to [unit]"""

    type: Type
    _raw: lib.Common_Model_ty_def[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


TypeInterpretation = FiniteTypeInterpretation | UnitAliasTypeInterpretation
"""The interpretation of a type in a model"""


def type_interpretation_of_lib(x: lib.Common_Model_ty_def[lib.Mir_Term, lib.Mir_Type]) -> TypeInterpretation:
    """Convert a library type interpretation into the matching `TypeInterpretation` variant"""
    match x:
        case lib.Common_Model_ty_def_Ty_finite(arg=ts):
            return FiniteTypeInterpretation(elements=tuple(term_of_lib(t) for t in ts), _raw=x)
        case lib.Common_Model_ty_def_Ty_alias_unit(arg=ty):
            return UnitAliasTypeInterpretation(type=type_of_lib(ty), _raw=x)


@dataclass(slots=True, frozen=True)
class Model:
    """A model, e.g. a counter-model or an instance"""

    types: FrozenMap[Type, TypeInterpretation]
    """The interpretations of types"""
    constants: FrozenMap[AppliedSymbol, Term]
    """The values of constants"""
    functions: FrozenMap[AppliedSymbol, FunctionInterpretation]
    """The interpretations of functions"""
    representable: bool
    """Can it be entirely represented into OCaml? Not the case if it contains irrational reals"""
    completed: bool
    """Indicates whether the model has been completed"""
    type_substitution: tuple[tuple[Uid, Type], ...]
    """Types that had new ones substituted during model extraction."""
    _raw: lib.Mir_Model = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, x: lib.Mir_Model) -> "Model":
        return cls(
            types=FrozenMap((type_of_lib(t), type_interpretation_of_lib(d)) for (t, d) in x.tys),
            constants=FrozenMap((AppliedSymbol.of_lib(s), term_of_lib(t)) for (s, t) in x.consts),
            functions=FrozenMap((AppliedSymbol.of_lib(s), FunctionInterpretation.of_lib(f)) for (s, f) in x.funs),
            representable=x.representable,
            completed=x.completed,
            type_substitution=tuple((Uid(u), type_of_lib(t)) for u, t in x.ty_subst),
            _raw=x,
        )

    def to_python(self) -> dict[str, PyValue]:
        """The constants' values as plain Python data, by short name, e.g. `{"x": 3, "ys": []}`

        Constants whose short names clash are keyed by full name instead.

        Raises:
            ValueError: if a constant's value is not a value, see `Term.to_python`
        """
        counts = Counter(s.id.short_name for s in self.constants)
        return {
            s.id.short_name if counts[s.id.short_name] == 1 else s.id.full_name: t.to_python()
            for s, t in self.constants.items()
        }

    def __str__(self) -> str:
        return f"types: {self.types} constants: {self.constants} functions: {self.functions}"


@dataclass(slots=True, frozen=True)
class UnknownStatus:
    _raw: lib.Common_Region_status[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class FeasibleStatus:
    model: Model
    _raw: lib.Common_Region_status[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


@dataclass(slots=True, frozen=True)
class FeasibilityCheckFailedStatus:
    """Trying to assess feasibility failed, eg with a timeout"""

    message: str
    _raw: lib.Common_Region_status[lib.Mir_Term, lib.Mir_Type] = field(repr=False, compare=False)


RegionStatus = UnknownStatus | FeasibleStatus | FeasibilityCheckFailedStatus


def region_status_of_lib(x: lib.Common_Region_status[lib.Mir_Term, lib.Mir_Type]) -> RegionStatus:
    """Convert a library region status into the matching `RegionStatus` variant"""
    match x:
        case lib.Common_Region_status_Unknown():
            return UnknownStatus(_raw=x)
        case lib.Common_Region_status_Feasible(arg=m):
            return FeasibleStatus(model=Model.of_lib(m), _raw=x)
        case lib.Common_Region_status_Feasibility_check_failed(arg=msg):
            return FeasibilityCheckFailedStatus(message=msg, _raw=x)


def _meta_of_lib(m: lib.Common_Region_meta[lib.Mir_Term]) -> "Decomposition.Region.Meta":
    """Convert a library region metadata value into a Python value"""
    match m:
        case lib.Common_Region_meta_Null():
            return None
        case lib.Common_Region_meta_Bool(arg=b):
            return b
        case lib.Common_Region_meta_Int(arg=n):
            return n
        case lib.Common_Region_meta_Real(arg=(num, den)):
            return Fraction(num, den)
        case lib.Common_Region_meta_String(arg=s):
            return s
        case lib.Common_Region_meta_Assoc(arg=kvs):
            return FrozenMap((k, _meta_of_lib(v)) for k, v in kvs)
        case lib.Common_Region_meta_Term(arg=t):
            return term_of_lib(t)
        case lib.Common_Region_meta_List(arg=xs):
            return tuple(_meta_of_lib(x) for x in xs)


def _meta_term(m: "Decomposition.Region.Meta") -> Term:
    """`m`, which the server sends as a term"""
    if not isinstance(m, _Term):
        raise UnexpectedResponseError(f"expected a term in region metadata, got {m}")
    return m


@dataclass(slots=True, frozen=True)
class Decomposition:
    """A region decomposition of a function"""

    @dataclass(slots=True, frozen=True, repr=False)
    class Region:
        """A region of the input space, given by constraints, and the result in it"""

        type Meta = (
            None
            | bool
            | int
            | Fraction  # real/rational
            | str
            | Term
            | FrozenMap[str, Decomposition.Region.Meta]
            | tuple[Decomposition.Region.Meta, ...]
        )
        """A metadata value attached to a region"""

        constraints: tuple[Term, ...]
        """The constraints on the inputs that define the region"""
        invariant: Term
        """The function's result for inputs in the region"""
        meta: FrozenMap[str, Meta]
        """Metadata attached to the region, by name"""
        status: RegionStatus
        """Whether the region is known to be feasible"""
        _raw: lib.Mir_Region_Region = field(repr=False, compare=False)

        @classmethod
        def of_lib(cls, r: lib.Mir_Region_Region) -> "Decomposition.Region":
            return cls(
                constraints=tuple(term_of_lib(c) for c in r.constraints),
                invariant=term_of_lib(r.invariant),
                meta=FrozenMap((k, _meta_of_lib(v)) for k, v in r.meta),
                status=region_status_of_lib(r.status),
                _raw=r,
            )

        @property
        def sample(self) -> dict[str, PyValue] | None:
            """An input in the region as plain Python data, by argument name, if the server sent one

            The server sends one for feasible regions, i.e. when decomposing with `prune=True`.

            Raises:
                ValueError: if an argument's value is not a value, see `Term.to_python`
                UnexpectedResponseError: if the server sent something other than terms
            """
            match self.meta.get("model"):
                case None:
                    return None
                case FrozenMap() as m:
                    return {k: _meta_term(v).to_python() for k, v in m.items()}
                case m:
                    raise UnexpectedResponseError(f"expected the region's sample as terms, got {m}")

        @property
        def sample_output(self) -> PyValue | None:
            """The function's result on `sample`, as plain Python data, if the server sent one

            Raises:
                ValueError: if the result is not a value, see `Term.to_python`
                UnexpectedResponseError: if the server sent something other than a term
            """
            match self.meta.get("model_eval"):
                case None:
                    return None
                case m:
                    return _meta_term(m).to_python()

        @property
        def constraints_str(self) -> tuple[str, ...] | None:
            """The constraints in IML syntax, if requested with `string_results=True`"""
            match self._str_meta("constraints"):
                case None:
                    return None
                case tuple() as cs if all(isinstance(c, str) for c in cs):
                    return cast(tuple[str, ...], cs)
                case cs:
                    raise UnexpectedResponseError(f"expected the region's constraints as strings, got {cs}")

        @property
        def invariant_str(self) -> str | None:
            """The invariant in IML syntax, if requested with `string_results=True`"""
            match self._str_meta("invariant"):
                case None | str() as s:
                    return s
                case s:
                    raise UnexpectedResponseError(f"expected the region's invariant as a string, got {s}")

        def _str_meta(self, key: str) -> Decomposition.Region.Meta:
            match self.meta.get("str"):
                case FrozenMap() as m:
                    return m.get(key)
                case _:
                    return None

        def __str__(self) -> str:
            constraints = "; ".join(str(c) for c in self.constraints)
            match self.status:
                case UnknownStatus():
                    status = "unknown"
                case FeasibleStatus():
                    status = "feasible"
                case FeasibilityCheckFailedStatus(message=msg):
                    status = f"feasibility check failed: {msg}"
            return f"constraints: [{constraints}] invariant: {self.invariant} status: {status}"

        def __repr__(self) -> str:
            return f"{type(self).__name__}({self})"

    id: Uid
    """The identifier of the decomposed function"""
    arguments: tuple[Var, ...]
    """The decomposed function's parameters"""
    regions: tuple[Region, ...]
    """The regions"""
    _raw: lib.Mir_Fun_decomp = field(repr=False, compare=False)

    @classmethod
    def of_lib(cls, d: lib.Mir_Fun_decomp) -> "Decomposition":
        return cls(
            id=Uid(d.f_id),
            arguments=tuple(var_term_of_var(a) for a in d.f_args),
            regions=tuple(Decomposition.Region.of_lib(r) for r in d.regions),
            _raw=d,
        )

    def __str__(self) -> str:
        return str(list(self.regions))


class DB:
    """A database of symbols

    Its contents are converted on first access.
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
        self._raw_rw_rules: dict[PatternHead, list[lib.Mir_Rewrite_rule]] = {}
        self._raw_fc: dict[PatternHead, list[lib.Mir_Trigger]] = {}
        self._raw_elim: dict[PatternHead, list[lib.Mir_Elimination_rule]] = {}
        self._raw_gen: dict[PatternHead, list[lib.Mir_Trigger]] = {}
        self._raw_admission: dict[Uid, lib.Common_Admission] = {}
        self._raw_thm_as_rw: dict[Uid, list[lib.Mir_Rewrite_rule]] = {}
        self._raw_thm_as_fc: dict[Uid, list[lib.Mir_Instantiation_rule]] = {}
        self._raw_thm_as_elim: dict[Uid, list[lib.Mir_Elimination_rule]] = {}
        self._raw_thm_as_gen: dict[Uid, lib.Mir_Instantiation_rule] = {}
        self._raw_inst_rules: dict[Uid, lib.Mir_Instantiation_rule] = {}
        self._raw_rule_spec_fc: dict[Uid, list[lib.Mir_Trigger]] = {}
        self._raw_rule_spec_rw_rules: dict[Uid, list[lib.Mir_Rewrite_rule]] = {}
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
                                self._raw_funs[uid] = thm.thm_link
                            case lib.Common_Decl_t_poly_Rule_spec():
                                pass
                            case lib.Common_Decl_t_poly_Verify(arg=v):
                                self._raw_funs[uid] = v.verify_link
                case lib.Common_Db_op_t_poly_Op_add_rw((head, rule)):
                    self._raw_rw_rules.setdefault(pattern_head_of_lib(head), []).append(rule)
                case lib.Common_Db_op_t_poly_Op_add_fc_trigger((head, trigger)):
                    self._raw_fc.setdefault(pattern_head_of_lib(head), []).append(trigger)
                case lib.Common_Db_op_t_poly_Op_add_elim((head, rule)):
                    self._raw_elim.setdefault(pattern_head_of_lib(head), []).append(rule)
                case lib.Common_Db_op_t_poly_Op_add_gen_trigger((head, trigger)):
                    self._raw_gen.setdefault(pattern_head_of_lib(head), []).append(trigger)
                case lib.Common_Db_op_t_poly_Op_add_count_fun():
                    pass  # ignored in imandrax
                case lib.Common_Db_op_t_poly_Op_set_admission((uid, adm)):
                    self._raw_admission[Uid(uid)] = adm
                case lib.Common_Db_op_t_poly_Op_set_thm_as_rw((uid, rules)):
                    self._raw_thm_as_rw[Uid(uid)] = rules
                case lib.Common_Db_op_t_poly_Op_set_thm_as_fc((uid, rules)):
                    self._raw_thm_as_fc[Uid(uid)] = rules
                case lib.Common_Db_op_t_poly_Op_set_thm_as_elim((uid, rules)):
                    self._raw_thm_as_elim[Uid(uid)] = rules
                case lib.Common_Db_op_t_poly_Op_set_thm_as_gen((uid, rule)):
                    self._raw_thm_as_gen[Uid(uid)] = rule
                case lib.Common_Db_op_t_poly_Op_add_instantiation_rule(rule):
                    self._raw_inst_rules[Uid(rule.ir_from.f_name)] = rule
                case lib.Common_Db_op_t_poly_Op_add_rule_spec_fc_triggers((uid, triggers)):
                    self._raw_rule_spec_fc.setdefault(Uid(uid), []).extend(triggers)
                case lib.Common_Db_op_t_poly_Op_add_rule_spec_rw((uid, rules)):
                    self._raw_rule_spec_rw_rules.setdefault(Uid(uid), []).extend(rules)
                case _:
                    raise UnexpectedResponseError("unknown MIR database operation")

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

    @cached_property
    def rw_rules(self) -> dict[PatternHead, list[RewriteRule]]:
        """Rewrite rules, by the uid of their pattern head"""
        return {h: [RewriteRule.of_lib(r) for r in rs] for h, rs in self._raw_rw_rules.items()}

    @cached_property
    def fc(self) -> dict[PatternHead, list[Trigger]]:
        """Forward-chaining triggers, by the uid of their pattern head"""
        return {h: [Trigger.of_lib(t) for t in ts] for h, ts in self._raw_fc.items()}

    @cached_property
    def elim(self) -> dict[PatternHead, list[EliminationRule]]:
        """Elimination rules, by the uid of their pattern head"""
        return {h: [EliminationRule.of_lib(r) for r in rs] for h, rs in self._raw_elim.items()}

    @cached_property
    def gen(self) -> dict[PatternHead, list[Trigger]]:
        """Generalization triggers, by the uid of their pattern head"""
        return {h: [Trigger.of_lib(t) for t in ts] for h, ts in self._raw_gen.items()}

    @cached_property
    def admission(self) -> dict[Uid, Admission]:
        """Admission information, by function uid"""
        return {u: Admission.of_lib(a) for u, a in self._raw_admission.items()}

    @cached_property
    def thm_as_rw(self) -> dict[Uid, list[RewriteRule]]:
        """Rewrite rules derived from each theorem, by theorem uid"""
        return {u: [RewriteRule.of_lib(r) for r in rs] for u, rs in self._raw_thm_as_rw.items()}

    @cached_property
    def thm_as_fc(self) -> dict[Uid, list[InstantiationRule]]:
        """Forward-chaining rules derived from each theorem, by theorem uid"""
        return {u: [InstantiationRule.of_lib(r) for r in rs] for u, rs in self._raw_thm_as_fc.items()}

    @cached_property
    def thm_as_elim(self) -> dict[Uid, list[EliminationRule]]:
        """Elimination rules derived from each theorem, by theorem uid"""
        return {u: [EliminationRule.of_lib(r) for r in rs] for u, rs in self._raw_thm_as_elim.items()}

    @cached_property
    def thm_as_gen(self) -> dict[Uid, InstantiationRule]:
        """The generalization rule derived from each theorem, by theorem uid"""
        return {u: InstantiationRule.of_lib(r) for u, r in self._raw_thm_as_gen.items()}

    @cached_property
    def inst_rules(self) -> dict[Uid, InstantiationRule]:
        """Instantiation rules, by the uid of the function they come from"""
        return {u: InstantiationRule.of_lib(r) for u, r in self._raw_inst_rules.items()}

    @cached_property
    def rule_spec_fc(self) -> dict[Uid, list[Trigger]]:
        """Forward-chaining triggers of each rule spec, by uid"""
        return {u: [Trigger.of_lib(t) for t in ts] for u, ts in self._raw_rule_spec_fc.items()}

    @cached_property
    def rule_spec_rw_rules(self) -> dict[Uid, list[RewriteRule]]:
        """Rewrite rules of each rule spec, by uid"""
        return {u: [RewriteRule.of_lib(r) for r in rs] for u, rs in self._raw_rule_spec_rw_rules.items()}

    def __str__(self) -> str:
        def uids(us: Iterable[Uid]) -> list[str]:
            return sorted(str(u) for u in us)

        def counts(entries: Iterable[tuple[Uid | PatternHead, Sized]]) -> list[str]:
            return sorted(f"{u}: {len(xs)}" for u, xs in entries)

        sections: list[tuple[str, list[str]]] = [
            ("disabled", uids(self.disabled)),
            ("rw_rules", counts(self.rw_rules.items())),
            ("fc", counts(self.fc.items())),
            ("elim", counts(self.elim.items())),
            ("gen", counts(self.gen.items())),
            ("admission", uids(self.admission.keys())),
            ("thm_as_rw", counts(self.thm_as_rw.items())),
            ("thm_as_fc", counts(self.thm_as_fc.items())),
            ("thm_as_elim", counts(self.thm_as_elim.items())),
            ("thm_as_gen", uids(self.thm_as_gen.keys())),
            ("inst_rules", uids(self.inst_rules.keys())),
            ("rule_spec_fc", counts(self.rule_spec_fc.items())),
            ("rule_spec_rw_rules", counts(self.rule_spec_rw_rules.items())),
        ]
        lines = [f"decls: {len(self.decls)}"]
        for name, items in sections:
            lines.append(f"{name}:" if items else f"{name}: {{}}")
            lines.extend(f"  {x}" for x in items)
        return "\n".join(lines)

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
