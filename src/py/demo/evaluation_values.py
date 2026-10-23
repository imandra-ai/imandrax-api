from dataclasses import dataclass, field
from fractions import Fraction
from typing import override

import mir
from imandrax_api import lib

# `Imandrax_api_eval.Value`
# =========================

# Like the classes in `mir`, values are frozen dataclasses converted eagerly by
# `value_of_lib`, keeping the library value they were converted from in the hidden
# field `_raw`.

type _View = lib.Eval_Value_view[lib.Eval_Value, lib.Eval_Value_erased_closure]


class Value:
    """A value produced by evaluation; base class of all value kinds."""

    __slots__ = ()
    _raw: _View

    def __str__(self) -> str:
        return "<value>"

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


@dataclass(slots=True, frozen=True, repr=False)
class True_(Value):
    """The boolean `true`."""

    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return "true"


@dataclass(slots=True, frozen=True, repr=False)
class False_(Value):
    """The boolean `false`."""

    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return "false"


@dataclass(slots=True, frozen=True, repr=False)
class Int(Value):
    """An integer, stored in `value`."""

    value: int
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return str(self.value)


@dataclass(slots=True, frozen=True, repr=False)
class Real(Value):
    """A real number, stored exactly as a `Fraction` in `value`."""

    value: Fraction
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return str(self.value)


@dataclass(slots=True, frozen=True, repr=False)
class String(Value):
    """A string, stored in `value`."""

    value: str
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return f'"{self.value}"'


@dataclass(slots=True, frozen=True, repr=False)
class Constructor(Value):
    """A data constructor applied to arguments, e.g. `Some 3` or `None`.

    `name` is the constructor's name, `index` its position among the type's constructors, and
    `args` its arguments.
    """

    name: str
    index: int
    args: tuple[Value, ...]
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        if not self.args:
            return self.name
        return f"{self.name} ({', '.join(str(a) for a in self.args)})"


@dataclass(slots=True, frozen=True, repr=False)
class Tuple(Value):
    """A tuple; `elements` holds its components in order."""

    elements: tuple[Value, ...]
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return f"({', '.join(str(e) for e in self.elements)})"


@dataclass(slots=True, frozen=True, repr=False)
class Record(Value):
    """A record; `name` identifies the record type and `fields` maps field names to values."""

    name: str
    fields: dict[str, Value]
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return "{" + "; ".join(f"{k} = {x}" for k, x in self.fields.items()) + "}"


@dataclass(slots=True, frozen=True, repr=False)
class QuotedTerm(Value):
    """A quoted term: a MIR function with parameters `params` and body `body`."""

    params: tuple[mir.Var, ...]
    body: mir.Term
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return "<quoted term>"


@dataclass(slots=True, frozen=True, repr=False)
class Uid(Value):
    """A unique identifier, stored in `uid` and printed by name."""

    uid: mir.Uid
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return self.uid.short_name


@dataclass(slots=True, frozen=True, repr=False)
class Closure(Value):
    """A function value; its code is not sent to the client, so it prints as `<fun>`."""

    closure: lib.Eval_Value_erased_closure
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return "<fun>"


@dataclass(slots=True, frozen=True, repr=False)
class Custom(Value):
    """A custom value.

    The library cannot decode custom values yet (decoding raises an error), so this class is
    currently never produced.
    """

    value: lib.Eval__Value_Custom_value
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return "<custom>"


def _ordinal_str(o: lib.Eval_Ordinal) -> str:
    """Format an ordinal: a plain integer as `n`, a `Cons (a, n, b)` as the triple `(a, n, b)`."""
    match o:
        case lib.Eval_Ordinal_Int(arg=n):
            return f"{n}"
        case lib.Eval_Ordinal_Cons(args=(a, n, b)):
            return f"({_ordinal_str(a)}, {n}, {_ordinal_str(b)})"


@dataclass(slots=True, frozen=True, repr=False)
class Ordinal(Value):
    """An ordinal, stored in `value`."""

    value: lib.Eval_Ordinal
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return _ordinal_str(self.value)


def value_of_lib(x: _View) -> Value:
    """Convert an evaluation value from `imandrax_api.lib` into the matching `Value` subclass.

    Nested values (constructor arguments, tuple elements, record fields) are converted
    recursively.
    """
    match x:
        case lib.Eval_Value_view_V_true():
            return True_(_raw=x)
        case lib.Eval_Value_view_V_false():
            return False_(_raw=x)
        case lib.Eval_Value_view_V_int(arg=n):
            return Int(value=n, _raw=x)
        case lib.Eval_Value_view_V_real(arg=(num, den)):
            return Real(value=Fraction(num, den), _raw=x)
        case lib.Eval_Value_view_V_string(arg=s):
            return String(value=s, _raw=x)
        case lib.Eval_Value_view_V_cstor(args=(descriptor, args)):
            return Constructor(
                name=descriptor.cd_name.name,
                index=descriptor.cd_idx,
                args=tuple(value_of_lib(a.v) for a in args),
                _raw=x,
            )
        case lib.Eval_Value_view_V_tuple(arg=elements):
            return Tuple(elements=tuple(value_of_lib(e.v) for e in elements), _raw=x)
        case lib.Eval_Value_view_V_record(args=(descriptor, values)):
            return Record(
                name=descriptor.rd_name.name,
                fields={f.name: value_of_lib(v.v) for f, v in zip(descriptor.rd_fields, values)},
                _raw=x,
            )
        case lib.Eval_Value_view_V_quoted_term(arg=(params, body)):
            return QuotedTerm(
                params=tuple(mir.var_term_of_var(p) for p in params), body=mir.term_of_lib(body), _raw=x
            )
        case lib.Eval_Value_view_V_uid(arg=u):
            return Uid(uid=mir.Uid(u), _raw=x)
        case lib.Eval_Value_view_V_closure(arg=c):
            return Closure(closure=c, _raw=x)
        case lib.Eval_Value_view_V_custom(arg=c):
            return Custom(value=c, _raw=x)
        case lib.Eval_Value_view_V_ordinal(arg=o):
            return Ordinal(value=o, _raw=x)
        case _:
            raise Exception("Unexpected evaluation value")
