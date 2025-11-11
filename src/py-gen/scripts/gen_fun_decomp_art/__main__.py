# pyright: basic
# %%
import base64
import json
from pathlib import Path

import yaml
from imandrax_api import Client, url_dev, url_prod
from imandrax_api.lib import read_artifact_data
from IPython.core.getipython import get_ipython
from rich import print

if ip := get_ipython():
    ip.run_line_magic('reload_ext', 'autoreload')
    ip.run_line_magic('autoreload', '2')
import os
from typing import Any, Final

import dotenv
from decode_artifact import decode_artifact
from google.protobuf.json_format import MessageToDict
from google.protobuf.message import Message

curr_dir = Path.cwd() if ip else Path(__file__).parent
dotenv.load_dotenv()


ONE_YAML: Final = False


class LiteralString(str):
    pass


def literal_presenter(dumper, data):
    if '\n' in data:
        return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')
    return dumper.represent_scalar('tag:yaml.org,2002:str', data)


yaml.add_representer(LiteralString, literal_presenter)


def proto_to_dict(proto_obj: Message) -> dict[Any, Any]:
    return MessageToDict(
        proto_obj,
        preserving_proto_field_name=True,
        always_print_fields_with_no_presence=True,
    )


# %%
c = Client(auth_token=os.environ['IMANDRAX_API_KEY'], url=url_dev)

out_dir = curr_dir

# %%
with (curr_dir / 'data.yaml').open('r') as f:
    inputs = yaml.safe_load(f)


# %%
decomp_res_by_eg = []
regions_by_eg = []
for i, item in enumerate(inputs):
    iml = item['iml']
    decomp_kwargs = item['decomp_kwargs']
    _eval_res = c.eval_src(iml)
    decomp_res = c.decompose(**decomp_kwargs)
    decomp_res_by_eg.append(proto_to_dict(decomp_res))
    regions = decode_artifact(
        data=decomp_res.artifact.data, kind=decomp_res.artifact.kind
    )
    regions = [r.to_dict() for r in regions]
    regions_by_eg.append(regions)


# %%
out_dir = curr_dir / 'result'
out_dir.mkdir(exist_ok=True)
for item, decomp_res, regions in zip(
    inputs, decomp_res_by_eg, regions_by_eg, strict=True
):
    name = item['name'].replace(' ', '_')
    out = item | {'regions': regions} | {'decomp_res': decomp_res}
    out['iml'] = LiteralString(item['iml'])  # format IML
    with (out_dir / f'{item["name"]}.yaml').open('w') as f:
        f.write(yaml.dump(out, sort_keys=False, default_flow_style=False))
