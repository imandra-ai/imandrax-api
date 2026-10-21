# automatically generated using genbindings.ml, do not edit
# pyright: reportUnusedVariable=false, reportUnusedImport=false, reportUnusedFunction=false

"""Artifacts returned by ImandraX, and functions to read them."""

from __future__ import annotations  # delaying typing: https://peps.python.org/pep-0563/
from dataclasses import dataclass
from zipfile import ZipFile
import json
from typing import Any, assert_never
from . import twine
from . import _runtime as _rt
from .tasks import po_task as tasks_po_task
from .tasks import po_res as tasks_po_res
from .tasks import eval_task as tasks_eval_task
from .tasks import eval_res as tasks_eval_res
from .tasks import decomp_task as tasks_decomp_task
from .tasks import decomp_res as tasks_decomp_res
from .report import report as report_report
from .mir import type as mir_type
from .mir import term as mir_term
from .mir import model as mir_model
from .mir import fun_decomp as mir_fun_decomp
from .mir import decl as mir_decl
from .core import uid as core_uid
from .common import var as common_var
from .common import region as common_region
from .common import fun_decomp as common_fun_decomp


# union of the types!
type Artifact = mir_term.Term|mir_type.Type|tasks_po_task.Mir|tasks_po_res.Shallow|tasks_eval_task.Mir|tasks_eval_res.EvalRes|mir_model.Model|str|mir_fun_decomp.FunDecomp|tasks_decomp_task.Mir|tasks_decomp_res.Shallow|report_report.Report|mir_decl.Decl

artifact_decoders: dict[str, twine.DecoderFn[Artifact]] = {\
  'term': (lambda d, off: mir_term.Term_of_twine(d=d, off=off)),
  'ty': (lambda d, off: mir_type.Type_of_twine(d=d, off=off)),
  'po_task': (lambda d, off: tasks_po_task.Mir_of_twine(d=d, off=off)),
  'po_res': (lambda d, off: tasks_po_res.Shallow_of_twine(d=d, off=off)),
  'eval_task': (lambda d, off: tasks_eval_task.Mir_of_twine(d=d, off=off)),
  'eval_res': (lambda d, off: tasks_eval_res.EvalRes_of_twine(d=d, off=off)),
  'mir.model': (lambda d, off: mir_model.Model_of_twine(d=d, off=off)),
  'show': (lambda d, off: d.get_str(off=off)),
  'mir.fun_decomp': (lambda d, off: mir_fun_decomp.FunDecomp_of_twine(d=d, off=off)),
  'decomp_task': (lambda d, off: tasks_decomp_task.Mir_of_twine(d=d, off=off)),
  'decomp_res': (lambda d, off: tasks_decomp_res.Shallow_of_twine(d=d, off=off)),
  'report': (lambda d, off: report_report.Report_of_twine(d=d, off=off)),
  'mir.decl': (lambda d, off: mir_decl.Decl_of_twine(d=d, off=off)),
}


def read_artifact_data(data: bytes, kind: str) -> Artifact:
    'Read artifact from `data`, with artifact kind `kind`'
    decoder = artifact_decoders[kind]
    twine_dec = twine.Decoder(data)
    return decoder(twine_dec, twine_dec.entrypoint())

def read_artifact_zip(path: str) -> Artifact:
    'Read artifact from a zip file'
    with ZipFile(path) as f:
        manifest = json.loads(f.read('manifest.json'))
        kind = str(manifest['kind'])
        twine_data = f.read('data.twine')
    return read_artifact_data(data=twine_data, kind=kind)


@dataclass
class RegionStr:
    constraints_str: list[str] | None
    invariant_str: str | None
    model_str: dict[str, str] | None
    model_eval_str: str | None


type region_meta_value = (
    common_region.MetaAssoc[mir_term.Term]
    | common_region.MetaTerm[mir_term.Term]
    | common_region.MetaString[mir_term.Term]
)


def get_region_str_from_decomp_artifact(
    data: bytes,
    kind: str,
) -> list[RegionStr]:
    """Get string representation of regions from `mir.fun_decomp` artifact."""
    art: Artifact = read_artifact_data(data=data, kind=kind)
    match (art, kind):
        case (
            common_fun_decomp.FunDecomp(
                f_id=_f_id,
                f_args=_f_args,
                regions=regions,
            ) as _fun_decomp,
            'mir.fun_decomp',
        ):
            _fun_decomp: mir_fun_decomp.FunDecomp
            _f_id: core_uid.Uid
            _f_args: list[common_var.Var[mir_type.Type]]
            regions: list[common_region.Region[mir_term.Term, mir_type.Type]]

            return [unwrap_region_str(region) for region in regions]
        case _:
            raise Exception(
                f'Incorrect artifact type: {type(art)}, with {kind = }. Expected "mir.fun_decomp"'
            )


def unwrap_region_str(
    region: common_region.Region[mir_term.Term, mir_type.Type],
) -> RegionStr:
    """Get `RegionStr` from `Region.t`."""
    match region:
        case common_region.Region(
            constraints=_constraints,
            invariant=_invariant,
            meta=meta,
            status=_status,
        ):
            # Convert meta list to dict
            meta_d: dict[Any, Any] = dict(meta)

            # get `str` dict
            meta_str_raw = meta_d.get('str')
            assert meta_str_raw is not None, "Never: no 'str' in meta"

            # meta_str should be common_region.MetaAssoc[mir_term.Term]
            if not isinstance(meta_str_raw, common_region.MetaAssoc):
                raise ValueError(
                    f'Expected common_region.MetaAssoc, got {type(meta_str_raw)}'
                )

            meta_str_d: dict[Any, Any] = dict(meta_str_raw.arg)  # type: ignore[arg-type]

            # Extract constraints
            constraints_raw = meta_str_d.get('constraints')
            constraints: list[str] | None
            if constraints_raw is not None:
                constraints = [c.arg for c in constraints_raw.arg]
            else:
                constraints = None

            # Extract invariant
            invariant_raw = meta_str_d.get('invariant')
            invariant: str = invariant_raw.arg if invariant_raw is not None else ''

            # Extract model
            model_raw = meta_str_d.get('model')
            model: dict[str, str] = {}
            if model_raw is not None:
                model = {k: v.arg for (k, v) in model_raw.arg}

            # Extract model_eval (optional)
            model_eval: str | None = None
            if 'model_eval' in meta_str_d:
                model_eval_raw = meta_str_d['model_eval']
                if model_eval_raw is not None:
                    model_eval = model_eval_raw.arg

            return RegionStr(
                invariant_str=invariant,
                constraints_str=constraints,
                model_str=model,
                model_eval_str=model_eval,
            )
        case _:
            assert_never(region)
