from inline_snapshot import snapshot

from imandrax_api.v2._utils import FrozenMap
from imandrax_api.v2.interface import Client
from imandrax_api.v2.mir import AppliedSymbol, Decomposition, Model, Term, Variable

SRC_DECOMP_DUP_VAR = """
let pos (x : int) : bool = x > 0
let g (x : int) : int = if x > 8 then 1 else if x < -5 then 2 else 0
let d = g [@@decomp top () |>> enumerate_all ~style:Additive [top () [%id pos]] |>> prune]
"""


def test_model_tells_same_named_variables_apart(c: Client) -> None:
    """Region's model keys arguments by UID, so it's possible to tell them apart even
    if they have the same short name, e.g. in case of `enumerate_all ~style:Additive`"""
    res = c.eval_src(SRC_DECOMP_DUP_VAR)
    assert res.success, res.errors
    (dres,) = res.decomp_results
    assert dres.decomposition is not None, dres.errors

    decomp: Decomposition = dres.decomposition

    assert len(decomp.arguments) == 1, "g should only has x as arguments"
    x: Variable = decomp.arguments[0]
    assert repr({"short_name": x.id.short_name, "type": x.type}) == snapshot(
        "{'short_name': 'x', 'type': <ConstructedType int>}"
    )

    models: list[Model | None] = [r.model for r in decomp.regions]
    fst_model = models[0]
    assert fst_model is not None

    consts: FrozenMap[AppliedSymbol, Term] = fst_model.constants
    assert len(consts) == 2
    (
        (x_, _),
        (x__, _),
    ) = consts.items()
    assert x_.id.short_name == x__.id.short_name == "x", (
        "Regions have the same variable x ..."
    )
    assert x_.id.full_name != x__.id.full_name, "... with different full name"
