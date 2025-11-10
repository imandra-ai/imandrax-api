"""This module closely follows the structure from lib/ast.ml with
dataclass decorators added.
"""

from __future__ import annotations

from pydantic import ConfigDict
from pydantic.dataclasses import dataclass

dc = dataclass(config=ConfigDict(arbitrary_types_allowed=True))


@dc
class AST:
    pass


@dc
class mod(AST):
    pass


@dc
class Module(mod):
    body: list[stmt]


@dc
class stmt:
    # lineno: int
    # col_offset: int
    # end_lineno: int | None
    # end_col_offset: int | None
    pass


@dc
class ClassDef(stmt):
    name: str
    bases: list[expr]
    keywords: list[keyword]
    body: list[stmt]
    decorator_list: list[expr]


@dc
class Assign(stmt):
    targets: list[expr]
    value: expr
    type_comment: str | None


@dc
class AugAssign(stmt):
    target: Name | Attribute | Subscript
    op: operator
    value: expr


@dc
class AnnAssign(stmt):
    target: Name | Attribute | Subscript
    annotation: expr
    value: expr | None
    simple: int


@dc
class Expr(stmt):
    # L792
    value: expr


@dc
class Pass(stmt):
    pass


@dc
class expr(AST):
    pass
    # lineno: int
    # col_offset: int
    # end_lineno: int | None
    # end_col_offset: int | None


@dc
class BoolOp(expr):
    op: boolop
    values: list[expr]


@dc
class BinOp(expr):
    left: expr
    op: operator
    right: expr


@dc
class UnaryOp(expr):
    op: unaryop
    operand: expr


@dc
class Dict(expr):
    keys: list[expr | None]
    values: list[expr]


@dc
class Set(expr):
    elts: list[expr]


@dc
class Call(expr):
    # L1024
    func: expr
    args: list[expr]
    keywords: list[keyword]


# original: `_ConstantValue: typing_extensions.TypeAlias = ...`
type _ConstantValue = (
    str | bytes | bool | int | float | complex | None
    # | EllipsisType
)


@dc
class Constant(expr):
    # L1037
    value: _ConstantValue
    kind: str | None


@dc
class Attribute(expr):
    value: expr
    attr: str
    ctx: expr_context


@dc
class Subscript(expr):
    # L1139
    value: expr
    slice: expr
    ctx: expr_context


@dc
class Name(expr):
    # L1162
    id: str
    ctx: expr_context


@dc
class List(expr):
    # L1175
    elts: list[expr]
    ctx: expr_context


@dc
class Tuple(expr):
    # L1185
    elts: list[expr]
    ctx: expr_context
    # dims: list[expr]


@dc
class expr_context(AST):
    pass


@dc
class Load(expr_context):
    # L1239
    pass


@dc
class Store(expr_context):
    pass


@dc
class Del(expr_context):
    pass


@dc
class boolop(AST):
    pass


@dc
class And(boolop):
    pass


@dc
class Or(boolop):
    pass


@dc
class operator(AST):
    pass


@dc
class Add(operator):
    pass


@dc
class Sub(operator):
    pass


@dc
class Mult(operator):
    pass


@dc
class MatMult(operator):
    pass


@dc
class Div(operator):
    pass


@dc
class Mod(operator):
    pass


@dc
class Pow(operator):
    pass


@dc
class LShift(operator):
    pass


@dc
class RShift(operator):
    pass


@dc
class BitOr(operator):
    pass


@dc
class BitXor(operator):
    pass


@dc
class BitAnd(operator):
    pass


@dc
class FloorDiv(operator):
    pass


@dc
class unaryop(AST):
    pass


@dc
class Invert(unaryop):
    pass


@dc
class Not(unaryop):
    pass


@dc
class UAdd(unaryop):
    pass


@dc
class USub(unaryop):
    pass


@dc
class cmpop(AST):
    pass


@dc
class Eq(cmpop):
    pass


@dc
class NotEq(cmpop):
    pass


@dc
class Lt(cmpop):
    pass


@dc
class LtE(cmpop):
    pass


@dc
class Gt(cmpop):
    pass


@dc
class GtE(cmpop):
    pass


@dc
class Is(cmpop):
    pass


@dc
class IsNot(cmpop):
    pass


@dc
class In(cmpop):
    pass


@dc
class NotIn(cmpop):
    pass


@dc
class arg(AST):
    # lineno: int
    # col_offset: int
    # end_lineno: int | None
    # end_col_offset: int | None
    arg: str
    annotation: expr | None
    type_comment: str | None


@dc
class keyword(AST):
    # lineno: int
    # col_offset: int
    # end_lineno: int | None
    # end_col_offset: int | None
    arg: str | None
    value: expr


@dc
class arguments(AST):
    posonlyargs: list[arg]
    args: list[arg]
    vararg: arg | None
    kwonlyargs: list[arg]
    kw_defaults: list[expr | None]
    kwarg: arg | None
    defaults: list[expr]


@dc
class Lambda(expr):
    args: arguments
    body: expr


@dc
class type_param(AST):
    # lineno: int
    # col_offset: int
    # end_lineno: int
    # end_col_offset: int
    pass


@dc
class TypeVar(type_param):
    name: str
    bound: expr | None
    default_value: expr | None


@dc
class ParamSpec(type_param):
    name: str
    default_value: expr | None


@dc
class TypeVarTuple(type_param):
    name: str
    default_value: expr | None


@dc
class FunctionDef(stmt):
    name: str
    args: arguments
    body: list[stmt]
    decorator_list: list[expr]
    returns: expr | None
    type_comment: str | None
    type_params: list[type_param]


@dc
class alias(AST):
    name: str
    asname: str | None
    # lineno: int
    # col_offset: int
    # end_lineno: int | None
    # end_col_offset: int | None


@dc
class Assert(stmt):
    test: expr
    msg: expr | None


@dc
class Import(stmt):
    names: list[alias]


@dc
class ImportFrom(stmt):
    module: str | None
    names: list[alias]
    level: int


@dc
class Compare(expr):
    left: expr
    ops: list[cmpop]
    comparators: list[expr]
