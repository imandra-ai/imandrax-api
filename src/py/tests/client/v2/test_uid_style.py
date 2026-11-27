"""The uid name switch, without a server

Printers show uids by full name unless `set_uid_style` or `uid_style` chooses short names; nothing
but printed output depends on the choice.
"""

# ai-disclosure: autonomous

import asyncio
import threading
from collections.abc import Iterator

import pytest

from imandrax_api import lib
from imandrax_api.v2.mir import Constructed, Term, Uid, term_of_lib
from imandrax_api.v2.uid_print_style import get_uid_style, set_uid_style, uid_style

# Raw terms whose uids all have a suffix
# ======================================

HASH = bytes(range(8))
HASH_STR = "AAECAwQFBgc"


def cname_uid(name: str) -> lib.Uid:
    return lib.Uid(
        name=name,
        view=lib.Uid_view_Cname(
            cname=lib.Cname_t_(name=name, chash=HASH, is_key=False)
        ),
    )


def local_uid(name: str, id: int) -> lib.Uid:
    return lib.Uid(
        name=name,
        view=lib.Uid_view_Generative(id=id, gen_kind=lib.Uid_gen_kind_Local()),
    )


T = lib.Mir_Type(view=lib.Ty_view_view_Constr(args=(cname_uid("t"), [])))
INT = lib.Mir_Type(
    view=lib.Ty_view_view_Constr(
        args=(lib.Uid(name="int", view=lib.Uid_view_Persistent()), [])
    )
)


def sym(id: lib.Uid, t: lib.Mir_Type) -> lib.Mir_Applied_symbol:
    return lib.Common_Applied_symbol_t_poly(
        sym=lib.Common_Typed_symbol_t_poly(
            id=id, ty=lib.Common_Type_schema_t_poly(params=[], ty=t)
        ),
        args=[],
        ty=t,
    )


def term(
    view: lib.Mir_Term_view[lib.Mir_Term, lib.Mir_Type], t: lib.Mir_Type
) -> lib.Mir_Term:
    return lib.Mir_Term(view=view, ty=t, sub_anchor=None)


ONE = term(lib.Mir_Term_view_Const(arg=lib.Const_Const_z(arg=1)), INT)

# `A {x = 1}`, of type `t`
CONSTRUCT = term(
    lib.Mir_Term_view_Construct(
        c=sym(cname_uid("A"), T), args=[ONE], labels=[cname_uid("x")]
    ),
    T,
)
# `f.y`, where `f` is a local variable
FIELD = term(
    lib.Mir_Term_view_Field(
        f=sym(cname_uid("y"), INT),
        t=term(
            lib.Mir_Term_view_Var(
                arg=lib.Common_Var_t_poly(id=local_uid("f", 3), ty=T)
            ),
            T,
        ),
    ),
    INT,
)


@pytest.fixture(autouse=True)
def restore_global() -> Iterator[None]:
    yield
    set_uid_style("full")


def printed(t: lib.Mir_Term) -> str:
    return str(term_of_lib(t))


# Tests
# =====


def test_default_is_full() -> None:
    assert get_uid_style() == "full"
    assert printed(CONSTRUCT) == f"A/{HASH_STR} {{x/{HASH_STR} = 1}}"
    assert printed(FIELD) == f"f/3.y/{HASH_STR}"


def test_short_names_drop_every_suffix() -> None:
    with uid_style("short"):
        assert printed(CONSTRUCT) == "A {x = 1}"
        assert printed(FIELD) == "f.y"


def test_uid_follows_switch() -> None:
    u = Uid(cname_uid("g"))
    assert str(u) == f"g/{HASH_STR}"
    with uid_style("short"):
        assert str(u) == "g"
        assert repr(u) == "<Uid g>"


def test_set_uid_style_is_global() -> None:
    set_uid_style("short")
    assert printed(FIELD) == "f.y"
    set_uid_style("full")
    assert printed(FIELD) == f"f/3.y/{HASH_STR}"


def test_scoped_choice_wins_and_is_restored() -> None:
    set_uid_style("short")
    with uid_style("full"):
        assert get_uid_style() == "full"
        with uid_style("short"):
            assert get_uid_style() == "short"
        assert get_uid_style() == "full"
    assert get_uid_style() == "short"


def test_scoped_choice_is_restored_on_error() -> None:
    with pytest.raises(RuntimeError), uid_style("short"):
        raise RuntimeError
    assert get_uid_style() == "full"


def test_invalid_choice_is_rejected() -> None:
    with pytest.raises(ValueError):
        set_uid_style("long")  # pyright: ignore[reportArgumentType]
    with pytest.raises(ValueError), uid_style("long"):  # pyright: ignore[reportArgumentType]
        pass
    assert get_uid_style() == "full"


def test_global_choice_reaches_other_threads() -> None:
    set_uid_style("short")
    seen: list[str] = []
    th = threading.Thread(target=lambda: seen.append(get_uid_style()))
    th.start()
    th.join()
    assert seen == ["short"]


def test_scoped_choice_stays_in_its_thread() -> None:
    entered, checked = threading.Event(), threading.Event()
    seen: list[str] = []

    def scoped() -> None:
        with uid_style("short"):
            entered.set()
            checked.wait()

    th = threading.Thread(target=scoped)
    th.start()
    entered.wait()
    seen.append(get_uid_style())
    checked.set()
    th.join()
    assert seen == ["full"]


def test_scoped_choice_stays_in_its_task() -> None:
    async def main() -> list[str]:
        entered, checked = asyncio.Event(), asyncio.Event()

        async def scoped() -> None:
            with uid_style("short"):
                entered.set()
                await checked.wait()

        task = asyncio.create_task(scoped())
        await entered.wait()
        seen = [get_uid_style()]
        checked.set()
        await task
        return seen

    assert asyncio.run(main()) == ["full"]


def test_native_values_do_not_depend_on_switch() -> None:
    def native(t: Term) -> object:
        return t.to_python()

    t = term_of_lib(CONSTRUCT)
    full = native(t)
    with uid_style("short"):
        short = native(t)
    assert full == short == Constructed("A", ({"x": 1},))
