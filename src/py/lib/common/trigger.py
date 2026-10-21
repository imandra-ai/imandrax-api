# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_common.Trigger`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..core import uid as core_uid
from ..common import pattern_head as common_pattern_head
from ..common import fo_pattern as common_fo_pattern

__all__ = [
    "Trigger",
]

# def Imandrax_api_common.Trigger.t_poly
@dataclass(slots=True, frozen=True)
class Trigger[Ty]:
    trigger_head: common_pattern_head.PatternHead[Ty]
    trigger_patterns: list[common_fo_pattern.FoPattern[Ty]]
    trigger_instantiation_rule_name: core_uid.Uid

def Trigger_of_twine[Ty](d: twine.Decoder, d0: twine.DecoderFn[Ty], off: int) -> Trigger[Ty]:
    decode_Ty = d0
    fields = list(d.get_array(off=off))
    trigger_head = common_pattern_head.PatternHead_of_twine(d=d, off=fields[0], d0=(lambda d, off: decode_Ty(d=d, off=off)))
    trigger_patterns = [common_fo_pattern.FoPattern_of_twine(d=d, off=x, d0=(lambda d, off: decode_Ty(d=d, off=off))) for x in d.get_array(off=fields[1])]
    trigger_instantiation_rule_name = core_uid.Uid_of_twine(d=d, off=fields[2])
    return Trigger(trigger_head=trigger_head, trigger_patterns=trigger_patterns, trigger_instantiation_rule_name=trigger_instantiation_rule_name)

