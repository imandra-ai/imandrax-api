# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Types from the OCaml module `Imandrax_api_report.Report`."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
import typing
from dataclasses import dataclass
from .. import twine
from .. import _runtime as _rt
from ..report import event as report_event
from ..report import atomic_event as report_atomic_event

__all__ = [
    "Event",
    "Report",
]

# def Imandrax_api_report.Report.event
type Event = report_event.TLinear[report_atomic_event.Mir]

def Event_of_twine(d: twine.Decoder, off: int) -> Event:
    return report_event.TLinear_of_twine(d=d, off=off, d0=(lambda d, off: report_atomic_event.Mir_of_twine(d=d, off=off)))

# def Imandrax_api_report.Report.t
@dataclass(slots=True, frozen=True)
class Report:
    events: list[Event]

def Report_of_twine(d: twine.Decoder, off: int) -> Report:
    x = [Event_of_twine(d=d, off=x) for x in d.get_array(off=off)] # single unboxed field
    return Report(events=x)

