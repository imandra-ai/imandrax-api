from fractions import Fraction
from typing import override

from imandrax_api import lib


class Value:
    """A value produced by evaluation; base class of all value kinds."""

    def __str__(self) -> str:
        return "<value>"

    def __repr__(self) -> str:
        return f"{type(self).__name__}({self})"


class True_(Value):
    """The boolean `true`."""

    def __init__(self):
        pass

    @override
    def __str__(self) -> str:
        return "true"


class False_(Value):
    """The boolean `false`."""

    def __init__(self):
        pass

    @override
    def __str__(self) -> str:
        return "false"


class Int(Value):
    """An integer, stored in `value`."""

    def __init__(self, v: lib.Eval_Value_view_V_int[lib.Eval_Value, lib.Eval_Value_erased_closure]):
        self.value: int = v.arg

    @override
    def __str__(self) -> str:
        return str(self.value)


class Real(Value):
    """A real number, stored exactly as a `Fraction` in `value`."""

    def __init__(
        self, v: lib.Eval_Value_view_V_real[lib.Eval_Value, lib.Eval_Value_erased_closure]
    ):
        num, den = v.arg
        self.value: Fraction = Fraction(num, den)

    @override
    def __str__(self) -> str:
        return str(self.value)


class String(Value):
    """A string, stored in `value`."""

    def __init__(
        self, v: lib.Eval_Value_view_V_string[lib.Eval_Value, lib.Eval_Value_erased_closure]
    ):
        self.value: str = v.arg

    @override
    def __str__(self) -> str:
        return f'"{self.value}"'


class Constructor(Value):
    """A data constructor applied to arguments, e.g. `Some 3` or `None`.

    `name` is the constructor's name, `index` its position among the type's constructors, and
    `args` its arguments.
    """

    def __init__(
        self, v: lib.Eval_Value_view_V_cstor[lib.Eval_Value, lib.Eval_Value_erased_closure]
    ):
        descriptor, args = v.args
        self.name: str = descriptor.cd_name.name
        self.index: int = descriptor.cd_idx
        self.args: list[Value] = [of_lib(a.v) for a in args]

    @override
    def __str__(self) -> str:
        if not self.args:
            return self.name
        return f"{self.name} ({', '.join(str(a) for a in self.args)})"


class Tuple(Value):
    """A tuple; `elements` holds its components in order."""

    def __init__(
        self, v: lib.Eval_Value_view_V_tuple[lib.Eval_Value, lib.Eval_Value_erased_closure]
    ):
        self.elements: list[Value] = [of_lib(e.v) for e in v.arg]

    @override
    def __str__(self) -> str:
        return f"({', '.join(str(e) for e in self.elements)})"


class Record(Value):
    """A record; `name` identifies the record type and `fields` maps field names to values."""

    def __init__(
        self, v: lib.Eval_Value_view_V_record[lib.Eval_Value, lib.Eval_Value_erased_closure]
    ):
        descriptor, values = v.args
        self.name: str = descriptor.rd_name.name
        self.fields: dict[str, Value] = {
            f.name: of_lib(x.v) for f, x in zip(descriptor.rd_fields, values)
        }

    @override
    def __str__(self) -> str:
        return "{" + "; ".join(f"{k} = {x}" for k, x in self.fields.items()) + "}"


class QuotedTerm(Value):
    """A quoted term: a MIR function with parameters `params` and body `body`."""

    def __init__(
        self, v: lib.Eval_Value_view_V_quoted_term[lib.Eval_Value, lib.Eval_Value_erased_closure]
    ):
        params, body = v.arg
        self.params: list[lib.Mir_Var] = params
        self.body: lib.Mir_Term = body

    @override
    def __str__(self) -> str:
        return "<quoted term>"


class Uid(Value):
    """A unique identifier, stored in `uid` and printed by name."""

    def __init__(self, v: lib.Eval_Value_view_V_uid[lib.Eval_Value, lib.Eval_Value_erased_closure]):
        self.uid: lib.Uid = v.arg

    @override
    def __str__(self) -> str:
        return self.uid.name


class Closure(Value):
    """A function value; its code is not sent to the client, so it prints as `<fun>`."""

    def __init__(
        self, v: lib.Eval_Value_view_V_closure[lib.Eval_Value, lib.Eval_Value_erased_closure]
    ):
        self.closure: lib.Eval_Value_erased_closure = v.arg

    @override
    def __str__(self) -> str:
        return "<fun>"


class Custom(Value):
    """A custom value.

    The library cannot decode custom values yet (decoding raises an error), so this class is
    currently never produced.
    """

    def __init__(
        self, v: lib.Eval_Value_view_V_custom[lib.Eval_Value, lib.Eval_Value_erased_closure]
    ):
        self.value: lib.Eval__Value_Custom_value = v.arg

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


class Ordinal(Value):
    """An ordinal, stored in `value`."""

    def __init__(
        self, v: lib.Eval_Value_view_V_ordinal[lib.Eval_Value, lib.Eval_Value_erased_closure]
    ):
        self.value: lib.Eval_Ordinal = v.arg

    @override
    def __str__(self) -> str:
        return _ordinal_str(self.value)


def value_of_lib(x: lib.Eval_Value_view[lib.Eval_Value, lib.Eval_Value_erased_closure]) -> Value:
    """Convert an evaluation value from `imandrax_api.lib` into the matching `Value` subclass.

    Nested values (constructor arguments, tuple elements, record fields) are converted
    recursively.
    """
    match x:
        case lib.Eval_Value_view_V_true():
            return True_()
        case lib.Eval_Value_view_V_false():
            return False_()
        case lib.Eval_Value_view_V_int():
            return Int(x)
        case lib.Eval_Value_view_V_real():
            return Real(x)
        case lib.Eval_Value_view_V_string():
            return String(x)
        case lib.Eval_Value_view_V_cstor():
            return Constructor(x)
        case lib.Eval_Value_view_V_tuple():
            return Tuple(x)
        case lib.Eval_Value_view_V_record():
            return Record(x)
        case lib.Eval_Value_view_V_quoted_term():
            return QuotedTerm(x)
        case lib.Eval_Value_view_V_uid():
            return Uid(x)
        case lib.Eval_Value_view_V_closure():
            return Closure(x)
        case lib.Eval_Value_view_V_custom():
            return Custom(x)
        case lib.Eval_Value_view_V_ordinal():
            return Ordinal(x)
        case _:
            raise Exception("Unexpected evaluation value")
