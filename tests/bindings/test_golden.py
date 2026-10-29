"""Golden cases: decode the artifacts `gen.ml` built from OCaml values, and check the decoding

Each `golden/<artifact kind>/<name>.pb` is an artifact as the server sends it. It is decoded into
its wrapper class and dumped to plain data, which must:
- equal `golden/<artifact kind>/<name>.json`: dataclasses by their fields, other wrapper classes
  (e.g. tasks and task results) by their public properties
- contain every marker in the artifact (see `shapes.is_marker`), so no value is dropped

Regenerate the cases with `dune exec tests/bindings/gen.exe -- tests/bindings/golden` from the
repository root, then rewrite the expected decodings with `UPDATE_GOLDEN=1 pytest` and review them.
"""

import dataclasses
import inspect
import json
import os
import re
from collections.abc import Callable, Iterable, Mapping
from enum import Enum
from functools import cached_property
from pathlib import Path
from typing import cast

import pytest
from shapes import observe

from imandrax_api import lib
from imandrax_api.bindings import artmsg_pb2, task_pb2
from imandrax_api.demo.errors import ImandraXError
from imandrax_api.demo.interface import (
    Artifact,
    DecompositionTaskResult,
    EvaluationTaskResult,
    ProofObligationTaskResult,
    Task,
    task_of_raw,
)
from imandrax_api.demo.mir import (
    ArrowType,
    ConstructedType,
    Decomposition,
    Model,
    TupleType,
    TypeVariable,
    Uid,
    declaration_of_lib,
    term_of_lib,
    type_of_lib,
)
from imandrax_api.demo.report import Report

GOLDEN_DIR = Path(__file__).parent / "golden"

DECODERS: dict[str, Callable[[Artifact], object]] = {
    "term": lambda a: term_of_lib(a.decode_as(lib.Mir_Term)),
    "ty": lambda a: type_of_lib(a.decode_as(lib.Mir_Type)),
    # `decode_as` needs a class: `lib.Mir_Decl` is a union, and `lib.Mir_Model` an alias
    "mir.decl": lambda a: declaration_of_lib(
        cast(lib.Mir_Decl, lib.read_artifact_data(a.data, a.kind))
    ),
    "mir.model": lambda a: Model.of_lib(
        a.decode_as(lib.Common_Model_t_poly[lib.Mir_Term, lib.Mir_Type])
    ),
    "mir.fun_decomp": lambda a: Decomposition.of_lib(
        a.decode_as(lib.Common_Fun_decomp_t_poly[lib.Mir_Term, lib.Mir_Type])
    ),
    "report": lambda a: Report.of_lib(a.decode_as(lib.Report_Report)),
    "po_res": ProofObligationTaskResult,
    "eval_res": EvaluationTaskResult,
    "decomp_res": DecompositionTaskResult,
    "po_task": lambda a: _task(task_pb2.TASK_CHECK_PO, a),
    "eval_task": lambda a: _task(task_pb2.TASK_EVAL, a),
    "decomp_task": lambda a: _task(task_pb2.TASK_DECOMP, a),
}
"""How to decode an artifact of each kind into its wrapper class"""

CASES = sorted(GOLDEN_DIR.glob("*/*.pb"))


def _task(kind: task_pb2.TaskKind, a: Artifact) -> Task:
    """A task of kind `kind` with no client, whose data is the artifact `a`"""
    t = task_of_raw(task_pb2.Task(id=task_pb2.TaskID(id="golden"), kind=kind))
    t._artifacts[a.kind] = a  # pyright: ignore[reportPrivateUsage]
    return t


def _artifact(path: Path) -> artmsg_pb2.Artifact:
    return artmsg_pb2.Artifact.FromString(path.read_bytes())


def decode(path: Path) -> object:
    return DECODERS[path.parent.name](Artifact.of_raw(_artifact(path)))


def _public_properties(cls: type) -> list[str]:
    return sorted(
        name
        for name, member in inspect.getmembers(cls)
        if not name.startswith("_") and isinstance(member, (property, cached_property))
    )


COMPACT = (Uid, TypeVariable, ArrowType, TupleType, ConstructedType, Artifact)
"""Classes dumped as their `repr` below the top level: types are dumped in full by the `ty`
cases, and dumping every type and uid in full would bury the rest. An artifact's raw data is what
the case decodes."""


def dump(x: object, top: bool = True) -> object:
    """`x` as plain data, for comparison with the expected decoding

    Wrapper classes become dicts tagged with their class name: dataclasses of their public fields,
    other classes of their public properties. A property that raises is dumped as the error."""
    # A builtin uid in full: its `repr` has no kind
    if (
        not top
        and isinstance(x, COMPACT)
        and not (isinstance(x, Uid) and x.builtin_kind is not None)
    ):
        return repr(x)
    if isinstance(x, Mapping):
        # Keys can be wrappers, e.g. a model's types
        items = cast(Mapping[object, object], x).items()
        return [[dump(k, top=False), dump(v, top=False)] for k, v in items]
    if dataclasses.is_dataclass(x) and not isinstance(x, type):
        d: dict[str, object] = {"class": type(x).__qualname__}
        for f in dataclasses.fields(x):
            if not f.name.startswith("_"):
                d[f.name] = dump(getattr(x, f.name), top=False)
        return d
    if type(x).__module__.startswith("imandrax_api.demo.") and not isinstance(x, Enum):
        d = {"class": type(x).__qualname__}
        for name in _public_properties(type(x)):
            try:
                d[name] = dump(getattr(x, name), top=False)
            except ImandraXError as e:
                d[name] = {"raises": f"{type(e).__name__}: {e}"}
        return d
    match x:
        case Enum():
            return f"{type(x).__qualname__}.{x.name}"
        case tuple() | list():
            return [dump(e, top=False) for e in cast(Iterable[object], x)]
        case set() | frozenset():
            # Sorted: the iteration order of a set depends on the hash seed
            return sorted(
                (dump(e, top=False) for e in cast(Iterable[object], x)), key=json.dumps
            )
        case None | bool() | int() | float() | str():
            return x
        case _:
            return repr(x)


def _id(path: Path) -> str:
    return f"{path.parent.name}/{path.stem}"


@pytest.mark.parametrize("path", CASES, ids=_id)
def test_golden_case(path: Path):
    x = decode(path)
    expected_path = path.with_suffix(".json")
    actual = json.dumps(dump(x), indent=2) + "\n"
    if os.environ.get("UPDATE_GOLDEN"):
        expected_path.write_text(actual)
    assert expected_path.exists(), (
        "no expected decoding; write it with `UPDATE_GOLDEN=1 pytest`"
    )
    assert actual == expected_path.read_text()


_SKIPPED = "anchors are skipped, see `mir.py`"

DROPPED: dict[str, str] = {
    "Anchor_Eval.arg": _SKIPPED,
    "Sub_anchor.fname": _SKIPPED,
    "Sub_anchor.anchor": _SKIPPED,
}
"""Fields the wrappers drop on purpose, with the reason"""


@pytest.mark.parametrize("path", CASES, ids=_id)
def test_decoding_keeps_every_marker(path: Path):
    msg = _artifact(path)
    markers = observe(msg.kind, msg.data, {e.key: e.value for e in msg.storage}).markers
    decoding = json.dumps(dump(decode(path)))
    missing = [
        (f, m)
        for f, m in dict.fromkeys(markers)
        if f not in DROPPED and not _found(m, decoding)
    ]
    assert not missing, f"not in the decoding: {missing}"


def _found(marker: object, decoding: str) -> bool:
    """Whether `marker` is in the JSON text `decoding`, e.g. as a value or in a `repr`"""
    if isinstance(marker, str):
        return json.dumps(marker)[1:-1] in decoding
    # A number, not part of a larger one
    return (
        re.search(rf"(?<![\d.]){re.escape(str(marker))}(?![\d])", decoding) is not None
    )


@pytest.mark.parametrize("path", CASES, ids=_id)
def test_wrappers_compare_and_hash_by_content(path: Path):
    x = decode(path)
    if not dataclasses.is_dataclass(x):
        pytest.skip("not a dataclass wrapper, e.g. a task result")
    assert x == decode(path) and hash(x) == hash(decode(path))


def test_every_kind_has_a_decoder():
    kinds = {p.name for p in GOLDEN_DIR.iterdir() if p.is_dir()}
    assert kinds <= DECODERS.keys()
