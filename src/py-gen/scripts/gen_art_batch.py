# pyright: basic
# %%
import base64
import json
from pathlib import Path

import yaml
from imandrax_api import Client, url_prod
from imandrax_api.lib import read_artifact_data
from IPython.core.getipython import get_ipython
from rich import print
from typing_extensions import Format

if ip := get_ipython():
    ip.run_line_magic('reload_ext', 'autoreload')
    ip.run_line_magic('autoreload', '2')
import os
from typing import Any

import dotenv
from google.protobuf.json_format import MessageToDict
from google.protobuf.message import Message


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


dotenv.load_dotenv('../.env')


# %%
c = Client(auth_token=os.environ['IMANDRAX_API_KEY'], url=url_prod)

art_dir = Path.cwd().parent / 'examples' / 'art'


# %%
iml_v_template = """\
let v =
  fun w ->
    if w = {v} then true else false\
"""

values: list[tuple[str, str]] = [
    # Primitive
    ('real', iml_v_template.format(v=r'3.14')),
    ('int', iml_v_template.format(v=r'2')),
    ('LChar', iml_v_template.format(v=r'LChar.zero')),
    ('LString', iml_v_template.format(v=r'{l|hi|l}')),
    ('tuple (bool * int)', iml_v_template.format(v=r'(true, 2)')),
    # Composite
    ('empty list', iml_v_template.format(v=r'[]')),
    ('single element int list', iml_v_template.format(v=r'[1]')),
    ('bool list', iml_v_template.format(v=r'[true; false]')),
    ('int option', iml_v_template.format(v=r'Some 2')),
    (
        'record',
        """\
type user = {
    id: int;
    active: bool;
}

let v = {id = 1; active = true}

let v =
  fun w ->
    if w = v then true else false\
""",
    ),
    (
        'variant1',
        """\
type status =
    | Active
    | Waitlist of int

let v = Active

let v =
  fun w ->
    if w = v then true else false\
""",
    ),
    (
        'variant2',
        """\
type status =
    | Active
    | Waitlist of int

let v = Waitlist 1

let v =
  fun w ->
    if w = v then true else false\
""",
    ),
    (
        'variant3',
        """\
type status =
    | Active
    | Waitlist of int * bool

let v = Waitlist (2, true)

let v =
  fun w ->
    if w = v then true else false\
""",
    ),
]

# iml = r"""
# let v = function
#   | {v} -> true
#   | _ -> false
# """


# %%
def gen_art(name: str, iml: str):
    _eval_res = c.eval_src(iml)
    instance_res = c.instance_src(src='v')
    instance_res = proto_to_dict(instance_res)
    art = instance_res['sat']['model']['artifact']
    art['iml'] = LiteralString(iml)
    art['name'] = name
    order = [
        'name',
        'iml',
        'data',
        'api_version',
        'kind',
        'storage',
    ]
    return {k: art[k] for k in order}


art_data = []
for name, iml in values:
    art_data_item = gen_art(name, iml)
    art_data.append(art_data_item)

# %%
with (art_dir / 'art.yaml').open('w') as f:
    f.write(yaml.dump(art_data, sort_keys=False, default_flow_style=False))


# %%
# with (art_dir / f'{name}.yaml').open('w') as f:
#     f.write(yaml.dump(art_data, sort_keys=False, default_flow_style=False))
# print(yaml.dump(art_data, sort_keys=False, default_flow_style=False))

# %%
# print(read_artifact_data(data=base64.b64decode(art['data']), kind=art['kind']))
# decode_artifact(art['data'], art['kind'])
