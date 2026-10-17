import base64
import re

from collections.abc import Callable, Iterable, Iterator, Sized
from typing import Never, override

from imandrax_api import lib

# Note: all __str__ in there are purely for debugging purposes. There is no MIR
# text format; MIR is only exchanged in byte-serialized form and there is no
# parser that would turn text into MIR data structures. The reason is that
# during the transition from IML to MIR there are a number of processes that
# ensure the resulting MIR has the right properties (e.g. content hashed
# functions, lifted lambdas, correct types, inferred type variables, ...), and
# those processes are not replicated on the client side.


class InvalidSubterm(Exception):
    """An invalid subterm was encountered"""


class InvalidType(Exception):
    """An invalid type was encountered"""


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

    def __init__(self, x: lib.Mir_Type):
        self._raw: lib.Mir_Type = x

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Type) and self._raw == other._raw

    def __hash__(self) -> int:
        # Weak hash function because types contain lists that aren't hashable.
        return hash(type(self))

    def __str__(self) -> str:
        return "<type>"

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


def type_of_lib(x: lib.Mir_Type) -> Type:
    """Wrap a library type in the matching `Type` subclass"""
    match x.view:
        case lib.Ty_view_view_Var():
            return TypeVariable(x)
        case lib.Ty_view_view_Arrow():
            return ArrowType(x)
        case lib.Ty_view_view_Constr():
            return ConstructedType(x)
        case _:
            raise Exception("Invalid type")


class TypeVariable(Type):
    """A type variable"""

    def __init__(self, x: lib.Mir_Type):
        if not isinstance(x.view, lib.Ty_view_view_Var):
            raise InvalidType()
        self._raw: lib.Mir_Type = x

    @property
    def _view(self) -> lib.Ty_view_view_Var:
        assert isinstance(self._raw.view, lib.Ty_view_view_Var)
        return self._raw.view

    def __str__(self) -> str:
        return f"{self._view.arg}"


class ArrowType(Type):
    """A function type `a -> b`"""

    def __init__(self, x: lib.Mir_Type):
        if not isinstance(x.view, lib.Ty_view_view_Arrow):
            raise InvalidType()
        self._raw: lib.Mir_Type = x

    @property
    def _view(self) -> lib.Ty_view_view_Arrow:
        assert isinstance(self._raw.view, lib.Ty_view_view_Arrow)
        return self._raw.view

    def __str__(self) -> str:
        lbl, tl, tr = self._view.args
        lbl = "" if lbl is None else f"{lbl}"
        return f"{lbl}{str(type_of_lib(tl))} -> {str(type_of_lib(tr))}"


class ConstructedType(Type):
    """A type constructor applied to type arguments, e.g. `int list`"""

    def __init__(self, x: lib.Mir_Type):
        if not isinstance(x.view, lib.Ty_view_view_Constr):
            raise InvalidType()
        self._raw: lib.Mir_Type = x

    @property
    def _view(self) -> lib.Ty_view_view_Constr:
        assert isinstance(self._raw.view, lib.Ty_view_view_Constr)
        return self._raw.view

    def __str__(self) -> str:
        id, ts = self._view.args
        ts = [type_of_lib(t) for t in ts]
        elems = " ".join([f"{t}" for t in ts])
        if len(elems) > 0:
            elems += " "
        return f"{elems}{Uid(id)}"


class TypedSymbol:
    """A symbol together with its type schema"""

    def __init__(self, x: lib.Mir_Typed_symbol):
        self._raw = x

    @property
    def id(self) -> Uid:
        """The symbol's unique identifier"""
        return Uid(self._raw.id)

    @property
    def type_schema(self) -> lib.Common_Type_schema_t_poly:
        """The symbol's type schema"""
        return self._raw.ty


class AppliedSymbol:
    """A symbol instantiated at a concrete type"""

    def __init__(self, x: lib.Mir_Applied_symbol):
        self._raw = x

    @property
    def id(self) -> Uid:
        """The symbol's unique identifier"""
        return Uid(self._raw.sym.id)

    @property
    def symbol(self) -> TypedSymbol:
        """The underlying typed symbol"""
        return TypedSymbol(self._raw.sym)

    @property
    def type(self) -> Type:
        """The type at which the symbol is used"""
        return type_of_lib(self._raw.ty)

    def __eq__(self, other: object) -> bool:
        return isinstance(other, AppliedSymbol) and self._raw == other._raw

    def __hash__(self) -> int:
        # Weak hash function because types contain lists that aren't hashable.
        return hash(self._raw.sym.id)

    def __str__(self) -> str:
        return f"{self.id} : {self.type}"

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


class Term:
    """A term"""

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
    """Wrap a library term in the matching `Term` subclass"""
    match x.view:
        case lib.Mir_Term_view_Const():
            return Constant(x)
        case lib.Mir_Term_view_If():
            return If(x)
        case lib.Mir_Term_view_Apply():
            return Apply(x)
        case lib.Mir_Term_view_Var():
            return Var(x)
        case lib.Mir_Term_view_Sym():
            return Symbol(x)
        case lib.Mir_Term_view_Construct():
            return Construct(x)
        case lib.Mir_Term_view_Destruct():
            return Destruct(x)
        case lib.Mir_Term_view_Is_a():
            return IsA(x)
        case lib.Mir_Term_view_Tuple():
            return Tuple(x)
        case lib.Mir_Term_view_Field():
            return Field(x)
        case lib.Mir_Term_view_Tuple_field():
            return TupleField(x)
        case lib.Mir_Term_view_Record():
            return Record(x)
        case lib.Mir_Term_view_Case():
            return Case(x)
        case lib.Mir_Term_view_Sequence():
            return Sequence(x)
        case _:
            raise Exception("Unknown MIR term view")


def _name(s: lib.Mir_Applied_symbol) -> str:
    """The short name of an applied symbol"""
    return s.sym.id.name


class Constant(Term):
    """A constant"""

    def __init__(self, x: lib.Mir_Term):
        if not isinstance(x.view, lib.Mir_Term_view_Const):
            raise InvalidSubterm()
        self._raw = x

    @property
    def _view(self) -> lib.Mir_Term_view_Const[lib.Mir_Term, lib.Mir_Type]:
        assert isinstance(self._raw.view, lib.Mir_Term_view_Const)
        return self._raw.view

    @property
    def value(self) -> lib.Const:
        """The constant's value"""
        return self._view.arg

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


class If(Term):
    """A conditional `if c then a else b`"""

    def __init__(self, x: lib.Mir_Term):
        if not isinstance(x.view, lib.Mir_Term_view_If):
            raise InvalidSubterm()
        self._raw = x

    @property
    def _view(self) -> lib.Mir_Term_view_If[lib.Mir_Term, lib.Mir_Type]:
        assert isinstance(self._raw.view, lib.Mir_Term_view_If)
        return self._raw.view

    @property
    def condition(self) -> Term:
        """The condition"""
        return term_of_lib(self._view.args[0])

    @property
    def then_branch(self) -> Term:
        """The term evaluated if the condition is true"""
        return term_of_lib(self._view.args[1])

    @property
    def else_branch(self) -> Term:
        """The term evaluated if the condition is false"""
        return term_of_lib(self._view.args[2])

    @property
    @override
    def subterms(self) -> list[Term]:
        return [self.condition, self.then_branch, self.else_branch]

    @override
    def __str__(self) -> str:
        return f"if {self.condition} then {self.then_branch} else {self.else_branch}"


class Apply(Term):
    """A function application"""

    def __init__(self, x: lib.Mir_Term):
        if not isinstance(x.view, lib.Mir_Term_view_Apply):
            raise InvalidSubterm()
        self._raw = x

    @property
    def _view(self) -> lib.Mir_Term_view_Apply[lib.Mir_Term, lib.Mir_Type]:
        assert isinstance(self._raw.view, lib.Mir_Term_view_Apply)
        return self._raw.view

    @property
    def function(self) -> Term:
        """The function being applied"""
        return term_of_lib(self._view.f)

    @property
    def arguments(self) -> list[Term]:
        """The arguments the function is applied to"""
        return [term_of_lib(t) for t in self._view.l]

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


class Var(Term):
    """A variable"""

    def __init__(self, x: lib.Mir_Term):
        if not isinstance(x.view, lib.Mir_Term_view_Var):
            raise InvalidSubterm()
        self._raw = x

    @property
    def _view(self) -> lib.Mir_Term_view_Var[lib.Mir_Term, lib.Mir_Type]:
        assert isinstance(self._raw.view, lib.Mir_Term_view_Var)
        return self._raw.view

    @property
    def var(self) -> lib.Mir_Var:
        """The variable, with its type"""
        return self._view.arg

    @override
    def __str__(self) -> str:
        return self.var.id.name


def var_term_of_var(x: lib.Mir_Var) -> Var:
    """Turn a library variable into a `Var` term"""
    return Var(lib.Mir_Term(view=(lib.Mir_Term_view_Var(arg=x)), ty=x.ty, sub_anchor=None))


class Symbol(Term):
    """A symbol"""

    def __init__(self, x: lib.Mir_Term):
        if not isinstance(x.view, lib.Mir_Term_view_Sym):
            raise InvalidSubterm()
        self._raw = x

    @property
    def _view(self) -> lib.Mir_Term_view_Sym[lib.Mir_Term, lib.Mir_Type]:
        assert isinstance(self._raw.view, lib.Mir_Term_view_Sym)
        return self._raw.view

    @property
    def symbol(self) -> AppliedSymbol:
        """The symbol, instantiated at its type"""
        return AppliedSymbol(self._view.arg)

    @override
    def __str__(self) -> str:
        return self.symbol.id.full_name


class Construct(Term):
    """A constructor applied to arguments"""

    def __init__(self, x: lib.Mir_Term):
        if not isinstance(x.view, lib.Mir_Term_view_Construct):
            raise InvalidSubterm()
        self._raw = x

    @property
    def _view(self) -> lib.Mir_Term_view_Construct[lib.Mir_Term, lib.Mir_Type]:
        assert isinstance(self._raw.view, lib.Mir_Term_view_Construct)
        return self._raw.view

    @property
    def constructor(self) -> lib.Mir_Applied_symbol:
        """The constructor"""
        return self._view.c

    @property
    def arguments(self) -> list[Term]:
        """The constructor's arguments"""
        return [term_of_lib(t) for t in self._view.args]

    @property
    def labels(self) -> list[Uid] | None:
        """The argument labels, if the constructor takes labeled (record) arguments"""
        if self._view.labels is None:
            return None
        return [Uid(l) for l in self._view.labels]

    @property
    @override
    def subterms(self) -> list[Term]:
        return self.arguments

    @override
    def __str__(self) -> str:
        name = _name(self.constructor)
        args = self.arguments
        if not args:
            return name
        if (labels := self.labels) is not None:
            fields = "; ".join(f"{l.full_name} = {a}" for l, a in zip(labels, args))
            return f"{name} {{{fields}}}"
        if len(args) == 1:
            return f"{name} {str(args[0])}"
        return f"{name} ({', '.join(str(a) for a in args)})"


class Destruct(Term):
    """A destructor term. (The `index`-th argument of a term built with `constructor`.)"""

    def __init__(self, x: lib.Mir_Term):
        if not isinstance(x.view, lib.Mir_Term_view_Destruct):
            raise InvalidSubterm()
        self._raw = x

    @property
    def _view(self) -> lib.Mir_Term_view_Destruct[lib.Mir_Term, lib.Mir_Type]:
        assert isinstance(self._raw.view, lib.Mir_Term_view_Destruct)
        return self._raw.view

    @property
    def constructor(self) -> lib.Mir_Applied_symbol:
        """The constructor whose argument is extracted"""
        return self._view.c

    @property
    def index(self) -> int:
        """The position of the extracted argument"""
        return self._view.i

    @property
    def term(self) -> Term:
        """The term the argument is extracted from"""
        return term_of_lib(self._view.t)

    @property
    @override
    def subterms(self) -> list[Term]:
        return [self.term]

    @override
    def __str__(self) -> str:
        return f"Destruct({_name(self.constructor)}, {self.index}, {self.term})"


class IsA(Term):
    """A test whether a term was built with `constructor`"""

    def __init__(self, x: lib.Mir_Term):
        if not isinstance(x.view, lib.Mir_Term_view_Is_a):
            raise InvalidSubterm()
        self._raw = x

    @property
    def _view(self) -> lib.Mir_Term_view_Is_a[lib.Mir_Term, lib.Mir_Type]:
        assert isinstance(self._raw.view, lib.Mir_Term_view_Is_a)
        return self._raw.view

    @property
    def constructor(self) -> lib.Mir_Applied_symbol:
        """The constructor tested for"""
        return self._view.c

    @property
    def term(self) -> Term:
        """The term being tested"""
        return term_of_lib(self._view.t)

    @property
    @override
    def subterms(self) -> list[Term]:
        return [self.term]

    @override
    def __str__(self) -> str:
        return f"Is_a({_name(self.constructor)}, {self.term})"


class Tuple(Term):
    """A tuple"""

    def __init__(self, x: lib.Mir_Term):
        if not isinstance(x.view, lib.Mir_Term_view_Tuple):
            raise InvalidSubterm()
        self._raw = x

    @property
    def _view(self) -> lib.Mir_Term_view_Tuple[lib.Mir_Term, lib.Mir_Type]:
        assert isinstance(self._raw.view, lib.Mir_Term_view_Tuple)
        return self._raw.view

    @property
    def __len__(self) -> int:
        return len(self._view.l)

    @property
    def elements(self) -> list[Term]:
        """The tuple's elements"""
        return [term_of_lib(t) for t in self._view.l]

    @property
    @override
    def subterms(self) -> list[Term]:
        return self.elements

    @override
    def __str__(self) -> str:
        return f"({', '.join(str(e) for e in self.elements)})"


class Field(Term):
    """A record field"""

    def __init__(self, x: lib.Mir_Term):
        if not isinstance(x.view, lib.Mir_Term_view_Field):
            raise InvalidSubterm()
        self._raw = x

    @property
    def _view(self) -> lib.Mir_Term_view_Field[lib.Mir_Term, lib.Mir_Type]:
        assert isinstance(self._raw.view, lib.Mir_Term_view_Field)
        return self._raw.view

    @property
    def field(self) -> lib.Mir_Applied_symbol:
        """The field being accessed"""
        return self._view.f

    @property
    def term(self) -> Term:
        """The record whose field is accessed"""
        return term_of_lib(self._view.t)

    @property
    @override
    def subterms(self) -> list[Term]:
        return [self.term]

    @override
    def __str__(self) -> str:
        return f"{str(self.term)}.{_name(self.field)}"


class TupleField(Term):
    """A tuple field"""

    def __init__(self, x: lib.Mir_Term):
        if not isinstance(x.view, lib.Mir_Term_view_Tuple_field):
            raise InvalidSubterm()
        self._raw = x

    @property
    def _view(self) -> lib.Mir_Term_view_Tuple_field[lib.Mir_Term, lib.Mir_Type]:
        assert isinstance(self._raw.view, lib.Mir_Term_view_Tuple_field)
        return self._raw.view

    @property
    def index(self) -> int:
        """The position of the accessed component"""
        return self._view.i

    @property
    def term(self) -> Term:
        """The tuple whose component is accessed"""
        return term_of_lib(self._view.t)

    @property
    @override
    def subterms(self) -> list[Term]:
        return [self.term]

    @override
    def __str__(self) -> str:
        return f"{str(self.term)}.{self.index}"


class Record(Term):
    """A record"""

    def __init__(self, x: lib.Mir_Term):
        if not isinstance(x.view, lib.Mir_Term_view_Record):
            raise InvalidSubterm()
        self._raw = x

    @property
    def _view(self) -> lib.Mir_Term_view_Record[lib.Mir_Term, lib.Mir_Type]:
        assert isinstance(self._raw.view, lib.Mir_Term_view_Record)
        return self._raw.view

    @property
    def rows(self) -> list[tuple[lib.Mir_Applied_symbol, Term]]:
        """The record's fields and their values"""
        return [(f, term_of_lib(t)) for f, t in self._view.rows]

    @property
    def rest(self) -> Term | None:
        """The record being updated in `{rest with ...}`, if any"""
        return None if self._view.rest is None else term_of_lib(self._view.rest)

    @property
    @override
    def subterms(self) -> list[Term]:
        ts = [] if (rest := self.rest) is None else [rest]
        return ts + [t for _, t in self.rows]

    @override
    def __str__(self) -> str:
        fields = "; ".join(f"{_name(f)} = {t}" for f, t in self.rows)
        if (rest := self.rest) is not None:
            return f"{{{str(rest)} with {fields}}}"
        return f"{{{fields}}}"


class Case(Term):
    """A pattern match on `scrutinee`"""

    def __init__(self, x: lib.Mir_Term):
        if not isinstance(x.view, lib.Mir_Term_view_Case):
            raise InvalidSubterm()
        self._raw = x

    @property
    def _view(self) -> lib.Mir_Term_view_Case[lib.Mir_Term, lib.Mir_Type]:
        assert isinstance(self._raw.view, lib.Mir_Term_view_Case)
        return self._raw.view

    @property
    def scrutinee(self) -> Term:
        """The term being matched on"""
        return term_of_lib(self._view.u)

    @property
    def cases(self) -> list[tuple[lib.Mir_Applied_symbol, Term]]:
        """The match arms, each a constructor and the term for that case"""
        return [(c, term_of_lib(t)) for c, t in self._view.cases]

    @property
    def default(self) -> Term | None:
        """The term for the wildcard case `_`, if any"""
        return None if self._view.default is None else term_of_lib(self._view.default)

    @property
    @override
    def subterms(self) -> list[Term]:
        ts = [self.scrutinee, *(t for _, t in self.cases)]
        if (default := self.default) is not None:
            ts.append(default)
        return ts

    @override
    def __str__(self) -> str:
        arms = [f"| {_name(c)} -> {t}" for c, t in self.cases]
        if (default := self.default) is not None:
            arms.append(f"| _ -> {default}")
        return f"match {self.scrutinee} with {' '.join(arms)}"


class Sequence(Term):
    """A sequence `t1; ...; tn; last`"""

    def __init__(self, x: lib.Mir_Term):
        if not isinstance(x.view, lib.Mir_Term_view_Sequence):
            raise InvalidSubterm()
        self._raw = x

    @property
    def _view(self) -> lib.Mir_Term_view_Sequence[lib.Mir_Term, lib.Mir_Type]:
        assert isinstance(self._raw.view, lib.Mir_Term_view_Sequence)
        return self._raw.view

    @property
    def prefix(self) -> list[Term]:
        """The terms evaluated before `last`"""
        return [term_of_lib(t) for t in self._view.args[0]]

    @property
    def last(self) -> Term:
        """The final term, whose value is the value of the sequence"""
        return term_of_lib(self._view.args[1])

    @property
    @override
    def subterms(self) -> list[Term]:
        return [*self.prefix, self.last]

    @override
    def __str__(self) -> str:
        return "; ".join(str(t) for t in [*self.prefix, self.last])


class Sequent:
    """A sequent"""

    def __init__(self, x: lib.Mir_Sequent):
        self._raw = x

    @property
    def hypotheses(self) -> list[tuple[str | None, Term]]:
        """The hypotheses, each with an optional name"""
        return [(n, term_of_lib(t)) for (n, t) in self._raw.hyps]

    @property
    def conclusions(self) -> list[tuple[str | None, Term]]:
        """The conclusions, each with an optional name"""
        return [(n, term_of_lib(t)) for (n, t) in self._raw.concls]


class FunctionDefinition:
    """A function definition"""

    def __init__(self, x: lib.Mir_Fun_def):
        self._raw = x

    @property
    def name(self) -> Uid:
        """The function's name"""
        return Uid(self._raw.f_name)

    @property
    def type_parameters(self) -> list[Uid]:
        """The type variables the function's type is generic over"""
        return [Uid(p) for p in self._raw.f_ty.params]

    @property
    def type(self) -> Type:
        """The function's type"""
        return type_of_lib(self._raw.f_ty.ty)

    @property
    def arguments(self) -> list[Var]:
        """The function's parameters"""
        return [var_term_of_var(a) for a in self._raw.f_args]

    @property
    def body(self) -> Term:
        """The function's body"""
        return term_of_lib(self._raw.f_body)

    @property
    def clique(self) -> set[Uid] | None:
        """The mutually recursive functions this function belongs to, if any"""
        clique = self._raw.f_clique
        return None if clique is None else {Uid(u) for u in clique}

    @property
    def kind(self) -> lib.Common_Fun_def_fun_kind:
        """Whether the function is defined, builtin or opaque"""
        return self._raw.f_kind

    @property
    def hints(self) -> lib.Mir_Hints:
        """Prover hints attached to the definition"""
        return self._raw.f_hints

    def __str__(self) -> str:
        args = "".join(f" {a}" for a in self.arguments)
        return f"let {self.name}{args} = {self.body}"

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


class TypeDefinition:
    """A type definition"""

    def __init__(self, x: lib.Mir_Type_def):
        self._raw = x

    @property
    def name(self) -> Uid:
        """The type's name"""
        return Uid(self._raw.name)

    @property
    def parameters(self) -> list[Uid]:
        """The type variables the type is parameterized over"""
        return [Uid(p) for p in self._raw.params]

    @property
    def declaration(self) -> lib.Ty_view_decl[lib.Uid, lib.Mir_Type, Never]:
        """How the type is defined: algebraic, record, skolem, builtin, ..."""
        return self._raw.decl

    @property
    def clique(self) -> set[Uid] | None:
        """The mutually recursive types this type belongs to, if any"""
        clique = self._raw.clique
        return None if clique is None else {Uid(u) for u in clique}

    @property
    def timeout(self) -> int | None:
        """The timeout for checking the definition, if any"""
        return self._raw.timeout

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


class Declaration:
    """A declaration: a function, type, theorem, rule spec or verify declaration"""

    def __init__(self, x: lib.Mir_Decl):
        self._raw = x

    @property
    def id(self) -> Uid:
        """The identifier of the declaration (for theorems etc., the linked function's)"""
        return _decl_uid(self._raw)

    @property
    def kind(self) -> str:
        """The kind of declaration: `function`, `type`, `theorem`, `rule_spec` or `verify`"""
        match self._raw:
            case lib.Common_Decl_t_poly_Fun():
                return "function"
            case lib.Common_Decl_t_poly_Ty():
                return "type"
            case lib.Common_Decl_t_poly_Theorem():
                return "theorem"
            case lib.Common_Decl_t_poly_Rule_spec():
                return "rule_spec"
            case lib.Common_Decl_t_poly_Verify():
                return "verify"

    @property
    def function(self) -> FunctionDefinition | None:
        """The function defined, or for theorems, rule specs and verify the linked function"""
        match self._raw:
            case lib.Common_Decl_t_poly_Fun(arg=f):
                return FunctionDefinition(f)
            case lib.Common_Decl_t_poly_Theorem(arg=thm):
                return FunctionDefinition(thm.thm_link)
            case lib.Common_Decl_t_poly_Rule_spec(arg=rs):
                return FunctionDefinition(rs.rule_spec_link)
            case lib.Common_Decl_t_poly_Verify(arg=v):
                return FunctionDefinition(v.verify_link)
            case _:
                return None

    @property
    def type(self) -> TypeDefinition | None:
        """The type defined, if this is a type declaration"""
        match self._raw:
            case lib.Common_Decl_t_poly_Ty(arg=ty):
                return TypeDefinition(ty)
            case _:
                return None

    @property
    def theorem(self) -> lib.Mir_Theorem | None:
        """The theorem, if this is a theorem declaration"""
        match self._raw:
            case lib.Common_Decl_t_poly_Theorem(arg=thm):
                return thm
            case _:
                return None

    @property
    def rule_spec(self) -> lib.Common_Rule_spec_t_poly[lib.Mir_Term, lib.Mir_Type] | None:
        """The rule spec, if this is a rule spec declaration"""
        match self._raw:
            case lib.Common_Decl_t_poly_Rule_spec(arg=rs):
                return rs
            case _:
                return None

    @property
    def verify(self) -> lib.Common_Verify_t_poly[lib.Mir_Term, lib.Mir_Type] | None:
        """The verify declaration, if this is one"""
        match self._raw:
            case lib.Common_Decl_t_poly_Verify(arg=v):
                return v
            case _:
                return None

    def __str__(self) -> str:
        if (ty := self.type) is not None:
            return str(ty)
        f = self.function
        if f is None:
            return f"<{self.kind}>"
        keyword = "let" if self.kind == "function" else self.kind
        args = "".join(f" {a}" for a in f.arguments)
        return f"{keyword} {f.name}{args} = {f.body}"

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


class PatternHead:
    """The head of a rule pattern: a symbol, a type, or a datatype operation"""

    def __init__(self, x: lib.Mir_Pattern_head):
        self._raw = x

    @property
    def uid(self) -> Uid | None:
        """The symbol's uid, if this is a symbol head"""
        match self._raw:
            case lib.Common_Pattern_head_t_poly_PH_id(arg=uid):
                return Uid(uid)
            case _:
                return None

    @property
    def type(self) -> Type | None:
        """The type, if this is a type head"""
        match self._raw:
            case lib.Common_Pattern_head_t_poly_PH_ty(arg=ty):
                return type_of_lib(ty)
            case _:
                return None

    @property
    def is_datatype_op(self) -> bool:
        """Whether this is a datatype operation head"""
        return isinstance(self._raw, lib.Common_Pattern_head_t_poly_PH_datatype_op)

    def __eq__(self, other: object) -> bool:
        return isinstance(other, PatternHead) and self._raw == other._raw

    def __hash__(self) -> int:
        # Weak hash function because types contain lists that aren't hashable.
        match self._raw:
            case lib.Common_Pattern_head_t_poly_PH_id(arg=uid):
                return hash(uid)
            case _:
                return hash(type(self._raw))

    def __str__(self) -> str:
        if (uid := self.uid) is not None:
            return str(uid)
        if (ty := self.type) is not None:
            return str(ty)
        return "<datatype op>"

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


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


class DB:
    """A database of symbols"""

    def __init__(self, ds: lib.Mir_Db_ser, storage: dict[str, bytes]):
        # ds is a series of serialized DB operations; we reconstruct a concrete
        # database by replaying all the operations.

        self._raw = ds
        self._storage = storage
        self._disabled: set[Uid] = set()
        self._tys: dict[Uid, TypeDefinition] = {}
        self._funs: dict[Uid, FunctionDefinition] = {}
        self._theorems: dict[Uid, lib.Mir_Theorem] = {}
        self._rule_specs: dict[Uid, lib.Common_Rule_spec_t_poly[lib.Mir_Term, lib.Mir_Type]] = {}
        self._decls: dict[Uid, Declaration] = {}
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
                        self._decls[uid] = Declaration(d)
                        match d:
                            case lib.Common_Decl_t_poly_Fun(arg=f):
                                self._funs[uid] = FunctionDefinition(f)
                            case lib.Common_Decl_t_poly_Ty(arg=ty):
                                self._tys[uid] = TypeDefinition(ty)
                            case lib.Common_Decl_t_poly_Theorem(arg=thm):
                                self._theorems[uid] = thm
                                self._funs[uid] = FunctionDefinition(thm.thm_link)
                            case lib.Common_Decl_t_poly_Rule_spec(arg=rs):
                                self._rule_specs[uid] = rs
                            case lib.Common_Decl_t_poly_Verify(arg=v):
                                self._funs[uid] = FunctionDefinition(v.verify_link)
                case lib.Common_Db_op_t_poly_Op_add_rw((head, rule)):
                    self._rw_rules.setdefault(PatternHead(head), []).append(rule)
                case lib.Common_Db_op_t_poly_Op_add_fc_trigger((head, trigger)):
                    self._fc.setdefault(PatternHead(head), []).append(trigger)
                case lib.Common_Db_op_t_poly_Op_add_elim((head, rule)):
                    self._elim.setdefault(PatternHead(head), []).append(rule)
                case lib.Common_Db_op_t_poly_Op_add_gen_trigger((head, trigger)):
                    self._gen.setdefault(PatternHead(head), []).append(trigger)
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
        r: dict[Uid, Declaration] = dict()
        for id, d in self._decls.items():
            if rx.match(id.full_name):
                r[id] = d
        return r

    def find_type(self, x: Uid) -> TypeDefinition | None:
        """The type definition with uid `x`, or `None`"""
        return self._tys.get(x)

    def find_type_re(self, regex: str) -> dict[Uid, TypeDefinition]:
        """All types whose full name matches `regex`"""
        rx = re.compile(regex)
        r: dict[Uid, TypeDefinition] = dict()
        for id, t in self._tys.items():
            if rx.match(id.full_name):
                r[id] = t
        return r

    def find_function(self, x: Uid) -> FunctionDefinition | None:
        """The function definition with uid `x`, or `None`"""
        return self._funs.get(x)

    def find_function_re(self, regex: str) -> dict[Uid, FunctionDefinition]:
        """All functions whose full name matches `regex`"""
        rx = re.compile(regex)
        r: dict[Uid, FunctionDefinition] = dict()
        for id, f in self._funs.items():
            if rx.match(id.full_name):
                r[id] = f
        return r
