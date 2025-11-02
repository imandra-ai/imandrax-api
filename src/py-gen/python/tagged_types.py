"""
Tagged union type definitions for JSON deserialization.
This module wraps the original ast_types with Pydantic Tag annotations
for parsing OCaml-style tagged unions without modifying the core types.
"""

from typing import Annotated

from pydantic import Tag

from ast_types import (
    Add,
    And,
    AnnAssign,
    Assign,
    Attribute,
    BinOp,
    BitAnd,
    BitOr,
    BitXor,
    Bool,
    BoolOp,
    Bytes,
    Call,
    ClassDef,
    Constant,
    Del,
    Dict,
    Div,
    Float,
    FloorDiv,
    IfExp,
    Int,
    Invert,
    LShift,
    List,
    ListComp,
    Load,
    LShift,
    Mod,
    Mult,
    Name,
    Not,
    Or,
    Pass,
    Pow,
    RShift,
    Set,
    Store,
    String,
    Sub,
    Subscript,
    Tuple,
    UAdd,
    UnaryOp,
    Unit,
    USub,
)

# Tagged unions for deserialization
expr_context_tagged = Annotated[
    Annotated[Load, Tag('Load')],
    Annotated[Store, Tag('Store')],
    Annotated[Del, Tag('Del')],
]

constant_value_tagged = Annotated[
    Annotated[String, Tag('String')],
    Annotated[Bytes, Tag('Bytes')],
    Annotated[Bool, Tag('Bool')],
    Annotated[Int, Tag('Int')],
    Annotated[Float, Tag('Float')],
    Annotated[Unit, Tag('Unit')],
]

operator_tagged = Annotated[
    Annotated[Add, Tag('Add')],
    Annotated[Sub, Tag('Sub')],
    Annotated[Mult, Tag('Mult')],
    Annotated[Div, Tag('Div')],
    Annotated[Mod, Tag('Mod')],
    Annotated[Pow, Tag('Pow')],
    Annotated[LShift, Tag('LShift')],
    Annotated[RShift, Tag('RShift')],
    Annotated[BitOr, Tag('BitOr')],
    Annotated[BitXor, Tag('BitXor')],
    Annotated[BitAnd, Tag('BitAnd')],
    Annotated[FloorDiv, Tag('FloorDiv')],
]

unary_op_tagged = Annotated[
    Annotated[Invert, Tag('Invert')],
    Annotated[Not, Tag('Not')],
    Annotated[UAdd, Tag('UAdd')],
    Annotated[USub, Tag('USub')],
]

bool_op_tagged = Annotated[
    Annotated[And, Tag('And')], Annotated[Or, Tag('Or')]
]

expr_tagged = Annotated[
    Annotated[Constant, Tag('Constant')],
    Annotated[BoolOp, Tag('BoolOp')],
    Annotated[BinOp, Tag('BinOp')],
    Annotated[UnaryOp, Tag('UnaryOp')],
    Annotated[IfExp, Tag('IfExp')],
    Annotated[Dict, Tag('Dict')],
    Annotated[Set, Tag('Set')],
    Annotated[ListComp, Tag('ListComp')],
    Annotated[List, Tag('List')],
    Annotated[Tuple, Tag('Tuple')],
    Annotated[Name, Tag('Name')],
    Annotated[Attribute, Tag('Attribute')],
    Annotated[Subscript, Tag('Subscript')],
    Annotated[Call, Tag('Call')],
]

stmt_tagged = Annotated[
    Annotated[Assign, Tag('Assign')],
    Annotated[AnnAssign, Tag('AnnAssign')],
    Annotated[ClassDef, Tag('ClassDef')],
    Annotated[Pass, Tag('Pass')],
]
