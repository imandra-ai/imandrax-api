# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Helpers shared by the generated modules."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
from typing import Any, Never
from . import twine


def twine_result[T,E](d: twine.Decoder, off: int, d0: twine.DecoderFn[T], d1: twine.DecoderFn[E]) -> T | E:
    match d.get_cstor(off=off):
        case twine.Constructor(idx=0, args=args):
            args = tuple(args)
            return d0(d=d, off=args[0])
        case twine.Constructor(idx=1, args=args):
            args = tuple(args)
            return d1(d=d, off=args[0])
        case _:
            raise twine.Error('expected result')

type WithTag6[T] = T
type WithTag7[T] = T

def decode_with_tag[T](tag: int, d: twine.Decoder, off: int, d0: twine.DecoderFn[T]) -> WithTag7[T]:
    dec_tag = d.get_tag(off=off)
    if dec_tag.tag != tag:
        raise twine.Error(f'Expected tag {tag}, got tag {dec_tag.tag} at off=0x{off:x}')
    return d0(d=d, off=dec_tag.arg)

def decode_q(d: twine.Decoder, off:int) -> tuple[int,int]:
    num, denum = d.get_array(off=off)
    num = d.get_int(off=num)
    denum = d.get_int(off=denum)
    return num, denum

def decode_void(d: twine.Decoder, off: int) -> Never:
    raise twine.Error(f'Cannot decode Void at off=0x{off:x}')

type Custom_value = Any
def decode_custom_value(d: twine.Decoder, off: int) -> Custom_value:
    raise twine.Error(f'Cannot decode Eval.Value.Custom_value at off=0x{off:x}')
