# pyright: basic
# %%
import json
from pathlib import Path

from imandrax_api import Client, url_prod
from IPython.core.getipython import get_ipython

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

iml_p = eg_dir / 'movement.iml'
iml = iml_p.read_text()

eval_res = c.eval_src(iml)
instance_res = c.instance_src(src='model_movement')
instance_res = proto_to_dict(instance_res)


# %%
art = instance_res['sat']['model']['artifact']

art_path = art_dir / 'movement.json'
if not art_path.exists():
    art_path.parent.mkdir(parents=True, exist_ok=True)
    art_path.touch()
with art_path.open('w') as f:
    json.dump(art, f, indent=2)
