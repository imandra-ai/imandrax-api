"""Coverage gate: the golden cases must hold every shape of data an artifact can hold

The inventory of shapes comes from the generated bindings, see `shapes.py`. A shape that is in no
golden case, and not in `UNCOVERED`, fails `test_every_shape_is_covered`, which lists it: add a case
holding it to a `cases_*.ml`.
"""

from pathlib import Path

from shapes import Observed, inventory, observe

from imandrax_api.bindings import artmsg_pb2

GOLDEN_DIR = Path(__file__).parent / "golden"

_ALIAS = "a type alias's target is `Void.t`, which has no values"

UNCOVERED: dict[str, str] = {
    "class:Ty_view_decl_Alias": _ALIAS,
    "none:Ty_view_decl_Alias.reexport_def": _ALIAS,
    "some:Ty_view_decl_Alias.reexport_def": _ALIAS,
    "class:Eval_Value_view_V_custom": "custom values cannot be encoded to twine",
    "marker:In_mem_archive_raw.ty": "the type tag of a report archive is fixed, `report_ser.mir`",
    "marker:Report_Smt_proof.logic": "a set of 6 logic fragments, encoded as an int below 64",
}
"""Shapes no golden case can hold, with the reason"""


def _observe_all() -> set[str]:
    seen: set[str] = set()
    for path in sorted(GOLDEN_DIR.glob("*/*.pb")):
        seen |= observe_file(path).shapes
    return seen


def observe_file(path: Path) -> Observed:
    """The shapes and markers in the golden case `path`"""
    msg = artmsg_pb2.Artifact.FromString(path.read_bytes())
    return observe(msg.kind, msg.data, {e.key: e.value for e in msg.storage})


def test_every_shape_is_covered():
    shapes = inventory()
    missing = sorted(shapes.keys() - _observe_all() - UNCOVERED.keys())
    assert not missing, "in no golden case:\n" + "\n".join(
        f"  {s}  ({shapes[s]})" for s in missing
    )


def test_uncovered_is_up_to_date():
    assert not UNCOVERED.keys() - inventory().keys(), "not in the inventory any more"
    assert not UNCOVERED.keys() & _observe_all(), "in a golden case now"
