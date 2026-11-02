# pyright: reportPrivateUsage=false
"""Constructors for the decomposition request of `decompose_full`"""
# Note: we reuse protobuf constructors in `imandrax_api.v1.decomp`
# but allow `from_artifact` to take `Artifact` and `DecompositionTaskResult`

from imandrax_api.bindings import artmsg_pb2
from imandrax_api.v1 import decomp as _decomp
from imandrax_api.v1.decomp import (
    Decomp,
    combine,
    compound_merge,
    get,
    let,
    merge,
    prune,
)

from .interface import Artifact, DecompositionTaskResult, LiftBool, _lift_bool_to_pb

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


def by_name(
    name: str,
    assuming: str | None = None,
    basis: list[str] | None = None,
    rule_specs: list[str] | None = None,
    prune: bool | None = None,
    ctx_simp: bool | None = None,
    lift_bool: LiftBool | None = None,
) -> Decomp:
    """Decompose the function `name`

    Args:
        name: The function to decompose
        assuming: The side condition function the decomposition assumes
        basis: Functions not to unfold during decomposition
        rule_specs: Rule specs to use during decomposition
        prune: Whether to prune infeasible regions
        ctx_simp: Whether to simplify regions in their context
        lift_bool: How Boolean subterms are lifted into region constraints
    """
    return _decomp.by_name(
        name,
        assuming=assuming,
        basis=basis,
        rule_specs=rule_specs,
        prune=prune,
        ctx_simp=ctx_simp,
        lift_bool=_lift_bool_to_pb(lift_bool),
    )


def from_artifact(
    art: artmsg_pb2.Artifact | Artifact | DecompositionTaskResult,
) -> Decomp:
    """Resume from a decomposition previously returned as an artifact, e.g.
    `DecompositionResult.artifact` or a `DecompositionTaskResult`"""
    match art:
        case artmsg_pb2.Artifact():
            raw = art
        case Artifact():
            raw = art._raw
        case DecompositionTaskResult():
            raw = art._artifact._raw
    return _decomp.from_artifact(raw)
