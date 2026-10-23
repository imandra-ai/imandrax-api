from __future__ import annotations

from dataclasses import dataclass, field
from fractions import Fraction
from typing import assert_never, override

import mir
from imandrax_api import lib


# Like the classes in `mir`, values are frozen dataclasses converted eagerly by
# `value_of_lib`, keeping the library value they were converted from in the hidden
# field `_raw`.

type _View = lib.Eval_Value_view[lib.Eval_Value, lib.Eval_Value_erased_closure]


@dataclass(slots=True, frozen=True)
class True_:
    """The boolean `true`."""

    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return "true"


@dataclass(slots=True, frozen=True)
class False_:
    """The boolean `false`."""

    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return "false"


@dataclass(slots=True, frozen=True)
class Int:
    """An integer, stored in `value`."""

    value: int
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return str(self.value)


@dataclass(slots=True, frozen=True)
class Real:
    """A real number, stored exactly as a `Fraction` in `value`."""

    value: Fraction
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return str(self.value)


@dataclass(slots=True, frozen=True)
class String:
    """A string, stored in `value`."""

    value: str
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return f'"{self.value}"'


@dataclass(slots=True, frozen=True)
class Constructor:
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


@dataclass(slots=True, frozen=True)
class Tuple:
    """A tuple; `elements` holds its components in order."""

    elements: tuple[Value, ...]
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return f"({', '.join(str(e) for e in self.elements)})"


@dataclass(slots=True, frozen=True)
class Record:
    """A record; `name` identifies the record type and `fields` maps field names to values."""

    name: str
    fields: dict[str, Value]
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return "{" + "; ".join(f"{k} = {x}" for k, x in self.fields.items()) + "}"


@dataclass(slots=True, frozen=True)
class QuotedTerm:
    """A quoted term: a MIR function with parameters `params` and body `body`."""

    params: tuple[mir.Var, ...]
    body: mir.Term
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return "<quoted term>"


@dataclass(slots=True, frozen=True)
class Uid:
    """A unique identifier, stored in `uid` and printed by name."""

    uid: mir.Uid
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return self.uid.short_name


@dataclass(slots=True, frozen=True)
class Closure:
    """A function value; its code is not sent to the client, so it prints as `<fun>`."""

    missing: int
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return "<fun>"


@dataclass(slots=True, frozen=True)
class Custom:
    """A custom value.

    The library cannot decode custom values yet (decoding raises an error), so this class is
    currently never produced.
    """

    value: lib.Eval__Value_Custom_value
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return "<custom>"


@dataclass(slots=True, frozen=True)
class Ordinal:
    """An ordinal, stored in `value`."""

    value: OrdinalExpr
    _raw: _View = field(repr=False, compare=False)

    @override
    def __str__(self) -> str:
        return str(self.value)


Value = (
    True_ | False_ | Int | Real | String | Constructor | Tuple | Record | QuotedTerm | Uid | Closure | Custom | Ordinal
)
"""A value produced by evaluation"""


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
            return Closure(missing=c.missing, _raw=x)
        case lib.Eval_Value_view_V_custom(arg=c):
            return Custom(value=c, _raw=x)
        case lib.Eval_Value_view_V_ordinal(arg=o):
            return Ordinal(value=ordinal_expr_of_lib(o), _raw=x)
        case _:
            assert_never(x)


@dataclass(slots=True, frozen=True)
class IntOrdinal:
    value: int
    _raw: lib.Eval_Ordinal = field(repr=False, compare=False)

    def __str__(self) -> str:
        return f"{self.value}"


@dataclass(slots=True, frozen=True)
class ConsOrdinal:
    """`coefficient·ω^exponent + rest`"""

    exponent: OrdinalExpr
    coefficient: int
    rest: OrdinalExpr
    _raw: lib.Eval_Ordinal = field(repr=False, compare=False)

    def __str__(self) -> str:
        return f"({self.exponent}, {self.coefficient}, {self.rest})"


OrdinalExpr = IntOrdinal | ConsOrdinal
"""Ordinal type."""


def ordinal_expr_of_lib(x: lib.Eval_Ordinal) -> OrdinalExpr:
    """Convert a library ordinal into the matching `OrdinalExpr` variant"""
    match x:
        case lib.Eval_Ordinal_Int(arg=n):
            return IntOrdinal(value=n, _raw=x)
        case lib.Eval_Ordinal_Cons(args=(a, n, b)):
            return ConsOrdinal(exponent=ordinal_expr_of_lib(a), coefficient=n, rest=ordinal_expr_of_lib(b), _raw=x)
