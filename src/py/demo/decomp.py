# pyright: reportPrivateUsage=false
"""Constructors for the decomposition request of `decompose_full`"""
# Note: we reuse protobuf constructors in `imandrax_api.client.decomp`
# but allow `from_artifact` to take `Artifact` and `DecompositionTaskResult`

from imandrax_api.bindings import artmsg_pb2
from imandrax_api.client import decomp as _decomp
from imandrax_api.client.decomp import (
    Decomp,
    by_name,
    combine,
    compound_merge,
    get,
    let,
    merge,
    prune,
)

from .interface import Artifact, DecompositionTaskResult

__all__ = [
    "Decomp",
    "by_name",
    "combine",
    "compound_merge",
    "from_artifact",
    "get",
    "let",
    "merge",
    "prune",
]


def from_artifact(
    art: artmsg_pb2.Artifact | Artifact | DecompositionTaskResult,
) -> Decomp:
    match art:
        case artmsg_pb2.Artifact():
            raw = art
        case Artifact():
            raw = art._raw
        case DecompositionTaskResult():
            raw = art._artifact._raw
    return _decomp.from_artifact(raw)
