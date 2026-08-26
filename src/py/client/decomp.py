# pyright: strict, reportUnknownMemberType=false, reportUnknownVariableType=false
"""Builders for the recursive `DecomposeReqFull.Decomp` tree.

`decompose_full` takes a small expression language describing what to
decompose: a base decomposition (by name, or read back from an artifact) that
can then be pruned, combined, merged with another, or bound to a local
variable for reuse.

Example:

    from imandrax_api.client import decomp

    d = decomp.let(
        [("base", decomp.by_name("f", prune=True))],
        decomp.merge(decomp.get("base"), decomp.by_name("g")),
    )
    res = client.decompose_full(d)
"""

from __future__ import annotations

from typing import Optional

from ..bindings import artmsg_pb2, simple_api_pb2

Decomp = simple_api_pb2.DecomposeReqFull.Decomp

__all__ = [
    "Decomp",
    "from_artifact",
    "by_name",
    "merge",
    "compound_merge",
    "prune",
    "combine",
    "get",
    "let",
]


def from_artifact(art: artmsg_pb2.Art) -> Decomp:
    """Resume from a decomposition previously returned as an artifact."""
    return Decomp(from_artifact=art)


def by_name(
    name: str,
    assuming: Optional[str] = None,
    basis: Optional[list[str]] = None,
    rule_specs: Optional[list[str]] = None,
    prune: Optional[bool] = None,
    ctx_simp: Optional[bool] = None,
    lift_bool: Optional[simple_api_pb2.LiftBool] = None,
) -> Decomp:
    """Decompose the function called `name`."""
    by_name_msg = simple_api_pb2.DecomposeReqFull.ByName(
        name=name,
        assuming=assuming,
        basis=basis,
        rule_specs=rule_specs,
    )
    # If None, keep it as unset
    if prune is not None:
        by_name_msg.prune = prune
    if ctx_simp is not None:
        by_name_msg.ctx_simp = ctx_simp
    if lift_bool is not None:
        by_name_msg.lift_bool = lift_bool
    return Decomp(by_name=by_name_msg)


def merge(d1: Decomp, d2: Decomp) -> Decomp:
    """Merge two decompositions."""
    return Decomp(merge=simple_api_pb2.DecomposeReqFull.Merge(d1=d1, d2=d2))


def compound_merge(d1: Decomp, d2: Decomp) -> Decomp:
    """Compound-merge two decompositions."""
    return Decomp(
        compound_merge=simple_api_pb2.DecomposeReqFull.CompoundMerge(d1=d1, d2=d2)
    )


def prune(d: Decomp) -> Decomp:
    """Prune the regions of `d`."""
    return Decomp(prune=simple_api_pb2.DecomposeReqFull.Prune(d=d))


def combine(d: Decomp) -> Decomp:
    """Combine the regions of `d`."""
    return Decomp(combine=simple_api_pb2.DecomposeReqFull.Combine(d=d))


def get(name: str) -> Decomp:
    """Read back the decomposition bound to the local variable `name`."""
    return Decomp(get=simple_api_pb2.DecomposeReqFull.LocalVarGet(name=name))


def let(bindings: list[tuple[str, Decomp]], and_then: Decomp) -> Decomp:
    """Bind each `(name, decomp)` pair, then evaluate `and_then`.

    The bindings are evaluated simultaneously in the same environment, so one
    binding cannot refer to another from the same `let`; nest `let` calls
    for that.
    """
    return Decomp(
        set=simple_api_pb2.DecomposeReqFull.LocalVarLet(
            bindings=[
                simple_api_pb2.DecomposeReqFull.LocalVarBinding(name=n, d=d)
                for (n, d) in bindings
            ],
            and_then=and_then,
        )
    )
