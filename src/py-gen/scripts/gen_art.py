# pyright: basic
# %%
import base64
import json
from pathlib import Path

from imandrax_api import Client, url_prod
from imandrax_api.lib import read_artifact_data
from IPython.core.getipython import get_ipython
from rich import print

if ip := get_ipython():
    ip.run_line_magic('reload_ext', 'autoreload')
    ip.run_line_magic('autoreload', '2')
import os
from typing import Any

import dotenv
from google.protobuf.json_format import MessageToDict
from google.protobuf.message import Message


def proto_to_dict(proto_obj: Message) -> dict[Any, Any]:
    return MessageToDict(
        proto_obj,
        preserving_proto_field_name=True,
        always_print_fields_with_no_presence=True,
    )


dotenv.load_dotenv('../.env')


# %%
c = Client(auth_token=os.environ['IMANDRAX_API_KEY'], url=url_prod)

eg_dir = Path.cwd().parent / 'examples' / 'iml'
art_dir = eg_dir.parent / 'art'

# %%
name = 'movement'
iml_p = eg_dir / f'{name}.iml'
iml = iml_p.read_text()
eval_res = c.eval_src(iml)
instance_res = c.instance_src(src='model_movement')
instance_res = proto_to_dict(instance_res)
art = instance_res['sat']['model']['artifact']
with (art_dir / name / f'{name}.json').open('w') as f:
    json.dump(art, f, indent=2)


# %%
iml_p = eg_dir / 'primitives.iml'
iml = iml_p.read_text()
eval_res = c.eval_src(iml)
instance_res = c.instance_src(src='model_my_int')
instance_res = proto_to_dict(instance_res)
art = instance_res['sat']['model']['artifact']
with (art_dir / 'primitives' / 'int.json').open('w') as f:
    json.dump(art, f, indent=2)


eval_res = c.eval_src(iml)
instance_res = c.instance_src(src='model_my_bool_list')
instance_res = proto_to_dict(instance_res)
art = instance_res['sat']['model']['artifact']
with (art_dir / 'primitives' / 'bool_list.json').open('w') as f:
    json.dump(art, f, indent=2)

# %%
# print(read_artifact_data(data=base64.b64decode(art['data']), kind=art['kind']))
# decode_artifact(art['data'], art['kind'])
