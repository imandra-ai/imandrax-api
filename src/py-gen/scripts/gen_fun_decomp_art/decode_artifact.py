# pyright: basic
# ruff: noqa: F841
from __future__ import annotations

import base64
from dataclasses import asdict, dataclass
from typing import Any

from imandrax_api.lib import (
    Artifact,
    Common_Applied_symbol_t_poly,
    Common_Fun_decomp_t_poly,
    Common_Model_fi,
    Common_Model_t_poly,
    Common_Model_ty_def,
    Common_Region_meta_Assoc,
    Common_Region_meta_String,
    Common_Region_meta_Term,
    Common_Region_t_poly,
    Common_Var_t_poly,
    Mir_Fun_decomp,
    Mir_Model,
    Mir_Term,
    Mir_Term_view_Const,
    Mir_Term_view_Construct,
    Mir_Type,
    Uid,
    read_artifact_data,
)


@dataclass
class RegionStr:
    model_str: dict[str, str]
    model_eval_str: str | None
    invariant_str: str
    constraints_str: list[str] | None

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


class ArtifactDecodeError(Exception):
    pass


def decode_artifact(
    data: bytes | str,
    kind: str,
) -> list[RegionStr] | dict[str, str] | None:
    if isinstance(data, str):
        data = base64.b64decode(data)
    data: bytes
    art: Artifact = read_artifact_data(data=data, kind=kind)
    match (art, kind):
        # DecomposeRes
        case (
            Common_Fun_decomp_t_poly(
                f_id=_f_id,
                f_args=_f_args,
                regions=regions,
            ) as _fun_decomp,
            'mir.fun_decomp',
        ):
            _fun_decomp: Mir_Fun_decomp
            _f_id: Uid
            _f_args: list[Common_Var_t_poly[Mir_Type]]
            regions: list[Common_Region_t_poly[Mir_Term, Mir_Type]]

            return unwrap_region_str(regions)
        # VerifyRes / InstanceRes
        case (
            Common_Model_t_poly(
                tys=tys,
                consts=consts,
                funs=funs,
                representable=representable,
                completed=completed,
                ty_subst=ty_subst,
            ) as mir_model,
            'mir.model',
        ):
            mir_model: Mir_Model
            tys: list[tuple[Mir_Type, Common_Model_ty_def[Mir_Term, Mir_Type]]]
            consts: list[
                tuple[Common_Applied_symbol_t_poly[Mir_Type], Mir_Term]
            ]
            funs: list[
                tuple[
                    Common_Applied_symbol_t_poly[Mir_Type],
                    Common_Model_fi[Mir_Term, Mir_Type],
                ]
            ]
            representable: bool
            completed: bool
            ty_subst: list[tuple[Uid, Mir_Type]]

            consts_d: dict[str, Any] = unwrap_model_constants(consts)
            return consts_d
        case _:
            raise ArtifactDecodeError(
                f'Unknown artifact type: {type(art)}, with {kind = }'
            )


def unwrap_model_constants(
    consts: list[tuple[Common_Applied_symbol_t_poly[Mir_Type], Mir_Term]],
) -> dict[str, Any]:
    constants: dict[str, Any] = {}

    for applied_symbol, term in consts:
        match applied_symbol, term:
            case (
                Common_Applied_symbol_t_poly(
                    sym=applied_symbol_sym,
                    args=applied_symbol_args,
                    ty=applied_symbol_ty,
                ),
                Mir_Term(
                    view=term_view, ty=term_ty, sub_anchor=term_sub_anchor
                ),
            ):
                var_name = applied_symbol_sym.id.name

                # Extract the value from the term
                match term_view:
                    case Mir_Term_view_Const(arg=term_view_const):
                        constants[var_name] = term_view_const.arg
                    case Mir_Term_view_Construct():
                        raise NotImplementedError(
                            'Term view type of Mir_Term_view_Construct is not supported'
                        )
                    case _:
                        raise ValueError(
                            f'Unexpected term view type: {type(term_view)}'
                        )

    return constants


type region_meta_value = (
    Common_Region_meta_Assoc
    | Common_Region_meta_Term
    | Common_Region_meta_String
)


def unwrap_region_str(
    regions: list[Common_Region_t_poly[Mir_Term, Mir_Type]],
) -> list[RegionStr]:
    """
    A region object looks like:
        {
            "constraints": [...],
            "invariant": ...,
            "meta": [
                ("str", ...)  # What we want
                ("model_eval", ...)
                ("id", "...")
            ]
            "status": ...
        }
    """
    regions_str: list[RegionStr] = []
    for region in regions:
        match region:
            case Common_Region_t_poly(
                constraints=_constraints,
                invariant=_invariant,
                meta=meta,
                status=_status,
            ):
                meta: list[tuple[str, region_meta_value]]
                meta_d: dict[str, region_meta_value] = dict(meta)

                # get `str` dict
                meta_str = meta_d.get('str')
                assert meta_str is not None, "Missing 'str' in meta"
                meta_str: Common_Region_meta_Assoc
                meta_str_d = dict(meta_str.arg)

                #
                constraints: list[str] = [
                    c.arg for c in meta_str_d['constraints'].arg
                ]
                invariant: str = meta_str_d['invariant'].arg
                model: dict[str, str] = {
                    k: v.arg for (k, v) in meta_str_d['model'].arg
                }

                model_eval: str | None
                if 'model_eval' in meta_str_d:
                    model_eval = meta_str_d['model_eval'].arg
                else:
                    model_eval = None

                #
                region_str = RegionStr(
                    invariant_str=invariant,
                    constraints_str=constraints,
                    model_str=model,
                    model_eval_str=model_eval,
                )
                regions_str.append(region_str)
            case _:
                raise ValueError(f'Unknown region type: {type(region)}')
    return regions_str
