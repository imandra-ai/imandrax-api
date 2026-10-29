"""The shapes of data an artifact can hold, and the shapes and markers a golden case holds

Shapes come from the generated bindings (`imandrax_api.lib`, which `genbindings` generates from the
OCaml type registry): every class reachable from an artifact kind's type, plus, for each field, the
states worth covering. Pointers into the artifact's storage (`Ca_ptr`) are followed, to the type of
the value they point to.

Shapes:
- `class:C`: the class `C`, e.g. a variant constructor, occurs
- `none:C.f`, `some:C.f`: the optional field `f` is absent / present
- `nonempty:C.f`: the list field `f` has elements
- `marker:C.f`: the field `f` holds a marker value (see `is_marker`)
"""

import dataclasses
import re
import types
import typing
from collections.abc import Callable, Iterator
from typing import Any, TypeAliasType, TypeVar, get_args, get_origin, get_type_hints

from imandrax_api import lib

type Env = dict[Any, tuple[Any, Env]]
"""The type each type parameter in scope is bound to, with the scope that type is in"""

NO_ENV: Env = {}

SCALARS = (int, float, str)


# Markers
# =======

MARKER_RE = re.compile(r"\d{4}")


def is_marker(x: object) -> bool:
    """Whether `x` is a marker: a number of at least 1000, or a string containing one

    Every marker in a case must appear in the case's decoding. Values that are not markers, e.g.
    names like `x` or `int`, would be found anywhere in it, so they are not checked."""
    match x:
        case bool():
            return False
        case int() | float():
            return abs(x) >= 1000
        case str():
            return MARKER_RE.search(x) is not None
        case _:
            return False


# Types
# =====


def root_type(kind: str) -> Any | None:
    """The `lib` type of the data of artifacts of kind `kind`, `None` for a plain string"""
    # The decoder calls `<type>_of_twine`
    decoder: Any = lib.artifact_decoders[kind]
    name: str = decoder.__code__.co_names[0].removesuffix("_of_twine")
    return getattr(lib, name, None)


def _hints(cls: type) -> dict[str, Any]:
    params = {p.__name__: p for p in getattr(cls, "__type_params__", ())}
    return get_type_hints(cls, globalns=dict(vars(lib)), localns=params)


def _is_ptr(tp: Any) -> bool:
    return get_origin(tp) is lib.Ca_store_Ca_ptr


def _expand(tp: Any, env: Env) -> Iterator[tuple[Any, Env]]:
    """The members of the type `tp`, with type parameters and aliases resolved and unions split

    A pointer into the storage, `Ca_ptr[X]`, is kept as is. An unbound type parameter is `Any`."""
    while not _is_ptr(tp):
        if isinstance(tp, TypeVar):
            tp, env = env.get(tp, (Any, {}))
        elif isinstance(tp, TypeAliasType):
            tp = tp.__value__
        elif isinstance(
            origin := get_origin(tp), TypeAliasType
        ):  # a generic alias specialized
            env = {
                p: (a, env)
                for p, a in zip(origin.__type_params__, get_args(tp), strict=True)
            }
            tp = origin.__value__
        else:
            break
    if get_origin(tp) in (typing.Union, types.UnionType):
        for a in get_args(tp):
            yield from _expand(a, env)
    else:
        yield tp, env


def _class_env(tp: Any, env: Env) -> Env:
    cls = get_origin(tp) or tp
    return {
        p: (a, env) for p, a in zip(getattr(cls, "__type_params__", ()), get_args(tp))
    }


def _decoder(tp: Any, env: Env) -> Callable[[Any, int], Any]:
    """The `lib` decoder of the type `tp`"""
    while isinstance(tp, TypeVar):
        tp, env = env[tp]
    origin = get_origin(tp) or tp
    decode = getattr(lib, f"{origin.__name__}_of_twine")
    params = {f"d{i}": _decoder(a, env) for i, a in enumerate(get_args(tp))}
    return lambda d, off: decode(d=d, off=off, **params)


# Inventory
# =========


def inventory() -> dict[str, str]:
    """Every shape an artifact can hold, with an artifact kind it can be in"""
    shapes: dict[str, str] = {}
    visited: set[type] = set()

    def visit(tp: Any, env: Env, kind: str, field: str | None) -> None:
        for t, e in _expand(tp, env):
            if _is_ptr(t):
                visit(lib.Ca_store_Ca_ptr_Raw, {}, kind, field)
                [target] = get_args(t)
                visit(target, e, kind, None)
                continue
            origin = get_origin(t) or t
            if origin in (list, tuple):
                for a in get_args(t):
                    if a is not Ellipsis:
                        visit(a, e, kind, field)
            elif origin in SCALARS and field is not None:
                shapes.setdefault(f"marker:{field}", kind)
            elif (
                isinstance(origin, type)
                and dataclasses.is_dataclass(origin)
                and origin not in visited
            ):
                visited.add(origin)
                shapes.setdefault(f"class:{origin.__name__}", kind)
                cls_env = _class_env(t, e)
                for name, hint in _hints(origin).items():
                    f = f"{origin.__name__}.{name}"
                    members = [m for m, _ in _expand(hint, cls_env)]
                    if type(None) in members and len(members) > 1:
                        shapes.setdefault(f"none:{f}", kind)
                        shapes.setdefault(f"some:{f}", kind)
                    if any(get_origin(m) is list for m in members):
                        shapes.setdefault(f"nonempty:{f}", kind)
                    visit(hint, cls_env, kind, f)

    for kind in lib.artifact_decoders:
        if (root := root_type(kind)) is not None:
            visit(root, {}, kind, None)
    return shapes


# Observation
# ===========


@dataclasses.dataclass
class Observed:
    """The shapes and markers in a golden case"""

    shapes: set[str] = dataclasses.field(default_factory=set[str])
    markers: list[tuple[str | None, object]] = dataclasses.field(
        default_factory=list[tuple[str | None, object]]
    )
    """Every marker, with the field it is in, e.g. `Uid.name`"""


def observe(kind: str, data: bytes, storage: dict[str, bytes]) -> Observed:
    """The shapes and markers in an artifact of kind `kind`"""
    obs = Observed()

    def walk(x: object, tp: Any, env: Env, field: str | None) -> None:
        members: list[tuple[Any, Env]] = list(_expand(tp, env))
        x_type = type(x)
        if dataclasses.is_dataclass(x) and not isinstance(x, type):
            ptr: tuple[Any, Env] | None = next(
                ((t, e) for t, e in members if _is_ptr(t)), None
            )
            if ptr is not None and isinstance(x, lib.Ca_store_Ca_ptr_Raw):
                obs.shapes.add("class:Ca_store_Ca_ptr_Raw")
                # Only the type in `hash:<type>:<hash>`: a hash can contain digits by chance
                if is_marker(ty := x.key.split(":")[1]):
                    obs.markers.append(("Ca_store_Ca_ptr_Raw.key", ty))
                    obs.shapes.add("marker:Ca_store_Ca_ptr_Raw.key")
                if (entry := storage.get(x.key)) is not None:
                    [target] = get_args(ptr[0])
                    d = lib.twine.Decoder(entry)
                    walk(
                        _decoder(target, ptr[1])(d, d.entrypoint()),
                        target,
                        ptr[1],
                        None,
                    )
                return
            cls = type(x)
            match: tuple[Any, Env] = next(
                ((t, e) for t, e in members if (get_origin(t) or t) is cls),
                (cls, NO_ENV),
            )
            cls_env = _class_env(*match)
            obs.shapes.add(f"class:{cls.__name__}")
            hints = _hints(cls)
            for fld in dataclasses.fields(x):
                v: object = getattr(x, fld.name)
                f = f"{cls.__name__}.{fld.name}"
                walk(v, hints[fld.name], cls_env, f)
                obs.shapes.add(f"none:{f}" if v is None else f"some:{f}")
                if isinstance(v, list) and v:
                    obs.shapes.add(f"nonempty:{f}")
        elif isinstance(x, (list, tuple)):
            elems: list[object] = list(x)  # pyright: ignore[reportUnknownArgumentType]
            seq: tuple[Any, Env] = next(
                ((t, e) for t, e in members if get_origin(t) is x_type), (Any, NO_ENV)
            )
            args = get_args(seq[0])
            for i, v in enumerate(elems):
                if (
                    isinstance(x, tuple)
                    and len(args) == len(elems)
                    and Ellipsis not in args
                ):
                    elem_tp = args[i]
                else:
                    elem_tp = args[0] if args else Any
                walk(v, elem_tp, seq[1], field)
        elif is_marker(x):
            obs.markers.append((field, x))
            if field is not None:
                obs.shapes.add(f"marker:{field}")

    root = root_type(kind)
    walk(
        lib.read_artifact_data(data, kind), root if root is not None else str, {}, None
    )
    return obs
